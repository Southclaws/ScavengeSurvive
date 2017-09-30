/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


static
PlayerText:	KeyActions[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
			KeyActionsText[MAX_PLAYERS][512];


hook OnPlayerConnect(playerid)
{
	KeyActions[playerid]			=CreatePlayerTextDraw(playerid, 618.000000, 120.000000, "fixed it");
	PlayerTextDrawAlignment			(playerid, KeyActions[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, KeyActions[playerid], 255);
	PlayerTextDrawFont				(playerid, KeyActions[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, KeyActions[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, KeyActions[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, KeyActions[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, KeyActions[playerid], 1);
}


/*==============================================================================

	Core

==============================================================================*/


stock ShowPlayerKeyActionUI(playerid)
{
	PlayerTextDrawSetString(playerid, KeyActions[playerid], KeyActionsText[playerid]);
	PlayerTextDrawShow(playerid, KeyActions[playerid]);
}

stock HidePlayerKeyActionUI(playerid)
{
	PlayerTextDrawHide(playerid, KeyActions[playerid]);
}

stock ClearPlayerKeyActionUI(playerid)
{
	KeyActionsText[playerid][0] = EOS;
}

stock AddToolTipText(playerid, key[], use[])
{
	new tmp[128];
	format(tmp, sizeof(tmp), "~y~%s ~w~%s~n~", key, use);
	strcat(KeyActionsText[playerid], tmp);
}


/*==============================================================================

	Internal

==============================================================================*/


// Enter/exit inventory
hook OnPlayerOpenInventory(playerid)
{
	HidePlayerKeyActionUI(playerid);
}

hook OnPlayerCloseInventory(playerid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	HidePlayerKeyActionUI(playerid);
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerAddToInventory(playerid, itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnItemRemovedFromInv(playerid, itemid, slot)
{
	_UpdateKeyActions(playerid);
}

hook OnItemRemovedFromPlayer(playerid, itemid)
{
	_UpdateKeyActions(playerid);
}

// Pickup/drop item
hook OnPlayerPickedUpItem(playerid, itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerGetItem(playerid, itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerGiveItem(playerid, targetid, itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerGivenItem(playerid, targetid, itemid)
{
	_UpdateKeyActions(playerid);
}

// Vehicles
hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerExitVehicle(playerid, vehicleid)
{
	_UpdateKeyActions(playerid);
}

// Areas
hook OnPlayerEnterDynArea(playerid, areaid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerLeaveDynArea(playerid, areaid)
{
	_UpdateKeyActions(playerid);
}

// State change
hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	_UpdateKeyActions(playerid);

	if(!IsPlayerToolTipsOn(playerid))
		return 1;

	if(newstate != PLAYER_STATE_DRIVER)
		return 1;

	new vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicle(vehicleid))
		return 1;

	_ShowRepairTip(playerid, vehicleid);

	return 1;
}

_UpdateKeyActions(playerid)
{
	if(!IsPlayerSpawned(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(IsPlayerViewingInventory(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(IsValidContainer(GetPlayerCurrentContainer(playerid)))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(IsPlayerKnockedOut(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(!IsPlayerHudOn(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		ClearPlayerKeyActionUI(playerid);
		AddToolTipText(playerid, KEYTEXT_ENGINE, "Toggle engine");
		AddToolTipText(playerid, KEYTEXT_LIGHTS, "Toggle lights");
		AddToolTipText(playerid, KEYTEXT_DOORS, "Toggle locks");
		AddToolTipText(playerid, KEYTEXT_RADIO, "Open radio");
		ShowPlayerKeyActionUI(playerid);

		return;
	}

	new
		itemid = GetPlayerItem(playerid),
		invehiclearea = GetPlayerVehicleArea(playerid),
		inplayerarea = -1;

	ClearPlayerKeyActionUI(playerid);

	if(invehiclearea != INVALID_VEHICLE_ID)
	{
		if(IsPlayerAtVehicleTrunk(playerid, invehiclearea))
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Open Trunk");

		if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Repair with tool");
	}

	foreach(new i : Player)
	{
		if(IsPlayerInPlayerArea(playerid, i))
		{
			inplayerarea = i;
			break;
		}
	}

	if(!IsValidItem(itemid))
	{
		if(IsPlayerCuffed(inplayerarea))
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Remove handcuffs");
			ShowPlayerKeyActionUI(playerid);
		}

		AddToolTipText(playerid, KEYTEXT_INVENTORY, "Open inventory");

		if(IsValidItem(GetPlayerBagItem(playerid)))
			AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Remove bag");

		ShowPlayerKeyActionUI(playerid);

		return;
	}

	new ItemType:itemtype = GetItemType(itemid);

	// Single items

	if(itemtype == item_Sign)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Place sign");
	}
	else if(itemtype == item_Armour)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Wear armour");
	}
	else if(itemtype == item_Crowbar)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Deconstruct");
	}
	else if(itemtype == item_Shield)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Place shield");
	}
	else if(itemtype == item_HandCuffs)
	{
		if(inplayerarea != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "HandCuff player");
	}
	else if(itemtype == item_Wheel)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Repair vehicle wheel");
	}
	else if(itemtype == item_GasCan)
	{
		if(invehiclearea != INVALID_VEHICLE_ID)
		{
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Refuel vehicle");
		}
		else
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Fill at pump");
		}
	}
	else if(itemtype == item_Clothes)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Wear clothes");
	}
	else if(itemtype == item_Headlight)
	{
		if(invehiclearea != INVALID_VEHICLE_ID)
		{
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Install Headlight");
		}
	}
	else if(itemtype == item_Pills)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Take Pills");
	}
	else if(itemtype == item_AutoInjec)
	{
		if(inplayerarea == -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Inject self");

		else
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Inject other player");
	}
	else if(itemtype == item_HerpDerp)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Herp-a-derp");
	}
	else if(itemtype == item_Medkit || itemtype == item_Bandage || itemtype == item_DoctorBag)
	{
		if(inplayerarea != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Heal player");
		
		else
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Heal yourself");
	}
	else if(itemtype == item_Wrench || itemtype == item_Screwdriver || itemtype == item_Hammer)
	{
		if(invehiclearea != INVALID_VEHICLE_ID)
		{
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Repair vehicle engine");
		}
	}
	else
	{
		if(IsItemTypeFood(itemtype))
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Eat");
		}
		else if(IsItemTypeBag(itemtype))
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Open satchel");
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Wear");
		}
		else if(GetHatFromItem(itemtype) != -1)
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Wear Hat");
		}
		else if(GetMaskFromItem(itemtype) != -1)
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Wear Hat");
		}
		else if(GetItemTypeExplosiveType(itemtype) != -1)
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Arm Explosive");
		}
		else if(GetItemTypeLiquidContainerType(itemtype) != -1)
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Drink");
		}
	}

	if(GetItemTypeWeapon(itemtype) != -1)
	{
		ClearPlayerKeyActionUI(playerid);

		foreach(new i : Player)
		{
			if(IsPlayerInPlayerArea(playerid, i))
			{
				inplayerarea = i;
				break;
			}
		}

		AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Holster weapon");
		AddToolTipText(playerid, KEYTEXT_RELOAD, "Reload");
		AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "(Hold) Unload");
	}
	else
	{
		AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Put away");
	}

	if(inplayerarea == -1)
	{
		AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Drop item");
	}
	else
	{
		AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Give item");
	}

	AddToolTipText(playerid, KEYTEXT_INVENTORY, "Open inventory");
	ShowPlayerKeyActionUI(playerid);

	return;
}

_ShowRepairTip(playerid, vehicleid)
{
	new Float:health;

	GetVehicleHealth(vehicleid, health);

	if(health <= VEHICLE_HEALTH_CHUNK_2)
	{
		ShowHelpTip(playerid, ls(playerid, "TUTORVEHVER"), 20000);
		return;
	}
	else if(health <= VEHICLE_HEALTH_CHUNK_3)
	{
		ShowHelpTip(playerid, ls(playerid, "TUTORVEHBRO"), 20000);
		return;
	}
	else if(health <= VEHICLE_HEALTH_CHUNK_4)
	{
		ShowHelpTip(playerid, ls(playerid, "TUTORVEHBIT"), 20000);
		return;
	}
	else if(health <= VEHICLE_HEALTH_MAX)
	{
		ShowHelpTip(playerid, ls(playerid, "TUTORVEHSLI"), 20000);
		return;
	}

	return;
}

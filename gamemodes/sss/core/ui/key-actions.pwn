/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

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
PlayerText:	ToolTip[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
			ToolTipText[MAX_PLAYERS][512];


hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/player/tool-tips.pwn");

	ToolTip[playerid]				=CreatePlayerTextDraw(playerid, 618.000000, 120.000000, "fixed it");
	PlayerTextDrawAlignment			(playerid, ToolTip[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, ToolTip[playerid], 255);
	PlayerTextDrawFont				(playerid, ToolTip[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ToolTip[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, ToolTip[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ToolTip[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, ToolTip[playerid], 1);
}

ptask ToolTipUpdate[1000](playerid)
{
	if(!IsPlayerSpawned(playerid))
	{
		HidePlayerToolTip(playerid);
		return;		
	}

	if(IsPlayerViewingInventory(playerid))
	{
		HidePlayerToolTip(playerid);
		return;		
	}

	if(IsValidContainer(GetPlayerCurrentContainer(playerid)))
	{
		HidePlayerToolTip(playerid);
		return;		
	}

	if(IsPlayerKnockedOut(playerid))
	{
		HidePlayerToolTip(playerid);
		return;		
	}

	if(!IsPlayerHudOn(playerid))
	{
		HidePlayerToolTip(playerid);
		return;		
	}

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		ClearToolTipText(playerid);
		AddToolTipText(playerid, KEYTEXT_ENGINE, "Toggle engine");
		AddToolTipText(playerid, KEYTEXT_LIGHTS, "Toggle lights");
		AddToolTipText(playerid, KEYTEXT_DOORS, "Toggle locks");
		AddToolTipText(playerid, KEYTEXT_RADIO, "Open radio");
		ShowPlayerToolTip(playerid);

		return;
	}

	new
		itemid = GetPlayerItem(playerid),
		invehiclearea = GetPlayerVehicleArea(playerid),
		inplayerarea = -1;

	ClearToolTipText(playerid);

	if(invehiclearea != INVALID_VEHICLE_ID)
	{
		if(IsPlayerAtVehicleTrunk(playerid, invehiclearea))
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Open Trunk");
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
			ShowPlayerToolTip(playerid);
		}

		AddToolTipText(playerid, KEYTEXT_INVENTORY, "Open inventory");

		if(IsValidItem(GetPlayerBagItem(playerid)))
			AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Remove bag");

		ShowPlayerToolTip(playerid);

		return;
	}

	new ItemType:itemtype = GetItemType(itemid);

	// Single items

	if(itemtype == item_TntTimebomb)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Arm timebomb");
	}
	else if(itemtype == item_Bottle)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Drink from bottle");
	}
	else if(itemtype == item_Sign)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Place sign");
	}
	else if(itemtype == item_Armour)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Wear armour");
	}
	else if(itemtype == item_Crowbar)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Pry Open");
	}
	else if(itemtype == item_Shield)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Place shield");
	}
	else if(itemtype == item_Flashlight)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Turn on/off");
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
	else if(itemtype == item_CanDrink)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Drink from can");
	}
	else if(itemtype == item_HerpDerp)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Herp-a-derp");
	}

	// Groups of items

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
		// Looped groups of items

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
	}

	if(GetItemTypeWeapon(itemtype) != -1)
	{
		ClearToolTipText(playerid);

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
	ShowPlayerToolTip(playerid);

	return;
}

hook OnPlayerOpenInventory(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerOpenInventory] in /gamemodes/sss/core/ui/key-actions.pwn");

	HidePlayerToolTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerOpenContainer] in /gamemodes/sss/core/ui/key-actions.pwn");

	HidePlayerToolTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock ShowPlayerToolTip(playerid)
{
	PlayerTextDrawSetString(playerid, ToolTip[playerid], ToolTipText[playerid]);
	PlayerTextDrawShow(playerid, ToolTip[playerid]);
}

stock HidePlayerToolTip(playerid)
{
	PlayerTextDrawHide(playerid, ToolTip[playerid]);
}

stock ClearToolTipText(playerid)
{
	ToolTipText[playerid][0] = EOS;
}

stock AddToolTipText(playerid, key[], use[])
{
	new tmp[128];
	format(tmp, sizeof(tmp), "~y~%s ~w~%s~n~", key, use);
	strcat(ToolTipText[playerid], tmp);
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	d:3:GLOBAL_DEBUG("[OnPlayerStateChange] in /gamemodes/sss/core/player/tool-tips.pwn");

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

_ShowRepairTip(playerid, vehicleid)
{
	new Float:health;

	GetVehicleHealth(vehicleid, health);

	if(health <= VEHICLE_HEALTH_CHUNK_2)
	{
		ShowHelpTip(playerid, "This vehicle is very broken! To fix, equip a wrench and hold "KEYTEXT_INTERACT" while at the front of the vehicle.", 20000);
		return;
	}
	else if(health <= VEHICLE_HEALTH_CHUNK_3)
	{
		ShowHelpTip(playerid, "This vehicle is broken! To fix, equip a screwdriver and hold "KEYTEXT_INTERACT" while at the front of the vehicle.", 20000);
		return;
	}
	else if(health <= VEHICLE_HEALTH_CHUNK_4)
	{
		ShowHelpTip(playerid, "This vehicle is a bit broken! To fix, equip a hammer and hold "KEYTEXT_INTERACT" while at the front of the vehicle.", 20000);
		return;
	}
	else if(health <= VEHICLE_HEALTH_MAX)
	{
		ShowHelpTip(playerid, "This vehicle is slightly broken! To fix, equip a wrench and hold "KEYTEXT_INTERACT" while at the front of the vehicle.", 20000);
		return;
	}

	return;
}

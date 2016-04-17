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


#define UI_ELEMENT_TITLE	(0)
#define UI_ELEMENT_TILE		(1)
#define UI_ELEMENT_ITEM		(2)


static
	inv_GearActive[MAX_PLAYERS],
	inv_HealthInfoActive[MAX_PLAYERS],

	PlayerText:GearSlot_Head[3],
	PlayerText:GearSlot_Face[3],
	PlayerText:GearSlot_Hand[3],
	PlayerText:GearSlot_Hols[3],
	PlayerText:GearSlot_Tors[3],
	PlayerText:GearSlot_Back[3],

	inv_TempContainerID[MAX_PLAYERS],
	inv_InventoryOptionID[MAX_PLAYERS];


forward CreatePlayerTile(playerid, &PlayerText:title, &PlayerText:tile, &PlayerText:item, Float:x, Float:y, Float:width, Float:height, colour, overlaycolour);


hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/char/inventory.pwn");

	CreatePlayerTile(playerid, GearSlot_Head[0], GearSlot_Head[1], GearSlot_Head[2], 490.0, 120.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Face[0], GearSlot_Face[1], GearSlot_Face[2], 560.0, 120.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Hand[0], GearSlot_Hand[1], GearSlot_Hand[2], 490.0, 230.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Hols[0], GearSlot_Hols[1], GearSlot_Hols[2], 560.0, 230.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Tors[0], GearSlot_Tors[1], GearSlot_Tors[2], 490.0, 340.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Back[0], GearSlot_Back[1], GearSlot_Back[2], 560.0, 340.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);

	PlayerTextDrawSetString(playerid, GearSlot_Head[0], "Head");
	PlayerTextDrawSetString(playerid, GearSlot_Face[0], "Face");
	PlayerTextDrawSetString(playerid, GearSlot_Hand[0], "Hand");
	PlayerTextDrawSetString(playerid, GearSlot_Hols[0], "Holster");
	PlayerTextDrawSetString(playerid, GearSlot_Tors[0], "Torso");
	PlayerTextDrawSetString(playerid, GearSlot_Back[0], "Back");
}


CreatePlayerTile(playerid, &PlayerText:title, &PlayerText:tile, &PlayerText:item, Float:x, Float:y, Float:width, Float:height, colour, overlaycolour)
{
	title							=CreatePlayerTextDraw(playerid, x + width / 2.0, y - 12.0, "_");
	PlayerTextDrawAlignment			(playerid, title, 2);
	PlayerTextDrawBackgroundColor	(playerid, title, 255);
	PlayerTextDrawFont				(playerid, title, 2);
	PlayerTextDrawLetterSize		(playerid, title, 0.15, 1.0);
	PlayerTextDrawColor				(playerid, title, -1);
	PlayerTextDrawSetOutline		(playerid, title, 1);
	PlayerTextDrawSetProportional	(playerid, title, 1);
	PlayerTextDrawTextSize			(playerid, title, height, width - 4);
	PlayerTextDrawUseBox			(playerid, title, true);

	tile							=CreatePlayerTextDraw(playerid, x, y, "_");
	PlayerTextDrawFont				(playerid, tile, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor	(playerid, tile, colour);
	PlayerTextDrawColor				(playerid, tile, overlaycolour);
	PlayerTextDrawTextSize			(playerid, tile, width, height);
	PlayerTextDrawSetSelectable		(playerid, tile, true);

	item							=CreatePlayerTextDraw(playerid, x + width / 2.0, y + height, "_");
	PlayerTextDrawAlignment			(playerid, item, 2);
	PlayerTextDrawBackgroundColor	(playerid, item, 255);
	PlayerTextDrawFont				(playerid, item, 2);
	PlayerTextDrawLetterSize		(playerid, item, 0.15, 1.0);
	PlayerTextDrawColor				(playerid, item, -1);
	PlayerTextDrawSetOutline		(playerid, item, 1);
	PlayerTextDrawSetProportional	(playerid, item, 1);
	PlayerTextDrawTextSize			(playerid, item, height, width + 10);
}

ShowPlayerGear(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	inv_GearActive[playerid] = true;

	for(new i; i < 3; i++)
	{
		PlayerTextDrawShow(playerid, GearSlot_Head[i]);
		PlayerTextDrawShow(playerid, GearSlot_Face[i]);
		PlayerTextDrawShow(playerid, GearSlot_Hand[i]);
		PlayerTextDrawShow(playerid, GearSlot_Hols[i]);
		PlayerTextDrawShow(playerid, GearSlot_Tors[i]);
		PlayerTextDrawShow(playerid, GearSlot_Back[i]);
	}

	return 1;
}

HidePlayerGear(playerid)
{
	inv_GearActive[playerid] = false;

	for(new i; i < 3; i++)
	{
		PlayerTextDrawHide(playerid, GearSlot_Head[i]);
		PlayerTextDrawHide(playerid, GearSlot_Face[i]);
		PlayerTextDrawHide(playerid, GearSlot_Hand[i]);
		PlayerTextDrawHide(playerid, GearSlot_Hols[i]);
		PlayerTextDrawHide(playerid, GearSlot_Tors[i]);
		PlayerTextDrawHide(playerid, GearSlot_Back[i]);
	}
}

ShowPlayerHealthInfo(playerid)
{
	new
		string[64],
		tmp,
		bodypartwounds[7],
		drugslist[MAX_DRUG_TYPE],
		drugs,
		drugname[MAX_DRUG_NAME],
		Float:bleedrate = GetPlayerBleedRate(playerid),
		Float:hunger = GetPlayerFP(playerid),
		infected1 = GetPlayerInfectionIntensity(playerid, 0),
		infected2 = GetPlayerInfectionIntensity(playerid, 1);

	GetPlayerWoundsPerBodypart(playerid, bodypartwounds);
	drugs = GetPlayerDrugsList(playerid, drugslist);

	inv_HealthInfoActive[playerid] = true;

	HideBodyPreviewUI(playerid);
	ShowBodyPreviewUI(playerid);

	SetBodyPreviewLabel(playerid, 0, tmp++, 35.0, sprintf("Head: %d", bodypartwounds[6]),
		bodypartwounds[6] ? RGBAToHex(max(bodypartwounds[6] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 25.0, sprintf("Torso: %d", bodypartwounds[0]),
		bodypartwounds[0] ? RGBAToHex(max(bodypartwounds[0] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 30.0, sprintf("Arm R: %d", bodypartwounds[3]),
		bodypartwounds[3] ? RGBAToHex(max(bodypartwounds[3] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 20.0, sprintf("Arm L: %d", bodypartwounds[2]),
		bodypartwounds[2] ? RGBAToHex(max(bodypartwounds[2] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 20.0, sprintf("Groin: %d", bodypartwounds[1]),
		bodypartwounds[1] ? RGBAToHex(max(bodypartwounds[1] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 20.0, sprintf("Leg R: %d", bodypartwounds[5]),
		bodypartwounds[5] ? RGBAToHex(max(bodypartwounds[5] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 20.0, sprintf("Leg L: %d", bodypartwounds[4]),
		bodypartwounds[4] ? RGBAToHex(max(bodypartwounds[4] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	tmp = 0;

	if(bleedrate > 0.0)
		SetBodyPreviewLabel(playerid, 1, tmp++, 35.0, "Bleeding", RGBAToHex(truncateforbyte(floatround(bleedrate * 3200.0)), truncateforbyte(255 - floatround(bleedrate * 3200.0)), 0, 255));

	if(hunger < 66.6)
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, "Hungry", RGBAToHex(truncateforbyte(floatround((66.6 - hunger) * 4.8)), truncateforbyte(255 - floatround((66.6 - hunger) * 4.8)), 0, 255));

	if(infected1)
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, "Food Infect", 0xFF0000FF);

	if(infected2)
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, "Wound Infect", 0xFF0000FF);

	for(new i; i < drugs; i++)
	{
		GetDrugName(drugslist[i], drugname);
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, drugname, 0xFFFF00FF);
	}

	format(string, sizeof(string), "%.1f%% Unconsciousness chance", (GetPlayerKnockoutChance(playerid, 5.7) + GetPlayerKnockoutChance(playerid, 22.6)) / 2);
	SetBodyPreviewFooterText(playerid, string);
}

HidePlayerHealthInfo(playerid)
{
	inv_HealthInfoActive[playerid] = false;
	HideBodyPreviewUI(playerid);
}

UpdatePlayerGear(playerid, show = 1)
{
	new
		tmp[5 + ITM_MAX_NAME + ITM_MAX_TEXT],
		itemid;

	itemid = _:GetItemTypeFromHat(GetPlayerHat(playerid));
	if(IsValidItemType(ItemType:itemid))
	{
		GetItemTypeName(ItemType:itemid, tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Head[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Head[UI_ELEMENT_TILE], GetItemTypeModel(ItemType:itemid));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Head[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Head[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Head[UI_ELEMENT_TILE], 19300);
	}

	itemid = _:GetItemTypeFromMask(GetPlayerMask(playerid));
	if(IsValidItemType(ItemType:itemid))
	{
		GetItemTypeName(ItemType:itemid, tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Face[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Face[UI_ELEMENT_TILE], GetItemTypeModel(ItemType:itemid));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Face[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Face[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Face[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerItem(playerid);
	if(IsValidItem(itemid))
	{
		GetItemName(itemid, tmp);
		format(tmp, sizeof(tmp), "(%02d) %s", GetItemTypeSize(GetItemType(itemid)), tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Hand[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hand[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemid)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Hand[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Hand[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hand[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerHolsterItem(playerid);
	if(IsValidItem(itemid))
	{
		GetItemName(itemid, tmp);
		format(tmp, sizeof(tmp), "(%02d) %s", GetItemTypeSize(GetItemType(itemid)), tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Hols[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hols[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemid)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Hols[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Hols[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hols[UI_ELEMENT_TILE], 19300);
	}

	if(GetPlayerAP(playerid) > 0.0)
	{
		PlayerTextDrawSetString(playerid, GearSlot_Tors[UI_ELEMENT_ITEM], sprintf("Armour (%.0f)", GetPlayerAP(playerid)));
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Tors[UI_ELEMENT_TILE], 19515);
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Tors[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Tors[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Tors[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerBagItem(playerid);
	if(IsValidItem(itemid))
	{
		GetItemName(itemid, tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Back[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Back[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemid)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Back[UI_ELEMENT_TILE], 0.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Back[UI_ELEMENT_ITEM], "<Empty>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Back[UI_ELEMENT_TILE], 19300);
	}

	if(show)
		ShowPlayerGear(playerid);

	return;
}

hook OnPlayerOpenInventory(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerOpenInventory] in /gamemodes/sss/core/char/inventory.pwn");

	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);
	ShowPlayerHealthInfo(playerid);
	SelectTextDraw(playerid, 0xFFFF00FF);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseInventory(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerCloseInventory] in /gamemodes/sss/core/char/inventory.pwn");

	HidePlayerGear(playerid);
	HidePlayerHealthInfo(playerid);
	CancelSelectTextDraw(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerOpenContainer] in /gamemodes/sss/core/char/inventory.pwn");

	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);
	ShowPlayerHealthInfo(playerid);
	SelectTextDraw(playerid, 0xFFFF00FF);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerCloseContainer] in /gamemodes/sss/core/char/inventory.pwn");

	HidePlayerGear(playerid);
	HidePlayerHealthInfo(playerid);
	CancelSelectTextDraw(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromCnt(containerid, slotid, playerid)
{
	d:3:GLOBAL_DEBUG("[OnItemRemoveFromCnt] in /gamemodes/sss/core/char/inventory.pwn");

	if(IsPlayerConnected(playerid))
	{
		if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
		{
			UpdatePlayerGear(playerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromInv(playerid, itemid, slot)
{
	d:3:GLOBAL_DEBUG("[OnItemRemoveFromInv] in /gamemodes/sss/core/char/inventory.pwn");

	UpdatePlayerGear(playerid, 0);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddToInventory(playerid, itemid, slot)
{
	d:3:GLOBAL_DEBUG("[OnItemAddToInventory] in /gamemodes/sss/core/char/inventory.pwn");

	if(IsItemTypeCarry(GetItemType(itemid)))
		return 1;

	UpdatePlayerGear(playerid, 0);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromPlayer(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemRemovedFromPlayer] in /gamemodes/sss/core/char/inventory.pwn");

	if(IsItemTypeCarry(GetItemType(itemid)))
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerClickPlayerTD] in /gamemodes/sss/core/char/inventory.pwn");

	if(playertextid == GearSlot_Head[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Head(playerid);

	if(playertextid == GearSlot_Face[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Face(playerid);

	if(playertextid == GearSlot_Hand[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Hand(playerid);

	if(playertextid == GearSlot_Hols[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Hols(playerid);

	if(playertextid == GearSlot_Tors[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Tors(playerid);

	if(playertextid == GearSlot_Back[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Back(playerid);

	return 1;
}


_inv_HandleGearSlotClick_Head(playerid)
{
	new hatid = GetPlayerHat(playerid);
	
	if(!IsValidHat(hatid))
		return 0;

	new
		containerid = GetPlayerCurrentContainer(playerid),
		itemid;

	if(IsValidContainer(containerid))
	{
		if(IsContainerFull(containerid))
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerHat(playerid);

				itemid = CreateItem(GetItemTypeFromHat(hatid), 0.0, 0.0, 0.0);
				GiveWorldItemToPlayer(playerid, itemid);

				ShowActionText(playerid, ls(playerid, "INVREMOVHAT"), 3000);
			}
			else
			{
				ShowActionText(playerid, ls(playerid, "INVHOLDINGI"), 3000);
			}
		}
		else
		{
			itemid = CreateItem(GetItemTypeFromHat(hatid), 0.0, 0.0, 0.0);

			new required = AddItemToContainer(containerid, itemid, playerid);

			if(required > 0)
			{
				ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO"), required), 3000, 150);
				DestroyItem(itemid);
			}
			else if(required == 0)
			{
				RemovePlayerHat(playerid);
				ShowActionText(playerid, ls(playerid, "INVREMOVHAT"), 3000);
			}
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		if(IsPlayerInventoryFull(playerid))
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerHat(playerid);

				itemid = CreateItem(GetItemTypeFromHat(hatid), 0.0, 0.0, 0.0);
				GiveWorldItemToPlayer(playerid, itemid);

				ShowActionText(playerid, ls(playerid, "INVREMOVHAT"), 3000, 150);
			}
			else
			{
				ShowActionText(playerid, ls(playerid, "INVHOLDINGI"), 3000);
			}
		}
		else
		{
			itemid = CreateItem(GetItemTypeFromHat(hatid), 0.0, 0.0, 0.0);

			new required = AddItemToInventory(playerid, itemid);

			if(required > 0)
			{
				ShowActionText(playerid, sprintf(ls(playerid, "INVEXTRASLO"), required), 3000, 150);
				DestroyItem(itemid);
			}
			else if(required == 0)
			{
				RemovePlayerHat(playerid);
				ShowActionText(playerid, ls(playerid, "INVREMOVHAT"), 3000);
			}
		}

		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Face(playerid)
{
	new maskid = GetPlayerMask(playerid);
	
	if(!IsValidMask(maskid))
		return 0;

	new
		containerid = GetPlayerCurrentContainer(playerid),
		itemid;

	if(IsValidContainer(containerid))
	{
		if(IsContainerFull(containerid))
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerMask(playerid);

				itemid = CreateItem(GetItemTypeFromMask(maskid), 0.0, 0.0, 0.0);
				GiveWorldItemToPlayer(playerid, itemid);

				ShowActionText(playerid, ls(playerid, "INVREMOVMAS"), 3000, 150);
			}
			else
			{
				ShowActionText(playerid, ls(playerid, "INVHOLDINGI"), 3000);
			}
		}
		else
		{
			itemid = CreateItem(GetItemTypeFromMask(maskid), 0.0, 0.0, 0.0);

			new required = AddItemToContainer(containerid, itemid, playerid);

			if(required > 0)
			{
				ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO"), required), 3000, 150);
				DestroyItem(itemid);
			}
			else if(required == 0)
			{
				RemovePlayerMask(playerid);
				ShowActionText(playerid, ls(playerid, "INVREMOVMAS"), 3000, 150);
			}
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		if(IsPlayerInventoryFull(playerid))
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerMask(playerid);

				itemid = CreateItem(GetItemTypeFromMask(maskid), 0.0, 0.0, 0.0);
				GiveWorldItemToPlayer(playerid, itemid);

				ShowActionText(playerid, ls(playerid, "INVREMOVMAS"), 3000, 150);
			}
			else
			{
				ShowActionText(playerid, ls(playerid, "INVHOLDINGI"), 3000);
			}
		}
		else
		{
			itemid = CreateItem(GetItemTypeFromMask(maskid), 0.0, 0.0, 0.0);
			
			new required = AddItemToInventory(playerid, itemid);

			if(required > 0)
			{
				ShowActionText(playerid, sprintf(ls(playerid, "INVEXTRASLO"), required), 3000, 150);
				DestroyItem(itemid);
			}
			else if(required == 0)
			{
				RemovePlayerMask(playerid);
				ShowActionText(playerid, ls(playerid, "INVREMOVMAS"), 3000, 150);
			}
		}

		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Hand(playerid)
{
	new itemid = GetPlayerItem(playerid);
	
	if(!IsValidItem(itemid))
		return 0;

	new containerid = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerid))
	{
		if(IsItemTypeBag(GetItemType(itemid)))
		{
			if(containerid == GetBagItemContainerID(itemid))
				return 1;
		}

		new required = AddItemToContainer(containerid, itemid, playerid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO"), required), 3000, 150);
			return 1;
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		new required = AddItemToInventory(playerid, itemid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(ls(playerid, "INVEXTRASLO"), required), 3000, 150);
			return 1;
		}

		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Hols(playerid)
{
	new itemid = GetPlayerHolsterItem(playerid);
	
	if(!IsValidItem(itemid))
		return 0;

	new containerid = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerid))
	{
		if(IsItemTypeBag(GetItemType(itemid)))
		{
			if(containerid == GetBagItemContainerID(itemid))
				return 1;
		}

		new required = AddItemToContainer(containerid, itemid, playerid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO"), required), 3000, 150);
		}
		else if(required == 0)
		{
			RemovePlayerHolsterItem(playerid);
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		new required = AddItemToInventory(playerid, itemid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(ls(playerid, "INVEXTRASLO"), required), 3000, 150);
		}
		else if(required == 0)
		{
			RemovePlayerHolsterItem(playerid);
		}
		
		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Tors(playerid)
{
	if(GetPlayerAP(playerid) == 0.0)
		return 0;

	new containerid = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerid))
	{
		new
			itemid,
			required;

		itemid = CreateItem(item_Armour);
		required = AddItemToContainer(containerid, itemid, playerid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO"), required), 3000, 150);

			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
				SetPlayerAP(playerid, 0.0);
				GiveWorldItemToPlayer(playerid, itemid);
			}
			else
			{
				ShowActionText(playerid, ls(playerid, "INVHOLDINGI"), 3000);
				DestroyItem(itemid);
			}
		}
		else if(required == 0)
		{
			SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
			SetPlayerAP(playerid, 0.0);
			ShowActionText(playerid, ls(playerid, "INVREMOVARM"), 3000);
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		new
			itemid,
			required;

		itemid = CreateItem(item_Armour);
		required = AddItemToInventory(playerid, itemid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(ls(playerid, "INVEXTRASLO"), required), 3000, 150);

			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
				SetPlayerAP(playerid, 0.0);
				GiveWorldItemToPlayer(playerid, itemid);
			}
			else
			{
				ShowActionText(playerid, ls(playerid, "INVHOLDINGI"), 3000);
				DestroyItem(itemid);
			}
		}
		else if(required == 0)
		{
			SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
			SetPlayerAP(playerid, 0.0);
			ShowActionText(playerid, ls(playerid, "INVREMOVARM"), 3000);
		}

		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Back(playerid)
{
	new itemid = GetPlayerBagItem(playerid);
	
	if(!IsValidItem(itemid))
		return 0;

	if(GetPlayerCurrentContainer(playerid) == GetBagItemContainerID(itemid))
	{
		ClosePlayerContainer(playerid);

		if(IsValidContainer(inv_TempContainerID[playerid]))
		{
			DisplayContainerInventory(playerid, inv_TempContainerID[playerid]);
		}
		else
		{
			DisplayPlayerInventory(playerid);
		}

		inv_TempContainerID[playerid] = INVALID_CONTAINER_ID;
	}
	else
	{
		inv_TempContainerID[playerid] = GetPlayerCurrentContainer(playerid);

		DisplayContainerInventory(playerid, GetBagItemContainerID(itemid));
	}

	UpdatePlayerGear(playerid);

	return 1;
}


hook OnPlayerViewCntOpt(playerid, containerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerViewCntOpt] in /gamemodes/sss/core/char/inventory.pwn");

	if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
	{
		if(IsValidContainer(inv_TempContainerID[playerid]))
		{
			new
				name[CNT_MAX_NAME],
				str[9 + CNT_MAX_NAME];

			GetContainerName(inv_TempContainerID[playerid], name);
			format(str, sizeof(str), "Move to %s", name);

			inv_InventoryOptionID[playerid] = AddContainerOption(playerid, str);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectCntOpt(playerid, containerid, option)
{
	d:3:GLOBAL_DEBUG("[OnPlayerSelectCntOpt] in /gamemodes/sss/core/char/inventory.pwn");

	if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
	{
		if(IsValidContainer(inv_TempContainerID[playerid]))
		{
			if(option == inv_InventoryOptionID[playerid])
			{
				new
					slot,
					itemid;

				slot = GetPlayerContainerSlot(playerid);
				itemid = GetContainerSlotItem(containerid, slot);

				if(!IsValidItem(itemid))
				{
					DisplayContainerInventory(playerid, containerid);
					return 0;
				}

				new required = AddItemToContainer(inv_TempContainerID[playerid], itemid, playerid);

				if(required > 0)
				{
					ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO"), required), 3000, 150);
				}
				else
				{
					DisplayContainerInventory(playerid, containerid);
				}
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerClickTextDraw] in /gamemodes/sss/core/char/inventory.pwn");

	if(clickedid == Text:65535)
	{
		if(IsPlayerViewingInventory(playerid))
		{
			// HidePlayerGear(playerid);
			// HidePlayerHealthInfo(playerid);
			// ClosePlayerInventory(playerid);
			DisplayPlayerInventory(playerid);
		}

		if(GetPlayerCurrentContainer(playerid) != INVALID_CONTAINER_ID)
		{
			// HidePlayerGear(playerid);
			// HidePlayerHealthInfo(playerid);
			// ClosePlayerContainer(playerid);
			DisplayContainerInventory(playerid, GetPlayerCurrentContainer(playerid));
		}
	}
}

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	d:3:GLOBAL_DEBUG("[OnPlayerTakeDamage] in /gamemodes/sss/core/char/inventory.pwn");

	if(IsPlayerSpawned(playerid))
	{
		if(inv_HealthInfoActive[playerid])
			ShowPlayerHealthInfo(playerid);
	}
}

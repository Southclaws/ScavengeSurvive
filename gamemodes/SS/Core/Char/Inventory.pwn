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
	CreatePlayerTile(playerid, GearSlot_Head[0], GearSlot_Head[1], GearSlot_Head[2], 490.0, 120.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Face[0], GearSlot_Face[1], GearSlot_Face[2], 560.0, 120.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Hand[0], GearSlot_Hand[1], GearSlot_Hand[2], 490.0, 210.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Hols[0], GearSlot_Hols[1], GearSlot_Hols[2], 560.0, 210.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Tors[0], GearSlot_Tors[1], GearSlot_Tors[2], 490.0, 300.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Back[0], GearSlot_Back[1], GearSlot_Back[2], 560.0, 300.0, 60.0, 60.0, 0xFFFFFF08, 0xFFFFFFFF);

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
}

ShowPlayerGear(playerid)
{
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
		tmp,
		bodypartwounds[7],
		drugslist[MAX_DRUG_TYPE],
		drugs,
		drugname[MAX_DRUG_NAME],
		Float:bleedrate = GetPlayerBleedRate(playerid),
		Float:hunger = GetPlayerFP(playerid),
		infected = IsPlayerInfected(playerid);

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
		SetBodyPreviewLabel(playerid, 1, tmp++, 35.0, "Bleeding", RGBAToHex(floatround(bleedrate * 10.0), 255 - floatround(bleedrate * 10.0), 0, 255));

	if(hunger < 66.6)
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, "Hungry", RGBAToHex(floatround((66.6 - hunger) * 4.8), 255 - floatround((66.6 - hunger) * 4.8), 0, 255));

	if(infected)
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, "Infected", 0xFF0000FF);

	for(new i; i < drugs; i++)
	{
		GetDrugName(drugslist[i], drugname);
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, drugname, 0xFFFF00FF);
	}
}

HidePlayerHealthInfo(playerid)
{
	inv_HealthInfoActive[playerid] = false;
	HideBodyPreviewUI(playerid);
}

UpdatePlayerGear(playerid, show = 1)
{
	new
		tmp[ITM_MAX_NAME],
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

public OnPlayerOpenInventory(playerid)
{
	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);
	ShowPlayerHealthInfo(playerid);
	SelectTextDraw(playerid, 0xFFFF00FF);

	return CallLocalFunction("app_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory app_OnPlayerOpenInventory
forward app_OnPlayerOpenInventory(playerid);

public OnPlayerCloseInventory(playerid)
{
	HidePlayerGear(playerid);
	HidePlayerHealthInfo(playerid);
	CancelSelectTextDraw(playerid);

	return CallLocalFunction("app_OnPlayerCloseInventory", "d", playerid);
}
#if defined _ALS_OnPlayerCloseInventory
	#undef OnPlayerCloseInventory
#else
	#define _ALS_OnPlayerCloseInventory
#endif
#define OnPlayerCloseInventory app_OnPlayerCloseInventory
forward app_OnPlayerCloseInventory(playerid);

public OnPlayerOpenContainer(playerid, containerid)
{
	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);
	ShowPlayerHealthInfo(playerid);

	return CallLocalFunction("app_OnPlayerOpenContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer app_OnPlayerOpenContainer
forward app_OnPlayerOpenContainer(playerid, containerid);

public OnPlayerCloseContainer(playerid, containerid)
{
	HidePlayerGear(playerid);
	HidePlayerHealthInfo(playerid);
	CancelSelectTextDraw(playerid);

	return CallLocalFunction("app_OnPlayerCloseContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer app_OnPlayerCloseContainer
forward app_OnPlayerCloseContainer(playerid, containerid);

public OnItemRemoveFromContainer(containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
		{
			UpdatePlayerGear(playerid);
		}
	}

	return CallLocalFunction("app_OnItemRemoveFromContainer", "ddd", containerid, slotid, playerid);
}
#if defined _ALS_OnItemRemoveFromContainer
	#undef OnItemRemoveFromContainer
#else
	#define _ALS_OnItemRemoveFromContainer
#endif
#define OnItemRemoveFromContainer app_OnItemRemoveFromContainer
forward app_OnItemRemoveFromContainer(containerid, slotid, playerid);

public OnItemRemoveFromInventory(playerid, itemid, slot)
{
	UpdatePlayerGear(playerid, 0);

	return CallLocalFunction("app_OnItemRemoveFromInventory", "ddd", playerid, itemid, slot);
}
#if defined _ALS_OnPlayerRemoveFromInv
	#undef OnItemRemoveFromInventory
#else
	#define _ALS_OnPlayerRemoveFromInv
#endif
#define OnItemRemoveFromInventory app_OnItemRemoveFromInventory
forward app_OnItemRemoveFromInventory(playerid, itemid, slot);

public OnItemAddToInventory(playerid, itemid, slot)
{
	UpdatePlayerGear(playerid, 0);

	return CallLocalFunction("app_OnItemAddToInventory", "ddd", playerid, itemid, slot);
}
#if defined _ALS_OnItemAddToInventory
	#undef OnItemAddToInventory
#else
	#define _ALS_OnItemAddToInventory
#endif
#define OnItemAddToInventory app_OnItemAddToInventory
forward app_OnItemAddToInventory(playerid, itemid, slot);

public OnItemRemovedFromPlayer(playerid, itemid)
{
	if(GetItemTypeSize(GetItemType(itemid)) == ITEM_SIZE_CARRY)
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	
	return CallLocalFunction("app_OnItemRemovedFromPlayer", "dd", playerid, itemid);
}
#if defined _ALS_OnItemRemovedFromPlayer
	#undef OnItemRemovedFromPlayer
#else
	#define _ALS_OnItemRemovedFromPlayer
#endif
#define OnItemRemovedFromPlayer app_OnItemRemovedFromPlayer
forward app_OnItemRemovedFromPlayer(playerid, itemid);

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == GearSlot_Head[UI_ELEMENT_TILE])
	{
		new hatid = GetPlayerHat(playerid);

		if(IsValidHat(hatid))
		{
			new
				containerid = GetPlayerCurrentContainer(playerid),
				itemid;

			if(IsValidContainer(containerid))
			{
				if(IsContainerFull(containerid))
				{
					RemovePlayerHat(playerid);

					itemid = CreateItem(GetItemTypeFromHat(hatid), 0.0, 0.0, 0.0);
					GiveWorldItemToPlayer(playerid, itemid);
					UpdatePlayerGear(playerid);

					ShowActionText(playerid, "Hat removed", 3000, 150);
				}
				else
				{
					RemovePlayerHat(playerid);

					itemid = CreateItem(GetItemTypeFromHat(hatid), 0.0, 0.0, 0.0);
					if(AddItemToContainer(containerid, itemid, playerid) == 1)
					{
						UpdatePlayerGear(playerid);
						DisplayContainerInventory(playerid, containerid);

						ShowActionText(playerid, "Hat removed", 3000, 150);
					}
					else
					{
						DestroyItem(itemid);
					}
				}
			}
			else
			{
				if(IsPlayerInventoryFull(playerid))
				{
					RemovePlayerHat(playerid);

					itemid = CreateItem(GetItemTypeFromHat(hatid), 0.0, 0.0, 0.0);
					GiveWorldItemToPlayer(playerid, itemid);
					UpdatePlayerGear(playerid);

					ShowActionText(playerid, "Hat removed", 3000, 150);
				}
				else
				{
					RemovePlayerHat(playerid);

					itemid = CreateItem(GetItemTypeFromHat(hatid), 0.0, 0.0, 0.0);
					if(AddItemToInventory(playerid, itemid) == 1)
					{
						UpdatePlayerGear(playerid);
						DisplayPlayerInventory(playerid);

						ShowActionText(playerid, "Hat removed", 3000, 150);
					}
					else
					{
						DestroyItem(itemid);
					}
				}
			}
		}
	}

	if(playertextid == GearSlot_Face[UI_ELEMENT_TILE])
	{
		new maskid = GetPlayerMask(playerid);

		if(IsValidMask(maskid))
		{
			new
				containerid = GetPlayerCurrentContainer(playerid),
				itemid;

			if(IsValidContainer(containerid))
			{
				if(IsContainerFull(containerid))
				{
					RemovePlayerMask(playerid);

					itemid = CreateItem(GetItemTypeFromMask(maskid), 0.0, 0.0, 0.0);
					GiveWorldItemToPlayer(playerid, itemid);
					UpdatePlayerGear(playerid);

					ShowActionText(playerid, "Mask removed", 3000, 150);
				}
				else
				{
					RemovePlayerMask(playerid);

					itemid = CreateItem(GetItemTypeFromMask(maskid), 0.0, 0.0, 0.0);
					if(AddItemToContainer(containerid, itemid, playerid) == 1)
					{
						UpdatePlayerGear(playerid);
						DisplayContainerInventory(playerid, containerid);

						ShowActionText(playerid, "Mask removed", 3000, 150);
					}
					else
					{
						DestroyItem(itemid);
					}
				}
			}
			else
			{
				if(IsPlayerInventoryFull(playerid))
				{
					RemovePlayerMask(playerid);

					itemid = CreateItem(GetItemTypeFromMask(maskid), 0.0, 0.0, 0.0);
					GiveWorldItemToPlayer(playerid, itemid);
					UpdatePlayerGear(playerid);

					ShowActionText(playerid, "Mask removed", 3000, 150);
				}
				else
				{
					RemovePlayerMask(playerid);

					itemid = CreateItem(GetItemTypeFromMask(maskid), 0.0, 0.0, 0.0);
					if(AddItemToInventory(playerid, itemid) == 1)
					{
						UpdatePlayerGear(playerid);
						DisplayPlayerInventory(playerid);

						ShowActionText(playerid, "Mask removed", 3000, 150);
					}
					else
					{
						DestroyItem(itemid);
					}
				}
			}
		}
	}

	if(playertextid == GearSlot_Hand[UI_ELEMENT_TILE])
	{
		new itemid = GetPlayerItem(playerid);

		if(IsValidItem(itemid))
		{
			new containerid = GetPlayerCurrentContainer(playerid);

			if(IsValidContainer(containerid))
			{
				if(IsItemTypeBag(GetItemType(itemid)))
				{
					if(containerid == GetBagItemContainerID(itemid))
						return 1;
				}
				if(!WillItemTypeFitInContainer(containerid, GetItemType(itemid)))
				{
					ShowActionText(playerid, "Item won't fit", 3000, 150);
					return 1;
				}

				AddItemToContainer(containerid, itemid, playerid);
				UpdatePlayerGear(playerid);
				DisplayContainerInventory(playerid, containerid);
			}
			else
			{
				if(GetItemTypeSize(GetItemType(itemid)) != ITEM_SIZE_SMALL)
				{
					ShowActionText(playerid, "Item too big", 3000, 140);
				}
				else
				{
					if(AddItemToInventory(playerid, itemid) == 1)
						ShowActionText(playerid, "Item added to inventory", 3000, 150);

					else
						ShowActionText(playerid, "Inventory full", 3000, 100);
				}
				UpdatePlayerGear(playerid);
				DisplayPlayerInventory(playerid);
			}
		}
	}

	if(playertextid == GearSlot_Hols[UI_ELEMENT_TILE])
	{
		new itemid = GetPlayerHolsterItem(playerid);

		if(IsValidItem(itemid))
		{
			new
				containerid = GetPlayerCurrentContainer(playerid),
				ItemType:itemtype = GetItemType(itemid);

			if(IsValidContainer(containerid))
			{
				if(IsContainerFull(containerid))
				{
					new str[CNT_MAX_NAME + 6];
					GetContainerName(containerid, str);
					strcat(str, " full");
					ShowActionText(playerid, str, 3000, 150);
					return 1;
				}

				if(!WillItemTypeFitInContainer(containerid, itemtype))
				{
					ShowActionText(playerid, "Item won't fit", 3000, 150);
					return 1;
				}

				AddItemToContainer(containerid, itemid, playerid);
				RemovePlayerHolsterItem(playerid);

				UpdatePlayerGear(playerid);
				DisplayContainerInventory(playerid, containerid);
			}
			else
			{
				if(GetItemTypeSize(GetItemType(itemid)) != ITEM_SIZE_SMALL)
				{
					ShowActionText(playerid, "That item is too big for your inventory", 3000, 140);
					return 1;
				}

				if(AddItemToInventory(playerid, itemid) == 1)
				{
					RemovePlayerHolsterItem(playerid);
					ShowActionText(playerid, "Item added to inventory", 3000, 150);
				}
				else
				{
					ShowActionText(playerid, "Inventory full", 3000, 100);
				}

				UpdatePlayerGear(playerid);
				DisplayPlayerInventory(playerid);
			}
		}
	}

	if(playertextid == GearSlot_Tors[UI_ELEMENT_TILE])
	{
		if(GetPlayerAP(playerid) > 0.0)
		{
			new
				containerid = GetPlayerCurrentContainer(playerid);

			if(IsValidContainer(containerid))
			{
				if(IsContainerFull(containerid))
				{
					new str[CNT_MAX_NAME + 6];
					GetContainerName(containerid, str);
					strcat(str, " full");
					ShowActionText(playerid, str, 3000, 150);
					return 1;
				}

				if(!WillItemTypeFitInContainer(containerid, item_Armour))
				{
					ShowActionText(playerid, "Item won't fit", 3000, 150);
					return 1;
				}

				new itemid = CreateItem(item_Armour);

				SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
				AddItemToContainer(containerid, itemid, playerid);
				SetPlayerAP(playerid, 0.0);

				UpdatePlayerGear(playerid);
				DisplayContainerInventory(playerid, containerid);
			}
		}
	}

	if(playertextid == GearSlot_Back[UI_ELEMENT_TILE])
	{
		new itemid = GetPlayerBagItem(playerid);

		if(IsValidItem(itemid))
		{
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
		}
	}

	return 1;
}

public OnPlayerViewContainerOpt(playerid, containerid)
{
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

	return CallLocalFunction("inv_OnPlayerViewContainerOpt", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt inv_OnPlayerViewContainerOpt
forward inv_OnPlayerViewContainerOpt(playerid, containerid);

public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
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

				if(IsContainerFull(inv_TempContainerID[playerid]))
				{
					new
						str[CNT_MAX_NAME + 6],
						name[CNT_MAX_NAME];

					GetContainerName(inv_TempContainerID[playerid], name);
					format(str, sizeof(str), "%s full", name);
					ShowActionText(playerid, str, 3000, 100);
					DisplayContainerInventory(playerid, containerid);
					return 0;
				}

				if(!WillItemTypeFitInContainer(inv_TempContainerID[playerid], GetItemType(itemid)))
				{
					ShowActionText(playerid, "Item won't fit", 3000, 140);
					DisplayContainerInventory(playerid, containerid);
					return 0;
				}

				RemoveItemFromContainer(containerid, slot);
				AddItemToContainer(inv_TempContainerID[playerid], itemid, playerid);
				DisplayContainerInventory(playerid, containerid);
			}
		}
	}

	return CallLocalFunction("inv_OnPlayerSelectContainerOpt", "ddd", playerid, containerid, option);
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt inv_OnPlayerSelectContainerOpt
forward inv_OnPlayerSelectContainerOpt(playerid, containerid, option);

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(IsPlayerViewingInventory(playerid))
		{
			CancelSelectTextDraw(playerid);
			ClosePlayerInventory(playerid);
		}
	}
}

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(IsPlayerSpawned(playerid))
	{
		if(inv_HealthInfoActive[playerid])
			ShowPlayerHealthInfo(playerid);
	}
}

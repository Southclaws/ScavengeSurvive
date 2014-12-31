#include <YSI\y_hooks>


/*
	Spawn in

	Items:
		pick up bag and use to wear
		play inventory tutorial
		spawn a weapon
		pick up
		holster, unholster
		spawn ammo
		load ammo
		unload ammo
		spawn ammo of different type and load
		spawn same ammo, pick up
		explain extratext meanings (ammo type, calibre etc)
		shoot and reload

	Vehicles:
		enter vehicle and exit
		explain saving vehicles
		get wrench from trunk
		fix vehicle, explain more tools
		get petrol can from trunk
		fill petrol can
		fill vehicle
		enter vehicle
		explain UI and keys
		exit vehicle
		spawn locksmith kit
		apply to vehicle

	Construction:
		spawn defence
		spawn screwdriver
		explain building defences
		spawn crowbar
		explain removing defences
		spawn timed IED (repeatedly)
		explain destroying defences

	Storage:
		spawn tent pack
		spawn hammer
		explain building tents
		spawn boxes
		add item to box
		explain storage

*/


#define TUTORIAL_WORLD	(90 + playerid)


enum E_TUT_STATE
{
	E_TUT_NONE,
	E_TUT_PICK_BAG,
	E_TUT_WEAR_BAG,
	E_TUT_OPEN_INV,
	E_TUT_OPEN_BAG,
	E_TUT_CLICK_ITEM,
	E_TUT_EQUIP_ITEM,
	E_TUT_DROP,
	E_TUT_RE_PICK,
	E_TUT_PUT_AWAY,
	E_TUT_OPEN_INV1,
	E_TUT_INV_ITEM_OPT,
	E_TUT_MOVE_TO_BAG,
	E_TUT_CLOSE_INV,
	E_TUT_PICK_WEAPON,
	E_TUT_HOLSTER,
	E_TUT_UNHOLSTER,
	E_TUT_PICK_AMMO,
	E_TUT_PICK_MORE_AMMO,
	E_TUT_UNLOAD_AMMO,
	E_TUT_LOAD_NEW_AMMO,
	E_TUT_OPEN_INV2,
	E_TUT_DROP_WEAPON
}


static
PlayerText:	ClassButtonTutorial		[MAX_PLAYERS],
E_TUT_STATE:TutorialState			[MAX_PLAYERS],
Float:		Zone_points[12] = {-1657.0,-2703.0,-1630.0,-2676.0,-1563.0,-2694.0,-1507.0,-2747.0,-1534.0,-2796.0,-1657.0,-2703.0},
			Zone					[MAX_PLAYERS] = {-1, ...},

			Bag						[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
			Wrench					[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
			Weapon					[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
			Ammo					[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


static
			HANDLER = -1;


forward OnPlayerWearBag(playerid, itemid);
forward OnPlayerHolsteredItem(playerid, itemid);
forward OnPlayerUnHolsteredItem(playerid, itemid);


hook OnGameModeInit()
{
	// Static objects
	// CreateDynamicObject(17037, -1547.99207, -2725.40356, 49.66700,   0.00000, 0.00000, 55.68000, TUTORIAL_WORLD);

	HANDLER = debug_register_handler("tutorial", 0);
}

public OnPlayerLoadAccount(playerid)
{
	d:1:HANDLER("[OnPlayerLoadAccount]");

	ClassButtonTutorial[playerid]	=CreatePlayerTextDraw(playerid, 320.000000, 260.000000, "~n~Play Tutorial~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonTutorial[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonTutorial[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonTutorial[playerid], 0.25, 1.000000);
	PlayerTextDrawColor				(playerid, ClassButtonTutorial[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonTutorial[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonTutorial[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonTutorial[playerid], 24.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonTutorial[playerid], true);

	#if defined tut_OnPlayerLoadAccount
		return tut_OnPlayerLoadAccount(playerid);
	#else
		return 0;
	#endif
}

public OnPlayerSpawnExistingChar(playerid)
{
	PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);

	#if defined tut_OnPlayerSpawnExistingChar
		return tut_OnPlayerSpawnExistingChar(playerid);
	#else
		return 1;
	#endif
}

public OnPlayerSpawnNewCharacter(playerid)
{
	PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);

	#if defined tut_OnPlayerSpawnNewCharacter
		return tut_OnPlayerSpawnNewCharacter(playerid);
	#else
		return 1;
	#endif
}

public OnPlayerCreateNewCharacter(playerid)
{
	d:1:HANDLER("[OnPlayerCreateNewCharacter]");

	PlayerTextDrawShow(playerid, ClassButtonTutorial[playerid]);

	#if defined tut_OnPlayerCreateNewCharacter
		return tut_OnPlayerCreateNewCharacter(playerid);
	#else
		return 1;
	#endif
}

public OnButtonPress(playerid, buttonid)
{
	d:1:HANDLER("[OnButtonPress]");

	#if defined tut_OnButtonPress
		return tut_OnButtonPress(playerid, buttonid);
	#else
		return 1;
	#endif
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	d:1:HANDLER("[OnPlayerClickPlayerTextDraw]");
	if(playertextid == ClassButtonTutorial[playerid])
	{
		SetPlayerPos(playerid, -1642.1008, -2705.5376, 48.9919);
		SetPlayerFacingAngle(playerid, 250.0);
		SetPlayerVirtualWorld(playerid, TUTORIAL_WORLD);

		switch(random(14))
		{
			case 0: SetPlayerClothesID(playerid, skin_MainM);
			case 1: SetPlayerClothesID(playerid, skin_Civ1M);
			case 2: SetPlayerClothesID(playerid, skin_Civ2M);
			case 3: SetPlayerClothesID(playerid, skin_Civ3M);
			case 4: SetPlayerClothesID(playerid, skin_Civ4M);
			case 5: SetPlayerClothesID(playerid, skin_MechM);
			case 6: SetPlayerClothesID(playerid, skin_BikeM);
			case 7: SetPlayerClothesID(playerid, skin_MainF);
			case 8: SetPlayerClothesID(playerid, skin_Civ1F);
			case 9: SetPlayerClothesID(playerid, skin_Civ2F);
			case 10: SetPlayerClothesID(playerid, skin_Civ3F);
			case 11: SetPlayerClothesID(playerid, skin_Civ4F);
			case 12: SetPlayerClothesID(playerid, skin_ArmyF);
			case 13: SetPlayerClothesID(playerid, skin_IndiF);
		}

		SetPlayerHP(playerid, 100.0);
		SetPlayerAP(playerid, 0.0);
		SetPlayerFP(playerid, 80.0);
		SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
		SetPlayerGender(playerid, GetClothesGender(GetPlayerClothesID(playerid)));
		SetPlayerBleedRate(playerid, 0.0);

		SetPlayerBitFlag(playerid, Alive, true);
		SetPlayerBitFlag(playerid, Infected, false);

		FreezePlayer(playerid, gLoginFreezeTime * 1000);
		PrepareForSpawn(playerid);

		PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
		PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);
		PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);

		SetPlayerScreenFadeLevel(playerid, 255);

		DestroyDynamicArea(Zone[playerid]);
		Zone[playerid] = CreateDynamicPolygon(Zone_points, _, _, _, TUTORIAL_WORLD);

		DestroyItem(Bag[playerid]);
		Bag[playerid] = CreateItem(item_Satchel, -1639.0580, -2704.1577, 47.8802, _, _, _, _, TUTORIAL_WORLD);
		ShowHelpTip(playerid, "Welcome to the tutorial! Start by picking up that bag over there by holding "KEYTEXT_INTERACT" while standing over it.");
		TutorialState[playerid] = E_TUT_PICK_BAG;
	}
}

hook OnPlayerDeath(playerid)
{
	ExitTutorial(playerid);
}

ExitTutorial(playerid)
{
	if(TutorialState[playerid] == E_TUT_NONE)
		return 0;

	TutorialState[playerid] = E_TUT_NONE;
	HideHelpTip(playerid);
	SetPlayerHealth(playerid, 0.0);

	DestroyDynamicArea(Zone[playerid]);
	DestroyItem(Bag[playerid]);
	DestroyItem(Wrench[playerid]);
	DestroyItem(Weapon[playerid]);
	DestroyItem(Ammo[playerid]);

	Zone[playerid] = -1;
	Bag[playerid] = INVALID_ITEM_ID;
	Wrench[playerid] = INVALID_ITEM_ID;
	Weapon[playerid] = INVALID_ITEM_ID;
	Ammo[playerid] = INVALID_ITEM_ID;

	return 1;
}


public OnPlayerPickUpItem(playerid, itemid)
{
	if(TutorialState[playerid] == E_TUT_PICK_BAG)
	{
		if(itemid == Bag[playerid])
		{
			ShowHelpTip(playerid, "Now wear the bag by pressing "KEYTEXT_PUT_AWAY". You can also remove your bag item by pressing "KEYTEXT_DROP_ITEM" while not holding anything.");
			TutorialState[playerid] = E_TUT_WEAR_BAG;
		}
	}

	if(TutorialState[playerid] == E_TUT_RE_PICK)
	{
		if(GetItemType(itemid) == item_Wrench)
		{
			ShowHelpTip(playerid, "You can't go around carrying everything by hand! Put your current item in your inventory by pressing "KEYTEXT_PUT_AWAY"");
			TutorialState[playerid] = E_TUT_PUT_AWAY;
		}
	}

	if(TutorialState[playerid] == E_TUT_PICK_WEAPON)
	{
		if(itemid == Weapon[playerid])
		{
			ShowHelpTip(playerid, "Some items (such as weapons) can be stored on your character by holstering them. Press "KEYTEXT_PUT_AWAY" to holster your item.");
			TutorialState[playerid] = E_TUT_HOLSTER;
		}
	}

	#if defined tut_OnPlayerPickUpItem
		return tut_OnPlayerPickUpItem(playerid, itemid);
	#else
		return 0;
	#endif
}


public OnPlayerWearBag(playerid, itemid)
{
	if(TutorialState[playerid] == E_TUT_WEAR_BAG)
	{
		ShowHelpTip(playerid, "Using your inventory effectively is key to scavenging items quickly and efficiently! When you have a bag on your back it is available for extra storage.~n~~b~Press "KEYTEXT_INVENTORY" to open your inventory now.");
		DestroyItem(Wrench[playerid]);
		Wrench[playerid] = CreateItem(item_Wrench, .world = TUTORIAL_WORLD);
		AddItemToContainer(GetBagItemContainerID(itemid), Wrench[playerid]);
		TutorialState[playerid] = E_TUT_OPEN_INV;
	}

	#if defined tut_OnPlayerWearBag
		return tut_OnPlayerWearBag(playerid, itemid);
	#else
		return 0;
	#endif
}


public OnPlayerOpenInventory(playerid)
{
	if(TutorialState[playerid] == E_TUT_OPEN_INV)
	{
		ShowHelpTip(playerid, "Great! From here you can access your items and bag if you have one. Click your bag on the right side of the screen now. It is labeled \"Small Bag\".");
		TutorialState[playerid] = E_TUT_OPEN_BAG;
	}
	if(TutorialState[playerid] == E_TUT_OPEN_INV1)
	{
		ShowHelpTip(playerid, "Open the options menu for the item in your inventory.");
		TutorialState[playerid] = E_TUT_INV_ITEM_OPT;
	}
	if(TutorialState[playerid] == E_TUT_OPEN_INV2)
	{
		new
			itemid,
			itemweaponid;

		itemid = GetPlayerItem(playerid);
		itemweaponid = GetItemTypeWeapon(GetItemType(itemid));

		if(itemweaponid == -1)
		{
			ShowHelpTip(playerid, "Once some of your ammunition has been shot, you can reload by pressing "KEYTEXT_RELOAD". To progress, unload your weapon by holding "KEYTEXT_DROP_ITEM".");
			TutorialState[playerid] = E_TUT_UNLOAD_AMMO;
			return 0;
		}

		new
			ammotype,
			calibrename[32],
			ammoname[32],
			string[256];

		ammotype = GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(itemid));
		GetCalibreName(GetItemWeaponCalibre(itemweaponid), calibrename);

		if(ammotype == -1)
			ammoname = "Unloaded";

		else
			GetAmmoTypeName(ammotype, ammoname);

		format(string, sizeof(string), "Next to the weapon is '(%d/%d, %s, %s)'. This represents your current ammunition, weapon calibre and current ammunition type. Drop the weapon to progress.", GetItemWeaponItemMagAmmo(itemid), GetItemWeaponItemReserve(itemid), calibrename, ammoname);
		ShowHelpTip(playerid, string);
		TutorialState[playerid] = E_TUT_DROP_WEAPON;
	}

	#if defined tut_OnPlayerOpenInventory
		return tut_OnPlayerOpenInventory(playerid);
	#else
		return 0;
	#endif
}


public OnPlayerOpenContainer(playerid, containerid)
{
	if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
	{
		if(TutorialState[playerid] == E_TUT_OPEN_BAG)
		{
			ShowHelpTip(playerid, "This is your starting gear. Now double click an item in your bag.");
			TutorialState[playerid] = E_TUT_CLICK_ITEM;
		}
	}

	#if defined tut_OnPlayerOpenContainer
		return tut_OnPlayerOpenContainer(playerid, containerid);
	#else
		return 0;
	#endif
}


public OnPlayerViewContainerOpt(playerid, containerid)
{
	if(TutorialState[playerid] == E_TUT_CLICK_ITEM)
	{
		if(GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))) == item_Wrench)
		{
			ShowHelpTip(playerid, "Now click \"Equip\" to remove the item from your bag and put it in your hands.");
			TutorialState[playerid] = E_TUT_EQUIP_ITEM;
		}
	}

	#if defined tut_OnPlayerViewContainerOpt
		return tut_OnPlayerViewContainerOpt(playerid, containerid);
	#else
		return 0;
	#endif
}


public OnItemRemoveFromContainer(containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
		{
			if(TutorialState[playerid] == E_TUT_EQUIP_ITEM)
			{
				if(GetItemType(GetContainerSlotItem(containerid, slotid)) == item_Wrench)
				{
					ShowHelpTip(playerid, "Wrenches can be used to repair vehicles, but it will only repair so much, you'll need more tools to repair a vehicle fully. Press "KEYTEXT_DROP_ITEM" to drop/give your current item or weapon.");
					TutorialState[playerid] = E_TUT_DROP;
				}
			}
		}
	}

	#if defined tut_OnItemRemoveFromContainer
		return tut_OnItemRemoveFromContainer(containerid, slotid, playerid);
	#else
		return 0;
	#endif
}


public OnPlayerDropItem(playerid, itemid)
{
	if(TutorialState[playerid] == E_TUT_DROP)
	{
		if(GetItemType(itemid) == item_Wrench)
		{
			ShowHelpTip(playerid, "Good, you should grab that again though, you might need it! Press "KEYTEXT_INTERACT" to pick up items.");
			TutorialState[playerid] = E_TUT_RE_PICK;
		}
	}

	if(TutorialState[playerid] == E_TUT_UNLOAD_AMMO)
	{
		defer _WeaponUnloadOffset(playerid);
	}

	#if defined tut_OnPlayerDropItem
		return tut_OnPlayerDropItem(playerid, itemid);
	#else
		return 0;
	#endif
}

timer _WeaponUnloadOffset[500](playerid)
{
	if(TutorialState[playerid] == E_TUT_UNLOAD_AMMO)
	{
		ShowHelpTip(playerid, "Now load up that different ammunition type. Different types have different effects on your target.");
		TutorialState[playerid] = E_TUT_LOAD_NEW_AMMO;
		DestroyItem(Ammo[playerid]);
		Ammo[playerid] = CreateItem(item_AmmoFlechette, -1635.4324, -2708.2253, 47.5936, _, _, _, FLOOR_OFFSET, TUTORIAL_WORLD);
		SetItemExtraData(Ammo[playerid], 12);
	}
}

public OnPlayerDroppedItem(playerid, itemid)
{
	if(TutorialState[playerid] == E_TUT_DROP_WEAPON)
	{
		DestroyItem(Weapon[playerid]);
		DestroyItem(Ammo[playerid]);
		ShowHelpTip(playerid, "The next section of the tutorial is not yet complete. Type /exit to leave the tutorial.");
		return 1;
	}

	#if defined tut_OnPlayerDroppedItem
		return tut_OnPlayerDroppedItem(playerid, itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDroppedItem
	#undef OnPlayerDroppedItem
#else
	#define _ALS_OnPlayerDroppedItem
#endif
 
#define OnPlayerDroppedItem tut_OnPlayerDroppedItem
#if defined tut_OnPlayerDroppedItem
	forward tut_OnPlayerDroppedItem(playerid, itemid);
#endif

public OnItemAddToInventory(playerid, itemid, slot)
{
	if(TutorialState[playerid] == E_TUT_PUT_AWAY)
	{
		ShowHelpTip(playerid, "You put it in your inventory, you can move items between your inventory and your bag, open your inventory again with "KEYTEXT_INVENTORY".");
		TutorialState[playerid] = E_TUT_OPEN_INV1;
	}

	#if defined tut_OnItemAddToInventory
		return tut_OnItemAddToInventory(playerid, itemid, slot);
	#else
		return 0;
	#endif
}


public OnPlayerViewInventoryOpt(playerid)
{
	if(TutorialState[playerid] == E_TUT_INV_ITEM_OPT)
	{
		ShowHelpTip(playerid, "Now press the \"Move to bag\" button to remove that item from your inventory and put it in your bag.");
		TutorialState[playerid] = E_TUT_MOVE_TO_BAG;
	}

	#if defined tut_OnPlayerViewInventoryOpt
		return tut_OnPlayerViewInventoryOpt(playerid);
	#else
		return 0;
	#endif
}


public OnItemAddToContainer(containerid, itemid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
		{
			if(TutorialState[playerid] == E_TUT_MOVE_TO_BAG)
			{
				ShowHelpTip(playerid, "This works both ways, in your bag item options \"Move to inventory\" moves an item from your bag to your inventory. Click Close or press ESC to close your inventory.");
				TutorialState[playerid] = E_TUT_CLOSE_INV;
			}
		}
	}

	#if defined tut_OnItemAddToContainer
		return tut_OnItemAddToContainer(containerid, itemid, playerid);
	#else
		return 0;
	#endif
}


public OnPlayerCloseContainer(playerid, containerid)
{
	if(TutorialState[playerid] == E_TUT_CLOSE_INV)
	{
		ShowHelpTip(playerid, "Now pick up that shotgun by pressing "KEYTEXT_INTERACT" while standing over it.", 30000);
		DestroyItem(Weapon[playerid]);
		Weapon[playerid] = CreateItem(item_PumpShotgun, -1635.4324, -2707.2253, 47.6371, _, _, _, FLOOR_OFFSET, TUTORIAL_WORLD, 0);
		TutorialState[playerid] = E_TUT_PICK_WEAPON;
	}

	#if defined tut_OnPlayerCloseContainer
		return tut_OnPlayerCloseContainer(playerid, containerid);
	#else
		return 0;
	#endif
}


public OnPlayerCloseInventory(playerid)
{
	if(TutorialState[playerid] == E_TUT_CLOSE_INV)
	{
		ShowHelpTip(playerid, "Now pick up that shotgun by pressing "KEYTEXT_INTERACT" while standing over it.", 30000);
		DestroyItem(Weapon[playerid]);
		Weapon[playerid] = CreateItem(item_PumpShotgun, -1635.4324, -2707.2253, 47.5671, _, _, _, FLOOR_OFFSET, TUTORIAL_WORLD, 0);
		TutorialState[playerid] = E_TUT_PICK_WEAPON;
	}

	#if defined tut_OnPlayerCloseInventory
		return tut_OnPlayerCloseInventory(playerid);
	#else
		return 0;
	#endif
}

public OnPlayerHolsteredItem(playerid, itemid)
{
	if(TutorialState[playerid] == E_TUT_HOLSTER)
	{
		ShowHelpTip(playerid, "You can hit the same key to unholster your item if your hands are empty. If you are holding another item that can be holstered, your items will be swapped.");
		TutorialState[playerid] = E_TUT_UNHOLSTER;
	}

	#if defined tut_OnPlayerHolsteredItem
		return tut_OnPlayerHolsteredItem(playerid, itemid);
	#else
		return 1;
	#endif
}

public OnPlayerUnHolsteredItem(playerid, itemid)
{
	if(TutorialState[playerid] == E_TUT_UNHOLSTER)
	{
		ShowHelpTip(playerid, "What good is a gun without ammunition? Load your weapon by standing at the ammunition item and pressing "KEYTEXT_INTERACT".");
		DestroyItem(Ammo[playerid]);
		Ammo[playerid] = CreateItem(item_AmmoBuck, -1635.4324, -2707.2253, 47.5936, _, _, _, FLOOR_OFFSET, TUTORIAL_WORLD);
		SetItemExtraData(Ammo[playerid], 12);
		TutorialState[playerid] = E_TUT_PICK_AMMO;
	}

	#if defined tut_OnPlayerUnHolsteredItem
		return tut_OnPlayerUnHolsteredItem(playerid, itemid);
	#else
		return 1;
	#endif
}

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(itemid == Weapon[playerid] && withitemid == Ammo[playerid])
	{
		if(TutorialState[playerid] == E_TUT_PICK_AMMO)
		{
			ShowHelpTip(playerid, "You've loaded the ammunition into your weapon. You can store some extra reserve ammo too, try picking it up again.");
			TutorialState[playerid] = E_TUT_PICK_MORE_AMMO;
		}
		else if(TutorialState[playerid] == E_TUT_PICK_MORE_AMMO)
		{
			ShowHelpTip(playerid, "Once some of your ammunition has been shot, you can reload by pressing "KEYTEXT_RELOAD". To progress, unload your weapon by holding "KEYTEXT_DROP_ITEM".");
			TutorialState[playerid] = E_TUT_UNLOAD_AMMO;
		}
		else if(TutorialState[playerid] == E_TUT_LOAD_NEW_AMMO)
		{
			ShowHelpTip(playerid, "This ammunition type makes your target bleed faster but has less of a chance to knock them down. Open your inventory with the weapon in hand and look on the right side at the weapon information.");
			TutorialState[playerid] = E_TUT_OPEN_INV2;
		}
	}

	#if defined tut_OnPlayerUseItemWithItem
		return tut_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
 
#define OnPlayerUseItemWithItem tut_OnPlayerUseItemWithItem
#if defined tut_OnPlayerUseItemWithItem
	forward tut_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif

CMD:exit(playerid, params[])
{
	ExitTutorial(playerid);

	return 1;
}


public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	if(IsPlayerInTutorial(playerid))
	{
		if(areaid == Zone[playerid])
		{
			Msg(playerid, YELLOW, "If you want to leave the tutorial area, type /exit and create a character.");
			defer _tut_AreaCheck(playerid);
		}
	}

	#if defined tut_OnPlayerLeaveDynamicArea
		return tut_OnPlayerLeaveDynamicArea(playerid, areaid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif
#define OnPlayerLeaveDynamicArea tut_OnPlayerLeaveDynamicArea
#if defined tut_OnPlayerLeaveDynamicArea
	forward tut_OnPlayerLeaveDynamicArea(playerid, areaid);
#endif

timer _tut_AreaCheck[100](playerid)
{
	if(GetPlayerVirtualWorld(playerid) != TUTORIAL_WORLD)
		return;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:angle;

	GetPlayerPos(playerid, x, y, z);
	angle = GetAngleToPoint(x, y, -1583.0, -2733.0);

	SetPlayerVelocity(playerid, 0.5 * floatsin(-angle, degrees), 0.5 * floatcos(-angle, degrees), 0.1);

	if(!IsPlayerInDynamicArea(playerid, Zone[playerid]))
		defer _tut_AreaCheck(playerid);

	return;
}


// ALS Stuff (Out of the way)


#if defined _ALS_OnPlayerLoadAccount
	#undef OnPlayerLoadAccount
#else
	#define _ALS_OnPlayerLoadAccount
#endif
#define OnPlayerLoadAccount tut_OnPlayerLoadAccount
#if defined tut_OnPlayerLoadAccount
	forward tut_OnPlayerLoadAccount(playerid);
#endif

#if defined _ALS_OnPlayerSpawnExistingChar
	#undef OnPlayerSpawnExistingChar
#else
	#define _ALS_OnPlayerSpawnExistingChar
#endif
#define OnPlayerSpawnExistingChar tut_OnPlayerSpawnExistingChar
#if defined tut_OnPlayerSpawnExistingChar
	forward tut_OnPlayerSpawnExistingChar(playerid);
#endif

#if defined _ALS_OnPlayerSpawnNewCharacter
	#undef OnPlayerSpawnNewCharacter
#else
	#define _ALS_OnPlayerSpawnNewCharacter
#endif
#define OnPlayerSpawnNewCharacter tut_OnPlayerSpawnNewCharacter
#if defined tut_OnPlayerSpawnNewCharacter
	forward tut_OnPlayerSpawnNewCharacter(playerid);
#endif

#if defined _ALS_OnPlayerCreateNewCharacter
	#undef OnPlayerCreateNewCharacter
#else
	#define _ALS_OnPlayerCreateNewCharacter
#endif
#define OnPlayerCreateNewCharacter tut_OnPlayerCreateNewCharacter
#if defined tut_OnPlayerCreateNewCharacter
	forward tut_OnPlayerCreateNewCharacter(playerid);
#endif

#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress tut_OnButtonPress
#if defined tut_OnButtonPress
	forward tut_OnButtonPress(playerid, buttonid);
#endif

#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory tut_OnPlayerOpenInventory
#if defined tut_OnPlayerOpenInventory
	forward tut_OnPlayerOpenInventory(playerid);
#endif

#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer tut_OnPlayerOpenContainer
#if defined tut_OnPlayerOpenContainer
	forward tut_OnPlayerOpenContainer(playerid, containerid);
#endif

#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt tut_OnPlayerViewContainerOpt
#if defined tut_OnPlayerViewContainerOpt
	forward tut_OnPlayerViewContainerOpt(playerid, containerid);
#endif

#if defined _ALS_OnItemRemoveFromContainer
	#undef OnItemRemoveFromContainer
#else
	#define _ALS_OnItemRemoveFromContainer
#endif
#define OnItemRemoveFromContainer tut_OnItemRemoveFromContainer
#if defined tut_OnItemRemoveFromContainer
	forward tut_OnItemRemoveFromContainer(containerid, slotid, playerid);
#endif

#if defined _ALS_OnPlayerDropItem
	#undef OnPlayerDropItem
#else
	#define _ALS_OnPlayerDropItem
#endif
#define OnPlayerDropItem tut_OnPlayerDropItem
#if defined tut_OnPlayerDropItem
	forward tut_OnPlayerDropItem(playerid, itemid);
#endif

#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem tut_OnPlayerPickUpItem
#if defined tut_OnPlayerPickUpItem
	forward tut_OnPlayerPickUpItem(playerid, itemid);
#endif

#if defined _ALS_OnItemAddToInventory
	#undef OnItemAddToInventory
#else
	#define _ALS_OnItemAddToInventory
#endif
#define OnItemAddToInventory tut_OnItemAddToInventory
#if defined tut_OnItemAddToInventory
	forward tut_OnItemAddToInventory(playerid, itemid, slot);
#endif

#if defined _ALS_OnPlayerViewInventoryOpt
	#undef OnPlayerViewInventoryOpt
#else
	#define _ALS_OnPlayerViewInventoryOpt
#endif
#define OnPlayerViewInventoryOpt tut_OnPlayerViewInventoryOpt
#if defined tut_OnPlayerViewInventoryOpt
	forward tut_OnPlayerViewInventoryOpt(playerid);
#endif

#if defined _ALS_OnItemAddToContainer
	#undef OnItemAddToContainer
#else
	#define _ALS_OnItemAddToContainer
#endif
#define OnItemAddToContainer tut_OnItemAddToContainer
#if defined tut_OnItemAddToContainer
	forward tut_OnItemAddToContainer(containerid, itemid, playerid);
#endif

#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer tut_OnPlayerCloseContainer
#if defined tut_OnPlayerCloseContainer
	forward tut_OnPlayerCloseContainer(playerid, containerid);
#endif

#if defined _ALS_OnPlayerCloseInventory
	#undef OnPlayerCloseInventory
#else
	#define _ALS_OnPlayerCloseInventory
#endif
#define OnPlayerCloseInventory tut_OnPlayerCloseInventory
#if defined tut_OnPlayerCloseInventory
	forward tut_OnPlayerCloseInventory(playerid);
#endif

#if defined _ALS_OnPlayerHolsteredItem
	#undef OnPlayerHolsteredItem
#else
	#define _ALS_OnPlayerHolsteredItem
#endif
#define OnPlayerHolsteredItem tut_OnPlayerHolsteredItem
#if defined tut_OnPlayerHolsteredItem
	forward tut_OnPlayerHolsteredItem(playerid, itemid);
#endif

#if defined _ALS_OnPlayerUnHolsteredItem
	#undef OnPlayerUnHolsteredItem
#else
	#define _ALS_OnPlayerUnHolsteredItem
#endif
#define OnPlayerUnHolsteredItem tut_OnPlayerUnHolsteredItem
#if defined tut_OnPlayerUnHolsteredItem
	forward tut_OnPlayerUnHolsteredItem(playerid, itemid);
#endif

#if defined _ALS_OnPlayerWearBag
	#undef OnPlayerWearBag
#else
	#define _ALS_OnPlayerWearBag
#endif
#define OnPlayerWearBag tut_OnPlayerWearBag
#if defined tut_OnPlayerWearBag
	forward tut_OnPlayerWearBag(playerid, itemid);
#endif


// Interface


stock IsPlayerInTutorial(playerid)
{
	if(TutorialState[playerid] != E_TUT_NONE)
		return 1;

	return 0;
}

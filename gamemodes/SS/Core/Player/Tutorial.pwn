#include <YSI\y_hooks>


static
PlayerText:	ClassButtonTutorial		[MAX_PLAYERS],
bool:		PlayerInTutorial		[MAX_PLAYERS],
			PlayerTutorialWorld		[MAX_PLAYERS],
			PlayerTutorialVehicle	[MAX_PLAYERS],
			TutorialWorld = 90;


static
			HANDLER = -1;


forward OnPlayerWearBag(playerid, itemid);
forward OnPlayerHolsteredItem(playerid, itemid);


hook OnGameModeInit()
{
	HANDLER = debug_register_handler("tutorial", 0);

	CreateDynamicObject(6959, 0.00000, 0.00000, -20.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19456, 8.06020, -0.00030, -18.28000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19456, -4.90600, 0.00000, -18.28000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19456, -0.26566, 14.42851, -18.28000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19456, 3.21220, -4.90600, -18.28000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19456, -4.90600, -9.81200, -18.28000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19456, -1.50600, -9.81200, -18.28000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, -3.21110, -4.90600, -18.28000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, -3.21110, -14.00600, -18.28000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1498, -3.99050, -14.01290, -20.03010,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19456, -4.90600, 9.63400, -18.28000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19456, 8.06330, 9.63260, -18.28000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19456, 9.36560, 14.42880, -18.28000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(6959, 0.00000, 0.00000, -16.51838,   0.00000, 0.00000, 0.00000);
}

public OnPlayerLoadAccount(playerid)
{
	d:1:HANDLER("[OnPlayerLoadAccount]");

	ClassButtonTutorial[playerid]	=CreatePlayerTextDraw(playerid, 320.000000, 300.000000, "~n~Want to try the game first?~n~~n~~y~Click here to play the tutorial!~n~~n~");
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
	PlayerTextDrawTextSize			(playerid, ClassButtonTutorial[playerid], 34.000000, 150.000000);
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

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	d:1:HANDLER("[OnPlayerClickPlayerTextDraw]");
	if(playertextid == ClassButtonTutorial[playerid])
	{
		PlayerTutorialWorld[playerid] = TutorialWorld;
		TutorialWorld++;

		SetPlayerPos(playerid, -3.17802, -12.89518, -19.03157);
		SetPlayerFacingAngle(playerid, 0.0);
		SetPlayerVirtualWorld(playerid, PlayerTutorialWorld[playerid]);

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

		SetPlayerBitFlag(playerid, Alive, false);
		SetPlayerBitFlag(playerid, Spawned, false);

		FreezePlayer(playerid, gLoginFreezeTime * 1000);
		PrepareForSpawn(playerid);

		PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
		PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);
		PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);

		SetPlayerScreenFadeLevel(playerid, 255);

		ShowHelpTip(playerid, "Welcome to the tutorial! Look around and try things. Help messages will appear here! Type /exit to leave the tutorial.");
		PlayerInTutorial[playerid] = true;

		CreateItem(item_Satchel, -3.15328, -6.40267, -19.9447, _, _, _, FLOOR_OFFSET, PlayerTutorialWorld[playerid]);

		PlayerTutorialVehicle[playerid] = CreateWorldVehicle(veht_Bobcat, 3.6560, 9.9606, -19.1121, 137.5200, -1, -1, PlayerTutorialWorld[playerid]);
		SetVehicleHealth(PlayerTutorialVehicle[playerid], 321.9);
		SetVehicleFuel(PlayerTutorialVehicle[playerid], frandom(1.0));
		FillContainerWithLoot(GetVehicleContainer(PlayerTutorialVehicle[playerid]), 5, loot_Civilian);
		SetVehicleDamageData(PlayerTutorialVehicle[playerid],
			encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4)),
			encode_doors(random(5), random(5), random(5), random(5)),
			encode_lights(random(2), random(2), random(2), random(2)),
			encode_tires(random(2), random(2), random(2), random(2)) );

		CreateItem(item_Wrench, -3.43313, 12.14963, -20.03342, _, _, frandom(360.0), FLOOR_OFFSET, PlayerTutorialWorld[playerid]);
		CreateItem(item_Screwdriver, -3.31169, 10.41365, -20.03261, _, _, frandom(360.0), FLOOR_OFFSET, PlayerTutorialWorld[playerid]);
		CreateItem(item_Hammer, -2.27567, 10.21404, -20.03267, _, _, frandom(360.0), FLOOR_OFFSET, PlayerTutorialWorld[playerid]);

		CreateItem(item_Wheel, 1.45441, 12.21830, -20.03421, _, _, frandom(360.0), FLOOR_OFFSET, PlayerTutorialWorld[playerid]);
		CreateItem(item_Wheel, 0.53707, 11.79060, -20.03381, _, _, frandom(360.0), FLOOR_OFFSET, PlayerTutorialWorld[playerid]);
		new itemid = CreateItem(item_GasCan, 0.63107, 10.54177, -20.03327, _, _, frandom(360.0), FLOOR_OFFSET, PlayerTutorialWorld[playerid]);
		SetItemExtraData(itemid, 10);
	}
}

hook OnPlayerDeath(playerid)
{
	ExitTutorial(playerid);
}

hook OnPlayerDisconnect(playerid, reason)
{
	ExitTutorial(playerid);
}

ExitTutorial(playerid)
{
	if(!PlayerInTutorial[playerid])
		return 0;

	PlayerInTutorial[playerid] = false;
	HideHelpTip(playerid);
	SetPlayerBitFlag(playerid, Spawned, false);
	SetPlayerBitFlag(playerid, Alive, false);
	SetPlayerVirtualWorld(playerid, 0);
	PlayerCreateNewCharacter(playerid);
	SetPlayerScreenFadeLevel(playerid, 0);

	DestroyWorldVehicle(PlayerTutorialVehicle[playerid]);
	PlayerTutorialVehicle[playerid] = INVALID_VEHICLE_ID;

	return 1;
}


public OnPlayerPickUpItem(playerid, itemid)
{
	if(PlayerInTutorial[playerid])
	{
		// ShowHelpTip(playerid, "This is an item. There are many different items in the game with different purposes. Some are common and some are rare.");
	}

	#if defined tut_OnPlayerPickUpItem
		return tut_OnPlayerPickUpItem(playerid, itemid);
	#else
		return 0;
	#endif
}


public OnPlayerWearBag(playerid, itemid)
{
	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "You can access your bag by pressing "KEYTEXT_INVENTORY" and clicking the Bag icon at the bottom right.");
	}

	#if defined tut_OnPlayerWearBag
		return tut_OnPlayerWearBag(playerid, itemid);
	#else
		return 0;
	#endif
}


public OnPlayerOpenInventory(playerid)
{
	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "This is your character inventory also known as your pockets. This is not your bag.");
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
		if(PlayerInTutorial[playerid])
		{
			ShowHelpTip(playerid, "This is your bag. Bags are extra storage. There are many different types of bags with different sizes.");
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
	if(PlayerInTutorial[playerid])
	{
		if(GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))) == item_Wrench)
		{
			ShowHelpTip(playerid, "These are your options for the selected item. Equip puts it in your hand. Combine can be selected on multiple items to attempt to combine them.");
		}
	}

	#if defined tut_OnPlayerViewContainerOpt
		return tut_OnPlayerViewContainerOpt(playerid, containerid);
	#else
		return 0;
	#endif
}


public OnPlayerDroppedItem(playerid, itemid)
{
	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "When you drop an item, other players can pick it up. Most item types ");
	}

	#if defined tut_OnPlayerDroppedItem
		return tut_OnPlayerDroppedItem(playerid, itemid);
	#else
		return 0;
	#endif
}

public OnItemAddToInventory(playerid, itemid, slot)
{
	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "You added an item to your inventory. If your inventory is full, the item will be put in your bag.");
	}

	#if defined tut_OnItemAddToInventory
		return tut_OnItemAddToInventory(playerid, itemid, slot);
	#else
		return 0;
	#endif
}


public OnPlayerViewInventoryOpt(playerid)
{
	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "These are your options for the selected item. Equip puts it in your hand. Combine can be selected on multiple items to attempt to combine them.");
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
		if(PlayerInTutorial[playerid])
		{
			if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
			{
				ShowHelpTip(playerid, "You added an item to your bag. You can access your bag by pressing "KEYTEXT_INVENTORY" and clicking the Bag icon at the bottom right.");
			}
			else
			{
				ShowHelpTip(playerid, "You added an item to a container. Containers are places to store items ");
			}
		}
	}

	#if defined tut_OnItemAddToContainer
		return tut_OnItemAddToContainer(containerid, itemid, playerid);
	#else
		return 0;
	#endif
}

public OnPlayerHolsteredItem(playerid, itemid)
{
	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "You have holstered an item. Holstered items can be quickly accessed by pressing "KEYTEXT_PUT_AWAY" again.");
	}

	#if defined tut_OnPlayerHolsteredItem
		return tut_OnPlayerHolsteredItem(playerid, itemid);
	#else
		return 0;
	#endif
}

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "You tried to use an item with another item because you're holding one already. This can be used sometimes, for example use a lighter with a campfire to light it or use a weapon with ammo to load it.");
	}

	#if defined tut_OnPlayerUseItemWithItem
		return tut_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
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

#if defined _ALS_OnPlayerWearBag
	#undef OnPlayerWearBag
#else
	#define _ALS_OnPlayerWearBag
#endif
#define OnPlayerWearBag tut_OnPlayerWearBag
#if defined tut_OnPlayerWearBag
	forward tut_OnPlayerWearBag(playerid, itemid);
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

#if defined _ALS_OnPlayerDroppedItem
	#undef OnPlayerDroppedItem
#else
	#define _ALS_OnPlayerDroppedItem
#endif
#define OnPlayerDroppedItem tut_OnPlayerDroppedItem
#if defined tut_OnPlayerDroppedItem
	forward tut_OnPlayerDroppedItem(playerid, itemid);
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

#if defined _ALS_OnPlayerHolsteredItem
	#undef OnPlayerHolsteredItem
#else
	#define _ALS_OnPlayerHolsteredItem
#endif
#define OnPlayerHolsteredItem tut_OnPlayerHolsteredItem
#if defined tut_OnPlayerHolsteredItem
	forward tut_OnPlayerHolsteredItem(playerid, itemid);
#endif


// Interface


stock IsPlayerInTutorial(playerid)
{
	if(PlayerInTutorial[playerid])
		return 1;

	return 0;
}

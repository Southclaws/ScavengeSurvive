#include <YSI\y_hooks>


static
PlayerText:	TutUI_Keys				[MAX_PLAYERS],
PlayerText:	TutUI_Watch				[MAX_PLAYERS],
PlayerText:	TutUI_Stats				[MAX_PLAYERS],
PlayerText:	TutUI_Exit				[MAX_PLAYERS],
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
	print("\n[OnGameModeInit] Initialising 'Tutorial'...");

	HANDLER = debug_register_handler("tutorial", 0);
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

		TutUI_Keys[playerid]			=CreatePlayerTextDraw(playerid, 390.000000, 140.000000, "This tells you ~>~ what keys to press");
		PlayerTextDrawBackgroundColor	(playerid, TutUI_Keys[playerid], 255);
		PlayerTextDrawFont				(playerid, TutUI_Keys[playerid], 1);
		PlayerTextDrawLetterSize		(playerid, TutUI_Keys[playerid], 0.300000, 1.500000);
		PlayerTextDrawColor				(playerid, TutUI_Keys[playerid], -1);
		PlayerTextDrawSetOutline		(playerid, TutUI_Keys[playerid], 0);
		PlayerTextDrawSetProportional	(playerid, TutUI_Keys[playerid], 1);
		PlayerTextDrawSetShadow			(playerid, TutUI_Keys[playerid], 1);
		PlayerTextDrawUseBox			(playerid, TutUI_Keys[playerid], 1);
		PlayerTextDrawBoxColor			(playerid, TutUI_Keys[playerid], 100);
		PlayerTextDrawTextSize			(playerid, TutUI_Keys[playerid], 480.000000, 0.000000);

		TutUI_Watch[playerid]			=CreatePlayerTextDraw(playerid, 83.000000, 250.000000, "This is your watch.~n~It shows your facing angle,~n~current time of day,~n~and chat radio frequency.~n~~d~");
		PlayerTextDrawAlignment			(playerid, TutUI_Watch[playerid], 2);
		PlayerTextDrawBackgroundColor	(playerid, TutUI_Watch[playerid], 255);
		PlayerTextDrawFont				(playerid, TutUI_Watch[playerid], 1);
		PlayerTextDrawLetterSize		(playerid, TutUI_Watch[playerid], 0.300000, 1.500000);
		PlayerTextDrawColor				(playerid, TutUI_Watch[playerid], -1);
		PlayerTextDrawSetOutline		(playerid, TutUI_Watch[playerid], 0);
		PlayerTextDrawSetProportional	(playerid, TutUI_Watch[playerid], 1);
		PlayerTextDrawSetShadow			(playerid, TutUI_Watch[playerid], 1);
		PlayerTextDrawUseBox			(playerid, TutUI_Watch[playerid], 1);
		PlayerTextDrawBoxColor			(playerid, TutUI_Watch[playerid], 100);
		PlayerTextDrawTextSize			(playerid, TutUI_Watch[playerid], 0.000000, 150.000000);

		TutUI_Stats[playerid]			=CreatePlayerTextDraw(playerid, 390.000000, 20.000000, "This shows your ~>~ health, armour, ammo and energy");
		PlayerTextDrawBackgroundColor	(playerid, TutUI_Stats[playerid], 255);
		PlayerTextDrawFont				(playerid, TutUI_Stats[playerid], 1);
		PlayerTextDrawLetterSize		(playerid, TutUI_Stats[playerid], 0.300000, 1.500000);
		PlayerTextDrawColor				(playerid, TutUI_Stats[playerid], -1);
		PlayerTextDrawSetOutline		(playerid, TutUI_Stats[playerid], 0);
		PlayerTextDrawSetProportional	(playerid, TutUI_Stats[playerid], 1);
		PlayerTextDrawSetShadow			(playerid, TutUI_Stats[playerid], 1);
		PlayerTextDrawUseBox			(playerid, TutUI_Stats[playerid], 1);
		PlayerTextDrawBoxColor			(playerid, TutUI_Stats[playerid], 100);
		PlayerTextDrawTextSize			(playerid, TutUI_Stats[playerid], 480.000000, 0.000000);

		TutUI_Exit[playerid]			=CreatePlayerTextDraw(playerid, 484.000000, 280.000000, "To exit the tutorial, type /exit. If you can only see the tutorial button:~n~~n~This server uses an anti-cheat program. To play, you must download this from ~y~ac.scavengesurvive.com then you can play unrestricted.");
		PlayerTextDrawBackgroundColor	(playerid, TutUI_Exit[playerid], 255);
		PlayerTextDrawFont				(playerid, TutUI_Exit[playerid], 1);
		PlayerTextDrawLetterSize		(playerid, TutUI_Exit[playerid], 0.300000, 1.500000);
		PlayerTextDrawColor				(playerid, TutUI_Exit[playerid], -1);
		PlayerTextDrawSetOutline		(playerid, TutUI_Exit[playerid], 0);
		PlayerTextDrawSetProportional	(playerid, TutUI_Exit[playerid], 1);
		PlayerTextDrawSetShadow			(playerid, TutUI_Exit[playerid], 1);
		PlayerTextDrawUseBox			(playerid, TutUI_Exit[playerid], 1);
		PlayerTextDrawBoxColor			(playerid, TutUI_Exit[playerid], 100);
		PlayerTextDrawTextSize			(playerid, TutUI_Exit[playerid], 630.000000, 0.000000);

		SetPlayerPos(playerid, 1078.36194, 2139.40771, 10.64758);
		SetPlayerFacingAngle(playerid, 180.0);
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

		ToggleTutorialUI(playerid, true);

		new itemid;

		CreateItem(item_Satchel, 1078.70325, 2132.96069, 9.85179, _, _, _, FLOOR_OFFSET, PlayerTutorialWorld[playerid]);

		PlayerTutorialVehicle[playerid] = CreateWorldVehicle(veht_Bobcat, 1075.4344, 2121.3606, 10.7901, 355.6799, -1, -1, PlayerTutorialWorld[playerid]);
		SetVehicleHealth(PlayerTutorialVehicle[playerid], 321.9);
		SetVehicleFuel(PlayerTutorialVehicle[playerid], frandom(1.0));
		FillContainerWithLoot(GetVehicleContainer(PlayerTutorialVehicle[playerid]), 5, loot_Civilian);
		SetVehicleDamageData(PlayerTutorialVehicle[playerid],
			encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4)),
			encode_doors(random(5), random(5), random(5), random(5)),
			encode_lights(random(2), random(2), random(2), random(2)),
			encode_tires(0, 1, 1, 0) );

		CreateItem(item_Wrench, 1077.57263, 2125.35938, 9.85153, _, _, frandom(360.0), FLOOR_OFFSET, PlayerTutorialWorld[playerid]);
		CreateItem(item_Screwdriver, 1076.52942, 2125.82959, 9.85156, _, _, frandom(360.0), FLOOR_OFFSET, PlayerTutorialWorld[playerid]);
		CreateItem(item_Hammer, 1074.94214, 2126.51489, 9.85160, _, _, frandom(360.0), FLOOR_OFFSET, PlayerTutorialWorld[playerid]);

		CreateItem(item_Wheel, 1073.59448, 2127.05786, 9.85164, _, _, frandom(360.0), FLOOR_OFFSET, PlayerTutorialWorld[playerid]);
		CreateItem(item_Wheel, 1073.4965, 2125.6582, 9.8516, _, _, frandom(360.0), FLOOR_OFFSET, PlayerTutorialWorld[playerid]);
		itemid = CreateItem(item_GasCan, 0.63107, 10.54177, -20.03327, _, _, frandom(360.0), FLOOR_OFFSET, PlayerTutorialWorld[playerid]);
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

	ToggleTutorialUI(playerid, false);

	return 1;
}

ToggleTutorialUI(playerid, toggle)
{
	if(toggle)
	{
		PlayerTextDrawShow(playerid, TutUI_Keys[playerid]);
		PlayerTextDrawShow(playerid, TutUI_Watch[playerid]);
		PlayerTextDrawShow(playerid, TutUI_Stats[playerid]);
		PlayerTextDrawShow(playerid, TutUI_Exit[playerid]);
	}
	else
	{
		PlayerTextDrawHide(playerid, TutUI_Keys[playerid]);
		PlayerTextDrawHide(playerid, TutUI_Watch[playerid]);
		PlayerTextDrawHide(playerid, TutUI_Stats[playerid]);
		PlayerTextDrawHide(playerid, TutUI_Exit[playerid]);
	}
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
		ToggleTutorialUI(playerid, false);

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
	if(PlayerInTutorial[playerid])
	{
		ToggleTutorialUI(playerid, false);

		if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
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

public OnPlayerCloseInventory(playerid)
{
	if(PlayerInTutorial[playerid])
		ToggleTutorialUI(playerid, true);

	#if defined tut_OnPlayerCloseInventory
		return tut_OnPlayerCloseInventory(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerCloseInventory
	#undef OnPlayerCloseInventory
#else
	#define _ALS_OnPlayerCloseInventory
#endif
 
#define OnPlayerCloseInventory tut_OnPlayerCloseInventory
#if defined tut_OnPlayerCloseInventory
	forward tut_OnPlayerCloseInventory(playerid);
#endif

public OnPlayerCloseContainer(playerid, containerid)
{
	if(PlayerInTutorial[playerid])
		ToggleTutorialUI(playerid, true);

	#if defined tut_OnPlayerCloseContainer
		return tut_OnPlayerCloseContainer(playerid, containerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
 
#define OnPlayerCloseContainer tut_OnPlayerCloseContainer
#if defined tut_OnPlayerCloseContainer
	forward tut_OnPlayerCloseContainer(playerid, containerid);
#endif

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

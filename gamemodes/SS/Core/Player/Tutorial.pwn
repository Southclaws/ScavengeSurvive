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


#define TUTORIAL_WORLD	(90)


static
PlayerText:	ClassButtonTutorial[MAX_PLAYERS],
			ExitButton,
			TutorialState[MAX_PLAYERS];


static
			HANDLER = -1;


hook OnGameModeInit()
{
	// Static objects
	CreateDynamicObject(17037, -1547.99207, -2725.40356, 49.66700,   0.00000, 0.00000, 55.68000, TUTORIAL_WORLD);

	ExitButton = CreateButton(-1623.7362, -2693.3596, 48.6953, "Leave tutorial", TUTORIAL_WORLD, 0, 1.0, 1, "Leave tutorial");

	HANDLER = debug_register_handler("tutorial", 5);
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
	PlayerTextDrawTextSize			(playerid, ClassButtonTutorial[playerid], 300.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonTutorial[playerid], true);

	#if defined tut_OnPlayerLoadAccount
		return tut_OnPlayerLoadAccount(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLoadAccount
	#undef OnPlayerLoadAccount
#else
	#define _ALS_OnPlayerLoadAccount
#endif
#define OnPlayerLoadAccount tut_OnPlayerLoadAccount
#if defined tut_OnPlayerLoadAccount
	forward tut_OnPlayerLoadAccount(playerid);
#endif

public OnPlayerCreateNewCharacter(playerid)
{
	d:1:HANDLER("[OnPlayerCreateNewCharacter]");

	// PlayerTextDrawShow(playerid, ClassButtonTutorial[playerid]);

	#if defined tut_OnPlayerCreateNewCharacter
		return tut_OnPlayerCreateNewCharacter(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerCreateNewCharacter
	#undef OnPlayerCreateNewCharacter
#else
	#define _ALS_OnPlayerCreateNewCharacter
#endif
 
#define OnPlayerCreateNewCharacter tut_OnPlayerCreateNewCharacter
#if defined tut_OnPlayerCreateNewCharacter
	forward tut_OnPlayerCreateNewCharacter(playerid);
#endif

public OnButtonPress(playerid, buttonid)
{
	d:1:HANDLER("[OnButtonPress]");

	if(buttonid == ExitButton)
		SetPlayerHP(playerid, 0.0);

	#if defined tut_OnButtonPress
		return tut_OnButtonPress(playerid, buttonid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
 
#define OnButtonPress tut_OnButtonPress
#if defined tut_OnButtonPress
	forward tut_OnButtonPress(playerid, buttonid);
#endif

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

		ShowHelpTip(playerid, "Using your inventory effectively is key to scavenging items quickly and efficiently! When you have a bag on your back it is available for extra storage.~n~~b~Press "KEYTEXT_INVENTORY" to open your inventory now.");
		TutorialState[playerid] = 1;
	}
}

public OnPlayerOpenInventory(playerid)
{
	if(TutorialState[playerid] == 1)
	{
		ShowHelpTip(playerid, "Great! From here you can access your items and bag if you have one. Click your bag on the right side of the screen now. It is labeled \"Small Bag\".");
		TutorialState[playerid] = 2;
	}
	if(TutorialState[playerid] == 8)
	{
		ShowHelpTip(playerid, "Open the options menu for the Wrench in your inventory.");
		TutorialState[playerid] = 9;
	}

	#if defined tut_OnPlayerOpenInventory
		return tut_OnPlayerOpenInventory(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory tut_OnPlayerOpenInventory
#if defined tut_OnPlayerOpenInventory
	forward tut_OnPlayerOpenInventory(playerid);
#endif

public OnPlayerOpenContainer(playerid, containerid)
{
	if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
	{
		if(TutorialState[playerid] == 2)
		{
			ShowHelpTip(playerid, "This is your starting gear. Now double click the Wrench in your bag.");
			TutorialState[playerid] = 3;
		}
	}

	#if defined tut_OnPlayerOpenContainer
		return tut_OnPlayerOpenContainer(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer tut_OnPlayerOpenContainer
#if defined tut_OnPlayerOpenContainer
	forward tut_OnPlayerOpenContainer(playerid, containerid);
#endif

public OnPlayerViewContainerOpt(playerid, containerid)
{
	if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
	{
		if(TutorialState[playerid] == 3)
		{
			if(GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))) == item_Wrench)
			{
				ShowHelpTip(playerid, "Now click \"Equip\" to remove the Wrench from your bag and put it in your hands.");
				TutorialState[playerid] = 4;
			}
		}
	}

	#if defined tut_OnPlayerViewContainerOpt
		return tut_OnPlayerViewContainerOpt(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt tut_OnPlayerViewContainerOpt
#if defined tut_OnPlayerViewContainerOpt
	forward tut_OnPlayerViewContainerOpt(playerid, containerid);
#endif

public OnItemRemoveFromContainer(containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
		{
			if(TutorialState[playerid] == 4)
			{
				if(GetItemType(GetContainerSlotItem(containerid, slotid)) == item_Wrench)
				{
					ShowHelpTip(playerid, "Wrenches can be used to repair vehicles, but it will only repair so much, you'll need more tools to repair a vehicle fully. Press "KEYTEXT_DROP_ITEM" to drop/give your current item or weapon.");
					TutorialState[playerid] = 5;
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
#if defined _ALS_OnItemRemoveFromContainer
	#undef OnItemRemoveFromContainer
#else
	#define _ALS_OnItemRemoveFromContainer
#endif
#define OnItemRemoveFromContainer tut_OnItemRemoveFromContainer
#if defined tut_OnItemRemoveFromContainer
	forward tut_OnItemRemoveFromContainer(containerid, slotid, playerid);
#endif

public OnPlayerDropItem(playerid, itemid)
{
	if(TutorialState[playerid] == 5)
	{
		if(GetItemType(itemid) == item_Wrench)
		{
			ShowHelpTip(playerid, "Good, you should grab that again though, you might need it! Press "KEYTEXT_INTERACT" to pick up items.");
			TutorialState[playerid] = 6;
		}
	}

	#if defined tut_OnPlayerDropItem
		return tut_OnPlayerDropItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerDropItem
	#undef OnPlayerDropItem
#else
	#define _ALS_OnPlayerDropItem
#endif
#define OnPlayerDropItem tut_OnPlayerDropItem
#if defined tut_OnPlayerDropItem
	forward tut_OnPlayerDropItem(playerid, itemid);
#endif

public OnPlayerPickUpItem(playerid, itemid)
{
	if(TutorialState[playerid] == 6)
	{
		if(GetItemType(itemid) == item_Wrench)
		{
			ShowHelpTip(playerid, "You can't go around carrying everything by hand! Put your current item in your inventory by pressing "KEYTEXT_PUT_AWAY"");
			TutorialState[playerid] = 7;
		}
	}

	#if defined tut_OnPlayerPickUpItem
		return tut_OnPlayerPickUpItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem tut_OnPlayerPickUpItem
#if defined tut_OnPlayerPickUpItem
	forward tut_OnPlayerPickUpItem(playerid, itemid);
#endif

public OnItemAddToInventory(playerid, itemid, slot)
{
	if(TutorialState[playerid] == 7)
	{
		ShowHelpTip(playerid, "You put it in your inventory, you can move items between your inventory and your bag, open your inventory again with "KEYTEXT_INVENTORY".");
		TutorialState[playerid] = 8;
	}

	#if defined tut_OnItemAddToInventory
		return tut_OnItemAddToInventory(playerid, itemid, slot);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemAddToInventory
	#undef OnItemAddToInventory
#else
	#define _ALS_OnItemAddToInventory
#endif
#define OnItemAddToInventory tut_OnItemAddToInventory
#if defined tut_OnItemAddToInventory
	forward tut_OnItemAddToInventory(playerid, itemid, slot);
#endif

public OnPlayerViewInventoryOpt(playerid)
{
	if(TutorialState[playerid] == 9)
	{
		ShowHelpTip(playerid, "Now press the \"Move to bag\" button to remove that item from your inventory and put it in your bag.");
		TutorialState[playerid] = 10;
	}

	#if defined tut_OnPlayerViewInventoryOpt
		return tut_OnPlayerViewInventoryOpt(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerViewInventoryOpt
	#undef OnPlayerViewInventoryOpt
#else
	#define _ALS_OnPlayerViewInventoryOpt
#endif
#define OnPlayerViewInventoryOpt tut_OnPlayerViewInventoryOpt
#if defined tut_OnPlayerViewInventoryOpt
	forward tut_OnPlayerViewInventoryOpt(playerid);
#endif

public OnItemAddToContainer(containerid, itemid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
		{
			if(TutorialState[playerid] == 10)
			{
				ShowHelpTip(playerid, "This works both ways, in your bag item options \"Move to inventory\" moves an item from your bag to your inventory.");
				TutorialState[playerid] = 11;
			}
		}
	}

	#if defined tut_OnItemAddToContainer
		return tut_OnItemAddToContainer(containerid, itemid, playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemAddToContainer
	#undef OnItemAddToContainer
#else
	#define _ALS_OnItemAddToContainer
#endif
#define OnItemAddToContainer tut_OnItemAddToContainer
#if defined tut_OnItemAddToContainer
	forward tut_OnItemAddToContainer(containerid, itemid, playerid);
#endif

public OnPlayerCloseContainer(playerid, containerid)
{
	if(TutorialState[playerid] == 11)
	{
		ShowHelpTip(playerid, "Great! You now know how to use your inventory and bag, you can remove your bag by pressing "KEYTEXT_DROP_ITEM" and it behaves just like an item.~n~~n~This concludes the tutorial, you can access it at any time by typing /tutorial. Good luck!", 30000);
		TutorialState[playerid] = 0;
	}

	#if defined tut_OnPlayerCloseContainer
		return tut_OnPlayerCloseContainer(playerid, containerid);
	#else
		return 0;
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

public OnPlayerCloseInventory(playerid)
{
	if(TutorialState[playerid] == 11)
	{
		ShowHelpTip(playerid, "Great! You now know how to use your inventory and bag, you can remove your bag by pressing "KEYTEXT_DROP_ITEM" and it behaves just like an item.~n~~n~This concludes the tutorial, you can access it at any time by typing /tutorial. Good luck!", 30000);
		TutorialState[playerid] = 0;
	}

	#if defined tut_OnPlayerCloseInventory
		return tut_OnPlayerCloseInventory(playerid);
	#else
		return 0;
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


// Interface


stock IsPlayerInTutorial(playerid)
{
	if(TutorialState[playerid] > 0)
		return 1;

	return 0;
}

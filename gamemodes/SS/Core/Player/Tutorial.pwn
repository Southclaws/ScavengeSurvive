static
	TutorialState[MAX_PLAYERS];

Tutorial_Start(playerid)
{
	ShowHelpTip(playerid, "Using your inventory effectively is key to scavenging items quickly and efficiently! When you have a bag on your back it is available for extra storage.~n~~b~Press "KEYTEXT_INVENTORY" to open your inventory now.~n~~n~~w~/skip to close the tutorial.");

	TutorialState[playerid] = 1;
}

Tutorial_End(playerid)
{
	HideHelpTip(playerid);
	TutorialState[playerid] = 0;
}

CMD:tutorial(playerid, params[])
{
	Tutorial_Start(playerid);
	return 1;
}
CMD:skip(playerid, params[])
{
	ShowHelpTip(playerid, "Tutorial skipped, you can start it at any time by typing /tutorial.", 5000);
	TutorialState[playerid] = 0;
	return 1;
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

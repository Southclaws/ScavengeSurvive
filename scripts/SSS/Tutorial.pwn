static
	TutorialState[MAX_PLAYERS];

Tutorial_Start(playerid)
{
	ShowHelpTip(playerid, "Using your inventory effectively is key to scavenging items quickly and efficiently! When you have a bag on your back it is available for extra storage.~n~~b~Press H to open your inventory now.~n~~n~~w~/skip to close the tutorial.");

	TutorialState[playerid] = 1;
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
		ShowHelpTip(playerid, "Open the options menu for the Medkit in your inventory.");
		TutorialState[playerid] = 9;
	}

	return CallLocalFunction("tut_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory tut_OnPlayerOpenInventory
forward tut_OnPlayerOpenInventory(playerid);

public OnPlayerOpenContainer(playerid, containerid)
{
	if(containerid == GetItemExtraData(GetPlayerBackpackItem(playerid)))
	{
		if(TutorialState[playerid] == 2)
		{
			ShowHelpTip(playerid, "This is your starting gear. Now double click the Medkit in your bag.");
			TutorialState[playerid] = 3;
		}
	}

	return CallLocalFunction("tut_OnPlayerOpenContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer tut_OnPlayerOpenContainer
forward tut_OnPlayerOpenContainer(playerid, containerid);

public OnPlayerViewContainerOpt(playerid, containerid)
{
	if(containerid == GetItemExtraData(GetPlayerBackpackItem(playerid)))
	{
		if(TutorialState[playerid] == 3)
		{
			if(GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))) == item_Medkit)
			{
				ShowHelpTip(playerid, "Now click \"Equip\" to remove the Medkit from your bag and put it in your hands.");
				TutorialState[playerid] = 4;
			}
		}
	}

	return CallLocalFunction("tut_OnPlayerViewContainerOpt", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt tut_OnPlayerViewContainerOpt
forward tut_OnPlayerViewContainerOpt(playerid, containerid);

public OnPlayerTakeFromContainer(playerid, containerid, slotid)
{
	if(containerid == GetItemExtraData(GetPlayerBackpackItem(playerid)))
	{
		if(TutorialState[playerid] == 4)
		{
			if(GetItemType(GetContainerSlotItem(containerid, slotid)) == item_Medkit)
			{
				ShowHelpTip(playerid, "Great! Now you can shoot hostile players, but what if you're feeling friendly? Press N to drop your current item or weapon.");
				TutorialState[playerid] = 5;
			}
		}
	}

	return CallLocalFunction("tut_OnPlayerTakeFromContainer", "dd", playerid, slotid);
}
#if defined _ALS_OnPlayerTakeFromContainer
	#undef OnPlayerTakeFromContainer
#else
	#define _ALS_OnPlayerTakeFromContainer
#endif
#define OnPlayerTakeFromContainer tut_OnPlayerTakeFromContainer
forward tut_OnPlayerTakeFromContainer(playerid, containerid, slotid);

public OnPlayerDropItem(playerid, itemid)
{
	if(TutorialState[playerid] == 5)
	{
		if(GetItemType(itemid) == item_Medkit)
		{
			ShowHelpTip(playerid, "Good, you should grab that again though, you might need it! Press F to pick up items.");
			TutorialState[playerid] = 6;
		}
	}

	return CallLocalFunction("tut_OnPlayerDropItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerDropItem
	#undef OnPlayerDropItem
#else
	#define _ALS_OnPlayerDropItem
#endif
#define OnPlayerDropItem tut_OnPlayerDropItem
forward tut_OnPlayerDropItem(playerid, itemid);

public OnPlayerPickUpItem(playerid, itemid)
{
	if(TutorialState[playerid] == 6)
	{
		if(GetItemType(itemid) == item_Medkit)
		{
			ShowHelpTip(playerid, "You can't go around carrying everything by hand! Put your current item in your inventory by pressing Y");
			TutorialState[playerid] = 7;
		}
	}

	return CallLocalFunction("tut_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem tut_OnPlayerPickUpItem
forward tut_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerAddToInventory(playerid, itemid)
{
	if(TutorialState[playerid] == 7)
	{
		ShowHelpTip(playerid, "You put it in your inventory, you can move items between your inventory and your bag, open your inventory again with H.");
		TutorialState[playerid] = 8;
	}

	return CallLocalFunction("tut_OnPlayerAddToInventory", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerAddToInventory
	#undef OnPlayerAddToInventory
#else
	#define _ALS_OnPlayerAddToInventory
#endif
#define OnPlayerAddToInventory tut_OnPlayerAddToInventory
forward tut_OnPlayerAddToInventory(playerid, itemid);

public OnPlayerViewInventoryOpt(playerid)
{
	if(TutorialState[playerid] == 9)
	{
		ShowHelpTip(playerid, "Now press the \"Move to bag\" button to remove that item from your inventory and put it in your bag.");
		TutorialState[playerid] = 10;
	}

	return CallLocalFunction("tut_OnPlayerViewInventoryOpt", "d", playerid);
}
#if defined _ALS_OnPlayerViewInventoryOpt
	#undef OnPlayerViewInventoryOpt
#else
	#define _ALS_OnPlayerViewInventoryOpt
#endif
#define OnPlayerViewInventoryOpt tut_OnPlayerViewInventoryOpt
forward OnPlayerViewInventoryOpt(playerid);

public OnPlayerAddToContainer(playerid, containerid, itemid)
{
	if(containerid == GetItemExtraData(GetPlayerBackpackItem(playerid)))
	{
		if(TutorialState[playerid] == 10)
		{
			ShowHelpTip(playerid, "This works both ways, in your bag item options \"Move to inventory\" moves an item from your bag to your inventory.");
			TutorialState[playerid] = 11;
		}
	}

	return CallLocalFunction("tut_OnPlayerAddToContainer", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerAddToContainer
	#undef OnPlayerAddToContainer
#else
	#define _ALS_OnPlayerAddToContainer
#endif
#define OnPlayerAddToContainer tut_OnPlayerAddToContainer
forward tut_OnPlayerAddToContainer(playerid, itemid);

public OnPlayerCloseContainer(playerid, containerid)
{
	if(TutorialState[playerid] == 11)
	{
		ShowHelpTip(playerid, "Great! You now know how to use your inventory and bag, you can remove your bag by pressing N and it behaves just like an item.~n~~n~This concludes the tutorial, you can access it at any time by typing /tutorial. Good luck!", 30000);
		TutorialState[playerid] = 0;
	}

	return CallLocalFunction("tut_OnPlayerCloseContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer tut_OnPlayerCloseContainer
forward OnPlayerCloseContainer(playerid, containerid);

public OnPlayerCloseInventory(playerid)
{
	if(TutorialState[playerid] == 11)
	{
		ShowHelpTip(playerid, "Great! You now know how to use your inventory and bag, you can remove your bag by pressing N and it behaves just like an item.~n~~n~This concludes the tutorial, you can access it at any time by typing /tutorial. Good luck!", 30000);
		TutorialState[playerid] = 0;
	}

	return CallLocalFunction("tut_OnPlayerCloseInventory", "d", playerid);
}
#if defined _ALS_OnPlayerCloseInventory
	#undef OnPlayerCloseInventory
#else
	#define _ALS_OnPlayerCloseInventory
#endif
#define OnPlayerCloseInventory tut_OnPlayerCloseInventory
forward OnPlayerCloseInventory(playerid);

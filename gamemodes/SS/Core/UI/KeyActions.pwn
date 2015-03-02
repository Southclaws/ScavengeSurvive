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
		else if(IsPlayerAtAnyFuelOutlet(playerid))
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Fill fuel can");
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

public OnPlayerOpenInventory(playerid)
{
	HidePlayerToolTip(playerid);

	#if defined tip_OnPlayerOpenInventory
		return tip_OnPlayerOpenInventory(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory tip_OnPlayerOpenInventory
#if defined tip_OnPlayerOpenInventory
	forward tip_OnPlayerOpenInventory(playerid);
#endif

public OnPlayerOpenContainer(playerid, containerid)
{
	HidePlayerToolTip(playerid);

	#if defined tip_OnPlayerOpenContainer
		return tip_OnPlayerOpenContainer(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer tip_OnPlayerOpenContainer
#if defined tip_OnPlayerOpenContainer
	forward tip_OnPlayerOpenContainer(playerid, containerid);
#endif

ptask ToolTipUpdate[1000](playerid)
{
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

	if(bPlayerGameSettings[playerid] & KnockedOut)
	{
		HidePlayerToolTip(playerid);
		return;		
	}

	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && bPlayerGameSettings[playerid] & ShowHUD)
	{
		if(GetPlayerWeapon(playerid) > 0)
		{
			new inplayerarea;

			ClearToolTipText(playerid);

			foreach(new i : Player)
			{
				if(IsPlayerInPlayerArea(playerid, i))
				{
					inplayerarea = i;
					break;
				}
			}

			if(GetItemTypeSize(ItemType:GetPlayerWeapon(playerid)) == ITEM_SIZE_SMALL && !IsPlayerInventoryFull(playerid))
				AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Put in inventory");

			else
				AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Holster weapon");

			if(inplayerarea > -1)
				AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Give weapon");

			else
				AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Drop weapon");

			AddToolTipText(playerid, KEYTEXT_INVENTORY, "Open inventory");
			ShowPlayerToolTip(playerid);
		}
		else
		{
			new
				itemid,
				ItemType:itemtype;

			itemid = GetPlayerItem(playerid);
			itemtype = GetItemType(itemid);

			if(IsValidItem(itemid))
			{
				new inplayerarea = -1;

				ClearToolTipText(playerid);

				foreach(new i : Player)
				{
					if(IsPlayerInPlayerArea(playerid, i))
					{
						inplayerarea = i;
						break;
					}
				}

				if(IsPlayerAtAnyVehicleBonnet(playerid))
				{
					if(itemtype == item_GasCan)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Refuel vehicle");

					else if(itemtype == item_Wrench || itemtype == item_Screwdriver || itemtype == item_Hammer)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Repair vehicle engine");

					else if(itemtype == item_Wheel)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Repair vehicle wheel");

					else
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Use item");
				}
				else if(IsPlayerAtAnyVehicleTrunk(playerid))
				{
					AddToolTipText(playerid, KEYTEXT_INTERACT, "Open Trunk");
				}
				else
				{
					if(itemtype == item_Clothes)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Wear clothes");

					else if(itemtype == item_HotDog || itemtype == item_Burger || itemtype == item_BurgerBox || itemtype == item_Pizza || itemtype == item_Taco)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Eat");

					else if(itemtype == item_Medkit)
					{
						if(inplayerarea > -1)
							AddToolTipText(playerid, KEYTEXT_INTERACT, "Heal player");
						
						else
							AddToolTipText(playerid, KEYTEXT_INTERACT, "Heal yourself");
					}

					else if(itemtype == item_timebomb)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Arm timebomb");

					else if(itemtype == item_Beer)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Drink");

					else if(itemtype == item_Sign)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Place sign");

					else if(itemtype == item_Shield)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Place shield");

					else if(itemtype == item_Flashlight)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Turn on/off");

					else if(itemtype == item_HandCuffs)
					{
						if(inplayerarea > -1)
							AddToolTipText(playerid, KEYTEXT_INTERACT, "HandCuff player");
					}

					else if(itemtype == item_Briefcase)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Open briefcase");

					else if(itemtype == item_Satchel)
					{
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Open satchel");
						AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Wear");
					}

					else if(itemtype == item_Backpack)
					{
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Open backpack");
						AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Wear");
					}

					else if(itemtype == item_GasCan)
					{
						if(IsPlayerAtAnyFuelOutlet(playerid))
							AddToolTipText(playerid, KEYTEXT_INTERACT, "Fill fuel can");
					}

					else
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Use item");
				}

				if(GetItemTypeSize(itemtype) == ITEM_SIZE_SMALL)
					AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Put away");

				if(inplayerarea > -1)
					AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Give item");

				else
					AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Drop item");

				AddToolTipText(playerid, KEYTEXT_INVENTORY, "Open inventory");
				ShowPlayerToolTip(playerid);
			}
			else
			{
				ClearToolTipText(playerid);

				new inplayerarea;

				foreach(new i : Player)
				{
					if(IsPlayerInPlayerArea(playerid, i))
					{
						inplayerarea = i;
						break;
					}
				}

				if(IsPlayerHandcuffed(inplayerarea))
				{
					AddToolTipText(playerid, KEYTEXT_INTERACT, "Remove handcuffs");
					ShowPlayerToolTip(playerid);
				}

				AddToolTipText(playerid, KEYTEXT_INVENTORY, "Open inventory");
				ShowPlayerToolTip(playerid);
			}
		}
	}
	else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		ClearToolTipText(playerid);
		AddToolTipText(playerid, KEYTEXT_ENGINE, "Toggle engine");
		AddToolTipText(playerid, KEYTEXT_LIGHTS, "Toggle lights");
		ShowPlayerToolTip(playerid);
	}
	else
	{
		HidePlayerToolTip(playerid);
	}

	return;
}

public OnPlayerOpenInventory(playerid)
{
	HidePlayerToolTip(playerid);

	return CallLocalFunction("tip_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory tip_OnPlayerOpenInventory
forward tip_OnPlayerOpenInventory(playerid);

public OnPlayerOpenContainer(playerid, containerid)
{
	HidePlayerToolTip(playerid);

	return CallLocalFunction("tip_OnPlayerOpenContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer tip_OnPlayerOpenContainer
forward tip_OnPlayerOpenContainer(playerid, containerid);

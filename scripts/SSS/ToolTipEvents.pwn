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

	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
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

					else if(itemtype == item_HealthRegen)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Take adrenaline");

					else if(itemtype == item_Shield)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Place shield");

					else if(itemtype == item_Flashlight)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Turn on/off");

					else if(itemtype == item_HandCuffs)
					{
						if(inplayerarea > -1)
							AddToolTipText(playerid, KEYTEXT_INTERACT, "HandCuff player");
					}

					else if(itemtype == item_Flag)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Place flag");

					else if(itemtype == item_Briefcase)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Open briefcase");

					else if(itemtype == item_Satchel)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Open satchel");

					else if(itemtype == item_Backpack)
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Open backpack");

					if(itemtype == item_GasCan)
					{
						if(IsPlayerAtAnyFuelOutlet(playerid))
							AddToolTipText(playerid, KEYTEXT_INTERACT, "Fill fuel can");
					}

					else
						AddToolTipText(playerid, KEYTEXT_INTERACT, "Use item");
				}

				if(GetItemTypeSize(itemtype) == ITEM_SIZE_SMALL)
					AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Put in inventory");

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




#endinput 


item_Medkit			
item_HardDrive		
item_Key			
item_FireworkBox	
item_FireLighter	
item_timer			
item_explosive		
item_timebomb		
item_battery		
item_fusebox		
item_Beer			
item_Sign			
item_HealthRegen	
item_ArmourRegen	
item_FishRod		
item_Wrench			
item_Crowbar		
item_Hammer			
item_Shield			
item_Flashlight		
item_Taser			
item_LaserPoint		
item_Screwdriver	
item_MobilePhone	
item_Pager			
item_Rake			
item_HotDog			
item_EasterEgg		
item_Cane			
item_HandCuffs		
item_Bucket			
item_GasMask		
item_Flag			
item_Briefcase		
item_Backpack		
item_Satchel		
item_Wheel			
item_Canister1		
item_Canister2		
item_Canister3		
item_MotionSense	
item_CapCase		
item_CapMineBad		
item_CapMine		
item_Pizza			
item_Burger			
item_BurgerBox		
item_Taco			
item_GasCan			
item_Clothes		

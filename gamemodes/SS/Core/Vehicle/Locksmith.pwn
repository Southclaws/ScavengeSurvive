#include <YSI\y_hooks>


static lsk_TargetVehicle[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	lsk_TargetVehicle[playerid] = INVALID_VEHICLE_ID;
}

public OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	if(225.0 < angle < 315.0)
	{
		new
			itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);
		
		if(itemtype == item_LocksmithKit)
		{
			CancelPlayerMovement(playerid);
			StartCraftingKey(playerid, vehicleid);
		}

		if(itemtype == item_Key)
		{
			new
				extradata = GetItemExtraData(itemid),
				vehiclekey = GetVehicleKey(vehicleid);

			if(extradata == 0)
			{
				ShowActionText(playerid, "That key hasn't been cut yet.", 3000);
				return 1;
			}

			if(vehiclekey == 0)
			{
				ShowActionText(playerid, "That vehicle lock hasn't been set up for a key yet. Use a Locksmith Kit to set it up.", 3000);
				return 1;
			}

			if(extradata != vehiclekey)
			{
				ShowActionText(playerid, "That key doesn't fit this vehicle", 3000);
				return 1;
			}

			CancelPlayerMovement(playerid);

			if(IsVehicleLocked(vehicleid))
			{
				SetVehicleExternalLock(vehicleid, 0);
				ShowActionText(playerid, "Unlocked", 3000);
			}
			else
			{
				SetVehicleExternalLock(vehicleid, 1);
				ShowActionText(playerid, "Locked", 3000);
			}
		}
	}

	return CallLocalFunction("lsk_OnPlayerInteractVehicle", "ddf", playerid, vehicleid, Float:angle);
}
#if defined _ALS_OnPlayerInteractVehicle
	#undef OnPlayerInteractVehicle
#else
	#define _ALS_OnPlayerInteractVehicle
#endif
#define OnPlayerInteractVehicle lsk_OnPlayerInteractVehicle
forward lsk_OnPlayerInteractVehicle(playerid, vehicleid, Float:angle);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		StopCraftingKey(playerid);
	}
}

StartCraftingKey(playerid, vehicleid)
{
	lsk_TargetVehicle[playerid] = vehicleid;
	ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

	StartHoldAction(playerid, 3000);

	return 0;
}

StopCraftingKey(playerid)
{
	if(lsk_TargetVehicle[playerid] == INVALID_VEHICLE_ID)
		return 0;

	ClearAnimations(playerid);
	StopHoldAction(playerid);

	lsk_TargetVehicle[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

public OnHoldActionUpdate(playerid, progress)
{
	if(lsk_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(!IsValidVehicleID(lsk_TargetVehicle[playerid]) || GetItemType(GetPlayerItem(playerid)) != item_LocksmithKit || !IsPlayerInVehicleArea(playerid, lsk_TargetVehicle[playerid]))
		{
			StopCraftingKey(playerid);
			return 1;
		}

		SetPlayerToFaceVehicle(playerid, lsk_TargetVehicle[playerid]);

		return 1;
	}

	return CallLocalFunction("lsk_OnHoldActionUpdate", "dd", playerid, progress);
}

public OnHoldActionFinish(playerid)
{
	if(lsk_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		new
			itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		if(itemtype == item_LocksmithKit)
		{
			new key = 1 + random(2147483646);

			DestroyItem(itemid);
			itemid = CreateItem(item_Key);
			GiveWorldItemToPlayer(playerid, itemid);

			SetItemExtraData(itemid, key);
			SetVehicleKey(lsk_TargetVehicle[playerid], key);
		}

		StopCraftingKey(playerid);			

		return 1;
	}

	return CallLocalFunction("lsk_OnHoldActionFinish", "d", playerid);
}


// Hooks


#if defined _ALS_OnHoldActionUpdate
	#undef OnHoldActionUpdate
#else
	#define _ALS_OnHoldActionUpdate
#endif
#define OnHoldActionUpdate lsk_OnHoldActionUpdate
forward lsk_OnHoldActionUpdate(playerid, progress);


#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish lsk_OnHoldActionFinish
forward lsk_OnHoldActionFinish(playerid);

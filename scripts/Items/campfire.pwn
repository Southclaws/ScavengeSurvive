public OnPlayerPickedUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Campfire)
	{
		defer AttachWoodLogs(playerid);
	}

	return CallLocalFunction("cmp_OnPlayerPickedUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickedUpItem
	#undef OnPlayerPickedUpItem
#else
	#define _ALS_OnPlayerPickedUpItem
#endif
#define OnPlayerPickedUpItem cmp_OnPlayerPickedUpItem
forward cmp_OnPlayerPickedUpItem(playerid, itemid);

timer AttachWoodLogs[0](playerid)
{
	SetPlayerAttachedObject(playerid, ITM_ATTACH_INDEX, 1463, 6, 0.023999, 0.027236, -0.204656, 251.243942, 356.352508, 73.549652, 0.384758, 0.200000, 0.200000);
}

public OnPlayerDroppedItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Campfire)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:rz;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, rz);
		DestroyItem(itemid);
		CreateCampfire(x + (0.5 * floatsin(-rz, degrees)), y + (0.5 * floatcos(-rz, degrees)), z - FLOOR_OFFSET, rz);

		return 1;
	}

	return CallLocalFunction("cmp_OnPlayerDroppedItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerDroppedItem
	#undef OnPlayerDroppedItem
#else
	#define _ALS_OnPlayerDroppedItem
#endif
#define OnPlayerDroppedItem cmp_OnPlayerDroppedItem
forward cmp_OnPlayerDroppedItem(playerid, itemid);


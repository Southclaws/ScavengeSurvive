public OnItemCreateInWorld(itemid)
{
	if(GetItemType(itemid) == item_Campfire)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:rz;

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rz, rz, rz);
		SetItemExtraData(itemid, CreateCampfire(x, y, z, rz, GetItemWorld(itemid), GetItemInterior(itemid)));
	}

	#if defined cmp_OnItemCreateInWorld
		return cmp_OnItemCreateInWorld(itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemCreateInWorld
	#undef OnItemCreateInWorld
#else
	#define _ALS_OnItemCreateInWorld
#endif
#define OnItemCreateInWorld cmp_OnItemCreateInWorld
#if defined cmp_OnItemCreateInWorld
	forward cmp_OnItemCreateInWorld(itemid);
#endif

public OnPlayerPickedUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Campfire)
	{
		DestroyCampfire(GetItemExtraData(itemid));
		defer AttachWoodLogs(playerid);
	}

	#if defined cmp_OnPlayerPickedUpItem
		return cmp_OnPlayerPickedUpItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerPickedUpItem
	#undef OnPlayerPickedUpItem
#else
	#define _ALS_OnPlayerPickedUpItem
#endif
#define OnPlayerPickedUpItem cmp_OnPlayerPickedUpItem
#if defined cmp_OnPlayerPickedUpItem
	forward cmp_OnPlayerPickedUpItem(playerid, itemid);
#endif

public OnPlayerGivenItem(playerid, targetid, itemid)
{
	if(GetItemType(itemid) == item_Campfire)
	{
		defer AttachWoodLogs(targetid);
	}

	#if defined cmp_OnPlayerGivenItem
		return cmp_OnPlayerGivenItem(playerid, targetid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerGivenItem
	#undef OnPlayerGivenItem
#else
	#define _ALS_OnPlayerGivenItem
#endif
#define OnPlayerGivenItem cmp_OnPlayerGivenItem
#if defined cmp_OnPlayerGivenItem
	forward cmp_OnPlayerGivenItem(playerid, targetid, itemid);
#endif

timer AttachWoodLogs[0](playerid)
{
	SetPlayerAttachedObject(playerid, ITM_ATTACH_INDEX, 1463, 6, 0.023999, 0.027236, -0.204656, 251.243942, 356.352508, 73.549652, 0.384758, 0.200000, 0.200000);		
}

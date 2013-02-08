new ItemType:item_Flashlight	= INVALID_ITEM_TYPE;


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Flashlight)
	{
		if(IsPlayerAttachedObjectSlotUsed(playerid, ATTACHSLOT_TORCH))
			RemovePlayerAttachedObject(playerid, ATTACHSLOT_TORCH);

		else
			SetPlayerAttachedObject(playerid, ATTACHSLOT_TORCH, 18656, 6, 0.060849, 0.056308, 0.081048, 101.173759, 0.000000, 0.000000, 0.039999, 0.039999, 0.050000);
	}
	return CallLocalFunction("lite_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem lite_OnPlayerUseItem
forward lite_OnPlayerUseItem(playerid, itemid);

public OnItemRemovedFromPlayer(playerid, itemid)
{
	if(GetItemType(itemid) == item_Flashlight)
		RemovePlayerAttachedObject(playerid, ATTACHSLOT_TORCH);

	return CallLocalFunction("lite_OnItemRemovedFromPlayer", "dd", playerid, itemid);
}
#if defined _ALS_OnItemRemovedFromPlayer
	#undef OnItemRemovedFromPlayer
#else
	#define _ALS_OnItemRemovedFromPlayer
#endif
#define OnItemRemovedFromPlayer lite_OnItemRemovedFromPlayer
forward lite_OnItemRemovedFromPlayer(playerid, itemid);

public OnPlayerDropItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Flashlight)
		RemovePlayerAttachedObject(playerid, ATTACHSLOT_TORCH);

	return CallLocalFunction("lite_OnPlayerDropItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerDropItem
	#undef OnPlayerDropItem
#else
	#define _ALS_OnPlayerDropItem
#endif
#define OnPlayerDropItem lite_OnPlayerDropItem
forward lite_OnPlayerDropItem(playerid, itemid);

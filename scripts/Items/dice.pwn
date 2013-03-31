public OnPlayerDroppedItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Dice)
	{
		defer RotateDice(itemid);
	}

	return CallLocalFunction("die_OnPlayerDroppedItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerDroppedItem
	#undef OnPlayerDroppedItem
#else
	#define _ALS_OnPlayerDroppedItem
#endif
#define OnPlayerDroppedItem die_OnPlayerDroppedItem
forward die_OnPlayerDroppedItem(playerid, itemid);

timer RotateDice[50](itemid)
{
	SetItemRot(itemid, random(4) * 90.0, random(4) * 90.0, random(360) * 1.0);
}

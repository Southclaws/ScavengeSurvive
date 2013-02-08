new ItemType:item_Briefcase = INVALID_ITEM_TYPE;


public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_Briefcase)
	{
		SetItemExtraData(itemid, CreateContainer("Briefcase", 6, .virtual = 1));
	}

	return CallLocalFunction("case_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate case_OnItemCreate
forward case_OnItemCreate(itemid);

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Briefcase)
	{
		DisplayContainerInventory(playerid, GetItemExtraData(itemid));
	}
	return CallLocalFunction("case_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem case_OnPlayerUseItem
forward case_OnPlayerUseItem(playerid, itemid);

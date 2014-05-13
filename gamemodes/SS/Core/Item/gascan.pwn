public OnItemCreate(itemid)
{
	if(IsItemLoot(itemid))
	{
		if(GetItemType(itemid) == item_GasCan)
		{
			SetItemExtraData(itemid, random(10));
		}
	}

	#if defined gas_OnItemCreate
		return gas_OnItemCreate(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate gas_OnItemCreate
#if defined gas_OnItemCreate
	forward gas_OnItemCreate(itemid);
#endif

public OnItemNameRender(itemid)
{
	if(GetItemType(itemid) == item_GasCan)
	{
		new str[4];
		valstr(str, GetItemExtraData(itemid));
		strcat(str, "L");
		SetItemNameExtra(itemid, str);
	}

	return CallLocalFunction("gas_OnItemNameRender", "d", itemid);
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender gas_OnItemNameRender
forward gas_OnItemNameRender(itemid);

#define MAX_TNT_PROXIMITY	(1024)


enum E_TNT_PROX_DATA
{
			tntpx_areaId,
			tntpx_itemId
}


new
			tntpx_Data[MAX_TNT_PROXIMITY][E_TNT_PROX_DATA],
Iterator:	tntpx_Index<MAX_TNT_PROXIMITY>;


/*==============================================================================

	Core

==============================================================================*/


timer CreateTntMineProx[5000](itemid)
{
	if(IsItemInWorld(itemid) != 1)
		return -1;

	new
		id,
		Float:x,
		Float:y,
		Float:z;

	id = Iter_Free(tntpx_Index);
	GetItemPos(itemid, x, y, z);

	tntpx_Data[id][tntpx_areaId] = CreateDynamicSphere(x, y, z, 5.0);
	tntpx_Data[id][tntpx_itemId] = itemid;

	Iter_Add(tntpx_Index, id);

	return id;
}

timer ExplodeTntProxMineDelay[1000](id)
{
	if(!Iter_Contains(tntpx_Index, id))
		return;

	SetItemToExplode(tntpx_Data[id][tntpx_itemId], 10, 12.0, EXPLOSION_PRESET_STRUCTURAL, 2);
	DestroyDynamicArea(tntpx_Data[id][tntpx_areaId]);

	Iter_Remove(tntpx_Index, id);

	return;
}

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TntProxMine)
	{
		PlayerDropItem(playerid);
		SetItemExtraData(itemid, 1);
	}
	return CallLocalFunction("tntpx_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem tntpx_OnPlayerUseItem
forward tntpx_OnPlayerUseItem(playerid, itemid);

public OnPlayerDroppedItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TntProxMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			defer CreateTntMineProx(itemid);
			Msg(playerid, YELLOW, " >  Proximity Mine Primed");
		}
	}
	return CallLocalFunction("tntpx_OnPlayerDroppedItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerDroppedItem
	#undef OnPlayerDroppedItem
#else
	#define _ALS_OnPlayerDroppedItem
#endif
#define OnPlayerDroppedItem tntpx_OnPlayerDroppedItem
forward tntpx_OnPlayerDroppedItem(playerid, itemid);

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : tntpx_Index)
	{
		if(areaid == tntpx_Data[i][tntpx_areaId])
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(tntpx_Data[i][tntpx_itemId], x, y, z);

			PlaySoundForAll(6400, x, y, z);
			defer ExplodeTntProxMineDelay(i);
		}
	}

	return CallLocalFunction("tntpx_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea tntpx_OnPlayerEnterDynamicArea
forward tntpx_OnPlayerEnterDynamicArea(playerid, areaid);

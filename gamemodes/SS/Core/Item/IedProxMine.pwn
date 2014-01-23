#define MAX_IED_PROXIMITY	(1024)


enum E_IED_PROX_DATA
{
			iedpx_areaId,
			iedpx_itemId
}


new
			iedpx_Data[MAX_IED_PROXIMITY][E_IED_PROX_DATA],
Iterator:	iedpx_Index<MAX_IED_PROXIMITY>;


/*==============================================================================

	Core

==============================================================================*/


timer CreateIedMineProx[5000](itemid)
{
	if(IsItemInWorld(itemid) != 1)
		return -1;

	new
		id,
		Float:x,
		Float:y,
		Float:z;

	id = Iter_Free(iedpx_Index);
	GetItemPos(itemid, x, y, z);

	iedpx_Data[id][iedpx_areaId] = CreateDynamicSphere(x, y, z, 5.0);
	iedpx_Data[id][iedpx_itemId] = itemid;

	Iter_Add(iedpx_Index, id);

	return id;
}

timer ExplodeIedProxMineDelay[1000](id)
{
	if(!Iter_Contains(iedpx_Index, id))
		return;

	SetItemToExplode(iedpx_Data[id][iedpx_itemId], 11, 8.0, EXPLOSION_PRESET_STRUCTURAL, 1);
	DestroyDynamicArea(iedpx_Data[id][iedpx_areaId]);

	Iter_Remove(iedpx_Index, id);

	return;
}

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_IedProxMine)
	{
		PlayerDropItem(playerid);
		SetItemExtraData(itemid, 1);
	}
	return CallLocalFunction("iedpx_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem iedpx_OnPlayerUseItem
forward iedpx_OnPlayerUseItem(playerid, itemid);

public OnPlayerDroppedItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_IedProxMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			defer CreateIedMineProx(itemid);
			Msg(playerid, YELLOW, " >  Proximity Mine Primed");
		}
	}
	return CallLocalFunction("iedpx_OnPlayerDroppedItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerDroppedItem
	#undef OnPlayerDroppedItem
#else
	#define _ALS_OnPlayerDroppedItem
#endif
#define OnPlayerDroppedItem iedpx_OnPlayerDroppedItem
forward iedpx_OnPlayerDroppedItem(playerid, itemid);

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : iedpx_Index)
	{
		if(areaid == iedpx_Data[i][iedpx_areaId])
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(iedpx_Data[i][iedpx_itemId], x, y, z);

			PlaySoundForAll(6400, x, y, z);
			defer ExplodeIedProxMineDelay(i);
		}
	}

	return CallLocalFunction("iedpx_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea iedpx_OnPlayerEnterDynamicArea
forward iedpx_OnPlayerEnterDynamicArea(playerid, areaid);

#define MAX_EMP_PROXIMITY	(1024)


enum E_EMP_PROX_DATA
{
			emppx_areaId,
			emppx_itemId
}


new
			emppx_Data[MAX_EMP_PROXIMITY][E_EMP_PROX_DATA],
Iterator:	emppx_Index<MAX_EMP_PROXIMITY>;


/*==============================================================================

	Core

==============================================================================*/


timer CreateEmpMineProx[5000](itemid)
{
	if(IsItemInWorld(itemid) != 1)
		return -1;

	new
		id,
		Float:x,
		Float:y,
		Float:z;

	id = Iter_Free(emppx_Index);
	GetItemPos(itemid, x, y, z);

	emppx_Data[id][emppx_areaId] = CreateDynamicSphere(x, y, z, 5.0);
	emppx_Data[id][emppx_itemId] = itemid;

	Iter_Add(emppx_Index, id);

	return id;
}

timer ExplodeEmpProxMineDelay[1000](id)
{
	if(!Iter_Contains(emppx_Index, id))
		return;

	SetItemToExplode(emppx_Data[id][emppx_itemId], 0, 12.0, EXPLOSION_PRESET_EMP, 0);
	DestroyDynamicArea(emppx_Data[id][emppx_areaId]);

	Iter_Remove(emppx_Index, id);

	return;
}

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_EmpProxMine)
	{
		PlayerDropItem(playerid);
		SetItemExtraData(itemid, 1);
	}
	return CallLocalFunction("emppx_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem emppx_OnPlayerUseItem
forward emppx_OnPlayerUseItem(playerid, itemid);

public OnPlayerDroppedItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_EmpProxMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			defer CreateEmpMineProx(itemid);
			Msg(playerid, YELLOW, " >  Proximity Mine Primed");
		}
	}
	return CallLocalFunction("emppx_OnPlayerDroppedItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerDroppedItem
	#undef OnPlayerDroppedItem
#else
	#define _ALS_OnPlayerDroppedItem
#endif
#define OnPlayerDroppedItem emppx_OnPlayerDroppedItem
forward emppx_OnPlayerDroppedItem(playerid, itemid);

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : emppx_Index)
	{
		if(areaid == emppx_Data[i][emppx_areaId])
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(emppx_Data[i][emppx_itemId], x, y, z);

			PlaySoundForAll(6400, x, y, z);
			defer ExplodeEmpProxMineDelay(i);
		}
	}

	return CallLocalFunction("emppx_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea emppx_OnPlayerEnterDynamicArea
forward emppx_OnPlayerEnterDynamicArea(playerid, areaid);

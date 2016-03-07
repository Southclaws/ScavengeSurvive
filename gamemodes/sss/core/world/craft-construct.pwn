enum E_CONSTRUCT_SET_DATA
{
ItemType:	cons_tool,
			cons_buildtime,
			cons_craftset
}


static
			cons_Data[CFT_MAX_CRAFT_SET][E_CONSTRUCT_SET_DATA],
bool:		cons_ConstructibleCraftSet[CFT_MAX_CRAFT_SET];


stock SetCraftSetConstructible(ItemType:tool, buildtime, craftset)
{
	if(GetCraftSetResult(craftset) == INVALID_ITEM_TYPE)
	{
		print("[SetCraftSetConstructible] ERROR: Invalid craftset.");
		return -1;
	}

	cons_Data[craftset][cons_tool] = tool;
	cons_Data[craftset][cons_buildtime] = buildtime;
	cons_Data[craftset][cons_craftset] = craftset;

	cons_ConstructibleCraftSet[craftset] = true;

	return craftset;
}

public OnPlayerCraft(playerid, craftset)
{
	if(cons_ConstructibleCraftSet[craftset])
		return 1;

	#if defined cons_OnPlayerCraft
		return cons_OnPlayerCraft(playerid, craftset);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerCraft
	#undef OnPlayerCraft
#else
	#define _ALS_OnPlayerCraft
#endif
#define OnPlayerCraft cons_OnPlayerCraft
#if defined cons_OnPlayerCraft
	forward cons_OnPlayerCraft(playerid, craftset);
#endif

public OnPlayerUseItem(playerid, itemid)
{
	// GetPlayerButtonList
	// _cft_AddItemToCraftList(playerid, );
	// _cft_ClearCraftList(playerid);
	// _cft_CraftSelected(playerid, craftset);
	// _cft_CompareSelected(playerid)
	// _cft_CompareListToCraftSet(playerid, craftset)

	#if defined cons_OnPlayerUseItem
		return cons_OnPlayerUseItem(playerid, itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
 
#define OnPlayerUseItem cons_OnPlayerUseItem
#if defined cons_OnPlayerUseItem
	forward cons_OnPlayerUseItem(playerid, itemid);
#endif

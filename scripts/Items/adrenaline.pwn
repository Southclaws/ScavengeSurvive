#define REGEN_HP_TIME (60000)

new
	ItemType:item_HealthRegen = INVALID_ITEM_TYPE;

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_HealthRegen)
	{
		t:bPlayerGameSettings[playerid]<RegenHP>;
		tick_StartRegenHP[playerid] = tickcount();
		DestroyItem(itemid);
	}
	return CallLocalFunction("adr_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem adr_OnPlayerUseItem
forward adr_OnPlayerUseItem(playerid, itemid);


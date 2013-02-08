#define REGEN_AP_TIME (120000)

new
	ItemType:item_ArmourRegen = INVALID_ITEM_TYPE;

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_ArmourRegen)
	{
		t:bPlayerGameSettings[playerid]<RegenAP>;
		tick_StartRegenAP[playerid] = tickcount();
		DestroyItem(itemid);
	}
    return CallLocalFunction("eap_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem eap_OnPlayerUseItem
forward eap_OnPlayerUseItem(playerid, itemid);


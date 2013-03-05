public OnPlayerPickUpItem(playerid, itemid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[playerid] & AdminDuty || bPlayerGameSettings[playerid] & KnockedOut)
		return 1;

	return CallLocalFunction("cuf_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem cuf_OnPlayerPickUpItem
forward cuf_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerGiveItem(playerid, targetid, itemid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[playerid] & AdminDuty || bPlayerGameSettings[playerid] & KnockedOut)
		return 1;

	return CallLocalFunction("cuf_OnPlayerGiveItem", "ddd", playerid, targetid, itemid);
}
#if defined _ALS_OnPlayerGiveItem
	#undef OnPlayerGiveItem
#else
	#define _ALS_OnPlayerGiveItem
#endif
#define OnPlayerGiveItem cuf_OnPlayerGiveItem
forward cuf_OnPlayerGiveItem(playerid, targetid, itemid);

public OnPlayerTakeFromContainer(playerid, containerid, slotid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[playerid] & AdminDuty || bPlayerGameSettings[playerid] & KnockedOut)
		return 1;

	return CallLocalFunction("cuf_OnPlayerTakeFromContainer", "ddd", playerid, containerid, slotid);
}
#if defined _ALS_OnPlayerTakeFromContainer
	#undef OnPlayerTakeFromContainer
#else
	#define _ALS_OnPlayerTakeFromContainer
#endif
#define OnPlayerTakeFromContainer cuf_OnPlayerTakeFromContainer
forward cuf_OnPlayerTakeFromContainer(playerid, containerid, slotid);

public OnPlayerOpenInventory(playerid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[playerid] & AdminDuty || bPlayerGameSettings[playerid] & KnockedOut)
		return 1;

	return CallLocalFunction("cuf_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory cuf_OnPlayerOpenInventory
forward cuf_OnPlayerOpenInventory(playerid);

public OnPlayerOpenContainer(playerid, containerid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[playerid] & AdminDuty || bPlayerGameSettings[playerid] & KnockedOut)
		return 1;

	return CallLocalFunction("cuf_OnPlayerOpenContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer cuf_OnPlayerOpenContainer
forward cuf_OnPlayerOpenContainer(playerid, containerid);

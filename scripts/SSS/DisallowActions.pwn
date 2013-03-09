public OnPlayerPickUpItem(playerid, itemid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[playerid] & AdminDuty || bPlayerGameSettings[playerid] & KnockedOut)
		return 1;

	return CallLocalFunction("dis_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem dis_OnPlayerPickUpItem
forward dis_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerGiveItem(playerid, targetid, itemid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[playerid] & AdminDuty || bPlayerGameSettings[playerid] & KnockedOut)
		return 1;

	return CallLocalFunction("dis_OnPlayerGiveItem", "ddd", playerid, targetid, itemid);
}
#if defined _ALS_OnPlayerGiveItem
	#undef OnPlayerGiveItem
#else
	#define _ALS_OnPlayerGiveItem
#endif
#define OnPlayerGiveItem dis_OnPlayerGiveItem
forward dis_OnPlayerGiveItem(playerid, targetid, itemid);

public OnPlayerTakeFromContainer(playerid, containerid, slotid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[playerid] & AdminDuty || bPlayerGameSettings[playerid] & KnockedOut)
		return 1;

	return CallLocalFunction("dis_OnPlayerTakeFromContainer", "ddd", playerid, containerid, slotid);
}
#if defined _ALS_OnPlayerTakeFromContainer
	#undef OnPlayerTakeFromContainer
#else
	#define _ALS_OnPlayerTakeFromContainer
#endif
#define OnPlayerTakeFromContainer dis_OnPlayerTakeFromContainer
forward dis_OnPlayerTakeFromContainer(playerid, containerid, slotid);

public OnPlayerOpenInventory(playerid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[playerid] & AdminDuty || bPlayerGameSettings[playerid] & KnockedOut)
		return 1;

	return CallLocalFunction("dis_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory dis_OnPlayerOpenInventory
forward dis_OnPlayerOpenInventory(playerid);

public OnPlayerOpenContainer(playerid, containerid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[playerid] & AdminDuty || bPlayerGameSettings[playerid] & KnockedOut)
		return 1;

	return CallLocalFunction("dis_OnPlayerOpenContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer dis_OnPlayerOpenContainer
forward dis_OnPlayerOpenContainer(playerid, containerid);

public OnPlayerUseItem(playerid, itemid)
{
	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return 1;

	return CallLocalFunction("dis_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem dis_OnPlayerUseItem
forward dis_OnPlayerUseItem(playerid, itemid);

public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == ItemType:0)
		return 1;

	return CallLocalFunction("dis_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate dis_OnItemCreate
forward dis_OnItemCreate(itemid);


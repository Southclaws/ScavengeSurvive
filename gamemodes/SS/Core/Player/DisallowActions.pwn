#define IsBadInteract(%0) GetPlayerSpecialAction(%0) == SPECIAL_ACTION_CUFFED || GetPlayerDataBitmask(%0) & AdminDuty || GetPlayerDataBitmask(%0) & KnockedOut || GetPlayerAnimationIndex(%0) == 1381

public OnPlayerPickUpItem(playerid, itemid)
{
	if(IsBadInteract(playerid))
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
	if(IsBadInteract(playerid))
		return 1;

	if(IsBadInteract(targetid) || gPlayerData[playerid][ply_SpectateTarget] != INVALID_PLAYER_ID)
		return 1;

	if(GetPlayerWeapon(targetid) != 0)
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

public OnItemRemoveFromContainer(containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(IsBadInteract(playerid))
			return 1;
	}

	return CallLocalFunction("dis_OnItemRemoveFromContainer", "ddd", containerid, slotid, playerid);
}
#if defined _ALS_OnItemRemoveFromContainer
	#undef OnItemRemoveFromContainer
#else
	#define _ALS_OnItemRemoveFromContainer
#endif
#define OnItemRemoveFromContainer dis_OnItemRemoveFromContainer
forward dis_OnItemRemoveFromContainer(containerid, slotid, playerid);

public OnPlayerOpenInventory(playerid)
{
	if(IsBadInteract(playerid))
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
	if(IsBadInteract(playerid))
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
	if(IsBadInteract(playerid))
		return 1;

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


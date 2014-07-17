#define IsBadInteract(%0) GetPlayerSpecialAction(%0) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(%0) || IsPlayerKnockedOut(%0) || GetPlayerAnimationIndex(%0) == 1381

public OnPlayerPickUpItem(playerid, itemid)
{
	if(IsBadInteract(playerid))
		return 1;

	#if defined dis_OnPlayerPickUpItem
		return dis_OnPlayerPickUpItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem dis_OnPlayerPickUpItem
#if defined dis_OnPlayerPickUpItem
	forward dis_OnPlayerPickUpItem(playerid, itemid);
#endif

public OnPlayerGiveItem(playerid, targetid, itemid)
{
	if(IsBadInteract(playerid))
		return 1;

	if(IsBadInteract(targetid) || GetPlayerSpectateTarget(playerid) != INVALID_PLAYER_ID)
		return 1;

	if(GetPlayerWeapon(targetid) != 0)
		return 1;

	#if defined dis_OnPlayerGiveItem
		return dis_OnPlayerGiveItem(playerid, targetid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerGiveItem
	#undef OnPlayerGiveItem
#else
	#define _ALS_OnPlayerGiveItem
#endif
#define OnPlayerGiveItem dis_OnPlayerGiveItem
#if defined dis_OnPlayerGiveItem
	forward dis_OnPlayerGiveItem(playerid, targetid, itemid);
#endif

public OnItemRemoveFromContainer(containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(IsBadInteract(playerid))
			return 1;
	}

	#if defined dis_OnItemRemoveFromContainer
		return dis_OnItemRemoveFromContainer(containerid, slotid, playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemRemoveFromContainer
	#undef OnItemRemoveFromContainer
#else
	#define _ALS_OnItemRemoveFromContainer
#endif
#define OnItemRemoveFromContainer dis_OnItemRemoveFromContainer
#if defined dis_OnItemRemoveFromContainer
	forward dis_OnItemRemoveFromContainer(containerid, slotid, playerid);
#endif

public OnPlayerOpenInventory(playerid)
{
	if(IsBadInteract(playerid))
		return 1;

	#if defined dis_OnPlayerOpenInventory
		return dis_OnPlayerOpenInventory(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory dis_OnPlayerOpenInventory
#if defined dis_OnPlayerOpenInventory
	forward dis_OnPlayerOpenInventory(playerid);
#endif

public OnPlayerOpenContainer(playerid, containerid)
{
	if(IsBadInteract(playerid))
		return 1;

	#if defined dis_OnPlayerOpenContainer
		return dis_OnPlayerOpenContainer(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer dis_OnPlayerOpenContainer
#if defined dis_OnPlayerOpenContainer
	forward dis_OnPlayerOpenContainer(playerid, containerid);
#endif

public OnPlayerUseItem(playerid, itemid)
{
	if(IsBadInteract(playerid))
		return 1;

	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return 1;

	#if defined dis_OnPlayerUseItem
		return dis_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem dis_OnPlayerUseItem
#if defined dis_OnPlayerUseItem
	forward dis_OnPlayerUseItem(playerid, itemid);
#endif

public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == ItemType:0)
		return 1;

	#if defined dis_OnItemCreate
		return dis_OnItemCreate(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate dis_OnItemCreate
#if defined dis_OnItemCreate
	forward dis_OnItemCreate(itemid);
#endif

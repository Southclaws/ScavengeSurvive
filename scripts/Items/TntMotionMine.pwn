new motm_ContainerOption[MAX_PLAYERS];


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TntMotionMine)
	{
		PlayerDropItem(playerid);
		SetItemExtraData(itemid, 1);
		Msg(playerid, YELLOW, " >  Mine primed");
		return 1;
	}
	return CallLocalFunction("motm_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem motm_OnPlayerUseItem
forward motm_OnPlayerUseItem(playerid, itemid);

public OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TntMotionMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(itemid, x, y, z);
			CreateStructuralExplosion(x, y, z, 1, 12.0, 2);

			DestroyItem(itemid);

			return 1;
		}
	}
	return CallLocalFunction("motm_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem motm_OnPlayerPickUpItem
forward motm_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerOpenContainer(playerid, containerid)
{
	new itemid;
	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		itemid = GetContainerSlotItem(containerid, i);

		if(GetItemType(itemid) == item_TntMotionMine)
		{
			if(GetItemExtraData(itemid) == 1)
			{
				new
					Float:x,
					Float:y,
					Float:z;

				GetPlayerPos(playerid, x, y, z);
				CreateStructuralExplosion(x, y, z, 1, 12.0);
				RemoveItemFromContainer(containerid, i);
				DestroyItem(itemid);
			}
		}
	}

	return CallLocalFunction("motm_OnPlayerOpenContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer motm_OnPlayerOpenContainer
forward motm_OnPlayerOpenContainer(playerid, containerid);

public OnPlayerViewContainerOpt(playerid, containerid)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_TntMotionMine)
	{
		if(GetItemExtraData(itemid) == 0)
			motm_ContainerOption[playerid] = AddContainerOption(playerid, "Arm Motion Mine");

		else
			motm_ContainerOption[playerid] = AddContainerOption(playerid, "Disarm Motion Mine");
	}

	return CallLocalFunction("motm_OnPlayerViewContainerOpt", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt motm_OnPlayerViewContainerOpt
forward motm_OnPlayerViewContainerOpt(playerid, containerid);

public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_TntMotionMine)
	{
		if(option == motm_ContainerOption[playerid])
		{
			if(GetItemExtraData(itemid) == 0)
			{
				DisplayContainerInventory(playerid, containerid);
				SetItemExtraData(itemid, 1);
			}
			else
			{
				SetItemExtraData(itemid, 0);
				DisplayContainerInventory(playerid, containerid);
			}
		}
	}

	return CallLocalFunction("motm_OnPlayerSelectContainerOpt", "ddd", playerid, containerid, option);
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt motm_OnPlayerSelectContainerOpt
forward motm_OnPlayerSelectContainerOpt(playerid, containerid, option);

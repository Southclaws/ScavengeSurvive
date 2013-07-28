new iedm_ContainerOption[MAX_PLAYERS];


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_IedMotionMine)
	{
		PlayerDropItem(playerid);
		SetItemExtraData(itemid, 1);
		Msg(playerid, YELLOW, " >  Mine primed");
		return 1;
	}
	return CallLocalFunction("iedm_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem iedm_OnPlayerUseItem
forward iedm_OnPlayerUseItem(playerid, itemid);

public OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_IedMotionMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(itemid, x, y, z);
			CreateStructuralExplosion(x, y, z, 11, 8.0, 1);

			DestroyItem(itemid);

			return 1;
		}
	}
	return CallLocalFunction("iedm_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem iedm_OnPlayerPickUpItem
forward iedm_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerOpenContainer(playerid, containerid)
{
	new itemid;
	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		itemid = GetContainerSlotItem(containerid, i);

		if(GetItemType(itemid) == item_IedMotionMine)
		{
			if(GetItemExtraData(itemid) == 1)
			{
				new
					Float:x,
					Float:y,
					Float:z;

				GetPlayerPos(playerid, x, y, z);
				CreateStructuralExplosion(x, y, z, 12, 5.0);
				RemoveItemFromContainer(containerid, i);
				DestroyItem(itemid);
			}
		}
	}

	return CallLocalFunction("iedm_OnPlayerOpenContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer iedm_OnPlayerOpenContainer
forward iedm_OnPlayerOpenContainer(playerid, containerid);

public OnPlayerViewContainerOpt(playerid, containerid)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_IedMotionMine)
	{
		if(GetItemExtraData(itemid) == 0)
			iedm_ContainerOption[playerid] = AddContainerOption(playerid, "Arm Motion Mine");

		else
			iedm_ContainerOption[playerid] = AddContainerOption(playerid, "Disarm Motion Mine");
	}

	return CallLocalFunction("iedm_OnPlayerViewContainerOpt", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt iedm_OnPlayerViewContainerOpt
forward iedm_OnPlayerViewContainerOpt(playerid, containerid);

public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_IedMotionMine)
	{
		if(option == iedm_ContainerOption[playerid])
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

	return CallLocalFunction("iedm_OnPlayerSelectContainerOpt", "ddd", playerid, containerid, option);
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt iedm_OnPlayerSelectContainerOpt
forward iedm_OnPlayerSelectContainerOpt(playerid, containerid, option);

new tntm_ContainerOption[MAX_PLAYERS];


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TntTripMine)
	{
		PlayerDropItem(playerid);
		SetItemExtraData(itemid, 1);
		Msg(playerid, YELLOW, " >  Mine primed");
		return 1;
	}
	return CallLocalFunction("tntm_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem tntm_OnPlayerUseItem
forward tntm_OnPlayerUseItem(playerid, itemid);

public OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TntTripMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			SetItemToExplode(itemid, 10, 12.0, EXPLOSION_PRESET_STRUCTURAL, 2);

			return 1;
		}
	}
	return CallLocalFunction("tntm_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem tntm_OnPlayerPickUpItem
forward tntm_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerOpenContainer(playerid, containerid)
{
	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		new itemid = GetContainerSlotItem(containerid, i);

		if(GetItemType(itemid) == item_TntTripMine)
		{
			if(GetItemExtraData(itemid) == 1)
			{
				SetItemToExplode(itemid, 10, 12.0, EXPLOSION_PRESET_STRUCTURAL, 2);
			}
		}
	}

	return CallLocalFunction("tntm_OnPlayerOpenContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer tntm_OnPlayerOpenContainer
forward tntm_OnPlayerOpenContainer(playerid, containerid);

public OnPlayerViewContainerOpt(playerid, containerid)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_TntTripMine)
	{
		if(GetItemExtraData(itemid) == 0)
			tntm_ContainerOption[playerid] = AddContainerOption(playerid, "Arm Motion Mine");

		else
			tntm_ContainerOption[playerid] = AddContainerOption(playerid, "Disarm Motion Mine");
	}

	return CallLocalFunction("tntm_OnPlayerViewContainerOpt", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt tntm_OnPlayerViewContainerOpt
forward tntm_OnPlayerViewContainerOpt(playerid, containerid);

public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_TntTripMine)
	{
		if(option == tntm_ContainerOption[playerid])
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

	return CallLocalFunction("tntm_OnPlayerSelectContainerOpt", "ddd", playerid, containerid, option);
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt tntm_OnPlayerSelectContainerOpt
forward tntm_OnPlayerSelectContainerOpt(playerid, containerid, option);

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
	#if defined tntm_OnPlayerUseItem
        return tntm_OnPlayerUseItem(playerid, itemid);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem tntm_OnPlayerUseItem
#if defined tntm_OnPlayerUseItem
    forward tntm_OnPlayerUseItem(playerid, itemid);
#endif

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
	#if defined tntm_OnPlayerPickUpItem
        return tntm_OnPlayerPickUpItem(playerid, itemid);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem tntm_OnPlayerPickUpItem
#if defined tntm_OnPlayerPickUpItem
    forward tntm_OnPlayerPickUpItem(playerid, itemid);
#endif

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
				break;
			}
		}
	}

	#if defined tntm_OnPlayerOpenContainer
        return tntm_OnPlayerOpenContainer(playerid, containerid);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer tntm_OnPlayerOpenContainer
#if defined tntm_OnPlayerOpenContainer
    forward tntm_OnPlayerOpenContainer(playerid, containerid);
#endif

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
			tntm_ContainerOption[playerid] = AddContainerOption(playerid, "Arm Trip Mine");

		else
			tntm_ContainerOption[playerid] = AddContainerOption(playerid, "Disarm Trip Mine");
	}

	#if defined tntm_OnPlayerViewContainerOpt
        return tntm_OnPlayerViewContainerOpt(playerid, containerid);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt tntm_OnPlayerViewContainerOpt
#if defined tntm_OnPlayerViewContainerOpt
    forward tntm_OnPlayerViewContainerOpt(playerid, containerid);
#endif

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

	#if defined tntm_OnPlayerSelectContainerOpt
        return tntm_OnPlayerSelectContainerOpt(playerid, containerid, option);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt tntm_OnPlayerSelectContainerOpt
#if defined tntm_OnPlayerSelectContainerOpt
    forward tntm_OnPlayerSelectContainerOpt(playerid, containerid, option);
#endif

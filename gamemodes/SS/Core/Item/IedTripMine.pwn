new iedm_ContainerOption[MAX_PLAYERS];


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_IedTripMine)
	{
		PlayerDropItem(playerid);
		SetItemExtraData(itemid, 1);
		Msg(playerid, YELLOW, " >  Mine primed");
		return 1;
	}
	#if defined iedm_OnPlayerUseItem
        return iedm_OnPlayerUseItem(playerid, itemid);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem iedm_OnPlayerUseItem
#if defined iedm_OnPlayerUseItem
    forward iedm_OnPlayerUseItem(playerid, itemid);
#endif

public OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_IedTripMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			SetItemToExplode(itemid, 11, 8.0, EXPLOSION_PRESET_STRUCTURAL, 1);

			return 1;
		}
	}
	#if defined iedm_OnPlayerPickUpItem
        return iedm_OnPlayerPickUpItem(playerid, itemid);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem iedm_OnPlayerPickUpItem
#if defined iedm_OnPlayerPickUpItem
    forward iedm_OnPlayerPickUpItem(playerid, itemid);
#endif

public OnPlayerOpenContainer(playerid, containerid)
{
	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		new itemid = GetContainerSlotItem(containerid, i);

		if(GetItemType(itemid) == item_IedTripMine)
		{
			if(GetItemExtraData(itemid) == 1)
			{
				SetItemToExplode(itemid, 11, 8.0, EXPLOSION_PRESET_STRUCTURAL, 1);
				RemoveItemFromContainer(containerid, i);
			}
		}
	}

	#if defined iedm_OnPlayerOpenContainer
        return iedm_OnPlayerOpenContainer(playerid, containerid);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer iedm_OnPlayerOpenContainer
#if defined iedm_OnPlayerOpenContainer
    forward iedm_OnPlayerOpenContainer(playerid, containerid);
#endif

public OnPlayerViewContainerOpt(playerid, containerid)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_IedTripMine)
	{
		if(GetItemExtraData(itemid) == 0)
			iedm_ContainerOption[playerid] = AddContainerOption(playerid, "Arm Trip Mine");

		else
			iedm_ContainerOption[playerid] = AddContainerOption(playerid, "Disarm Trip Mine");
	}

	#if defined iedm_OnPlayerViewContainerOpt
        return iedm_OnPlayerViewContainerOpt(playerid, containerid);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt iedm_OnPlayerViewContainerOpt
#if defined iedm_OnPlayerViewContainerOpt
    forward iedm_OnPlayerViewContainerOpt(playerid, containerid);
#endif

public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_IedTripMine)
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

	#if defined iedm_OnPlayerSelectContainerOpt
        return iedm_OnPlayerSelectContainerOpt(playerid, containerid, option);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt iedm_OnPlayerSelectContainerOpt
#if defined iedm_OnPlayerSelectContainerOpt
    forward iedm_OnPlayerSelectContainerOpt(playerid, containerid, option);
#endif

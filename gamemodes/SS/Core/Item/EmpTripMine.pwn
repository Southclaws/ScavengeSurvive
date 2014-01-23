new empm_ContainerOption[MAX_PLAYERS];


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_EmpTripMine)
	{
		PlayerDropItem(playerid);
		SetItemExtraData(itemid, 1);
		Msg(playerid, YELLOW, " >  Mine primed");
		return 1;
	}
	return CallLocalFunction("empm_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem empm_OnPlayerUseItem
forward empm_OnPlayerUseItem(playerid, itemid);

public OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_EmpTripMine)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			SetItemToExplode(itemid, 0, 12.0, EXPLOSION_PRESET_EMP, 0);

			return 1;
		}
	}
	return CallLocalFunction("empm_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem empm_OnPlayerPickUpItem
forward empm_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerOpenContainer(playerid, containerid)
{
	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		new itemid = GetContainerSlotItem(containerid, i);

		if(GetItemType(itemid) == item_EmpTripMine)
		{
			if(GetItemExtraData(itemid) == 1)
			{
				SetItemToExplode(itemid, 0, 12.0, EXPLOSION_PRESET_EMP, 0);
				RemoveItemFromContainer(containerid, i);
			}
		}
	}

	return CallLocalFunction("empm_OnPlayerOpenContainer", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerOpenContainer
	#undef OnPlayerOpenContainer
#else
	#define _ALS_OnPlayerOpenContainer
#endif
#define OnPlayerOpenContainer empm_OnPlayerOpenContainer
forward empm_OnPlayerOpenContainer(playerid, containerid);

public OnPlayerViewContainerOpt(playerid, containerid)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_EmpTripMine)
	{
		if(GetItemExtraData(itemid) == 0)
			empm_ContainerOption[playerid] = AddContainerOption(playerid, "Arm Trip Mine");

		else
			empm_ContainerOption[playerid] = AddContainerOption(playerid, "Disarm Trip Mine");
	}

	return CallLocalFunction("empm_OnPlayerViewContainerOpt", "dd", playerid, containerid);
}
#if defined _ALS_OnPlayerViewContainerOpt
	#undef OnPlayerViewContainerOpt
#else
	#define _ALS_OnPlayerViewContainerOpt
#endif
#define OnPlayerViewContainerOpt empm_OnPlayerViewContainerOpt
forward empm_OnPlayerViewContainerOpt(playerid, containerid);

public OnPlayerSelectContainerOpt(playerid, containerid, option)
{
	new
		slot,
		itemid;

	slot = GetPlayerContainerSlot(playerid);
	itemid = GetContainerSlotItem(containerid, slot);

	if(GetItemType(itemid) == item_EmpTripMine)
	{
		if(option == empm_ContainerOption[playerid])
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

	return CallLocalFunction("empm_OnPlayerSelectContainerOpt", "ddd", playerid, containerid, option);
}
#if defined _ALS_OnPlayerSelectContainerOpt
	#undef OnPlayerSelectContainerOpt
#else
	#define _ALS_OnPlayerSelectContainerOpt
#endif
#define OnPlayerSelectContainerOpt empm_OnPlayerSelectContainerOpt
forward empm_OnPlayerSelectContainerOpt(playerid, containerid, option);

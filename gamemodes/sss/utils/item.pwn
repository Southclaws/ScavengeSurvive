stock GetItemAbsolutePos(Item:itemid, &Float:x, &Float:y, &Float:z, &parent = -1, parenttype[32] = "")
{
	if(IsItemInWorld(itemid))
		return GetItemPos(itemid, x, y, z);

	new Container:containerid;
	GetItemContainer(itemid, containerid);

	if(IsValidContainer(containerid))
	{
		/*
			First, check if the container is a world-container with a button.
		*/
		new Button:buttonid = INVALID_BUTTON_ID;//GetContainerButton(containerid); // TODO!

		if(IsValidButton(buttonid))
		{
			parent = _:containerid;
			parenttype = "containerid";
			return GetButtonPos(buttonid, x, y, z);
		}

		/*
			No? Maybe it's a vehicle trunk container
		*/
		new vehicleid = GetContainerTrunkVehicleID(containerid);

		if(IsValidVehicle(vehicleid))
		{
			parent = vehicleid;
			parenttype = "vehicleid";
			return GetVehiclePos(vehicleid, x, y, z);
		}

		/*
			Safebox
		*/
		new Item:safeboxitemid = GetContainerSafeboxItem(containerid);

		if(IsValidItem(safeboxitemid))
		{
			parent = _:containerid;
			parenttype = "containerid";
			return GetItemAbsolutePos(safeboxitemid, x, y, z, parent, parenttype);
		}

		/*
			Bags worn by players
		*/
		new playerid = GetContainerPlayerBag(containerid);

		if(IsPlayerConnected(playerid))
		{
			parent = playerid;
			parenttype = "playerid";
			return GetPlayerPos(playerid, x, y, z);
		}

		/*
			Bags in the game world
		*/
		new Item:bagitemid = GetContainerBagItem(containerid);

		if(IsValidItem(bagitemid))
		{
			parent = _:containerid;
			parenttype = "containerid";
			return GetItemAbsolutePos(bagitemid, x, y, z, parent, parenttype);
		}
	}

	new playerid;
	GetItemInventoryPlayer(itemid, playerid);

	if(IsPlayerConnected(playerid))
	{
		parent = playerid;
		parenttype = "playerid";
		return GetPlayerPos(playerid, x, y, z);
	}

	playerid = GetItemHolder(itemid);

	if(GetPlayerItem(playerid) == itemid)
	{
		parent = playerid;
		parenttype = "playerid";
		return GetPlayerPos(playerid, x, y, z);
	}

	return 0;
}
/*
static
	follower[MAX_PLAYERS],
	followed[MAX_PLAYERS];

ACMD:itempostest[5](playerid, params[])
{
	new Item:itemid = GetPlayerItem(playerid);

	if(IsValidItem(itemid))
	{
		follower[playerid] = CreateDynamicObject(19307, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
		followed[playerid] = itemid;
	}

	return 1;
}

hook OnPlayerUpdate(playerid)
{
	if(IsValidItem(followed[playerid]))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			parent,
			parenttype[32];

		GetItemAbsolutePos(followed[playerid], x, y, z, parent, parenttype);
		SetDynamicObjectPos(follower[playerid], x, y, z);
		ShowActionText(playerid, sprintf("%d~n~%s~n~%.1f %.1f %.1f", parent, parenttype, x, y, z), 0);
	}
	else
	{
		ShowActionText(playerid, "Lost item", 0);
	}

	return 1;
}
*/

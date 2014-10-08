#include <YSI\y_hooks>


static
			trunk_ContainerVehicle	[CNT_MAX],
			trunk_ContainerID		[MAX_VEHICLES],
			trunk_Locked			[MAX_VEHICLES],
			trunk_CurrentVehicle	[MAX_PLAYERS];


/*==============================================================================

	Internal

==============================================================================*/


public OnVehicleCreated(vehicleid)
{
	printf("OnVehicleCreated %d", vehicleid);
	new
		vehicletype,
		trunksize;

	vehicletype = GetVehicleType(vehicleid);
	trunksize = GetVehicleTypeTrunkSize(vehicletype);

	if(trunksize > 0)
	{
		new vehicletypename[MAX_VEHICLE_TYPE_NAME];
		GetVehicleTypeName(vehicletype, vehicletypename);
		trunk_ContainerID[vehicleid] = CreateContainer(sprintf("%s trunk", vehicletypename), trunksize, .virtual = 1);
		trunk_Locked[vehicleid] = false;
	}

	#if defined trnk_OnVehicleCreated
		return trnk_OnVehicleCreated(vehicleid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnVehicleCreated
	#undef OnVehicleCreated
#else
	#define _ALS_OnVehicleCreated
#endif
#define OnVehicleCreated trnk_OnVehicleCreated
#if defined trnk_OnVehicleCreated
	forward trnk_OnVehicleCreated(vehicleid);
#endif

public OnVehicleReset(oldid, newid)
{
	if(oldid != newid)
	{
		trunk_ContainerID[newid] = trunk_ContainerID[oldid];
		trunk_Locked[newid] = trunk_Locked[oldid];
		trunk_ContainerVehicle[trunk_ContainerID[oldid]] = INVALID_VEHICLE_ID;
		trunk_ContainerVehicle[trunk_ContainerID[newid]] = newid;
	}

	#if defined trnk_OnVehicleReset
		return trnk_OnVehicleReset(oldid, newid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnVehicleReset
	#undef OnVehicleReset
#else
	#define _ALS_OnVehicleReset
#endif
 
#define OnVehicleReset trnk_OnVehicleReset
#if defined trnk_OnVehicleReset
	forward trnk_OnVehicleReset(oldid, newid);
#endif

public OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	if(155.0 < angle < 205.0)
	{
		if(IsValidContainer(GetVehicleContainer(vehicleid)))
		{
			if(IsVehicleTrunkLocked(vehicleid))
			{
				ShowActionText(playerid, "Trunk locked", 3000);
				return 1;
			}

			if(IsVehicleLocked(vehicleid))
			{
				ShowActionText(playerid, "Trunk locked", 3000);
				return 1;
			}

			new Float:vehicleangle;

			GetVehicleZAngle(vehicleid, vehicleangle);

			VehicleBootState(vehicleid, 1);
			CancelPlayerMovement(playerid);
			SetPlayerFacingAngle(playerid, (vehicleangle-angle)-180.0);

			DisplayContainerInventory(playerid, GetVehicleContainer(vehicleid));
			trunk_CurrentVehicle[playerid] = vehicleid;

			return 1;
		}
	}

	#if defined trnk_OnPlayerInteractVehicle
		return trnk_OnPlayerInteractVehicle(playerid, vehicleid, Float:angle);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerInteractVehicle
	#undef OnPlayerInteractVehicle
#else
	#define _ALS_OnPlayerInteractVehicle
#endif
 
#define OnPlayerInteractVehicle trnk_OnPlayerInteractVehicle
#if defined trnk_OnPlayerInteractVehicle
	forward trnk_OnPlayerInteractVehicle(playerid, vehicleid, Float:angle);
#endif

public OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidVehicle(trunk_CurrentVehicle[playerid]))
	{
		if(containerid == GetVehicleContainer(trunk_CurrentVehicle[playerid]))
		{
			VehicleBootState(trunk_CurrentVehicle[playerid], 0);

			trunk_CurrentVehicle[playerid] = INVALID_VEHICLE_ID;
		}
	}

	#if defined veh_OnPlayerCloseContainer
		return veh_OnPlayerCloseContainer(playerid, containerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerCloseContainer
	#undef OnPlayerCloseContainer
#else
	#define _ALS_OnPlayerCloseContainer
#endif
#define OnPlayerCloseContainer veh_OnPlayerCloseContainer
#if defined veh_OnPlayerCloseContainer
	forward veh_OnPlayerCloseContainer(playerid, containerid);
#endif

public OnPlayerUseItem(playerid, itemid)
{
	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return 1;

	#if defined veh_OnPlayerUseItem
		return veh_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem veh_OnPlayerUseItem
#if defined veh_OnPlayerUseItem
	forward veh_OnPlayerUseItem(playerid, itemid);
#endif

public OnItemAddedToContainer(containerid, itemid, playerid)
{
	if(IsPlayerConnected(playerid))
		VehicleTrunkUpdateSave(playerid);

	#if defined veh_OnItemAddedToContainer
		return veh_OnItemAddedToContainer(containerid, itemid, playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemAddedToContainer
	#undef OnItemAddedToContainer
#else
	#define _ALS_OnItemAddedToContainer
#endif
#define OnItemAddedToContainer veh_OnItemAddedToContainer
#if defined veh_OnItemAddedToContainer
	forward veh_OnItemAddedToContainer(containerid, itemid, playerid);
#endif

public OnItemRemovedFromContainer(containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
		VehicleTrunkUpdateSave(playerid);

	#if defined veh_OnItemRemovedFromContainer
		return veh_OnItemRemovedFromContainer(containerid, slotid, playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemRemovedFromContainer
	#undef OnItemRemovedFromContainer
#else
	#define _ALS_OnItemRemovedFromContainer
#endif
#define OnItemRemovedFromContainer veh_OnItemRemovedFromContainer
#if defined veh_OnItemRemovedFromContainer
	forward veh_OnItemRemovedFromContainer(containerid, slotid, playerid);
#endif

public OnVehicleDestroyed(vehicleid)
{
	if(IsValidContainer(trunk_ContainerID[vehicleid]))
		DestroyContainer(trunk_ContainerID[vehicleid]);

	#if defined trnk_OnVehicleDestroyed
		return trnk_OnVehicleDestroyed(vehicleid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnVehicleDestroyed
	#undef OnVehicleDestroyed
#else
	#define _ALS_OnVehicleDestroyed
#endif
#define OnVehicleDestroyed trnk_OnVehicleDestroyed
#if defined trnk_OnVehicleDestroyed
	forward trnk_OnVehicleDestroyed(vehicleid);
#endif

VehicleTrunkUpdateSave(playerid)
{
	if(IsValidVehicle(trunk_CurrentVehicle[playerid]))
	{
		new owner[MAX_PLAYER_NAME];

		GetVehicleOwner(trunk_CurrentVehicle[playerid], owner);

		if(!isnull(owner))
		{
			new name[MAX_PLAYER_NAME];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			if(!strcmp(owner, name))
			{
				new
					Float:x,
					Float:y,
					Float:z,
					Float:r;

				UpdateVehicleFile(trunk_CurrentVehicle[playerid]);
				GetVehiclePos(trunk_CurrentVehicle[playerid], x, y, z);
				GetVehicleZAngle(trunk_CurrentVehicle[playerid], r);
				SetVehicleSpawnPoint(trunk_CurrentVehicle[playerid], x, y, z, r);
			}
		}
	}
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetVehicleContainer(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return INVALID_CONTAINER_ID;

	return trunk_ContainerID[vehicleid];
}

stock GetContainerTrunkVehicleID(containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_VEHICLE_ID;

	return trunk_ContainerVehicle[containerid];
}

stock IsVehicleTrunkLocked(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return trunk_Locked[vehicleid];
}

stock SetVehicleTrunkLock(vehicleid, toggle)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	trunk_Locked[vehicleid] = toggle;
	return 1;
}


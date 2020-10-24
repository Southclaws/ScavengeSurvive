/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static
	trl_VehicleTrailer[MAX_VEHICLES] = {INVALID_VEHICLE_ID, ...},
	trl_TrailerVehicle[MAX_VEHICLES] = {INVALID_VEHICLE_ID, ...},
	trl_VehicleTypeHitchSize[MAX_VEHICLE_TYPE] = {-1, ...};


/*==============================================================================

	Core

==============================================================================*/


/*
	Used to set which vehicle types can pull specific sizes of trailers. The
	default is -1 (invalid size).
*/
stock SetVehicleTypeTrailerHitch(vehicletype, maxtrailersize)
{
	if(!IsValidVehicleType(vehicletype))
		return 0;

	trl_VehicleTypeHitchSize[vehicletype] = maxtrailersize;

	return 1;
}

/*
	Don't use AttachTrailerToVehicle anywhere else! Use this instead, which
	ensures everything stays synced properly.
*/
stock SetVehicleTrailer(vehicleid, trailerid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	if(!IsValidVehicle(trailerid))
		return 0;

	if(trl_VehicleTrailer[vehicleid] != INVALID_VEHICLE_ID && trl_VehicleTrailer[vehicleid] != trailerid)
	{
		if(IsValidVehicle(trl_VehicleTrailer[vehicleid]))
			return 0;
	}

	if(trl_TrailerVehicle[trailerid] != INVALID_VEHICLE_ID && trl_TrailerVehicle[trailerid] != vehicleid)
	{
		if(IsValidVehicle(trl_TrailerVehicle[trailerid]))
			return 0;
	}

	new
		vehicletype,
		trailersize;

	vehicletype = GetVehicleType(vehicleid);
	trailersize = GetVehicleTypeSize(GetVehicleType(trailerid));

	if(trl_VehicleTypeHitchSize[vehicletype] != trailersize)
		return 0;

	trl_VehicleTrailer[vehicleid] = trailerid;
	trl_TrailerVehicle[trailerid] = vehicleid;

	AttachTrailerToVehicle(trailerid, vehicleid);

	return 1;
}

/*
	Likewise, don't use DetachTrailerFromVehicle anywhere, use this instead.
*/
stock RemoveVehicleTrailer(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	new trailerid = trl_VehicleTrailer[vehicleid];

	if(!IsValidVehicle(trailerid))
		return 0;

	trl_VehicleTrailer[vehicleid] = INVALID_VEHICLE_ID;
	trl_TrailerVehicle[trailerid] = INVALID_VEHICLE_ID;

	DetachTrailerFromVehicle(vehicleid);

	return 1;
}

/*
	GetVehicleTrailer will return the client-side trailer. This returns the
	server-side trailer which is more reliable. A combination of both could be
	used for anti-cheat however.
*/
stock GetVehicleTrailerID(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return trl_VehicleTrailer[vehicleid];
}

/*
	Return the vehicle that's pulling the specified trailer because why not.
*/
stock GetTrailerVehicleID(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return trl_TrailerVehicle[vehicleid];
}


/*==============================================================================

	Internal

==============================================================================*/


/*
	This timer ensures two things: trailers detached from unoccupied vehicles
	are reattached (it might be desync or a player trying to pull the trailer
	away or something) and that trailers detached from occupied vehicles are
	also cleared on the server side (so the server doesn't still think the
	trailer is attached).
*/
task _trailerSync[1000]()
{
	new trailerid;

	foreach(new i : veh_Index)
	{
		// If this vehicle doesn't have a trailer, skip.
		if(trl_VehicleTrailer[i] == INVALID_VEHICLE_ID)
		{
			trailerid = GetVehicleTrailer(i);

			// Check for a client-sided trailer and try to add it
			if(IsValidVehicle(trailerid))
				SetVehicleTrailer(i, trailerid);

			else
				continue;
		}

		// If this vehicle apparently did have a trailer but it doesn't exist,
		// clear that trailer from memory.
		if(!IsValidVehicle(trl_VehicleTrailer[i]))
		{
			trl_TrailerVehicle[trl_VehicleTrailer[i]] = INVALID_VEHICLE_ID;
			trl_VehicleTrailer[i] = INVALID_VEHICLE_ID;
			continue;
		}

		// If the vehicle does have a trailer client-side and it's the server
		// side trailer, everything is fine so skip.
		if(GetVehicleTrailer(i) == trl_VehicleTrailer[i])
			continue;

		// If not, and the vehicle is occupied then remove the trailer using the
		// function to remove it server-side. If the vehicle isn't occupied,
		// attach the trailer again for all streamed players.
		if(IsVehicleOccupied(i))
			RemoveVehicleTrailer(i);

		else
			AttachTrailerToVehicle(trl_VehicleTrailer[i], i);
	}
}

/*
	If a vehicle pulling a trailer or a trailer itself dies, clean up.
*/
hook OnVehicleDeath(vehicleid, killerid)
{
	if(IsValidVehicle(trl_VehicleTrailer[vehicleid]))
	{
		trl_TrailerVehicle[trl_VehicleTrailer[vehicleid]] = INVALID_VEHICLE_ID;
		trl_VehicleTrailer[vehicleid] = INVALID_VEHICLE_ID;
	}

	if(IsValidVehicle(trl_TrailerVehicle[vehicleid]))
	{
		trl_VehicleTrailer[trl_TrailerVehicle[vehicleid]] = INVALID_VEHICLE_ID;
		trl_TrailerVehicle[vehicleid] = INVALID_VEHICLE_ID;
	}

	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
		return 1;

	if(newkeys == KEY_ACTION)
		_HandleTrailerTowKey(playerid);

	return 1;
}

_HandleTrailerTowKey(playerid)
{
	new
		vehicleid,
		vehicletype;

	vehicleid = GetPlayerVehicleID(playerid);
	vehicletype = GetVehicleType(vehicleid);

	if(!IsValidVehicleType(vehicletype))
		return 0;

	if(trl_VehicleTypeHitchSize[vehicletype] == -1)
		return 0;

	new
		tmptype,
		Float:vx1,
		Float:vy1,
		Float:vz1,
		Float:size_x1,
		Float:size_y1,
		Float:size_z1,
		Float:vx2,
		Float:vy2,
		Float:vz2,
		Float:size_x2,
		Float:size_y2,
		Float:size_z2;


	GetVehiclePos(vehicleid, vx1, vy1, vz1);
	GetVehicleModelInfo(GetVehicleTypeModel(vehicletype), VEHICLE_MODEL_INFO_SIZE, size_x1, size_y1, size_z1);

	if(IsTrailerAttachedToVehicle(vehicleid))
	{
		RemoveVehicleTrailer(vehicleid);
		return 1;
	}

	foreach(new i : veh_Index)
	{
		if(i == vehicleid)
			continue;

		tmptype = GetVehicleType(i);

		if(!IsVehicleTypeTrailer(tmptype))
			continue;

		if(GetVehicleTypeSize(tmptype) != trl_VehicleTypeHitchSize[vehicletype])
			continue;

		GetVehiclePos(i, vx2, vy2, vz2);
		GetVehicleModelInfo(GetVehicleTypeModel(tmptype), VEHICLE_MODEL_INFO_SIZE, size_x2, size_y2, size_z2);

		if(Distance(vx1, vy1, vz1, vx2, vy2, vz2) < size_y1 + size_y2 + 1.0)
		{
			SetVehicleTrailer(vehicleid, i);

			break;
		}
	}

	return 1;
}

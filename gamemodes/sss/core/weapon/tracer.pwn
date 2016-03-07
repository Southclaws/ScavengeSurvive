/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#define MAX_TRACERS						(512)
#define TRACER_STREAMER_AREA_IDENTIFIER	(800)


static
			tracer_ObjectID[MAX_TRACERS],
Iterator:	tracer_Index<MAX_TRACERS>;


stock CreateTracer(Float:originx, Float:originy, Float:originz, Float:targetx, Float:targety, Float:targetz)
{
	new id = Iter_Free(tracer_Index);

	if(id == -1)
		return -1;

	new
		Float:vecx,
		Float:vecy,
		Float:vecz,
		Float:rotation,
		Float:elevation,
		arr[2];

	vecx = targetx - originx;
	vecy = targety - originy;
	vecz = targetz - originz;

	rotation = absoluteangle(-(90-(atan2((vecy), (vecx)))));
	elevation = 90-floatabs(atan2(floatsqroot(floatpower(vecx, 2.0) + floatpower(vecy, 2.0)), vecz));

	tracer_ObjectID[id] = CreateDynamicObject(18650,
		originx + (2.0 * floatsin(-rotation, degrees) * floatcos(-elevation, degrees)),
		originy + (2.0 * floatcos(-rotation, degrees) * floatcos(-elevation, degrees)),
		originz + (2.0 * floatsin(-elevation, degrees)),
		elevation, 0.0, rotation);

	arr[0] = TRACER_STREAMER_AREA_IDENTIFIER;
	arr[1] = id;

	Streamer_SetArrayData(STREAMER_TYPE_OBJECT, tracer_ObjectID[id], E_STREAMER_EXTRA_ID, arr);

	MoveDynamicObject(tracer_ObjectID[id], targetx, targety, targetz, 800.0);
/*
	printf("Created tracer: %f, %f, %f > %f, %f, %f",
		originx + (2.0 * floatsin(rotation, degrees) * floatcos(elevation, degrees)),
		originy + (2.0 * floatcos(rotation, degrees) * floatcos(elevation, degrees)),
		originz + (2.0 * floatsin(elevation, degrees)),
		targetx, targety, targetz);
*/
	Iter_Add(tracer_Index, id);

	return id;
}

stock DestroyTracer(id)
{
	if(!Iter_Contains(tracer_Index, id))
		return 0;

	DestroyDynamicObject(tracer_ObjectID[id]);
	Iter_Remove(tracer_Index, id);

	return 1;
}

public OnDynamicObjectMoved(objectid)
{
	tracer_HandleObjectMoved(objectid);

	#if defined tracer_OnDynamicObjectMoved
		return tracer_OnDynamicObjectMoved(objectid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnDynamicObjectMoved
	#undef OnDynamicObjectMoved
#else
	#define _ALS_OnDynamicObjectMoved
#endif
 
#define OnDynamicObjectMoved tracer_OnDynamicObjectMoved
#if defined tracer_OnDynamicObjectMoved
	forward tracer_OnDynamicObjectMoved(objectid);
#endif

tracer_HandleObjectMoved(objectid)
{
	new arr[2];

	Streamer_GetArrayData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID, arr);

	if(arr[0] != TRACER_STREAMER_AREA_IDENTIFIER)
		return;

	if(!Iter_Contains(tracer_Index, arr[1]))
		return;

	DestroyTracer(arr[1]);

	return;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(IsBaseWeaponClipBased(weaponid))
	{
		new ItemType:ammoitemtype = GetItemWeaponItemAmmoItem(GetPlayerItem(playerid));

		if(ammoitemtype == item_Ammo556Tracer || ammoitemtype == item_Ammo357Tracer)
		{
			new
				Float:originx,
				Float:originy,
				Float:originz,
				Float:targetx,
				Float:targety,
				Float:targetz;

			GetPlayerLastShotVectors(playerid, originx, originy, originz, targetx, targety, targetz);

			if(targetx*targety*targetz == 0.0)
			{
				GetPlayerCameraFrontVector(playerid, targetx, targety, targetz);
				targetx = originx + (targetx * 80.0);
				targety = originy + (targety * 80.0);
				targetz = originz + (targetz * 80.0);
			}

			// MsgF(playerid, YELLOW, "hittype %d target: %f, %f, %f", hittype, targetx, targety, targetz);

			CreateTracer(originx, originy, originz, targetx, targety, targetz);
		}
	}

	#if defined tracer_OnPlayerWeaponShot
		return tracer_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerWeaponShot
	#undef OnPlayerWeaponShot
#else
	#define _ALS_OnPlayerWeaponShot
#endif
 
#define OnPlayerWeaponShot tracer_OnPlayerWeaponShot
#if defined tracer_OnPlayerWeaponShot
	forward tracer_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
#endif

/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#define MAX_TRACERS						(512)
#define TRACER_STREAMER_AREA_IDENTIFIER	(800)


static
			tracer_ObjectID[MAX_TRACERS],
   Iterator:tracer_Index<MAX_TRACERS>;


stock CreateTracer(Float:originx, Float:originy, Float:originz, Float:targetx, Float:targety, Float:targetz)
{
	new id = Iter_Free(tracer_Index);

	if(id == ITER_NONE)
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
	log("Created tracer: %f, %f, %f > %f, %f, %f",
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

hook OnDynamicObjectMoved(objectid)
{
	tracer_HandleObjectMoved(objectid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

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

hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
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

	return Y_HOOKS_CONTINUE_RETURN_1;
}

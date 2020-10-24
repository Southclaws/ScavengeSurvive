/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#define FILTERSCRIPT


#include <a_samp>

/*==============================================================================

	Libraries and respective links to their release pages

==============================================================================*/

#undef MAX_PLAYERS
#define MAX_PLAYERS	(32)


#include <streamer>			// by Incognito - github.com/samp-incognito/samp-streamer-plugin/releases


/*==============================================================================

	Utils

==============================================================================*/


Float:absoluteangle(Float:angle)
{
	while(angle < 0.0)angle += 360.0;
	while(angle > 360.0)angle -= 360.0;

	return angle;
}


/*==============================================================================

	Core

==============================================================================*/


static
		gTracer[MAX_PLAYERS];


public OnFilterScriptInit()
{
	Streamer_ToggleIdleUpdate(0, true);
}


public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(hittype == BULLET_HIT_TYPE_NONE)
	{
		// Ifthe hit position is nowhere (out of range)
		if(fX*fY*fZ == 0.0)
			return 1;

		new
			Float:fOriginX,
			Float:fOriginY,
			Float:fOriginZ,
			Float:fHitPosX,
			Float:fHitPosY,
			Float:fHitPosZ;

		new
			Float:fHitVecX,
			Float:fHitVecY,
			Float:fHitVecZ;

		new
			Float:fBulletRotation,
			Float:fBulletElevation;

		GetPlayerLastShotVectors(playerid, fOriginX, fOriginY, fOriginZ, fHitPosX, fHitPosY, fHitPosZ);

		fHitVecX = fHitPosX - fOriginX;
		fHitVecY = fHitPosY - fOriginY;
		fHitVecZ = fHitPosZ - fOriginZ;

		fBulletRotation = absoluteangle(-(90-(atan2((fHitVecY), (fHitVecX)))));
		fBulletElevation = 90-floatabs(atan2(floatsqroot(floatpower(fHitVecX, 2.0) + floatpower(fHitVecY, 2.0)), fHitVecZ));

		gTracer[playerid] = CreateDynamicObject(18650,
			fOriginX + (2.0 * floatsin(fBulletRotation, degrees) * floatcos(fBulletElevation, degrees)),
			fOriginY + (2.0 * floatcos(fBulletRotation, degrees) * floatcos(fBulletElevation, degrees)),
			fOriginZ + (2.0 * floatsin(fBulletElevation, degrees)),
			fBulletElevation, 0.0, fBulletRotation);

		MoveDynamicObject(gTracer[playerid], fHitPosX, fHitPosY, fHitPosZ, 500.0);
	}

	return 1;
}

public OnDynamicObjectMoved(objectid)
{
	DestroyDynamicObject(objectid);
	return 1;
}

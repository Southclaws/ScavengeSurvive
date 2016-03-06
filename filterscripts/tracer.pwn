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

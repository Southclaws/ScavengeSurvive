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
#include <YSI\y_iterate>	// by Y_Less
#include <YSI\y_timers>
#include <SIF/SIF>			// by Southclaws - github.com/Southclaws/SIF
#include <strlib>			// by Slice - github.com/oscar-broman/strlib
#include <Line>				// by Southclaws - github.com/Southclaws/Line
#include <ZCMD>				// by Zeex - forum.sa-mp.com/showthread.php?t=91354
#include <Zipline>			// by Southclaws


/*==============================================================================

	Utils

==============================================================================*/


Float:absoluteangle(Float:angle)
{
	while(angle < 0.0)angle += 360.0;
	while(angle > 360.0)angle -= 360.0;

	return angle;
}

/*
	Returns an adjusted camera vector based on the weapon that the player has.
		by Nero_3D
*/
stock GetPlayerCameraWeaponVector(playerid, & Float: vX, & Float: vY, & Float: vZ)
{
	new ret = GetPlayerCameraFrontVector(playerid, vX, vY, vZ);

	if(!ret)
		return 0;

	if(IsPlayerAiming(playerid))
	{
		switch(GetPlayerWeapon(playerid))
		{
			case WEAPON_SNIPER, WEAPON_ROCKETLAUNCHER, WEAPON_HEATSEEKER:
			{
				return true;
			}

			case WEAPON_RIFLE:
			{
				new Float: angle = -(atan2(vX, vY) + 12.920722);

				vX += floatcos(angle, degrees) * 0.019384;
				vY += floatsin(angle, degrees) * 0.019384;
				vZ += 0.047052;

				return true;
			}

			case WEAPON_AK47, WEAPON_M4:
			{
				new Float: angle = -(atan2(vX, vY) + 16.827384);

				vX += floatcos(angle, degrees) * 0.029147;
				vY += floatsin(angle, degrees) * 0.029147;
				vZ += 0.069293;

				return true;
			}

			case WEAPON_COLT45 .. WEAPON_MP5, WEAPON_TEC9, WEAPON_FLAMETHROWER, WEAPON_MINIGUN:
			{
				new Float: angle = -(atan2(vX, vY) + 15.476425);

				vX += floatcos(angle, degrees) * 0.043317;
				vY += floatsin(angle, degrees) * 0.043317;
				vZ += 0.078616;

				return true;
			}
		}
	}

	return ret;
}

/*
	Returns whether or not the player is aiming while taking into account
	animations.
		by Emmet_
*/
stock IsPlayerAiming(playerid)
{
	new
		iWeapon = GetPlayerWeapon(playerid),
		iAnimation = GetPlayerAnimationIndex(playerid);
	
	if(iWeapon >= 22 && iWeapon <= 38)
	{
		if(iAnimation >= 1160 && iAnimation <= 1167)
			return 1;
		
		static const arrAnimations[] = {1069, 1070, 1449, 1274, 363, 361, 1365, 360, 220, 1331, 1453, 1643};
		
		for (new i = 0; i < sizeof(arrAnimations); i ++)
		{
			if(iAnimation == arrAnimations[i])
				return 1;
		}
	}
	return 0;
}


/*==============================================================================

	Core

==============================================================================*/


static
		gGrappleMode	[MAX_PLAYERS],
		gVelocityTick	[MAX_PLAYERS],
Float:	gVelocityMultX	[MAX_PLAYERS],
Float:	gVelocityMultY	[MAX_PLAYERS],
Float:	gVelocityMultZ	[MAX_PLAYERS],
Float:	gVelocityDestX	[MAX_PLAYERS],
Float:	gVelocityDestY	[MAX_PLAYERS],
Float:	gVelocityDestZ	[MAX_PLAYERS];


public OnFilterScriptInit()
{
	Streamer_ToggleIdleUpdate(0, true);
	SetWorldTime(0); // So we can see neon
}


public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	new
		Float:x,
		Float:y,
		Float:z;

	if(hittype == BULLET_HIT_TYPE_NONE)
	{
		// Ifthe hit position is nowhere (out of range)
		if(fX*fY*fZ == 0.0)
			return 1;

		x = fX;
		y = fY;
		z = fZ;

		new
			Float:fOriginX,
			Float:fOriginY,
			Float:fOriginZ,
			Float:fHitPosX,
			Float:fHitPosY,
			Float:fHitPosZ;

		new
			Float:fCamVecX,
			Float:fCamVecY,
			Float:fCamVecZ,
			Float:fHitVecX,
			Float:fHitVecY,
			Float:fHitVecZ;

		new
			Float:fBulletRotation,
			Float:fBulletElevation,
			Float:fCameraRotation,
			Float:fCameraElevation;

		GetPlayerLastShotVectors(playerid, fOriginX, fOriginY, fOriginZ, fHitPosX, fHitPosY, fHitPosZ);
		GetPlayerCameraWeaponVector(playerid, fCamVecX, fCamVecY, fCamVecZ);

		fHitVecX = fHitPosX - fOriginX;
		fHitVecY = fHitPosY - fOriginY;
		fHitVecZ = fHitPosZ - fOriginZ;

		fBulletRotation = absoluteangle(-(90-(atan2((fHitVecY), (fHitVecX)))));
		fBulletElevation = 90-floatabs(atan2(floatsqroot(floatpower(fHitVecX, 2.0) + floatpower(fHitVecY, 2.0)), fHitVecZ));

		fCameraRotation = absoluteangle(-(90-(atan2((fCamVecY), (fCamVecX)))));
		fCameraElevation = 90-floatabs(atan2(floatsqroot(floatpower(fCamVecX, 2.0) + floatpower(fCamVecY, 2.0)), fCamVecZ));

		ShowActionText(playerid,
			sprintf("~>~: %.2f  |  ~u~: %.2f~n~~>~: %.2f  |  ~u~: %.2f~n~~>~: %.2f  |  ~u~: %.2f~n~V: %.2f, %.2f, %.2f",
			fBulletRotation, fBulletElevation,
			fCameraRotation, fCameraElevation,
			fCameraRotation - fBulletRotation, fCameraElevation - fBulletElevation,
			fCamVecX, fCamVecY, fCamVecZ), 0);

		CreateLineSegment(19087, 2.46,
			fOriginX, fOriginY, fOriginZ,
			fHitPosX, fHitPosY, fHitPosZ,
			.RotX = 90.0, .objlengthoffset = -(2.46/2), .maxlength = 1000.0);

		new
			Float:fCamPosX,
			Float:fCamPosY,
			Float:fCamPosZ;

		GetPlayerCameraPos(playerid, fCamPosX, fCamPosY, fCamPosZ);

		CreateLineSegment(18648, 2.0,
			fCamPosX, fCamPosY, fCamPosZ,
			fCamPosX + (fCamVecX * 100), fCamPosY + (fCamVecY * 100), fCamPosZ + (fCamVecZ * 100),
			.RotX = 0.0, .objlengthoffset = -(2.0/2), .maxlength = 1000.0);

		if(gGrappleMode[playerid])
		{
			if(fHitVecZ != 0.0)
			{
				gVelocityTick[playerid] = floatround(VectorSize(fOriginX - fHitPosX, fOriginY - fHitPosY, fOriginZ - fHitPosZ) / 2);
				gVelocityMultX[playerid] = fCamVecX;
				gVelocityMultY[playerid] = fCamVecY;
				gVelocityMultZ[playerid] = fCamVecZ;
				gVelocityDestX[playerid] = fHitPosX;
				gVelocityDestY[playerid] = fHitPosY;
				gVelocityDestZ[playerid] = fHitPosZ;
			}
		}

		return 0;
	}

	if(hittype == BULLET_HIT_TYPE_PLAYER)
	{
		if(!IsPlayerStreamedIn(playerid, hitid) || !IsPlayerStreamedIn(hitid, playerid))
			return 0;

		// TODO
	}

	if(hittype == BULLET_HIT_TYPE_VEHICLE)
	{

	}

	if(hittype == BULLET_HIT_TYPE_OBJECT)
	{

	}

	if(hittype == BULLET_HIT_TYPE_PLAYER_OBJECT)
	{

	}

	CreateDynamicObject(327, x, y, z, 0.0, 0.0, 0.0);

	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(gGrappleMode[playerid])
	{
		if(gVelocityTick[playerid] > 0)
		{
			if(IsPlayerInRangeOfPoint(playerid, 5.0, gVelocityDestX[playerid], gVelocityDestY[playerid], gVelocityDestZ[playerid]))
				gVelocityTick[playerid] = 0;

			SetPlayerVelocity(playerid, gVelocityMultX[playerid], gVelocityMultY[playerid], gVelocityMultZ[playerid] + (GetPlayerPing(playerid) * 0.0009));
			gVelocityTick[playerid]--;
		}
	}

	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	ShowActionText(playerid, sprintf("DMG: %d | %f", weaponid, amount), 0);

	if(weaponid == 54)
		return -1;

	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	return 0;
}


/*==============================================================================

	Interface

==============================================================================*/


CMD:w(playerid, params[])
{
	GivePlayerWeapon(playerid, strval(params), 99999);
	return 1;
}

CMD:grapple(playerid, params[])
{
	gGrappleMode[playerid] = !gGrappleMode[playerid];
	SendClientMessage(playerid, -1, sprintf("Grapple mode: %d", gGrappleMode[playerid]));
	return 1;
}

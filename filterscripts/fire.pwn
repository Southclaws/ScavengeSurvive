/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
#include <streamer>
#include <zcmd>


#define TEXTURE_1	2068,	"cj_ammo_net",		"CJ_cammonet"
#define TEXTURE_2	693,	"gta_tree_pine",	"sm_redwood_branch"
#define TEXTURE_3	693,	"gta_tree_pine",	"sm_pinetreebit"

#define DEFAULT		TEXTURE_2


CreateFire(Float:x, Float:y, Float:z, Float:rz)
{
	new
		fire_objMid1,
		fire_objMid2,
		fire_objMid3,
		fire_objMid4,
		fire_objStick1,
		fire_objStick2,
		fire_objStick3,
		fire_objStick4,
		fire_objStick5,
		fire_objStick6,
		fire_objStick7,
		fire_objStick8;

	fire_objMid1 = CreateDynamicObject(19475, x, y, z, 10.0, 90.0, rz + 18.0);
	fire_objMid2 = CreateDynamicObject(19475, x, y, z, -10.0, 90.0, rz + 36.0);
	fire_objMid3 = CreateDynamicObject(19475, x, y, z, 0.0, 100.0, rz + 54.0);
	fire_objMid4 = CreateDynamicObject(19475, x, y, z, 0.0, 80.0, rz + 72.0);


	fire_objStick1 = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz, degrees)),
		y + (0.1 * floatcos(-rz, degrees)),
		z + 0.01,
		10.0, 80.0, rz + 45.0);

	fire_objStick2 = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz - 90.0, degrees)),
		y + (0.1 * floatcos(-rz - 90.0, degrees)),
		z + 0.01,
		10.0, 80.0, rz + 45.0 + 90.0);

	fire_objStick3 = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz - 180.0, degrees)),
		y + (0.1 * floatcos(-rz - 180.0, degrees)),
		z + 0.01,
		10.0, 80.0, rz + 45.0 + 180.0);

	fire_objStick4 = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz - 270.0, degrees)),
		y + (0.1 * floatcos(-rz - 270.0, degrees)),
		z + 0.01,
		10.0, 80.0, rz + 45.0 + 270.0);

	fire_objStick5 = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz, degrees)),
		y + (0.1 * floatcos(-rz, degrees)),
		z + 0.01,
		10.0, 80.0, rz + random(90));

	fire_objStick6 = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz - 90.0, degrees)),
		y + (0.1 * floatcos(-rz - 90.0, degrees)),
		z + 0.01,
		10.0, 80.0, rz + random(90) + 90.0);

	fire_objStick7 = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz - 180.0, degrees)),
		y + (0.1 * floatcos(-rz - 180.0, degrees)),
		z + 0.01,
		10.0, 80.0, rz + random(90) + 180.0);

	fire_objStick8 = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz - 270.0, degrees)),
		y + (0.1 * floatcos(-rz - 270.0, degrees)),
		z + 0.01,
		10.0, 80.0, rz + random(90) + 270.0);


	SetDynamicObjectMaterial(fire_objMid1, 0, TEXTURE_1, 0);
	SetDynamicObjectMaterial(fire_objMid2, 0, TEXTURE_1, 0);
	SetDynamicObjectMaterial(fire_objMid3, 0, TEXTURE_1, 0);
	SetDynamicObjectMaterial(fire_objMid4, 0, TEXTURE_1, 0);

	SetDynamicObjectMaterial(fire_objStick1, 0, TEXTURE_2, 0);
	SetDynamicObjectMaterial(fire_objStick2, 0, TEXTURE_2, 0);
	SetDynamicObjectMaterial(fire_objStick3, 0, TEXTURE_2, 0);
	SetDynamicObjectMaterial(fire_objStick4, 0, TEXTURE_2, 0);

	SetDynamicObjectMaterial(fire_objStick5, 0, TEXTURE_2, 0);
	SetDynamicObjectMaterial(fire_objStick6, 0, TEXTURE_2, 0);
	SetDynamicObjectMaterial(fire_objStick7, 0, TEXTURE_2, 0);
	SetDynamicObjectMaterial(fire_objStick8, 0, TEXTURE_2, 0);

	CreateDynamicObject(18693,
		x - (0.0 * floatsin(-rz, degrees)),
		y - (0.0 * floatcos(-rz, degrees)),
		z - 1.5, 0.0, 0.0, rz);
}

CMD:fire(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:rz;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, rz);

	CreateFire(x + floatsin(-rz, degrees), y + floatcos(-rz, degrees), z - 0.85, rz);

	return 1;
}

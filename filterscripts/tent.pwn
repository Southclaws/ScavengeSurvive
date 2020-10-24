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


CreateTent(Float:x, Float:y, Float:z, Float:rz)
{
	new
		tent_SideR1,
		tent_SideR2,
		tent_SideL1,
		tent_SideL2,
		tent_EndF,
		tent_EndB,
		tent_PoleF,
		tent_PoleB;

	tent_SideR1 = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 270.0, degrees)),
		y + (0.49 * floatcos(-rz + 270.0, degrees)),
		z,
		0.0, 45.0, rz);

	tent_SideR2 = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 270.0, degrees)),
		y + (0.48 * floatcos(-rz + 270.0, degrees)),
		z,
		0.0, 45.0, rz);

	tent_SideL1 = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 90.0, degrees)),
		y + (0.49 * floatcos(-rz + 90.0, degrees)),
		z,
		0.0, -45.0, rz);

	tent_SideL2 = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 90.0, degrees)),
		y + (0.48 * floatcos(-rz + 90.0, degrees)),
		z,
		0.0, -45.0, rz);

	tent_EndF = CreateDynamicObject(19475,
		x + (1.3 * floatsin(-rz, degrees)),
		y + (1.3 * floatcos(-rz, degrees)),
		z + 0.17,
		45.0, 0.0, rz + 90);

	tent_EndB = CreateDynamicObject(19475,
		x - (1.3 * floatsin(-rz, degrees)),
		y - (1.3 * floatcos(-rz, degrees)),
		z + 0.17,
		45.0, 0.0, rz + 90);

	tent_PoleF = CreateDynamicObject(19087,
		x + (1.3 * floatsin(-rz, degrees)),
		y + (1.3 * floatcos(-rz, degrees)),
		z + 0.48,
		0.0, 0.0, rz);

	tent_PoleB = CreateDynamicObject(19087,
		x - (1.3 * floatsin(-rz, degrees)),
		y - (1.3 * floatcos(-rz, degrees)),
		z + 0.48,
		0.0, 0.0, rz);

	SetDynamicObjectMaterial(tent_SideR1, 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tent_SideR2, 0, 3095, "a51jdrx", "sam_camo", 0);
	SetDynamicObjectMaterial(tent_SideL1, 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tent_SideL2, 0, 3095, "a51jdrx", "sam_camo", 0);

	SetDynamicObjectMaterial(tent_EndF, 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tent_EndB, 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tent_PoleF, 0, 1270, "signs", "lamppost", 0);
	SetDynamicObjectMaterial(tent_PoleB, 0, 1270, "signs", "lamppost", 0);
}

CMD:tent(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:rz;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, rz);

	CreateTent(x, y, z - 0.5, rz);

	return 1;
}

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


stock TeleportPlayerToPlayer(playerid, targetid)
{
	new
		Float:px,
		Float:py,
		Float:pz,
		Float:ang,
		Float:vx,
		Float:vy,
		Float:vz,
		virtualworld = GetPlayerVirtualWorld(targetid),
		interior = GetPlayerInterior(targetid);

	if(IsPlayerInAnyVehicle(targetid))
	{
		new vehicleid = GetPlayerVehicleID(targetid);

		GetVehiclePos(vehicleid, px, py, pz);
		GetVehicleZAngle(vehicleid, ang);
		GetVehicleVelocity(vehicleid, vx, vy, vz);
		pz += 2.0;
	}
	else
	{
		GetPlayerPos(targetid, px, py, pz);
		GetPlayerFacingAngle(targetid, ang);
		GetPlayerVelocity(targetid, vx, vy, vz);
		px -= floatsin(-ang, degrees);
		py -= floatcos(-ang, degrees);
	}

	SetPlayerVirtualWorld(playerid, virtualworld);
	SetPlayerInterior(playerid, interior);

	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		SetVehiclePos(vehicleid, px, py, pz);
		SetVehicleZAngle(vehicleid, ang);
		SetVehicleVelocity(vehicleid, vx, vy, vz);
		SetVehicleVirtualWorld(vehicleid, virtualworld);
		LinkVehicleToInterior(vehicleid, interior);
	}
	else
	{
		SetPlayerPos(playerid, px, py, pz);
		SetPlayerFacingAngle(playerid, ang);
		SetPlayerVelocity(playerid, vx, vy, vz);
	}
}

stock IsValidUsername(name[])
{
	new
		i,
		len = strlen(name);

	if(len < 3)
		return 0;

	while(i < len)
	{
		switch(name[i])
		{
			case 'a'..'z', 'A'..'Z', '0'..'9', '(', ')', '[', ']', '.', '_', '$', '=', '@':
				i++;

			default:
				return 0;
		}
	}

	return 1;
}

stock GetPlayerIDFromName(name[], bool:ignorecase = false, bool:partialname = false)
{
	new
		playerid = INVALID_PLAYER_ID,
		comparison[MAX_PLAYER_NAME];

	if(partialname)
	{
		foreach(new i : Player)
		{
			GetPlayerName(i, comparison, MAX_PLAYER_NAME);

			if(!strfind(comparison, name, ignorecase))
			{
				playerid = i;
				break;
			}
		}
	}
	else
	{
		foreach(new i : Player)
		{
			GetPlayerName(i, comparison, MAX_PLAYER_NAME);

			if(!strcmp(name, comparison, ignorecase))
			{
				playerid = i;
				break;
			}
		}
	}

	return playerid;
}

stock CancelPlayerMovement(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(playerid, x, y, z);
	ClearAnimations(playerid);
	TogglePlayerControllable(playerid, false);
	TogglePlayerControllable(playerid, true);
	SetPlayerSkin(playerid, GetPlayerSkin(playerid));
}

stock SetPlayerToFacePlayer(playerid, targetid, Float:offset = 0.0)
{
	new
		Float:x1,
		Float:y1,
		Float:z1,
		Float:x2,
		Float:y2,
		Float:z2;

	GetPlayerPos(playerid, x1, y1, z1);
	GetPlayerPos(targetid, x2, y2, z2);
	SetPlayerFacingAngle(playerid, GetAngleToPoint(x1, y1, x2, y2) + offset);
}

stock SetPlayerToFaceVehicle(playerid, vehicleid, Float:offset = 0.0)
{
	new
		Float:x1,
		Float:y1,
		Float:z1,
		Float:x2,
		Float:y2,
		Float:z2;

	GetPlayerPos(playerid, x1, y1, z1);
	GetVehiclePos(vehicleid, x2, y2, z2);
	SetPlayerFacingAngle(playerid, GetAngleToPoint(x1, y1, x2, y2) + offset);
}

stock PlaySoundForAll(sound, Float:x, Float:y, Float:z, Float:range = -1.0)
{
	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, range, x, y, z) || range <= 0.0)
			PlayerPlaySound(i, sound, x, y, z);
	}

	return 1;
}

new Float:water_places[20][4] =
{
	{30.0,			2313.0,		-1417.0,	23.0},
	{15.0,			1280.0,		-773.0,		1083.0},
	{25.0,			2583.0,		2385.0,		15.0},
	{20.0,			225.0,		-1187.0,	74.0},
	{50.0,			1973.0,		-1198.0,	17.0},
	{180.0,			1937.0, 	1589.0,		9.0},
	{55.0,			2142.0,		1285.0, 	8.0},
	{45.0,			2150.0,		1132.0,		8.0},
	{55.0,			2089.0,		1915.0,		10.0},
	{32.0,			2531.0,		1567.0,		9.0},
	{21.0,			2582.0,		2385.0,		17.0},
	{33.0,			1768.0,		2853.0,		10.0},
	{47.0,			-2721.0,	-466.0,		4.0},
	{210.0,			-671.0,		-1898.0,	6.0},
	{45.0,			1240.0,		-2381.0,	9.0},
	{50.0,			1969.0,		-1200.0,	18.0},
	{10.0,			513.0,		-1105.0,	79.0},
	{20.0,			193.0,		-1230.0,	77.0},
	{30.0,			1094.0,		-672.0,		113.0},
	{20.0,			1278.0,		-805.0,		87.0}
};

stock IsPlayerInWater(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	if(z < 44.0)
	{
		if(Distance(x, y, z, -965.0, 2438.0, 42.0) <= 700.0)
			return 1;
	}

	if(z < 1.9)
		return !(Distance(x, y, z, 618.4129, 863.3164, 1.0839) < 200.0);

	for(new i; i < sizeof(water_places); i++)
	{
		if(Distance2D(x, y, water_places[i][1], water_places[i][2]) <= water_places[i][0])
		{
			if(z < water_places[i][3])
				return 1;
		}
	}

	return 0;
}

stock IsPlayerIdle(playerid)
{
	switch(GetPlayerAnimationIndex(playerid))
	{
		case 320, 471, 1164, 1183, 1188, 1189:
			return 1;
	}

	return 0;
}

stock IsPlayerInArea(playerid, Float:MinX, Float:MinY, Float:MaxX, Float:MaxY)
{
	new
		Float:x,
		Float:y,
		Float:pz;

	GetPlayerPos(playerid,x,y,pz);

	if(x >= MinX && x <= MaxX && y >= MinY && y <= MaxY)
	{
		return 1;
	}
	return 0;
}

stock Float:GetDistanceBetweenPlayers(playerid, targetid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(targetid, x, y, z);

	return GetPlayerDistanceFromPoint(playerid, x, y, z);
}

stock Float:GetPlayerAngleToPlayer(playerid, targetid)
{
	new
		Float:px,
		Float:py,
		Float:pz,
		Float:tx,
		Float:ty,
		Float:tz;

	GetPlayerPos(playerid, px, py, pz);
	GetPlayerPos(targetid, tx, ty, tz);

	return GetAngleToPoint(px, py, tx, ty);
}

stock GetClosestPlayerFromPlayer(playerid, &Float:range = 10000.0)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);
	
	return GetClosestPlayerFromPoint(x, y, z, range, playerid);
}

stock GetClosestPlayerFromPoint(Float:x, Float:y, Float:z, &Float:lowestdistance = 10000.0, exceptionid = INVALID_PLAYER_ID)
{
	new
		Float:px,
		Float:py,
		Float:pz,
		Float:distance,
		closestplayer = -1;

	foreach(new i : Player)
	{
		if(i == exceptionid)
			continue;

		GetPlayerPos(i, px, py, pz);

		distance = Distance(px, py, pz, x, y, z);

		if(distance < lowestdistance)
		{
			lowestdistance = distance;
			closestplayer = i;
		}
	}

	return closestplayer;
}

new CameraModeNames[66][37]=
{
	"MODE_NONE",
	"MODE_TOPDOWN",
	"MODE_GTACLASSIC",
	"MODE_BEHINDCAR",
	"MODE_FOLLOWPED",
	"MODE_AIMING",
	"MODE_DEBUG",
	"MODE_SNIPER",
	"MODE_ROCKETLAUNCHER",
	"MODE_MODELVIEW",
	"MODE_BILL",
	"MODE_SYPHON",
	"MODE_CIRCLE",
	"MODE_CHEESYZOOM",
	"MODE_WHEELCAM",
	"MODE_FIXED",
	"MODE_1STPERSON",
	"MODE_FLYBY",
	"MODE_CAM_ON_A_STRING",
	"MODE_REACTION",
	"MODE_FOLLOW_PED_WITH_BIND",
	"MODE_CHRIS",
	"MODE_BEHINDBOAT",
	"MODE_PLAYER_FALLEN_WATER",
	"MODE_CAM_ON_TRAIN_ROOF",
	"MODE_CAM_RUNNING_SIDE_TRAIN",
	"MODE_BLOOD_ON_THE_TRACKS",
	"MODE_IM_THE_PASSENGER_WOOWOO",
	"MODE_SYPHON_CRIM_IN_FRONT",
	"MODE_PED_DEAD_BABY",
	"MODE_PILLOWS_PAPS",
	"MODE_LOOK_AT_CARS",
	"MODE_ARRESTCAM_ONE",
	"MODE_ARRESTCAM_TWO",
	"MODE_M16_1STPERSON",
	"MODE_SPECIAL_FIXED_FOR_SYPHON",
	"MODE_FIGHT_CAM",
	"MODE_TOP_DOWN_PED",
	"MODE_LIGHTHOUSE",
	"MODE_SNIPER_RUNABOUT",
	"MODE_ROCKETLAUNCHER_RUNABOUT",
	"MODE_1STPERSON_RUNABOUT",
	"MODE_M16_1STPERSON_RUNABOUT",
	"MODE_FIGHT_CAM_RUNABOUT",
	"MODE_EDITOR",
	"MODE_HELICANNON_1STPERSON",
	"MODE_CAMERA",
	"MODE_ATTACHCAM",
	"MODE_TWOPLAYER",
	"MODE_TWOPLAYER_IN_CAR_AND_SHOOTING",
	"MODE_TWOPLAYER_SEPARATE_CARS",
	"MODE_ROCKETLAUNCHER_HS",
	"MODE_ROCKETLAUNCHER_RUNABOUT_HS",
	"MODE_AIMWEAPON",
	"MODE_TWOPLAYER_SEPARATE_CARS_TOPDOWN",
	"MODE_AIMWEAPON_FROMCAR",
	"MODE_DW_HELI_CHASE",
	"MODE_DW_CAM_MAN",
	"MODE_DW_BIRDY",
	"MODE_DW_PLANE_SPOTTER",
	"MODE_DW_DOG_FIGHT",
	"MODE_DW_FISH",
	"MODE_DW_PLANECAM1",
	"MODE_DW_PLANECAM2",
	"MODE_DW_PLANECAM3",
	"MODE_AIMWEAPON_ATTACHED"
};

stock GetCameraModeName(cameramode, output[])
{
	if(!(0 <= cameramode <= 66))
		return 0;

	output[0] = EOS;
	strcat(output, CameraModeNames[cameramode], 37);

	return 1;
}

#define PreloadAnimLib(%1,%2) ApplyAnimation(%1,%2,"null",0.0,0,0,0,0,0)
stock PreloadPlayerAnims(playerid)
{
	PreloadAnimLib(playerid, "AIRPORT");
	PreloadAnimLib(playerid, "ATTRACTORS");
	PreloadAnimLib(playerid, "BAR");
	PreloadAnimLib(playerid, "BASEBALL");
	PreloadAnimLib(playerid, "BD_FIRE");
	PreloadAnimLib(playerid, "BEACH");
	PreloadAnimLib(playerid, "BENCHPRESS");
	PreloadAnimLib(playerid, "BF_INJECTION");
	PreloadAnimLib(playerid, "BIKED");
	PreloadAnimLib(playerid, "BIKEH");
	PreloadAnimLib(playerid, "BIKELEAP");
	PreloadAnimLib(playerid, "BIKES");
	PreloadAnimLib(playerid, "BIKEV");
	PreloadAnimLib(playerid, "BIKE_DBZ");
	PreloadAnimLib(playerid, "BMX");
	PreloadAnimLib(playerid, "BOMBER");
	PreloadAnimLib(playerid, "BOX");
	PreloadAnimLib(playerid, "BSKTBALL");
	PreloadAnimLib(playerid, "BUDDY");
	PreloadAnimLib(playerid, "BUS");
	PreloadAnimLib(playerid, "CAMERA");
	PreloadAnimLib(playerid, "CAR");
	PreloadAnimLib(playerid, "CARRY");
	PreloadAnimLib(playerid, "CAR_CHAT");
	PreloadAnimLib(playerid, "CASINO");
	PreloadAnimLib(playerid, "CHAINSAW");
	PreloadAnimLib(playerid, "CHOPPA");
	PreloadAnimLib(playerid, "CLOTHES");
	PreloadAnimLib(playerid, "COACH");
	PreloadAnimLib(playerid, "COLT45");
	PreloadAnimLib(playerid, "COP_AMBIENT");
	PreloadAnimLib(playerid, "COP_DVBYZ");
	PreloadAnimLib(playerid, "CRACK");
	PreloadAnimLib(playerid, "CRIB");
	PreloadAnimLib(playerid, "DAM_JUMP");
	PreloadAnimLib(playerid, "DANCING");
	PreloadAnimLib(playerid, "DEALER");
	PreloadAnimLib(playerid, "DILDO");
	PreloadAnimLib(playerid, "DODGE");
	PreloadAnimLib(playerid, "DOZER");
	PreloadAnimLib(playerid, "DRIVEBYS");
	PreloadAnimLib(playerid, "FAT");
	PreloadAnimLib(playerid, "FIGHT_B");
	PreloadAnimLib(playerid, "FIGHT_C");
	PreloadAnimLib(playerid, "FIGHT_D");
	PreloadAnimLib(playerid, "FIGHT_E");
	PreloadAnimLib(playerid, "FINALE");
	PreloadAnimLib(playerid, "FINALE2");
	PreloadAnimLib(playerid, "FLAME");
	PreloadAnimLib(playerid, "FLOWERS");
	PreloadAnimLib(playerid, "FOOD");
	PreloadAnimLib(playerid, "FREEWEIGHTS");
	PreloadAnimLib(playerid, "GANGS");
	PreloadAnimLib(playerid, "GHANDS");
	PreloadAnimLib(playerid, "GHETTO_DB");
	PreloadAnimLib(playerid, "GOGGLES");
	PreloadAnimLib(playerid, "GRAFFITI");
	PreloadAnimLib(playerid, "GRAVEYARD");
	PreloadAnimLib(playerid, "GRENADE");
	PreloadAnimLib(playerid, "GYMNASIUM");
	PreloadAnimLib(playerid, "HAIRCUTS");
	PreloadAnimLib(playerid, "HEIST9");
	PreloadAnimLib(playerid, "INT_HOUSE");
	PreloadAnimLib(playerid, "INT_OFFICE");
	PreloadAnimLib(playerid, "INT_SHOP");
	PreloadAnimLib(playerid, "JST_BUISNESS");
	PreloadAnimLib(playerid, "KART");
	PreloadAnimLib(playerid, "KISSING");
	PreloadAnimLib(playerid, "KNIFE");
	PreloadAnimLib(playerid, "LAPDAN1");
	PreloadAnimLib(playerid, "LAPDAN2");
	PreloadAnimLib(playerid, "LAPDAN3");
	PreloadAnimLib(playerid, "LOWRIDER");
	PreloadAnimLib(playerid, "MD_CHASE");
	PreloadAnimLib(playerid, "MD_END");
	PreloadAnimLib(playerid, "MEDIC");
	PreloadAnimLib(playerid, "MISC");
	PreloadAnimLib(playerid, "MTB");
	PreloadAnimLib(playerid, "MUSCULAR");
	PreloadAnimLib(playerid, "NEVADA");
	PreloadAnimLib(playerid, "ON_LOOKERS");
	PreloadAnimLib(playerid, "OTB");
	PreloadAnimLib(playerid, "PARACHUTE");
	PreloadAnimLib(playerid, "PARK");
	PreloadAnimLib(playerid, "PAULNMAC");
	PreloadAnimLib(playerid, "PED");
	PreloadAnimLib(playerid, "PLAYER_DVBYS");
	PreloadAnimLib(playerid, "PLAYIDLES");
	PreloadAnimLib(playerid, "POLICE");
	PreloadAnimLib(playerid, "POOL");
	PreloadAnimLib(playerid, "POOR");
	PreloadAnimLib(playerid, "PYTHON");
	PreloadAnimLib(playerid, "QUAD");
	PreloadAnimLib(playerid, "QUAD_DBZ");
	PreloadAnimLib(playerid, "RAPPING");
	PreloadAnimLib(playerid, "RIFLE");
	PreloadAnimLib(playerid, "RIOT");
	PreloadAnimLib(playerid, "ROB_BANK");
	PreloadAnimLib(playerid, "ROCKET");
	PreloadAnimLib(playerid, "RUSTLER");
	PreloadAnimLib(playerid, "RYDER");
	PreloadAnimLib(playerid, "SCRATCHING");
	PreloadAnimLib(playerid, "SHAMAL");
	PreloadAnimLib(playerid, "SHOP");
	PreloadAnimLib(playerid, "SHOTGUN");
	PreloadAnimLib(playerid, "SILENCED");
	PreloadAnimLib(playerid, "SKATE");
	PreloadAnimLib(playerid, "SMOKING");
	PreloadAnimLib(playerid, "SNIPER");
	PreloadAnimLib(playerid, "SPRAYCAN");
	PreloadAnimLib(playerid, "STRIP");
	PreloadAnimLib(playerid, "SUNBATHE");
	PreloadAnimLib(playerid, "SWAT");
	PreloadAnimLib(playerid, "SWEET");
	PreloadAnimLib(playerid, "SWIM");
	PreloadAnimLib(playerid, "SWORD");
	PreloadAnimLib(playerid, "TANK");
	PreloadAnimLib(playerid, "TATTOOS");
	PreloadAnimLib(playerid, "TEC");
	PreloadAnimLib(playerid, "TRAIN");
	PreloadAnimLib(playerid, "TRUCK");
	PreloadAnimLib(playerid, "UZI");
	PreloadAnimLib(playerid, "VAN");
	PreloadAnimLib(playerid, "VENDING");
	PreloadAnimLib(playerid, "VORTEX");
	PreloadAnimLib(playerid, "WAYFARER");
	PreloadAnimLib(playerid, "WEAPONS");
	PreloadAnimLib(playerid, "WUZI");
	PreloadAnimLib(playerid, "WOP");
	PreloadAnimLib(playerid, "GFUNK");
	PreloadAnimLib(playerid, "RUNNINGMAN");
}

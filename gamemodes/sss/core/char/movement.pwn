/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


enum E_MOVEMENT_TYPE {
	E_MOVEMENT_TYPE_UNKNOWN,
	E_MOVEMENT_TYPE_IDLE,
	E_MOVEMENT_TYPE_SITTING,
	E_MOVEMENT_TYPE_CROUCHING,
	E_MOVEMENT_TYPE_JUMPING,
	E_MOVEMENT_TYPE_WALKING,
	E_MOVEMENT_TYPE_RUNNING,
	E_MOVEMENT_TYPE_STOPPING,
	E_MOVEMENT_TYPE_SPRINTING,
	E_MOVEMENT_TYPE_CLIMBING,
	E_MOVEMENT_TYPE_FALLING,
	E_MOVEMENT_TYPE_LANDING,
	E_MOVEMENT_TYPE_SWIMMING,
	E_MOVEMENT_TYPE_DIVING,
};

static E_MOVEMENT_TYPE:MovementType[MAX_PLAYERS];

static MovementTypeName[E_MOVEMENT_TYPE][] = {
	"Unknown",
	"Idle",
	"Sitting",
	"Crouching",
	"Jumping",
	"Walking",
	"Running",
	"Stopping",
	"Sprinting",
	"Climbing",
	"Falling",
	"Landing",
	"Swimming",
	"Diving"
};

ptask movementUpdate[100](playerid)
{
	if(!IsPlayerSpawned(playerid))
		return;

	new
		animidx = GetPlayerAnimationIndex(playerid),
		k,
		ud,
		lr;

	GetPlayerKeys(playerid, k, ud, lr);

	if(animidx == 1189)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_IDLE;
	}
	else if(animidx == 43)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_SITTING;
	}
	else if(animidx == 1274)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_CROUCHING;
	}
	else if(animidx == 1195 || animidx == 1197 || animidx == 1198)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_JUMPING;
	}
	else if(animidx == 1231)
	{
		if(k & KEY_WALK)
		{
			MovementType[playerid] = E_MOVEMENT_TYPE_WALKING;
		}
		else if(k & KEY_SPRINT)
		{
			MovementType[playerid] = E_MOVEMENT_TYPE_SPRINTING;
		}
		else if(k & KEY_JUMP)
		{
			MovementType[playerid] = E_MOVEMENT_TYPE_JUMPING;
		}
		else
		{
			MovementType[playerid] = E_MOVEMENT_TYPE_RUNNING;
		}
	}
	else if(animidx == 1234)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_STOPPING;
	}
	else if(animidx == 1235)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_STOPPING;
	}
	else if(animidx == 1196)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_SPRINTING;
	}
	else if(animidx == 1266)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_SPRINTING;
	}
	else if(animidx == 1061)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_CLIMBING;
	}
	else if(animidx == 1062)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_CLIMBING;
	}
	else if(animidx == 1063)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_CLIMBING;
	}
	else if(animidx == 1064)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_CLIMBING;
	}
	else if(animidx == 1065)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_CLIMBING;
	}
	else if(animidx == 1066)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_CLIMBING;
	}
	else if(animidx == 1067)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_CLIMBING;
	}
	else if(animidx == 1130)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_FALLING;
	}
	else if(animidx == 1132)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_FALLING;
	}
	else if(animidx == 1250)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_FALLING;
	}
	else if(animidx == 1129 || animidx == 1133)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_LANDING;
	}
	else if(animidx == 1208)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_LANDING;
	}
	else if(animidx == 1538)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_SWIMMING;
	}
	else if(animidx == 1539)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_SWIMMING;
	}
	else if(animidx == 1542)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_SWIMMING;
	}
	else if(animidx == 1540)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_DIVING;
	}
	else if(animidx == 1541)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_DIVING;
	}
	else if(animidx == 1544)
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_DIVING;
	}
	else
	{
		MovementType[playerid] = E_MOVEMENT_TYPE_UNKNOWN;
	}

	//ShowActionText(playerid, sprintf("Anim %d Movement: %s", animidx, MovementTypeName[MovementType[playerid]]), 0);

	return;
}

stock GetMovementTypeName(E_MOVEMENT_TYPE:type, name[])
{
	strcat(name, MovementTypeName[type]);
	return 0;
}

stock GetPlayerMovementState(playerid, &E_MOVEMENT_TYPE:type)
{
	if(!IsPlayerConnected(playerid))
		return 1;

	type = MovementType[playerid];

	return 0;
}

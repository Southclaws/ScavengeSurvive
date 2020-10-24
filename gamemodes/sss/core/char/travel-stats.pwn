/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


enum e_TRAVEL_STATS
{
Float:	STAT_DIST_WALKING,
Float:	STAT_DIST_RUNNING,
Float:	STAT_DIST_SPRINTING,
Float:	STAT_DIST_CROUCHING,
Float:	STAT_DIST_SWIMMING,
Float:	STAT_DIST_UNDERWATER,
Float:	STAT_DIST_DRIVING,
Float:	STAT_DIST_AIR,
		STAT_TIME_WALKING,
		STAT_TIME_RUNNING,
		STAT_TIME_SPRINTING,
		STAT_TIME_CROUCHING,
		STAT_TIME_SWIMMING,
		STAT_TIME_UNDERWATER,
		STAT_TIME_DRIVING,
		STAT_TIME_AIR,
		STAT_TIME_KNOCKED_OUT,
		STAT_JUMPS
}
static
		TravelStats[MAX_PLAYERS][e_TRAVEL_STATS],
Float:	TravelLastPosX[MAX_PLAYERS],
Float:	TravelLastPosY[MAX_PLAYERS],
Float:	TravelLastPosZ[MAX_PLAYERS],
		TravelLastTick[MAX_PLAYERS],
		ExpGainCooldown[MAX_PLAYERS];


hook OnPlayerScriptUpdate(playerid)
{
	new
		animidx = GetPlayerAnimationIndex(playerid),
		k,
		ud,
		lr,
		Float:x,
		Float:y,
		Float:z,
		Float:dist,
		tick,
		tick_diff;

	GetPlayerKeys(playerid, k, ud, lr);
	GetPlayerPos(playerid, x, y, z);
	tick = GetTickCount();

	dist = Distance(TravelLastPosX[playerid], TravelLastPosY[playerid], TravelLastPosZ[playerid], x, y, z);
	tick_diff = GetTickCountDifference(tick, TravelLastTick[playerid]);

	TravelLastTick[playerid] = tick;
	TravelLastPosX[playerid] = x;
	TravelLastPosY[playerid] = y;
	TravelLastPosZ[playerid] = z;

	if(IsPlayerInAnyVehicle(playerid))
	{
		if(dist > 75.0)
			return Y_HOOKS_CONTINUE_RETURN_0;

		TravelStats[playerid][STAT_DIST_DRIVING] += dist;
		TravelStats[playerid][STAT_TIME_DRIVING] += tick_diff;
	}
	else
	{
		if(dist > 25.0)
			return Y_HOOKS_CONTINUE_RETURN_0;

		if(animidx == 1231 || animidx == 1196) // Running
		{
			if(k & KEY_WALK) // Walking
			{
				TravelStats[playerid][STAT_DIST_WALKING] += dist;
				TravelStats[playerid][STAT_TIME_WALKING] += tick_diff;
			}
			else if(k & KEY_SPRINT) // Sprinting
			{
				TravelStats[playerid][STAT_DIST_SPRINTING] += dist;
				TravelStats[playerid][STAT_TIME_SPRINTING] += tick_diff;

				if(floatround(TravelStats[playerid][STAT_DIST_SPRINTING] / 10) % 50 == 0 && GetTickCountDifference(tick, ExpGainCooldown[playerid]) > 10000)
				{
					PlayerGainSkillExperience(playerid, "Endurance");
					ExpGainCooldown[playerid] = tick;
				}
			}
			else // running
			{
				TravelStats[playerid][STAT_DIST_RUNNING] += dist;
				TravelStats[playerid][STAT_TIME_RUNNING] += tick_diff;

				if(floatround(TravelStats[playerid][STAT_DIST_RUNNING] / 10) % 50 == 0 && GetTickCountDifference(tick, ExpGainCooldown[playerid]) > 10000)
				{
					PlayerGainSkillExperience(playerid, "Endurance");
					ExpGainCooldown[playerid] = tick;
				}
			}
		}
		else if(animidx == 1159 || animidx == 1274) // crouch moving
		{
			TravelStats[playerid][STAT_DIST_CROUCHING] += dist;
			TravelStats[playerid][STAT_TIME_CROUCHING] += tick_diff;
		}
		else if(animidx == 1538 || animidx == 1539) // swimming front-crawl or breastroke
		{
			TravelStats[playerid][STAT_DIST_SWIMMING] += dist;
			TravelStats[playerid][STAT_TIME_SWIMMING] += tick_diff;

			if(floatround(TravelStats[playerid][STAT_DIST_SWIMMING] / 10) % 20 == 0 && GetTickCountDifference(tick, ExpGainCooldown[playerid]) > 10000)
			{
				PlayerGainSkillExperience(playerid, "Endurance");
				ExpGainCooldown[playerid] = tick;
			}
		}
		else if(animidx == 1541 || animidx == 1544) // swimming under water
		{
			TravelStats[playerid][STAT_DIST_UNDERWATER] += dist;
			TravelStats[playerid][STAT_TIME_UNDERWATER] += tick_diff;

			if(floatround(TravelStats[playerid][STAT_DIST_UNDERWATER] / 10) % 20 == 0 && GetTickCountDifference(tick, ExpGainCooldown[playerid]) > 10000)
			{
				PlayerGainSkillExperience(playerid, "Endurance");
				ExpGainCooldown[playerid] = tick;
			}
		}
		else if(animidx == 1195 || animidx == 1197 || animidx == 1130 || animidx == 1132) // falling
		{
			TravelStats[playerid][STAT_DIST_AIR] += dist;
			TravelStats[playerid][STAT_TIME_AIR] += tick_diff;
		}
	}

	if(IsPlayerKnockedOut(playerid))
	{
		TravelStats[playerid][STAT_TIME_KNOCKED_OUT] += tick_diff;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

static AlreadyJumping[MAX_PLAYERS];

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_JUMP)
	{
		new animidx = GetPlayerAnimationIndex(playerid);

		if(animidx == 1231 || animidx == 1196)
		{
			defer JumpBoost(playerid);
		}
		if(animidx == 1195 || animidx == 1197)
		{
			AlreadyJumping[playerid] = true;
		}
	}

	if(oldkeys & KEY_JUMP)
	{
		if(!AlreadyJumping[playerid])
		{
			new animidx = GetPlayerAnimationIndex(playerid);
			if(animidx == 1195 || animidx == 1197)
			{
				TravelStats[playerid][STAT_JUMPS] += 1;

				if((TravelStats[playerid][STAT_JUMPS] / 10) % 10 == 0)
					PlayerGainSkillExperience(playerid, "Endurance");
			}
		}
		else
		{
			AlreadyJumping[playerid] = false;
		}
	}
}

timer JumpBoost[0](playerid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:boost;

	GetPlayerVelocity(playerid, x, y, z);

	boost = 1.0 + (1.3 * GetPlayerSkillValue(playerid, "Endurance"));

	SetPlayerVelocity(playerid, x * boost, y * boost, z * boost);
}

hook OnPlayerSave(playerid, filename[])
{
	modio_push(filename, _T<T,R,A,V>, _:e_TRAVEL_STATS, TravelStats[playerid]);
}

hook OnPlayerLoad(playerid, filename[])
{
	modio_read(filename, _T<T,R,A,V>, _:e_TRAVEL_STATS, TravelStats[playerid]);
}

CMD:mstats(playerid, params[])
{
	new str[400];
	format(str, sizeof(str),
		"DIST_WALKING: %f\n\
		DIST_RUNNING: %f\n\
		DIST_SPRINTING: %f\n\
		DIST_CROUCHING: %f\n\
		DIST_SWIMMING: %f\n\
		DIST_UNDERWATER: %f\n\
		DIST_DRIVING: %f\n\
		DIST_AIR: %f\n\
		TIME_WALKING: %d\n\
		TIME_RUNNING: %d\n\
		TIME_SPRINTING: %d\n\
		TIME_CROUCHING: %d\n\
		TIME_SWIMMING: %d\n\
		TIME_UNDERWATER: %d\n\
		TIME_DRIVING: %d\n\
		TIME_AIR: %d\n\
		TIME_KNOCKED_OUT: %d\n\
		JUMPS: %d\n",
		TravelStats[playerid][STAT_DIST_WALKING],
		TravelStats[playerid][STAT_DIST_RUNNING],
		TravelStats[playerid][STAT_DIST_SPRINTING],
		TravelStats[playerid][STAT_DIST_CROUCHING],
		TravelStats[playerid][STAT_DIST_SWIMMING],
		TravelStats[playerid][STAT_DIST_UNDERWATER],
		TravelStats[playerid][STAT_DIST_DRIVING],
		TravelStats[playerid][STAT_DIST_AIR],
		TravelStats[playerid][STAT_TIME_WALKING],
		TravelStats[playerid][STAT_TIME_RUNNING],
		TravelStats[playerid][STAT_TIME_SPRINTING],
		TravelStats[playerid][STAT_TIME_CROUCHING],
		TravelStats[playerid][STAT_TIME_SWIMMING],
		TravelStats[playerid][STAT_TIME_UNDERWATER],
		TravelStats[playerid][STAT_TIME_DRIVING],
		TravelStats[playerid][STAT_TIME_AIR],
		TravelStats[playerid][STAT_TIME_KNOCKED_OUT],
		TravelStats[playerid][STAT_JUMPS]);

	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "Movement statistics", str, "Close", "");

	return 1;
}
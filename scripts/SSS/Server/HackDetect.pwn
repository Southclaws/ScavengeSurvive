#include <YSI\y_hooks>


#define DETECTION_DISTANCE (40.0)


ptask AntiCheatUpdate[1000](playerid)
{
	PositionCheck(playerid);
	WeaponCheck(playerid);

	if(GetPlayerMoney(playerid) > 0)
		BanPlayer(playerid, "Having over 0 money (Money can't be obtained in the server, must be a hack)", -1);
}


// Anti-teleport


new
		tp_SetPosTick		[MAX_PLAYERS],
Float:	tp_CurPos			[MAX_PLAYERS][3],
Float:	tp_SetPos			[MAX_PLAYERS][3],
		tp_PosReportTick	[MAX_PLAYERS],
		tp_DetectDelay		[MAX_PLAYERS];


Detect_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	tp_SetPosTick[playerid] = tickcount();
	tp_SetPos[playerid][0] = x;
	tp_SetPos[playerid][1] = y;
	tp_SetPos[playerid][2] = z;

	return SetPlayerPos(playerid, x, y, z);
}
#define SetPlayerPos Detect_SetPlayerPos

hook OnPlayerSpawn(playerid)
{
	tp_SetPosTick[playerid] = tickcount();
	tp_DetectDelay[playerid] = tickcount();
	GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
}

PositionCheck(playerid)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
	{
		BanPlayer(playerid, "Having a jetpack (Jetpacks aren't in this server, must have been hacked)", -1);
		return;
	}

	if(
		IsAutoSaving() ||
		IsPlayerInAnyVehicle(playerid) ||
		IsPlayerOnZipline(playerid) ||
		tickcount() - GetPlayerVehicleExitTick(playerid) < 5000 ||
		tickcount() - GetPlayerServerJoinTick(playerid) < 10000 ||
		IsPlayerDead(playerid) ||
		IsPlayerOnAdminDuty(playerid) ||
		IsValidVehicle(GetPlayerSurfingVehicleID(playerid)))
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		tp_DetectDelay[playerid] = tickcount();
		return;
	}

	if(tickcount() - tp_DetectDelay[playerid] < 10000)
	{
		GetPlayerPos(playerid, tp_CurPos[playerid][0], tp_CurPos[playerid][1], tp_CurPos[playerid][2]);
		return;
	}

	new
		Float:x,
		Float:y,
		Float:z,
		Float:distance;

	GetPlayerPos(playerid, x, y, z);
	distance = Distance2D(x, y, tp_CurPos[playerid][0], tp_CurPos[playerid][1]);

	if(distance > DETECTION_DISTANCE)
	{
		if(tickcount() - tp_SetPosTick[playerid] > 5000)
		{
			if(tickcount() - tp_PosReportTick[playerid] > 10000)
			{
				new
					name[24],
					reason[32];

				GetPlayerName(playerid, name, 24);
				format(reason, sizeof(reason), "Moved %.2fm in 1 second", distance);
				ReportPlayer(name, reason, -1);

				tp_PosReportTick[playerid] = tickcount();
			}
		}
		else
		{
			if(tickcount() - tp_PosReportTick[playerid] > 10000)
			{
				distance = Distance(x, y, z, tp_SetPos[playerid][0], tp_SetPos[playerid][1], tp_SetPos[playerid][2]);
				if(distance > DETECTION_DISTANCE)
				{
					new
						name[24],
						reason[32];

					GetPlayerName(playerid, name, 24);
					format(reason, sizeof(reason), "Moved %.2fm in 1 second", distance);
					ReportPlayer(name, reason, -1);

					tp_PosReportTick[playerid] = tickcount();
				}
			}
		}
	}

	tp_CurPos[playerid][0] = x;
	tp_CurPos[playerid][1] = y;
	tp_CurPos[playerid][2] = z;

	return;
}


// Anti-weapon spawn


#define WEAPON_OFFENSE_MAX (3)


new
	WeaponOffenseStrike[MAX_PLAYERS];

WeaponCheck(playerid)
{
	if(tickcount() - GetPlayerWeaponSwapTick(playerid))
		return;

	new
		actualweapon = GetPlayerWeapon(playerid),
		itemweapon = GetPlayerCurrentWeapon(playerid);

	if(actualweapon != 0)
	{
		if(actualweapon != itemweapon)
		{
			WeaponOffenseStrike[playerid]++;

			if(WeaponOffenseStrike[playerid] == WEAPON_OFFENSE_MAX)
			{
				new
					name[24],
					weaponname1[32],
					weaponname2[32],
					reason[128];

				GetPlayerName(playerid, name, 24);
				GetItemTypeName(ItemType:actualweapon, weaponname1);
				GetItemTypeName(ItemType:itemweapon, weaponname2);

				format(reason, sizeof(reason), " >  '%s' Used {33CCFF}%d (%s) {FFFF00}when should have {33CCFF}%d (%s){FFFF00}. (TEST REPORT)", name, actualweapon, weaponname1, itemweapon, weaponname2);

				//ReportPlayer(name, reason, -1);
				MsgAdmins(2, 0xFFFF00FF, reason);

				WeaponOffenseStrike[playerid] = 0;
			}
		}
	}

	return;
}

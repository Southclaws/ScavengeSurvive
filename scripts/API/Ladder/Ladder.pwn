#include <YSI\y_hooks>

#define MAX_LADDER (16)

#define CLIMB_SPEED (0.1)
#define IDLE_SPEED  (0.01)


enum E_LADDER_DATA
{
	ldr_areaID,
	Float:ldr_posX,
	Float:ldr_posY,
	Float:ldr_base,
	Float:ldr_top,
	Float:ldr_ang
}


new
	ldr_Data[MAX_LADDER][E_LADDER_DATA],
    Iterator:ldr_Iterator<MAX_LADDER>,

	ldr_currentAnim[MAX_PLAYERS],
	ldr_currentLadder[MAX_PLAYERS],
	ldr_enterLadderTick[MAX_PLAYERS];


#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		ldr_currentLadder[i]=-1;
	}
    return CallLocalFunction("ldr_OnFilterScriptInit", "");
}
#if defined _ALS_OnFilterScriptInit
    #undef OnFilterScriptInit
#else
    #define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit ldr_OnFilterScriptInit
forward ldr_OnFilterScriptInit();

#else

public OnGameModeInit()
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		ldr_currentLadder[i]=-1;
	}
    return CallLocalFunction("ldr_OnGameModeInit", "");
}
#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit ldr_OnGameModeInit
forward ldr_OnGameModeInit();

#endif


stock CreateLadder(Float:x, Float:y, Float:z, Float:height, Float:angle, world = -1, interior = -1)
{
	new id = Iter_Free(ldr_Iterator);

	ldr_Data[id][ldr_areaID] = CreateDynamicCircle(x, y, 1.0, world, interior);
	ldr_Data[id][ldr_posX] = x;
	ldr_Data[id][ldr_posY] = y;
	ldr_Data[id][ldr_base] = z;
	ldr_Data[id][ldr_top] = height;
	ldr_Data[id][ldr_ang] = angle;

	Iter_Add(ldr_Iterator, id);
	return id;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 16)
	{
		foreach(new i : ldr_Iterator)
		{
		    if(IsPlayerInDynamicArea(playerid, ldr_Data[i][ldr_areaID]))
		    {
		        if(ldr_currentLadder[playerid]==-1)EnterLadder(playerid, i);
		        else ExitLadder(playerid);
		    }
		}
	}
    return 1;
}


EnterLadder(playerid, ladder)
{
	new
		Float:z,
		Float:zOffset;

	GetPlayerPos(playerid, z, z, z);

	if(floatabs(z - ldr_Data[ladder][ldr_top]) < 2.0)
		zOffset = ldr_Data[ladder][ldr_top] - 2.0926;

	else if(floatabs(z - ldr_Data[ladder][ldr_base]) < 2.0)
		zOffset = ldr_Data[ladder][ldr_base] + 1.5;

	else
		zOffset = z;

	ClearAnimations(playerid);
	SetPlayerFacingAngle(playerid, ldr_Data[ladder][ldr_ang]);
	SetPlayerPos(playerid, ldr_Data[ladder][ldr_posX], ldr_Data[ladder][ldr_posY], zOffset);

	ApplyAnimation(playerid, "PED", "CLIMB_IDLE", 3.0, 0, 0, 0, 1, 0, 1);
    ldr_enterLadderTick[playerid] = GetTickCount();
    ldr_currentLadder[playerid] = ladder;
}
ExitLadder(playerid)
{
	ClearAnimations(playerid);
	SetPlayerFacingAngle(playerid, ldr_Data[ldr_currentLadder[playerid]][ldr_ang]);

	SetPlayerVelocity(playerid,
		0.1*floatsin(-ldr_Data[ldr_currentLadder[playerid]][ldr_ang], degrees),
		0.1*floatcos(-ldr_Data[ldr_currentLadder[playerid]][ldr_ang], degrees), 0.1);

    ldr_currentLadder[playerid] = -1;
    return 1;
}
public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : ldr_Iterator)
	{
	    if(areaid == ldr_Data[i][ldr_areaID])
	    {
	        ShowMsgBox(playerid, "Press F to climb", 0, 120);
	    }
	}
    return CallLocalFunction("ldr_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea ldr_OnPlayerEnterDynamicArea
forward ldr_OnPlayerEnterDynamicArea(playerid, areaid);


public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	HideMsgBox(playerid);
    return CallLocalFunction("ldr_OnPlayerLeaveDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerLeaveDynamicArea
    #undef OnPlayerLeaveDynamicArea
#else
    #define _ALS_OnPlayerLeaveDynamicArea
#endif
#define OnPlayerLeaveDynamicArea ldr_OnPlayerLeaveDynamicArea
forward ldr_OnPlayerLeaveDynamicArea(playerid, areaid);


public OnPlayerUpdate(playerid)
{
	if(ldr_currentLadder[playerid] != -1)
	{
		new
			k,
			ud,
			lr,
			Float:z;

		GetPlayerKeys(playerid, k, ud, lr);
		GetPlayerPos(playerid, z, z, z);

		if(GetTickCount()-ldr_enterLadderTick[playerid] > 1000 &&
			( z-ldr_Data[ldr_currentLadder[playerid]][ldr_base]<0.5 || z >= ldr_Data[ldr_currentLadder[playerid]][ldr_top]-0.5) )
		{
			ExitLadder(playerid);
			goto end;
		}

		if(ud == KEY_UP)
		{
			if(ldr_currentAnim[playerid])
			{
				ApplyAnimation(playerid, "FINALE", "FIN_HANG_LOOP", 4.0, 1, 0, 0, 0, 0);
	//		    ApplyAnimation(playerid, "PED", "CLIMB_JUMP", 3.0, 0, 0, 0, 1, 0, 1);
			    ldr_currentAnim[playerid]=0;
				SetPlayerVelocity(playerid, 0.0, 0.0, CLIMB_SPEED);
			}
			else
			{
	//		    ApplyAnimation(playerid, "FINALE", "FIN_HANG_LOOP", 4.0, 1, 0, 0, 0, 0);
			    ApplyAnimation(playerid, "PED", "CLIMB_IDLE", 3.0, 0, 0, 0, 1, 0, 1);
			    ldr_currentAnim[playerid]=1;
			}
		}
		else if(ud == KEY_DOWN)
		{
			if(ldr_currentAnim[playerid])
			{
				ApplyAnimation(playerid, "FINALE", "FIN_HANG_LOOP", 4.0, 1, 0, 0, 0, 0);
	//		    ApplyAnimation(playerid, "PED", "CLIMB_JUMP", 3.0, 0, 0, 0, 1, 0, 1);
			    ldr_currentAnim[playerid]=0;
			}
			else
			{
	//			ApplyAnimation(playerid, "FINALE", "FIN_HANG_LOOP", 4.0, 1, 0, 0, 0, 0);
			    ApplyAnimation(playerid, "PED", "CLIMB_IDLE", 3.0, 0, 0, 0, 1, 0, 1);
			    ldr_currentAnim[playerid]=1;
				SetPlayerVelocity(playerid, 0.0, 0.0, -(CLIMB_SPEED*0.7));
			}
		}
		else
		{
		    ApplyAnimation(playerid, "PED", "CLIMB_IDLE", 3.0, 0, 0, 0, 1, 0, 1);
			SetPlayerVelocity(playerid, 0.0, 0.0, IDLE_SPEED);
		}
	}
	
	end:
	
    return CallLocalFunction("ldr_OnPlayerUpdate", "d", playerid);
}
#if defined _ALS_OnPlayerUpdate
    #undef OnPlayerUpdate
#else
    #define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate ldr_OnPlayerUpdate
forward ldr_OnPlayerUpdate(playerid);


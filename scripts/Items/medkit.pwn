#include <YSI\y_hooks>


#define MEDKIT_PROGRESS_MAX (40.0)


new
ItemType:	item_Medkit = INVALID_ITEM_TYPE,
Timer:		gPlayerMedkitTimer[MAX_PLAYERS],
Float:		gPlayerMedkitProgress[MAX_PLAYERS],
			gPlayerMedkitTarget[MAX_PLAYERS],
Bit1:		gPlayerUsingMedkit<MAX_PLAYERS>;


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetItemType(GetPlayerItem(playerid)) == item_Medkit)
	{
		if(newkeys == 16)
		{
		    gPlayerMedkitTarget[playerid] = playerid;
			foreach(new i : Character)
			{
			    if(i == playerid)continue;

				if(IsPlayerInDynamicArea(playerid, gPlayerArea[i]) && !IsPlayerInAnyVehicle(i))
				{
					gPlayerMedkitTarget[playerid] = i;
				}
			}
			gPlayerMedkitTimer[playerid] = defer MedkitStartUse(playerid);
		}
		if(oldkeys == 16)
		{
			stop gPlayerMedkitTimer[playerid];
			if(Bit1_Get(gPlayerUsingMedkit, playerid))
			{
	        	Bit1_Set(gPlayerUsingMedkit, playerid, false);
				HidePlayerProgressBar(playerid, ActionBar);
				if(gPlayerMedkitTarget[playerid] != playerid)
				{
					HidePlayerProgressBar(gPlayerMedkitTarget[playerid], ActionBar);
					ClearAnimations(gPlayerMedkitTarget[playerid]);
				}
				ClearAnimations(playerid);
			}
		}
	}
    return 1;
}


public OnPlayerEnterPlayerArea(playerid, targetid)
{
	if(GetItemType(GetPlayerItem(playerid)) == item_Medkit)
	{
		ShowMsgBox(playerid, "Press N to give~n~Hold F to heal");
	}
    return CallLocalFunction("med_OnPlayerEnterPlayerArea", "dd", playerid, targetid);
}
#if defined _ALS_OnPlayerEnterPlayerArea
    #undef OnPlayerEnterPlayerArea
#else
    #define _ALS_OnPlayerEnterPlayerArea
#endif
#define OnPlayerEnterPlayerArea med_OnPlayerEnterPlayerArea
forward med_OnPlayerEnterPlayerArea(playerid, targetid);


public OnPlayerLeavePlayerArea(playerid, targetid)
{
	HideMsgBox(playerid);

    return CallLocalFunction("med_OnPlayerLeavePlayerArea", "dd", playerid, targetid);
}
#if defined _ALS_OnPlayerLeavePlayerArea
    #undef OnPlayerLeavePlayerArea
#else
    #define _ALS_OnPlayerLeavePlayerArea
#endif
#define OnPlayerLeavePlayerArea med_OnPlayerLeavePlayerArea
forward med_OnPlayerLeavePlayerArea(playerid, targetid);



timer MedkitStartUse[100](playerid)
{
	Bit1_Set(gPlayerUsingMedkit, playerid, true);
	gPlayerMedkitProgress[playerid] = 0.0;
	SetPlayerProgressBarMaxValue(playerid, ActionBar, MEDKIT_PROGRESS_MAX);
	SetPlayerProgressBarValue(playerid, ActionBar, 0.0);

	if(gPlayerMedkitTarget[playerid] != playerid)
	{
		SetPlayerProgressBarMaxValue(gPlayerMedkitTarget[playerid], ActionBar, MEDKIT_PROGRESS_MAX);
		SetPlayerProgressBarValue(gPlayerMedkitTarget[playerid], ActionBar, 0.0);

		ApplyAnimation(playerid, "PED", "ATM", 4.0, 0, 0, 0, 0, 0);
		gPlayerMedkitTimer[playerid] = repeat MedkitHealUpdate(playerid);
	}
	else
	{
		ApplyAnimation(playerid, "CAMERA", "CAMSTND_TO_CAMCRCH", 4.0, 0, 0, 0, 0, 0);
		gPlayerMedkitTimer[playerid] = defer MedkitAnimEnter(playerid);
	}
}
timer MedkitAnimEnter[700](playerid)
{
	ApplyAnimation(playerid, "CAMERA", "PICCRCH_TAKE", 4.0, 1, 0, 0, 0, 0); // heal 1000
	gPlayerMedkitTimer[playerid] = repeat MedkitHealUpdate(playerid);
}
timer MedkitHealUpdate[100](playerid)
{
	gPlayerMedkitProgress[playerid] += 1.0;
	
	SetPlayerProgressBarValue(playerid, ActionBar, gPlayerMedkitProgress[playerid]);
	ShowPlayerProgressBar(playerid, ActionBar);

	if(gPlayerMedkitTarget[playerid] != playerid)
	{
		new
			Float:x1,
			Float:y1,
			Float:z1,
			Float:x2,
			Float:y2,
			Float:z2;

		GetPlayerPos(playerid, x1, y1, z1);
		GetPlayerPos(gPlayerMedkitTarget[playerid], x2, y2, z2);
		SetPlayerFacingAngle(playerid, GetAngleToPoint(x1, y1, x2, y2));

		SetPlayerProgressBarValue(gPlayerMedkitTarget[playerid], ActionBar, gPlayerMedkitProgress[playerid]);
		ShowPlayerProgressBar(gPlayerMedkitTarget[playerid], ActionBar);
	}

	if(gPlayerMedkitProgress[playerid] >= MEDKIT_PROGRESS_MAX)
	{
		stop gPlayerMedkitTimer[playerid];

		HidePlayerProgressBar(playerid, ActionBar);
		if(gPlayerMedkitTarget[playerid] != playerid)
		{
			HidePlayerProgressBar(gPlayerMedkitTarget[playerid], ActionBar);
			ClearAnimations(gPlayerMedkitTarget[playerid]);
			
			MsgF(playerid, YELLOW, " >  You healed %P", gPlayerMedkitTarget[playerid]);
			
		}
		else Msg(playerid, YELLOW, " >  You healed yourself");

		ClearAnimations(playerid);
		GivePlayerHP(gPlayerMedkitTarget[playerid], 50.0);
		DestroyItem(GetPlayerItem(playerid));
		HideMsgBox(playerid);

		gPlayerMedkitTarget[playerid] = INVALID_PLAYER_ID;
	}
}



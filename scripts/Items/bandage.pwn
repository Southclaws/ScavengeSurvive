#include <YSI\y_hooks>


#define BANDAGE_PROGRESS_MAX (40.0)


new
ItemType:	item_Bandage = INVALID_ITEM_TYPE,
Timer:		gPlayerBandageTimer[MAX_PLAYERS],
Float:		gPlayerBandageProgress[MAX_PLAYERS],
			gPlayerBandageTarget[MAX_PLAYERS],
Bit1:		gPlayerUsingBandage<MAX_PLAYERS>;


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetItemType(GetPlayerItem(playerid)) == item_Bandage)
	{
		if(newkeys == 16)
		{
			if(bPlayerGameSettings[playerid] & KnockedOut)
				return 0;

			gPlayerBandageTarget[playerid] = playerid;
			foreach(new i : Character)
			{
				if(i == playerid)continue;

				if(IsPlayerInDynamicArea(playerid, gPlayerArea[i]) && !IsPlayerInAnyVehicle(i))
				{
					gPlayerBandageTarget[playerid] = i;
				}
			}
			gPlayerBandageTimer[playerid] = defer BandageStartUse(playerid);
		}
		if(oldkeys == 16)
		{
			stop gPlayerBandageTimer[playerid];
			if(Bit1_Get(gPlayerUsingBandage, playerid))
			{
				Bit1_Set(gPlayerUsingBandage, playerid, false);
				HidePlayerProgressBar(playerid, ActionBar);
				if(gPlayerBandageTarget[playerid] != playerid)
				{
					HidePlayerProgressBar(gPlayerBandageTarget[playerid], ActionBar);
					ClearAnimations(gPlayerBandageTarget[playerid]);
				}
				ClearAnimations(playerid);
			}
		}
	}
	return 1;
}


timer BandageStartUse[100](playerid)
{
	Bit1_Set(gPlayerUsingBandage, playerid, true);
	gPlayerBandageProgress[playerid] = 0.0;
	SetPlayerProgressBarMaxValue(playerid, ActionBar, BANDAGE_PROGRESS_MAX);
	SetPlayerProgressBarValue(playerid, ActionBar, 0.0);

	if(gPlayerBandageTarget[playerid] != playerid)
	{
		SetPlayerProgressBarMaxValue(gPlayerBandageTarget[playerid], ActionBar, BANDAGE_PROGRESS_MAX);
		SetPlayerProgressBarValue(gPlayerBandageTarget[playerid], ActionBar, 0.0);

		if(bPlayerGameSettings[gPlayerBandageTarget[playerid]] & KnockedOut)
			ApplyAnimation(playerid, "MEDIC", "CPR", 4.0, 0, 0, 0, 0, 0);

		else
			ApplyAnimation(playerid, "PED", "ATM", 4.0, 0, 0, 0, 0, 0);

		gPlayerBandageTimer[playerid] = repeat BandageHealUpdate(playerid);
	}
	else
	{
		ApplyAnimation(playerid, "CAMERA", "CAMSTND_TO_CAMCRCH", 4.0, 0, 0, 0, 0, 0);
		gPlayerBandageTimer[playerid] = defer BandageAnimEnter(playerid);
	}
}
timer BandageAnimEnter[700](playerid)
{
	ApplyAnimation(playerid, "CAMERA", "PICCRCH_TAKE", 4.0, 1, 0, 0, 0, 0);
	gPlayerBandageTimer[playerid] = repeat BandageHealUpdate(playerid);
}
timer BandageHealUpdate[100](playerid)
{
	gPlayerBandageProgress[playerid] += 1.0;
	
	SetPlayerProgressBarValue(playerid, ActionBar, gPlayerBandageProgress[playerid]);
	ShowPlayerProgressBar(playerid, ActionBar);

	if(gPlayerBandageTarget[playerid] != playerid)
	{
		new
			Float:x1,
			Float:y1,
			Float:z1,
			Float:x2,
			Float:y2,
			Float:z2;

		GetPlayerPos(playerid, x1, y1, z1);
		GetPlayerPos(gPlayerBandageTarget[playerid], x2, y2, z2);
		SetPlayerFacingAngle(playerid, GetAngleToPoint(x1, y1, x2, y2));

		SetPlayerProgressBarValue(gPlayerBandageTarget[playerid], ActionBar, gPlayerBandageProgress[playerid]);
		ShowPlayerProgressBar(gPlayerBandageTarget[playerid], ActionBar);
	}

	if(gPlayerBandageProgress[playerid] >= BANDAGE_PROGRESS_MAX)
	{
		stop gPlayerBandageTimer[playerid];

		HidePlayerProgressBar(playerid, ActionBar);
		if(gPlayerBandageTarget[playerid] != playerid)
		{
			HidePlayerProgressBar(gPlayerBandageTarget[playerid], ActionBar);
			ClearAnimations(gPlayerBandageTarget[playerid]);	

			if(bPlayerGameSettings[gPlayerMedkitTarget[playerid]] & KnockedOut)
			{
				ApplyAnimation(playerid, "PED", "GETUP_FRONT", 4.0, 0, 1, 1, 0, 0);
				f:bPlayerGameSettings[gPlayerMedkitTarget[playerid]]<KnockedOut>;
			}
		}

		ClearAnimations(playerid);
		GivePlayerHP(gPlayerBandageTarget[playerid], 20.0);
		f:bPlayerGameSettings[gPlayerBandageTarget[playerid]]<Bleeding>;
		DestroyItem(GetPlayerItem(playerid));
		HideMsgBox(playerid);

		gPlayerBandageTarget[playerid] = INVALID_PLAYER_ID;
	}
}



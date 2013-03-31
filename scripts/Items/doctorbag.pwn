#include <YSI\y_hooks>


#define DOCBAG_PROGRESS_MAX (40.0)


new
Timer:		gPlayerDocBagTimer[MAX_PLAYERS],
Float:		gPlayerDocBagProgress[MAX_PLAYERS],
			gPlayerDocBagTarget[MAX_PLAYERS],
Bit1:		gPlayerUsingDocBag<MAX_PLAYERS>;


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetItemType(GetPlayerItem(playerid)) == item_DoctorBag)
	{
		if(newkeys == 16)
		{
			if(bPlayerGameSettings[playerid] & KnockedOut)
				return 0;

			gPlayerDocBagTarget[playerid] = playerid;
			foreach(new i : Character)
			{
				if(i == playerid)continue;

				if(IsPlayerInDynamicArea(playerid, gPlayerArea[i]) && !IsPlayerInAnyVehicle(i))
				{
					gPlayerDocBagTarget[playerid] = i;
				}
			}
			PlayerUseBandage(playerid);
		}
		if(oldkeys == 16)
		{
			stop gPlayerDocBagTimer[playerid];
			if(Bit1_Get(gPlayerUsingDocBag, playerid))
			{
				Bit1_Set(gPlayerUsingDocBag, playerid, false);
				HidePlayerProgressBar(playerid, ActionBar);
				if(gPlayerDocBagTarget[playerid] != playerid)
				{
					HidePlayerProgressBar(gPlayerDocBagTarget[playerid], ActionBar);
					ClearAnimations(gPlayerDocBagTarget[playerid]);
				}
				ClearAnimations(playerid);
			}
		}
	}
	return 1;
}


PlayerUseBandage(playerid, target)
{
	Bit1_Set(gPlayerUsingDocBag, playerid, true);
	gPlayerDocBagProgress[playerid] = 0.0;
	gPlayerDocBagTarget[playerid] = target;
	SetPlayerProgressBarMaxValue(playerid, ActionBar, DOCBAG_PROGRESS_MAX);
	SetPlayerProgressBarValue(playerid, ActionBar, 0.0);

	if(target != playerid)
	{
		SetPlayerProgressBarMaxValue(target, ActionBar, DOCBAG_PROGRESS_MAX);
		SetPlayerProgressBarValue(target, ActionBar, 0.0);

		if(bPlayerGameSettings[target] & KnockedOut)
			ApplyAnimation(playerid, "MEDIC", "CPR", 4.0, 0, 0, 0, 0, 0);

		else
			ApplyAnimation(playerid, "PED", "ATM", 4.0, 0, 0, 0, 0, 0);

		gPlayerDocBagTimer[playerid] = repeat BandageHealUpdate(playerid);
	}
	else
	{
		ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 0, 0, 0, 0, 0);
		gPlayerDocBagTimer[playerid] = repeat BandageHealUpdate(playerid);
	}
}
timer BandageHealUpdate[100](playerid)
{
	gPlayerDocBagProgress[playerid] += 1.0;
	
	SetPlayerProgressBarValue(playerid, ActionBar, gPlayerDocBagProgress[playerid]);
	ShowPlayerProgressBar(playerid, ActionBar);

	if(gPlayerDocBagTarget[playerid] != playerid)
	{
		new
			Float:x1,
			Float:y1,
			Float:z1,
			Float:x2,
			Float:y2,
			Float:z2;

		GetPlayerPos(playerid, x1, y1, z1);
		GetPlayerPos(gPlayerDocBagTarget[playerid], x2, y2, z2);
		SetPlayerFacingAngle(playerid, GetAngleToPoint(x1, y1, x2, y2));

		SetPlayerProgressBarValue(gPlayerDocBagTarget[playerid], ActionBar, gPlayerDocBagProgress[playerid]);
		ShowPlayerProgressBar(gPlayerDocBagTarget[playerid], ActionBar);
	}

	if(gPlayerDocBagProgress[playerid] >= DOCBAG_PROGRESS_MAX)
	{
		stop gPlayerDocBagTimer[playerid];

		HidePlayerProgressBar(playerid, ActionBar);
		if(gPlayerDocBagTarget[playerid] != playerid)
		{
			HidePlayerProgressBar(gPlayerDocBagTarget[playerid], ActionBar);
			ClearAnimations(gPlayerDocBagTarget[playerid]);	

			if(bPlayerGameSettings[gPlayerDocBagTarget[playerid]] & KnockedOut)
			{
				ApplyAnimation(playerid, "PED", "GETUP_FRONT", 4.0, 0, 1, 1, 0, 0);
				f:bPlayerGameSettings[gPlayerDocBagTarget[playerid]]<KnockedOut>;
			}
		}

		ClearAnimations(playerid);
		GivePlayerHP(gPlayerDocBagTarget[playerid], 70.0);
		f:bPlayerGameSettings[gPlayerDocBagTarget[playerid]]<Bleeding>;
		DestroyItem(GetPlayerItem(playerid));
		HideMsgBox(playerid);

		gPlayerDocBagTarget[playerid] = INVALID_PLAYER_ID;
	}
}



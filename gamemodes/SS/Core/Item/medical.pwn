#include <YSI\y_hooks>


#define HEAL_PROGRESS_MAX (4000)
#define REVIVE_PROGRESS_MAX (6000)


new med_HealTarget[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	med_HealTarget[playerid] = INVALID_PLAYER_ID;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

	if(itemtype == item_Medkit || itemtype == item_Bandage || itemtype == item_DoctorBag)
	{
		if(newkeys == 16)
		{
			if(gPlayerBitData[playerid] & KnockedOut)
				return 0;

			med_HealTarget[playerid] = playerid;
			foreach(new i : Character)
			{
				if(IsPlayerInPlayerArea(playerid, i) && !IsPlayerInAnyVehicle(i))
					med_HealTarget[playerid] = i;
			}
			PlayerStartHeal(playerid, med_HealTarget[playerid]);
		}
		if(oldkeys == 16)
		{
			PlayerStopHeal(playerid);
		}
	}
	return 1;
}


PlayerStartHeal(playerid, target)
{
	new duration = HEAL_PROGRESS_MAX;

	med_HealTarget[playerid] = target;

	if(target != playerid)
	{
		if(gPlayerBitData[target] & KnockedOut)
		{
			ApplyAnimation(playerid, "MEDIC", "CPR", 4.0, 1, 0, 0, 0, 0);
			duration = REVIVE_PROGRESS_MAX;
		}
		else
		{
			ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
		}

		SetPlayerProgressBarMaxValue(target, ActionBar, duration);
		SetPlayerProgressBarValue(target, ActionBar, 0.0);
	}
	else
	{
		ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 0, 0);
	}

	StartHoldAction(playerid, duration);
}

PlayerStopHeal(playerid)
{
	if(med_HealTarget[playerid] != INVALID_PLAYER_ID)
	{
		if(med_HealTarget[playerid] != playerid)
			HidePlayerProgressBar(med_HealTarget[playerid], ActionBar);

		StopHoldAction(playerid);
		ClearAnimations(playerid);

		med_HealTarget[playerid] = INVALID_PLAYER_ID;
	}
}

public OnHoldActionUpdate(playerid, progress)
{
	if(med_HealTarget[playerid] != INVALID_PLAYER_ID)
	{
		if(med_HealTarget[playerid] != playerid)
		{
			if(!IsPlayerInPlayerArea(playerid, med_HealTarget[playerid]))
			{
				StopHoldAction(playerid);
				return 1;
			}

			new progresscap = HEAL_PROGRESS_MAX;

			if(gPlayerBitData[med_HealTarget[playerid]] & KnockedOut)
				progresscap = REVIVE_PROGRESS_MAX;

			SetPlayerToFacePlayer(playerid, med_HealTarget[playerid]);
			SetPlayerProgressBarMaxValue(med_HealTarget[playerid], ActionBar, progresscap);
			SetPlayerProgressBarValue(med_HealTarget[playerid], ActionBar, progress);
			ShowPlayerProgressBar(med_HealTarget[playerid], ActionBar);
		}

		return 1;
	}
	return CallLocalFunction("med_OnHoldActionUpdate", "dd", playerid, progress);
}

public OnHoldActionFinish(playerid)
{
	if(med_HealTarget[playerid] != INVALID_PLAYER_ID)
	{
		new
			itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		if(med_HealTarget[playerid] != playerid)
		{
			if(gPlayerBitData[med_HealTarget[playerid]] & KnockedOut)
			{
				WakeUpPlayer(med_HealTarget[playerid]);
			}
		}

		if(itemtype == item_Medkit)
			GivePlayerHP(med_HealTarget[playerid], 40.0);

		if(itemtype == item_Bandage)
			GivePlayerHP(med_HealTarget[playerid], 20.0);

		if(itemtype == item_DoctorBag)
			GivePlayerHP(med_HealTarget[playerid], 70.0);

		f:gPlayerBitData[med_HealTarget[playerid]]<Bleeding>;
		DestroyItem(GetPlayerItem(playerid));

		PlayerStopHeal(playerid);

		return 1;
	}
	return CallLocalFunction("med_OnHoldActionFinish", "d", playerid);
}


// Hooks


#if defined _ALS_OnHoldActionUpdate
	#undef OnHoldActionUpdate
#else
	#define _ALS_OnHoldActionUpdate
#endif
#define OnHoldActionUpdate med_OnHoldActionUpdate
forward med_OnHoldActionUpdate(playerid, progress);


#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish med_OnHoldActionFinish
forward med_OnHoldActionFinish(playerid);

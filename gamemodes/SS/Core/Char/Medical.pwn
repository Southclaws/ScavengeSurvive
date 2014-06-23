#include <YSI\y_hooks>


#define HEAL_PROGRESS_MAX (4000)
#define REVIVE_PROGRESS_MAX (6000)


static med_HealTarget[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	med_HealTarget[playerid] = INVALID_PLAYER_ID;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(itemtype == item_Medkit || itemtype == item_Bandage || itemtype == item_DoctorBag)
	{
		if(newkeys == 16)
		{
			if(IsPlayerKnockedOut(playerid))
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
		if(IsPlayerKnockedOut(target))
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

			if(IsPlayerKnockedOut(med_HealTarget[playerid]))
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

		if(itemtype == item_Bandage)
		{
			SetPlayerBleedRate(med_HealTarget[playerid], GetPlayerBleedRate(med_HealTarget[playerid]) > 0.05 ? 0.05 : 0.0);
		}

		if(itemtype == item_Medkit)
		{
			SetPlayerBleedRate(med_HealTarget[playerid], GetPlayerBleedRate(med_HealTarget[playerid]) > 0.05 ? 0.05 : 0.0);
			ApplyDrug(med_HealTarget[playerid], drug_Painkill);
		}

		if(itemtype == item_DoctorBag)
		{
			SetPlayerBleedRate(med_HealTarget[playerid], 0.0);
			ApplyDrug(med_HealTarget[playerid], drug_Painkill);
			ApplyDrug(med_HealTarget[playerid], drug_Morphine);
			RemovePlayerWounds(med_HealTarget[playerid], 1);
		}

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

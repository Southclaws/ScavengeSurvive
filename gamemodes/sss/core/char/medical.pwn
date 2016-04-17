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


#include <YSI\y_hooks>


#define HEAL_PROGRESS_MAX (4000)
#define REVIVE_PROGRESS_MAX (6000)


static med_HealTarget[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/char/medical.pwn");

	med_HealTarget[playerid] = INVALID_PLAYER_ID;
}

hook OnItemCreate(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemCreate] in /gamemodes/sss/core/char/medical.pwn");

	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_DoctorBag)
		{
			SetItemArrayDataAtCell(itemid, 1 + random(3), 0, 1);

			switch(random(4))
			{
				case 0: SetItemArrayDataAtCell(itemid, drug_Antibiotic, 1, 1);
				case 1: SetItemArrayDataAtCell(itemid, drug_Painkill, 1, 1);
				case 2: SetItemArrayDataAtCell(itemid, drug_Morphine, 1, 1);
				case 3: SetItemArrayDataAtCell(itemid, drug_Adrenaline, 1, 1);
			}
		}
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/char/medical.pwn");

	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(itemtype == item_Medkit || itemtype == item_Bandage || itemtype == item_DoctorBag || itemtype == item_AntiSepBandage)
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

hook OnItemNameRender(itemid, ItemType:itemtype)
{
	d:3:GLOBAL_DEBUG("[OnItemNameRender] in /gamemodes/sss/core/char/medical.pwn");

	if(itemtype == item_DoctorBag)
	{
		new data[2];

		GetItemArrayData(itemid, data);

		if(data[0] > 0)
		{
			new name[MAX_DRUG_NAME];

			GetDrugName(data[1], name);

			SetItemNameExtra(itemid, sprintf("%d/3, %s", data, name));
		}
	}
}

hook OnHoldActionUpdate(playerid, progress)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionUpdate] in /gamemodes/sss/core/char/medical.pwn");

	if(med_HealTarget[playerid] != INVALID_PLAYER_ID)
	{
		if(med_HealTarget[playerid] != playerid)
		{
			if(!IsPlayerInPlayerArea(playerid, med_HealTarget[playerid]))
			{
				StopHoldAction(playerid);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			new progresscap = HEAL_PROGRESS_MAX;

			if(IsPlayerKnockedOut(med_HealTarget[playerid]))
				progresscap = REVIVE_PROGRESS_MAX;

			SetPlayerToFacePlayer(playerid, med_HealTarget[playerid]);
			SetPlayerProgressBarMaxValue(med_HealTarget[playerid], ActionBar, progresscap);
			SetPlayerProgressBarValue(med_HealTarget[playerid], ActionBar, progress);
			ShowPlayerProgressBar(med_HealTarget[playerid], ActionBar);
		}

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionFinish] in /gamemodes/sss/core/char/medical.pwn");

	if(med_HealTarget[playerid] != INVALID_PLAYER_ID)
	{
		new
			itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		if(itemtype == item_Bandage)
		{
			new Float:bleedrate = GetPlayerBleedRate(med_HealTarget[playerid]);

			if(bleedrate > 0.0)
			{
				bleedrate -= bleedrate * floatpower(1.0091 - bleedrate, 2.1);
				bleedrate = (bleedrate < 0.00001) ? 0.0 : bleedrate;

				if(random(100) < 33)
				{
					SetPlayerInfectionIntensity(playerid, 1, 1);
					ShowActionText(playerid, ls(playerid, "WOUNDINFECT"), 5000);
				}

				MsgF(playerid, YELLOW, "Reduced bleedrate from %f to %f", GetPlayerBleedRate(med_HealTarget[playerid]), bleedrate);

				SetPlayerBleedRate(med_HealTarget[playerid], bleedrate);

				DestroyItem(itemid);
			}
		}

		if(itemtype == item_Medkit)
		{
			new
				Float:bleedrate = GetPlayerBleedRate(med_HealTarget[playerid]),
				woundcount = (med_HealTarget[playerid] == playerid) ? 1 + random(2) : 2 + random(2);

			if(bleedrate > 0.0)
			{
				bleedrate -= bleedrate * floatpower(1.0091 - bleedrate, 2.1);
				bleedrate = (bleedrate < 0.00001) ? 0.0 : bleedrate;
				SetPlayerBleedRate(med_HealTarget[playerid], bleedrate);

				MsgF(playerid, YELLOW, "Reduced bleedrate from %f to %f", GetPlayerBleedRate(med_HealTarget[playerid]), bleedrate);
			}

			if(woundcount > 0)
			{
				RemovePlayerWounds(med_HealTarget[playerid], woundcount);
				ShowActionText(playerid, sprintf(ls(playerid, "WOUNDHEALED"), woundcount), 5000);

				DestroyItem(itemid);
			}
		}

		if(itemtype == item_DoctorBag)
		{
			new woundcount = (med_HealTarget[playerid] == playerid) ? 1 + random(2) : 3 + random(3);

			if(woundcount > 0)
			{
				RemovePlayerWounds(med_HealTarget[playerid], woundcount);
				ShowActionText(playerid, sprintf(ls(playerid, "WOUNDHEALED"), woundcount), 5000);
			}

			SetPlayerBleedRate(med_HealTarget[playerid], 0.0);
			SetPlayerInfectionIntensity(playerid, 1, 0);

			new data[2];

			GetItemArrayData(itemid, data);

			if(data[0] > 1)
			{
				SetItemArrayDataAtCell(itemid, data[0] - 1, 0);
			}
			else
			{
				DestroyItem(itemid);
			}

			ApplyDrug(med_HealTarget[playerid], data[1]);
		}

		if(itemtype == item_AntiSepBandage)
		{
			new Float:bleedrate = GetPlayerBleedRate(med_HealTarget[playerid]);

			if(bleedrate > 0.0)
			{
				bleedrate -= bleedrate * floatpower(1.0091 - bleedrate, 2.1);
				bleedrate = (bleedrate < 0.00001) ? 0.0 : bleedrate;

				SetPlayerBleedRate(med_HealTarget[playerid], bleedrate);
				DestroyItem(itemid);

				MsgF(playerid, YELLOW, "Reduced bleedrate from %f to %f", GetPlayerBleedRate(med_HealTarget[playerid]), bleedrate);
			}

			SetPlayerInfectionIntensity(playerid, 1, 0);
		}

		PlayerStopHeal(playerid);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

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


#include <YSI_4\y_hooks>


#define PILL_TYPE_ANTIBIOTICS	(0)
#define PILL_TYPE_PAINKILL		(1)
#define PILL_TYPE_LSD			(2)


static
	pill_CurrentlyTaking[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	pill_CurrentlyTaking[playerid] = -1;
}

hook OnItemCreate(itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_Pills)
		{
			SetItemExtraData(itemid, random(3));
		}
	}
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{
	if(itemtype == item_Pills)
	{
		switch(GetItemExtraData(itemid))
		{
			case PILL_TYPE_ANTIBIOTICS:		SetItemNameExtra(itemid, "Antibiotics");
			case PILL_TYPE_PAINKILL:		SetItemNameExtra(itemid, "Painkiller");
			case PILL_TYPE_LSD:				SetItemNameExtra(itemid, "LSD");
			default:						SetItemNameExtra(itemid, "Empty");
		}
	}
}

hook OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Pills)
	{
		StartTakingPills(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16 && pill_CurrentlyTaking[playerid] != -1)
	{
		StopTakingPills(playerid);
	}

	return 1;
}

StartTakingPills(playerid)
{
	pill_CurrentlyTaking[playerid] = GetPlayerItem(playerid);
	ApplyAnimation(playerid, "BAR", "dnk_stndM_loop", 3.0, 0, 1, 1, 0, 1000, 1);
	StartHoldAction(playerid, 1000);
}

StopTakingPills(playerid)
{
	ClearAnimations(playerid);
	StopHoldAction(playerid);

	pill_CurrentlyTaking[playerid] = -1;
}

public OnHoldActionFinish(playerid)
{
	if(pill_CurrentlyTaking[playerid] != -1)
	{
		if(!IsValidItem(pill_CurrentlyTaking[playerid]))
			return Y_HOOKS_CONTINUE_RETURN_0;

		if(GetPlayerItem(playerid) != pill_CurrentlyTaking[playerid])
			return Y_HOOKS_CONTINUE_RETURN_0;

		switch(GetItemExtraData(pill_CurrentlyTaking[playerid]))
		{
			case PILL_TYPE_ANTIBIOTICS:
			{
				SetPlayerInfectionIntensity(playerid, 0, 0);

				if(random(100) < 50)
					SetPlayerInfectionIntensity(playerid, 1, 0);

				ApplyDrug(playerid, drug_Antibiotic);
			}
			case PILL_TYPE_PAINKILL:
			{
				GivePlayerHP(playerid, 10.0);
				ApplyDrug(playerid, drug_Painkill);
			}
			case PILL_TYPE_LSD:
			{
				ApplyDrug(playerid, drug_Lsd);

				new
					hour = 22,
					minute = 3,
					weather = 33;

				SetTimeForPlayer(playerid, hour, minute);
				SetWeatherForPlayer(playerid, weather);
			}
		}

		DestroyItem(pill_CurrentlyTaking[playerid]);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDrugWearOff(playerid, drugtype)
{
	if(drugtype == drug_Lsd)
	{
		SetTimeForPlayer(playerid, -1, -1, true);
		SetWeatherForPlayer(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

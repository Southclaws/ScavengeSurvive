/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_HerpDerp)
	{
		switch(random(25))
		{
			case 00: ApplyAnimation(playerid, "TATTOOS", "TAT_ArmL_In_O", 4.0, 0, 1, 1, 0, 0);
			case 01: ApplyAnimation(playerid, "TATTOOS", "TAT_ArmL_Out_O", 4.0, 0, 1, 1, 0, 0);
			case 02: ApplyAnimation(playerid, "TATTOOS", "TAT_ArmR_In_O", 4.0, 0, 1, 1, 0, 0);
			case 03: ApplyAnimation(playerid, "TATTOOS", "TAT_ArmR_Out_O", 4.0, 0, 1, 1, 0, 0);
			case 04: ApplyAnimation(playerid, "TATTOOS", "TAT_Back_In_O", 4.0, 0, 1, 1, 0, 0);
			case 05: ApplyAnimation(playerid, "TATTOOS", "TAT_Back_Out_O", 4.0, 0, 1, 1, 0, 0);
			case 06: ApplyAnimation(playerid, "TATTOOS", "TAT_Bel_In_O", 4.0, 0, 1, 1, 0, 0);
			case 07: ApplyAnimation(playerid, "TATTOOS", "TAT_Bel_Out_O", 4.0, 0, 1, 1, 0, 0);
			case 08: ApplyAnimation(playerid, "TATTOOS", "TAT_Che_In_O", 4.0, 0, 1, 1, 0, 0);
			case 09: ApplyAnimation(playerid, "TATTOOS", "TAT_Che_Out_O", 4.0, 0, 1, 1, 0, 0);
			case 10: ApplyAnimation(playerid, "TATTOOS", "TAT_Drop_O", 4.0, 0, 1, 1, 0, 0);
			case 11: ApplyAnimation(playerid, "TATTOOS", "TAT_Idle_Loop_O", 4.0, 0, 1, 1, 0, 0);
			case 12: ApplyAnimation(playerid, "TATTOOS", "TAT_Sit_In_O", 4.0, 0, 1, 1, 0, 0);
			case 13: ApplyAnimation(playerid, "TATTOOS", "TAT_Sit_Loop_O", 4.0, 0, 1, 1, 0, 0);
			case 14: ApplyAnimation(playerid, "TATTOOS", "TAT_Sit_Out_O", 4.0, 0, 1, 1, 0, 0);
			case 15: ApplyAnimation(playerid, "GHANDS", "LHGsign1", 4.0, 0, 1, 1, 0, 0);
			case 16: ApplyAnimation(playerid, "GHANDS", "LHGsign2", 4.0, 0, 1, 1, 0, 0);
			case 17: ApplyAnimation(playerid, "GHANDS", "LHGsign3", 4.0, 0, 1, 1, 0, 0);
			case 18: ApplyAnimation(playerid, "GHANDS", "LHGsign4", 4.0, 0, 1, 1, 0, 0);
			case 19: ApplyAnimation(playerid, "GHANDS", "LHGsign5", 4.0, 0, 1, 1, 0, 0);
			case 20: ApplyAnimation(playerid, "GHANDS", "RHGsign1", 4.0, 0, 1, 1, 0, 0);
			case 21: ApplyAnimation(playerid, "GHANDS", "RHGsign2", 4.0, 0, 1, 1, 0, 0);
			case 22: ApplyAnimation(playerid, "GHANDS", "RHGsign3", 4.0, 0, 1, 1, 0, 0);
			case 23: ApplyAnimation(playerid, "GHANDS", "RHGsign4", 4.0, 0, 1, 1, 0, 0);
			case 24: ApplyAnimation(playerid, "GHANDS", "RHGsign5", 4.0, 0, 1, 1, 0, 0);

		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

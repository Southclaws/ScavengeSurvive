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


hook OnPlayerUseItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItem] in /gamemodes/sss/core/item/herpderp.pwn");

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

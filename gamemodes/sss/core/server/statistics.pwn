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


/*
	WORK IN PROGRESS!
*/


// Variable statistics that change
enum E_STATISTIC_VARIABLE_DATA
{
	statVar_Players,
	statVar_Items,
	statVar_Boxes,
	statVar_Tents,
	statVar_Defences,
	statVar_Signs,
	statVar_VehPlayer,
	statVar_VehWorld
}

// Statistics that only increment
enum E_STATISTIC_INCREMENT_DATA
{
	statInc_ConnectsNew,
	statInc_ConnectsExisting,
	statInc_ConnectsUnwhite,
	statInc_Quits,
	statInc_Kicks,
	statInc_Bans,
	statInc_Crashes,
	statInc_Restarts
}


static
	statVar_Data[E_STATISTIC_VARIABLE_DATA],
	statInc_Data[E_STATISTIC_INCREMENT_DATA];


hook OnGameModeInit()
{

}

UpdateVariableStatistics()
{
	statVar_Players = Iter_Count(Player);
	statVar_Items = Iter_Count(itm_Index);
	statVar_Boxes = Iter_Count(box_Index);
	statVar_Tents = Iter_Count(tnt_Index);
	statVar_Defences = Iter_Count(def_Index);
	statVar_Signs = Iter_Count(sgn_Index);

	statVar_VehPlayer = 0;
	statVar_VehWorld = 0;

	foreach(new i : veh_Index)
	{
		if(GetVehicleOwner(i))
			statVar_VehPlayer++;

		statVar_VehWorld++;
	}

	return 1;
}


IncrementStatistic(E_STATISTIC_INCREMENT_DATA:type, amount = 1)
{
	statInc_Data[type] += amount;
}

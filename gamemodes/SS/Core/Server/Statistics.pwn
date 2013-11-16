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

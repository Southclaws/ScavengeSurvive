/*
	WORK IN PROGRESS!
*/

static
	// Variable statistics that change
	statVar_Players,
	statVar_Items,
	statVar_Boxes,
	statVar_Tents,
	statVar_Defences,
	statVar_Signs,
	statVar_VehPlayer,
	statVar_VehWorld,

	// Statistics that only increment
	statInc_ConnectsNew,
	statInc_ConnectsExisting,
	statInc_ConnectsUnwhite,
	statInc_Quits,
	statInc_Kicks,
	statInc_Bans,
	statInc_Crashes,
	statInc_Restarts;


hook OnGameModeInit()
{

}

UpdateStatistic(name[])
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

		else
			statVar_VehWorld++;
	}

	statInc_ConnectsNew
	statInc_ConnectsExisting
	statInc_ConnectsUnwhite
	statInc_Quits
	statInc_Kicks
	statInc_Bans
	statInc_Crashes
	statInc_Restarts

	return 1;
}


IncrementStatistic()
{

}

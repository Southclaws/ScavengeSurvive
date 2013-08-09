CreateEmpExplosion(Float:x, Float:y, Float:z, Float:range)
{
	CreateTimedDynamicObject(18724, x, y, z - 1.0, 0.0, 0.0, 0.0, 3000);

	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, range, x, y, z))
		{
			KnockOutPlayer(i, 60000);
		}
	}

	foreach(new i : veh_Index)
	{
		if(IsVehicleInRangeOfPoint(i, range, x, y, z))
		{
			SetVehicleEngine(i, false);
		}
	}
}

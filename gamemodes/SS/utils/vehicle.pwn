stock IsVehicleInRangeOfPoint(vehicleid, Float:range, Float:x, Float:y, Float:z)
{
	new
		Float:vx,
		Float:vy,
		Float:vz;

	GetVehiclePos(vehicleid, vx, vy, vz);

	if(Distance(x, y, z, vx, vy, vz) < range)
		return 1;

	return 0;
}

stock GetPlayersInVehicle(vehicleid)
{
    new amount;
    PlayerLoop(i)if(!IsPlayerConnected(i)||!IsPlayerInVehicle(i,vehicleid))amount++;
    return amount;
}

stock VehicleEngineState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;

	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);

	if(t != -1)
		SetVehicleParamsEx(v, t, l, a, d, bn, bt, o);

	return e;
}

stock VehicleLightsState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;

	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);

	if(t != -1)
		SetVehicleParamsEx(v, e, t, a, d, bn, bt, o);

	return l;
}

stock VehicleAlarmState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;

	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);

	if(t != -1)
		SetVehicleParamsEx(v, e, l, t, d, bn, bt, o);

	return a;
}

stock VehicleDoorsState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;

	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);

	if(t != -1)
		SetVehicleParamsEx(v, e, l, a, t, bn, bt, o);

	return d;
}

stock VehicleBonnetState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;

	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);

	if(t != -1)
		SetVehicleParamsEx(v, e, l, a, d, t, bt, o);

	return bn;
}

stock VehicleBootState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;

	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);

	if(t != -1)
		SetVehicleParamsEx(v, e, l, a, d, bn, t, o);

	return bt;
}

stock RandomNumberPlateString()
{
	new str[9];
	for(new c; c < 8; c++)
	{
		if(c<4)str[c] = 'A' + random(26);
		else if(c>4)str[c] = '0' + random(10);
		str[4] = ' ';
	}
	return str;
}

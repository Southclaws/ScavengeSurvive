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
	if(t!=-1)SetVehicleParamsEx(v, t, l, a, d, bn, bt, o);
	return e;
}

stock VehicleLightsState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, t, a, d, bn, bt, o);
	return l;
}

stock VehicleAlarmState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, l, t, d, bn, bt, o);
	return a;
}

stock VehicleDoorsState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, l, a, t, bn, bt, o);
	return d;
}

stock VehicleBonnetState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, l, a, d, t, bt, o);
	return bn;
}

stock VehicleBootState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;
	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);
	if(t!=-1)SetVehicleParamsEx(v, e, l, a, d, bn, t, o);
	return bt;
}

stock encode_tires(tire1, tire2, tire3, tire4)
{
	return tire1 | (tire2 << 1) | (tire3 << 2) | (tire4 << 3);
}

stock encode_panels(flp, frp, rlp, rrp, windshield, front_bumper, rear_bumper)
{
    return flp | (frp << 4) | (rlp << 8) | (rrp << 12) | (windshield << 16) | (front_bumper << 20) | (rear_bumper << 24);
}

stock encode_doors(bonnet, boot, driver_door, passenger_door, behind_driver_door, behind_passenger_door)
{
    #pragma unused behind_driver_door
    #pragma unused behind_passenger_door
    return bonnet | (boot << 8) | (driver_door << 16) | (passenger_door << 24);
}

stock encode_lights(light1, light2, light3, light4)
{
    return light1 | (light2 << 1) | (light3 << 2) | (light4 << 3);
}

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


stock IsVehicleUpsideDown(vehicleid)
{
    new
    	Float:w,
    	Float:x,
    	Float:y,
    	Float:z;

    GetVehicleRotationQuat(vehicleid, w, x, y, z);

    new Float:angle = atan2(((y * z) + (w * x)) * 2.0, (w * w) - (x * x) - (y * y) + (z * z));

    return ((angle > 90.0) || (angle < -90.0));
}

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

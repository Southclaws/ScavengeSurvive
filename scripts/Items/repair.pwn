#include <YSI\y_hooks>


new
ItemType:	item_Wrench				= INVALID_ITEM_TYPE,
ItemType:	item_Hammer				= INVALID_ITEM_TYPE,
ItemType:	item_Screwdriver		= INVALID_ITEM_TYPE,
Timer:		gPlayerFixTimer			[MAX_PLAYERS],
Float:		gPlayerFixProgress		[MAX_PLAYERS],
			gPlayerFixTarget		[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	gPlayerFixTarget[playerid] = INVALID_VEHICLE_ID;
}


StartRepairingVehicle(playerid, vehicleid)
{
	new
		engine,
		lights,
		alarm,
		doors,
		bonnet,
		boot,
		objective;

	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, 1, boot, objective);
	GetVehicleHealth(vehicleid, gPlayerFixProgress[playerid]);
	ApplyAnimation(playerid, "INT_SHOP", "SHOP_CASHIER", 4.0, 1, 0, 0, 0, 0, 1);

	stop gPlayerFixTimer[playerid];
	gPlayerFixTimer[playerid] = repeat PlayerFixVehicleUpdate(playerid);
	gPlayerFixTarget[playerid] = vehicleid;

	return 1;
}

StopRepairingVehicle(playerid)
{
	stop gPlayerFixTimer[playerid];

	if(gPlayerFixTarget[playerid] == INVALID_VEHICLE_ID)
		return 0;

	new
		engine,
		lights,
		alarm,
		doors,
		bonnet,
		boot,
		objective;

	GetVehicleParamsEx(gPlayerFixTarget[playerid], engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(gPlayerFixTarget[playerid], engine, lights, alarm, doors, 0, boot, objective);

	gPlayerFixTarget[playerid] = INVALID_VEHICLE_ID;

	HidePlayerProgressBar(playerid, ActionBar);
	ClearAnimations(playerid);

	return 1;
}

timer PlayerFixVehicleUpdate[100](playerid)
{
	if(!IsPlayerInVehicleArea(playerid, gPlayerFixTarget[playerid]) || !IsValidVehicle(gPlayerFixTarget[playerid]))
		return StopRepairingVehicle(playerid);

	if(GetItemType(GetPlayerItem(playerid)) == item_Wrench)
	{
		if(!(250.0 <= gPlayerFixProgress[playerid] < 450.0) && !(800.0 <= gPlayerFixProgress[playerid] < 1000.0))
			return StopRepairingVehicle(playerid);
	}
	if(GetItemType(GetPlayerItem(playerid)) == item_Screwdriver)
	{
		if(!(450.0 <= gPlayerFixProgress[playerid] < 650.0))
			return StopRepairingVehicle(playerid);
	}
	if(GetItemType(GetPlayerItem(playerid)) == item_Hammer)
	{
		if(!(650.0 <= gPlayerFixProgress[playerid] < 800.0))
			return StopRepairingVehicle(playerid);
	}

	new
		Float:px,
		Float:py,
		Float:pz,
		Float:vx,
		Float:vy,
		Float:vz;

	gPlayerFixProgress[playerid] += frandom(3.0);
	
	SetPlayerProgressBarValue(playerid, ActionBar, gPlayerFixProgress[playerid]);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, 1000.0);
	ShowPlayerProgressBar(playerid, ActionBar);

	SetVehicleHealth(gPlayerFixTarget[playerid], gPlayerFixProgress[playerid]);

	GetVehiclePos(gPlayerFixTarget[playerid], vx, vy, vz);
	GetPlayerPos(playerid, px, py, pz);
	SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, vx, vy));

	return 1;
}

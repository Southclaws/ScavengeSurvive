Hook_HackDetect_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	HackDetect_SetPlayerPos(playerid, x, y, z);
	return SetPlayerPos(playerid, x, y, z);
}
#define SetPlayerPos Hook_HackDetect_SetPlayerPos

Hook_Debug_DestroyVehicle(vehicleid, source = -1)
{
	printf("DEBUG: DestroyVehicle %d called, Source: %d", vehicleid, source);
	return DestroyVehicle(vehicleid);
}
#define DestroyVehicle Hook_Debug_DestroyVehicle

SetPlayerToFacePlayer(playerid, targetid, Float:offset = 0.0)
{
	new
		Float:x1,
		Float:y1,
		Float:z1,
		Float:x2,
		Float:y2,
		Float:z2;

	GetPlayerPos(playerid, x1, y1, z1);
	GetPlayerPos(targetid, x2, y2, z2);
	SetPlayerFacingAngle(playerid, GetAngleToPoint(x1, y1, x2, y2) + offset);
}

SetPlayerToFaceVehicle(playerid, vehicleid, Float:offset = 0.0)
{
	new
		Float:x1,
		Float:y1,
		Float:z1,
		Float:x2,
		Float:y2,
		Float:z2;

	GetPlayerPos(playerid, x1, y1, z1);
	GetVehiclePos(vehicleid, x2, y2, z2);
	SetPlayerFacingAngle(playerid, GetAngleToPoint(x1, y1, x2, y2) + offset);
}

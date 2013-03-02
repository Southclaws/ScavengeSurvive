stock GetPlayerCameraWeaponVector(playerid, &Float:vX, &Float:vY, &Float:vZ)
{
	static
		weapon;
	if(21 < (weapon = GetPlayerWeapon(playerid)) < 39)
	{
		GetPlayerCameraFrontVector(playerid, vX, vY, vZ);
		switch(weapon)
		{
			case WEAPON_SNIPER, WEAPON_ROCKETLAUNCHER, WEAPON_HEATSEEKER: {}
			case WEAPON_RIFLE:
			{
				AdjustVector(vX, vY, vZ, 0.016204, 0.009899, 0.047177);
			}
			case WEAPON_AK47, WEAPON_M4:
			{
				AdjustVector(vX, vY, vZ, 0.026461, 0.013070, 0.069079);
			}
			default:
			{
				AdjustVector(vX, vY, vZ, 0.043949, 0.015922, 0.103412);
			}
		}
		return true;
	}
	return false;
}
stock AdjustVector(& Float: vX, & Float: vY, & Float: vZ, Float: oX, Float: oY, const Float: oZ)
{
	static
		Float: Angle;
	Angle = -atan2(vX, vY);
	if(45.0 < Angle)
	{
		oX ^= oY;
		oY ^= oX;
		oX ^= oY;
		if(90.0 < Angle)
		{
			oX *= -1;
			if(135.0 < Angle)
			{
				oX *= -1;
				oX ^= oY;
				oY ^= oX;
				oX ^= oY;
				oX *= -1;
			}
		}
	}
	else if(Angle < 0.0)
	{
		oY *= -1;
		if(Angle < -45.0)
		{
			oX *= -1;
			oX ^= oY;
			oY ^= oX;
			oX ^= oY;
			oX *= -1;
			if(Angle < -90.0)
			{
				oX *= -1;
				if(Angle < -135.0)
				{
					oX ^= oY;
					oY ^= oX;
					oX ^= oY;
				}
			}
		}
	}
	vX += oX,
	vY += oY;
	vZ += oZ;
	return false;
}
stock NoBadCam(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:ang;

	GetPlayerCameraFrontVector(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, ang);

	if(		(x < 0.0 && y > 0.0) && (ang > 90.0 	&& ang < 300.0)	) return 0;
	else if((x > 0.0 && y > 0.0) && (ang > 88.16 	&& ang < 275.0)	) return 0;
	else if((x < 0.0 && y < 0.0) && (ang > 257.30 	&& ang < 360.0)	) return 0;
	else if((x > 0.0 && y < 0.0) && (ang < 88.16 	&& ang < 257.30)) return 0;

	return 1;
}

stock IsPlayerAimingAt(playerid, Float:pX, Float:pY, Float:pZ, Float:radius)
{
	new
	    Float:cX, Float:cY, Float:cZ,
	    Float:vX, Float:vY, Float:vZ,
		Float:DistanceToLine;
	GetPlayerCameraPos(playerid, cX, cY, cZ);
	GetPlayerCameraWeaponVector(playerid, vX, vY, vZ);
	DistanceToLine=GetDistancePointLine(cX, cY, cZ, vX, vY, vZ, pX, pY, pZ);
	if(DistanceToLine<radius)return 1;
	return 0;
}

stock IsPlayerAimingAtPlayer(playerid, targetid)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(targetid, x, y, z);
	if (IsPlayerAimingAt(playerid, x, y, z-0.75, 0.25)) return 0;
	if (IsPlayerAimingAt(playerid, x, y, z-0.25, 0.25)) return 0;
	if (IsPlayerAimingAt(playerid, x, y, z+0.25, 0.25)) return 0;
	if (IsPlayerAimingAt(playerid, x, y, z+0.75, 0.25)) return 0;
	if (IsPlayerAimingAt(playerid, x, y, z+0.80, 0.20)) return 1;
	return -1;
}

stock IsPlayerAimingAtHead(playerid, targetid)
{
	if(!IsPlayerConnected(playerid))return 0;
	new Float:x, Float:y, Float:z;
	GetPlayerPos(targetid, x, y, z);
	if(IsPlayerAimingAt(playerid, x, y, z+0.80, 0.15)) return 1;
	return 0;
}

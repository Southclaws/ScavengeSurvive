#include <YSI\y_va>

static stock gs_Buffer[256];

stock Msg(playerid, colour, string[])
{
	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new c = 128; c > 0; c--)
		{
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.')
			{
			    splitpos = c;
			    break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;
		
		SendClientMessage(playerid, colour, string);
		SendClientMessage(playerid, colour, string2);
	}
	else SendClientMessage(playerid, colour, string);
	
	return 1;
}
stock MsgAll(colour, string[])
{
	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new c = 128; c>0; c--)
		{
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.')
			{
			    splitpos = c;
			    break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;

		SendClientMessageToAll(colour, string);
		SendClientMessageToAll(colour, string2);
	}
	else SendClientMessageToAll(colour, string);

	return 1;
}
stock MsgAllEx(exceptionid, colour, string[])
{
	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new c = 128; c>0; c--)
		{
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.')
			{
			    splitpos = c;
			    break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;

	    PlayerLoop(i)
	    {
	        if(i == exceptionid)
				continue;

			SendClientMessage(i, colour, string);
			SendClientMessage(i, colour, string2);
		}
	}
	else
	{
	    PlayerLoop(i)
	    {
	        if(i == exceptionid)
				continue;

			SendClientMessageToAll(i, colour, string);
		}
	}

	return 1;
}


stock MsgF(playerid, colour, fmat[], va_args<>)
{
    va_formatex(gs_Buffer, _, fmat, va_start<3>);
    Msg(playerid, colour, gs_Buffer);

    return 1;
}

stock MsgAllF(colour, fmat[], va_args<>)
{
    va_formatex(gs_Buffer, _, fmat, va_start<2>);
    MsgAll(colour, gs_Buffer);

    return 1;
}

stock MsgAdminsF(level, colour, fmat[], va_args<>)
{
    va_formatex(gs_Buffer, _, fmat, va_start<3>);
    MsgAdmins(level, colour, gs_Buffer);

    return 1;
}

stock MsgTeamF(team, colour, fmat[], va_args<>)
{
    va_formatex(gs_Buffer, _, fmat, va_start<3>);
    MsgTeam(team, colour, gs_Buffer);

    return 1;
}

stock MsgDeathmatchF(colour, fmat[], va_args<>)
{
    va_formatex(gs_Buffer, _, fmat, va_start<2>);
    MsgDeathmatch(colour, gs_Buffer);

    return 1;
}


//==============================================================================Player Functions


stock SetAllWeaponSkills(playerid, skill)
{
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED,	skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE,		skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN,			skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN,	skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5,				skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47,				skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_M4,				skill);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SNIPERRIFLE,		skill);
}

stock RemovePlayerWeapon(playerid, weaponid)
{
	new weapondata[12][2];

	for(new i = 0; i < 12; i++)
	{
		GetPlayerWeaponData(playerid, i, weapondata[i][0], weapondata[i][1]);
		if(weapondata[i][0] == weaponid)weapondata[i][0] = 0;
	}

	ResetPlayerWeapons(playerid);

	for(new i = 0; i != 12; i++)
		GivePlayerWeapon(playerid, weapondata[i][0], weapondata[i][1]);
}

stock GetNameGT(playerid)
{
	new tmpName[MAX_PLAYER_NAME];

	tmpName = gPlayerName[playerid];

	foreach(new c : Character)
	{
		if(tmpName[c]=='[')tmpName[c] = '(';
		if(tmpName[c]==']')tmpName[c] = ')';
	}
	return tmpName;
}

stock PlaySound(sound, Float:x, Float:y, Float:z, Float:range=100.0)
{
	PlayerLoop(i)if(IsPlayerInRangeOfPoint(i, range, x, y, z))PlayerPlaySound(i, sound, x, y, z);
	return 1;
}
stock PlaySoundForAll(sound)
{
	PlayerLoop(i)PlayerPlaySound(i, sound, 0, 0, 0);
	return 1;
}

stock GivePlayerArmour(playerid, Float:armour)
{
	new Float:am;
	GetPlayerArmour(playerid, am);
	SetPlayerArmour(playerid, am+armour);
}
stock IsPlayerSpawned(playerid)
{
	new PlayerState;
	PlayerState=GetPlayerState(playerid);
	return(PlayerState!=PLAYER_STATE_NONE&&PlayerState!=PLAYER_STATE_WASTED&&PlayerState!=PLAYER_STATE_SPECTATING);
}
stock GetPlayerID(name[])
{
	PlayerLoop(i)
		if(!strcmp(name, gPlayerName[i]))return i;

	return -1;
}


//==============================================================================Location / Geometrical


forward Float:GetPlayerDist3D(player1, player2);
stock Float:GetPlayerDist3D(player1, player2)
{
	new
		Float:x1, Float:y1, Float:z1,
		Float:x2, Float:y2, Float:z2;
	GetPlayerPos(player1, x1, y1, z1);
	GetPlayerPos(player2, x2, y2, z2);
	return floatsqroot((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
}
forward Float:GetPlayerDist2D(player1, player2);
stock Float:GetPlayerDist2D(player1, player2)
{
	new
		x1, y1, z1,
		x2, y2, z2;

	GetPlayerPos(player1, Float:x1, Float:y1, Float:z1);
	GetPlayerPos(player2, Float:x2, Float:y2, Float:z2);
	return floatsqroot((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
}
stock GetPlayer2DZone(playerid)
{
	new Float:x, Float:y, Float:z, zone[sizeof(Zones)];
	zone="Unknown";
	GetPlayerPos(playerid, x, y, z);
	for(new i=0;i<sizeof(Zones);i++)if(x>=Zones[i][zone_area][0]&&x<=Zones[i][zone_area][3]&&y>=Zones[i][zone_area][1]&&y<=Zones[i][zone_area][4])format(zone,sizeof(Zones),Zones[i][zone_name]);
	return zone;
}
stock GetPlayer3DZone(playerid)
{
	new Float:x, Float:y, Float:z, zone[sizeof(Zones)];
	zone="Unknown";
	GetPlayerPos(playerid, x, y, z);
	for(new i=0;i<sizeof(Zones);i++)
	if(x >= Zones[i][zone_area][0]&&x<=Zones[i][zone_area][3]&&y>=Zones[i][zone_area][1]&&y<=Zones[i][zone_area][4]&&z>=Zones[i][zone_area][2]&&z<=Zones[i][zone_area][5])format(zone,sizeof(Zones),Zones[i][zone_name]);
	return zone;
}
stock IsPlayerInTheZone(playerid, zone[])
{
	new TmpZone[MAX_ZONE_NAME];
	GetPlayer3DZone(playerid, TmpZone, sizeof(TmpZone));
	for(new i = 0; i != sizeof(Zones); i++)if(strfind(TmpZone, zone, true) != -1)return 1;
	return 0;
}

forward Float:GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance);
stock Float:GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
    new Float:a;
    GetPlayerPos(playerid, x, y, a);
    if (IsPlayerInAnyVehicle(playerid))
        GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
    else
        GetPlayerFacingAngle(playerid, a);
    x += (distance * floatsin(-a, degrees));
    y += (distance * floatcos(-a, degrees));
    return a;
}
stock GetClosestPlayer(playerid)
{
	new Float:dis,Float:dis2,player;
	player = -1;
	dis = 99999.99;
	for(new i = 0; i < MAX_PLAYERS; i++ )
	{
		if(IsPlayerConnected(i))
		{
			if(i != playerid)
			{
				dis2 = GetPlayerDist3D(playerid, i);
				if(dis2 < dis && dis2 != 10000.0)
				{
					dis = dis2;
					player = i;
				}
			}
		}
	}
	return player;
}
stock IsPlayerBehindPlayer(playerid, targetid, Float:dOffset)
{
	new
	    Float:pa,
	    Float:ta;
	if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 0;
	GetPlayerFacingAngle(playerid, pa);
	GetPlayerFacingAngle(targetid, ta);
	if(AngleInRangeOfAngle(pa, ta, dOffset) && IsPlayerFacingPlayer(playerid, targetid, dOffset)) return true;
	return false;
}
stock SetPlayerToFacePlayer(playerid, targetid)
{
	new
		Float:pX,
		Float:pY,
		Float:pZ,
		Float:X,
		Float:Y,
		Float:Z,
		Float:ang;
	if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 0;
	GetPlayerPos(targetid, X, Y, Z);
	GetPlayerPos(playerid, pX, pY, pZ);
	if( Y > pY ) ang = (-acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 90.0);
	else if( Y < pY && X < pX ) ang = (acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 450.0);
	else if( Y < pY ) ang = (acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 90.0);
	if(X > pX) ang = (floatabs(floatabs(ang) + 180.0));
	else ang = (floatabs(ang) - 180.0);
	SetPlayerFacingAngle(playerid, ang);
 	return 0;
}
stock IsPlayerFacingPlayer(playerid, targetid, Float:dOffset)
{
	new
		Float:pX,
		Float:pY,
		Float:pZ,
		Float:pA,
		Float:X,
		Float:Y,
		Float:Z,
		Float:ang;

	if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 0;

	GetPlayerPos(targetid, pX, pY, pZ);
	GetPlayerPos(playerid, X, Y, Z);
	GetPlayerFacingAngle(playerid, pA);

	if( Y > pY ) ang = (-acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 90.0);
	else if( Y < pY && X < pX ) ang = (acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 450.0);
	else if( Y < pY ) ang = (acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 90.0);
	if(AngleInRangeOfAngle(-ang, pA, dOffset)) return true;

	return false;
}


//==============================================================================Skin Functions


static const SkinArray[] =
{
	3, 4, 5, 6, 7, 8, 42, 65, 74, 86, 119, 149, 208, 268, 273,
	0,1,2,7,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,32,33,34,35,36,37,
	38,40,43,44,45,46,47,48,49,50,51,52,57,58,59,60,61,62,66,67,68,70,71,72,73,78,
	79,80,81,82,83,84,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,110,112,
	113,114,115,116,117,118,120,121,122,123,124,125,126,127,128,131,132,133,134,135,
	136,137,142,143,144,146,147,153,154,155,156,158,159,160,161,162,163,164,165,166,
	167,168,170,171,173,174,175,176,177,179,180,181,182,183,184,185,186,187,188,189,
	200,202,203,204,206,209,210,212,213,217,220,221,222,223,227,228,229,230,234,235,
	236,239,240,241,242,247,248,249,250,252,253,254,255,258,259,260,261,262,264,265,
	266,267,269,270,271,272,274,275,276,277,278,279,280,281,282,283,284,285,286,287,
	288,289,290,291,292,293,294,295,296,297,299,
	9,10,11,12,13,31,39,41,42,53,54,55,56,63,64,69,75,76,77,85,87,88,89,90,91,92,93,
	109,111,129,130,131,138,139,140,141,145,148,150,151,152,157,169,172,178,190,191,
	192,193,194,195,196,197,198,199,201,205,207,211,214,215,216,218,219,224,225,226,
	231,232,233,237,238,243,244,245,246,251,256,257,263,298
};
stock GetSkinGender(skinID)
{
    for(new i; i<sizeof(SkinArray); i++)
    {
        if(SkinArray[i] == skinID)
        {
		    switch(i)
		    {
		        case 0..14: return 0;
		        case 15..221: return 1;
				case 222..299: return 2;
		    }
		    break;
		}
    }
    return 0;
}
stock IsValidSkin(skinid)
{
    if(skinid == 74 || skinid > 299 || skinid < 0)
        return 0;
        
    return 1;
}

//==============================================================================Camera Functions


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

ACMD:sp[4](playerid, params[])
{
	new PositionName[128];
	if(!sscanf(params, "s[128]", PositionName))
	{
		new
			string[128],
			Float:x,
			Float:y,
			Float:z,
			Float:r;

		if(IsPlayerInAnyVehicle(playerid))
		{
		    new vehicleid = GetPlayerVehicleID(playerid);
			GetVehiclePos(vehicleid, x, y, z);
			GetVehicleZAngle(vehicleid, r);
		}
		else
		{
			GetPlayerPos(playerid, x, y, z);
			GetPlayerFacingAngle(playerid, r);
		}
		format(string, 128, "%.4f, %.4f, %.4f, %.4f", x, y, z, r);
		file_Open("savedpositions.txt");
		file_SetStr(PositionName, string);
		file_Save("savedpositions.txt");
		file_Close();
		MsgF(playerid, ORANGE, " >  %s = %s "#C_BLUE"Saved!", PositionName, string);
	}
	else Msg(playerid, YELLOW, " >  Usage: /sp [position name]");
 	return 1;
}
ACMD:tp[4](playerid, params[])
{
	new PositionName[128];
	if(!sscanf(params, "s[128]", PositionName))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:r,
			data[256];

		file_Open("savedpositions.txt");
		{
			if(file_IsKey(PositionName))
				file_GetStr(PositionName, data);
			else
			    return Msg(playerid, RED, " >  Position not found");
		}
		file_Close();

		sscanf(data, "p<,>ffff", x, y, z, r);
		MsgF(playerid, YELLOW, " >  "#C_BLUE"%s = %s "#C_YELLOW"Loaded!", PositionName, data);
		if(IsPlayerInAnyVehicle(playerid))
		{
		    new vehicleid = GetPlayerVehicleID(playerid);
			SetVehiclePos(vehicleid, x, y, z);
			SetVehicleZAngle(vehicleid, r);
		}
		else
		{
			SetPlayerPos(playerid, x, y, z);
			SetPlayerFacingAngle(playerid, r);
		}
	}
	else Msg(playerid, YELLOW, " >  Usage: /tp [position name]");
 	return 1;
}
ACMD:sound[4](playerid, params[])
{
	new
		soundid = strval(params),
		Float:x,
		Float:y,
		Float:z;

	PlayerLoop(i)
	{
	    if(IsPlayerInRangeOfPoint(i, 20.0, x, y, z))PlayerPlaySound(i, soundid, x, y, z);
	}
	
	return 1;
}
ACMD:stealth[4](playerid, params[])
{
    PlayerLoop(i)bitTrue(bPlayerGameSettings[i], Invis);
	return 1;
}
ACMD:stealthoff[4](playerid, params[])
{
    PlayerLoop(i)bitFalse(bPlayerGameSettings[i], Invis);
	return 1;
}
ACMD:anim[4](playerid, params[])
{
	new
		lib[20],
		anim[30],
		loop,
		Float:speed;
	if(sscanf(params, "s[20]s[30]D(0)F(4.0)", lib, anim, loop, speed))return Msg(playerid, YELLOW, "Usage: /anim LIB ANIM LOOP SPEED");
	else ApplyAnimation(playerid, lib, anim, speed, loop, 1, 1, 0, 0, 1);
	return 1;
}
ACMD:gotopos[4](playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	if(sscanf(params, "fff", x, y, z) || sscanf(params, "p<,>fff", x, y, z))
		return Msg(playerid, YELLOW, "Usage: /gotopos x, y, z (With or without commas)");

	MsgF(playerid, YELLOW, " >  Teleported to %f, %f, %f", x, y, z);
	SetPlayerPos(playerid, x, y, z);

	return 1;
}
ACMD:chatlock[4](playerid, params[])
{
	if(bServerGlobalSettings&ChatLocked)
	{
		bitFalse(bServerGlobalSettings, ChatLocked);
		Msg(playerid, YELLOW, " >  Chat Unlocked");
	}
	else
	{
		bitTrue(bServerGlobalSettings, ChatLocked);
		Msg(playerid, YELLOW, " >  Chat Locked");
	}
	return 1;
}
ACMD:serverlock[4](playerid, params[])
{
	if(bServerGlobalSettings&ServerLocked)
	{
		bitFalse(bServerGlobalSettings, ServerLocked);
		Msg(playerid, YELLOW, " >  Server Unlocked");
	}
	else
	{
		bitTrue(bServerGlobalSettings, ServerLocked);
		Msg(playerid, YELLOW, " >  Server Locked");
	}
	return 1;
}
ACMD:cleardm[4](playerid, params[])
{
	ResetDMVariables();
	return 1;
}
ACMD:realtime[4](playerid, params[])
{
    if(bServerGlobalSettings&Realtime)
	{
		bitFalse(bServerGlobalSettings, Realtime);
		Msg(playerid, GREEN, "Realtime deactivated");
	}
    else
	{
		bitTrue(bServerGlobalSettings, Realtime);
		Msg(playerid, GREEN, "Realtime activated");
	}
    return 1;
}
		ACMD:ccmd[4](playerid, params[])
		{
		    if(bServerGlobalSettings&FreeroamCommands)
		    {
				bitFalse(bServerGlobalSettings, FreeroamCommands);
				Msg(playerid, YELLOW, " >  Freeroam Commands "#C_BLUE"Disabled");
		    }
		    else
		    {
				bitTrue(bServerGlobalSettings, FreeroamCommands);
				Msg(playerid, YELLOW, " >  Freeroam Commands "#C_BLUE"Enabled");
		    }
			return 1;
		}
		ACMD:debug[4](playerid, params[])
		{
		    if(bPlayerGameSettings[playerid]&DebugMode)
			{
				bitFalse(bPlayerGameSettings[playerid], DebugMode);
				Msg(playerid, 0xFF5500AA, "Debug Mode disabled");
			}
		    else
			{
				bitTrue(bPlayerGameSettings[playerid], DebugMode);
				Msg(playerid, 0xFF5500AA, "Debug Mode enabled");
			}
		    return 1;
		}

		ACMD:k[4](playerid, params[])
		{
			SetPlayerHP(strval(params), 0);
			return 1;
		}
		ACMD:frz[4](playerid, params[])
		{
			TogglePlayerControllable(strval(params), 0);
			return 1;
		}
		ACMD:unfrz[4](playerid, params[])
		{
			TogglePlayerControllable(strval(params), 1);
			return 1;
		}
		ACMD:to[4](playerid, params[])
		{
			new id;
			if(sscanf(params, "d", id)) Msg(playerid, YELLOW, "Usage: /goto [playerid]");
			else if(!IsPlayerConnected(id)) return Msg(playerid, RED, "Invalid ID");
			else
			{
				new
					Float:px,
					Float:py,
					Float:pz,
					Float:ang,
					pVehicleID = GetPlayerVehicleID(playerid),
					Inter=GetPlayerInterior(id),
					Vworld=GetPlayerVirtualWorld(id);
				GetPlayerPos(id, px, py, pz);
				if(IsPlayerInAnyVehicle(id))GetVehicleZAngle(pVehicleID, ang);
				else GetPlayerFacingAngle(id, ang);
				SetPlayerPos(playerid, px, py, pz+2);
				SetPlayerFacingAngle(playerid, ang);
				SetPlayerInterior(playerid, Inter);
				SetPlayerVirtualWorld(playerid, Vworld);
				if(IsPlayerInAnyVehicle(playerid))
				{
					SetVehiclePos(pVehicleID, px, py, pz+2);
					SetVehicleZAngle(pVehicleID, ang);
					LinkVehicleToInterior(pVehicleID, Inter);
					PutPlayerInVehicle(playerid, pVehicleID, 0);
				}
			}
			return 1;
		}
		ACMD:geta[4](playerid, params[])
		{
			new id;
			if(sscanf(params, "d", id)) Msg(playerid, YELLOW, "Usage: /get [playerid]");
			else if(!IsPlayerConnected(id)) return Msg(playerid, RED, "Invalid ID");
			else
			{
				new Float:px, Float:py, Float:pz, Float:ang, Inter=GetPlayerInterior(id), Vworld=GetPlayerVirtualWorld(id);
	 			new opveh = GetPlayerVehicleID(id);
	   			GetPlayerPos(playerid, px, py, pz);
	   			GetPlayerFacingAngle(playerid, ang);
		  		SetPlayerPos(id, px, py, pz+2);
				SetPlayerFacingAngle(id, ang);
				SetPlayerInterior(id, Inter);
				SetPlayerVirtualWorld(id, Vworld);
				if(IsPlayerInAnyVehicle(id))
				{
					GetXYInFrontOfPlayer(playerid, px, py, -5);
					SetVehiclePos(opveh, px, py, pz+4);
					SetVehicleZAngle(opveh, ang);
					LinkVehicleToInterior(opveh, Inter);
		 			PutPlayerInVehicle(id, opveh, 0);
				}
			}
			return 1;
		}
		ACMD:exp[4](playerid, params[])
		{
			new Float:x,Float:y,Float:z;
			GetPlayerPos(strval(params), Float:x, Float:y, Float:z);
			CreateExplosion(Float:x, Float:y, Float:z, 7, 0.0001);
			return 1;
		}
		ACMD:getin[4](playerid, params[])
		{
			PutPlayerInVehicle(playerid, GetPlayerVehicleID(strval(params)), 1);
			return 1;
		}
		ACMD:resetcars[4](playerid, params[])
		{
			for(new i;i<MAX_VEHICLES;i++)
				if(!(bVehicleSettings[i] & v_Used))
					SetVehicleToRespawn(i);

			return 1;
		}
		ACMD:resetallcars[4](playerid, params[])
		{
			for(new i;i<MAX_VEHICLES;i++)
				SetVehicleToRespawn(i);

			return 1;
		}
		ACMD:sneakoff[4](playerid, params[])
		{
			OnPlayerDisconnect(playerid, 0);
			SetPlayerColor(playerid, 0x00000000);
			SetPlayerName(playerid, "[]");
			PlayerLoop(i)ShowPlayerNameTagForPlayer(playerid, i, false);
			bitTrue(bPlayerGameSettings[playerid], Invis);
			return 1;
		}
		ACMD:backpack[4](playerid, params[])
		{
			SetPlayerAttachedObject(playerid, 1, 1310, 1, -0.1, -0.2, 0, 0, 90, 0, 1, 1, 1);
			return 1;
		}
		ACMD:turtle[4](playerid, params[])
		{
		    if(IsPlayerAttachedObjectSlotUsed(playerid, MISC_SLOT_1))RemovePlayerAttachedObject(playerid, MISC_SLOT_1);
			else SetPlayerAttachedObject(playerid, MISC_SLOT_1, 1609, 2, _, _, 0.3, _, 90, _);
			return 1;
		}
		ACMD:armourtest[4](playerid, params[])
		{
		    SetPlayerAttachedObject(playerid, MISC_SLOT_1, 373, 1, 0.300327, -0.004779, -0.178271, 73.442504, 25.958881, 32.691726);
			return 1;
		}
		ACMD:gtest[4](playerid, params[])
		{
			SetPlayerAttachedObject(playerid, GHILLIE_SLOT, 760, 1, _, _, _, 90, _, _);
		    return 1;
		}


//==============================================================================Debug Commands
		ACMD:gotoflag[4](playerid, params[])
		{
		    SetPlayerPos(playerid, CtfPosF[pTeam(playerid)][0], CtfPosF[pTeam(playerid)][1], CtfPosF[pTeam(playerid)][2]);
			MsgF(playerid, YELLOW, "%d, %d, %d", CountDynamicPickups(), Streamer_CountVisibleItems(playerid, STREAMER_TYPE_PICKUP), IsValidDynamicPickup(CtfFlag[pTeam(playerid)]) );
		    return 1;
		}
		ACMD:givexp[4](playerid, params[])
		{
		    new strs[5][32]=
		    {
		        "long string to test it",
		        "well done",
		        "reward",
		        "kill-chain of 3",
		        "capture"
		    };
		    GiveXP(playerid, random(10), strs[random(5)]);
		    return 1;
		}
		ACMD:dminit[4](playerid, params[])
		{
		    StartDM();
		    return 1;
		}
		ACMD:getanim[4](playerid, params[])
		{
		    new animlib[32], animname[32], idx=GetPlayerAnimationIndex(playerid);
		    GetAnimationName(idx, animlib, 32, animname, 32);
		    MsgF(playerid, YELLOW, "Lib: %s Name: %s Idx: %d", animlib, animname, idx);
		    return 1;
		}
		ACMD:removeattach[4](playerid, params[])
		{
			RemovePlayerAttachedObject(playerid, 0);
			RemovePlayerAttachedObject(playerid, 1);
			RemovePlayerAttachedObject(playerid, 2);
			RemovePlayerAttachedObject(playerid, 3);
			RemovePlayerAttachedObject(playerid, 4);
			RemovePlayerAttachedObject(playerid, 5);
			RemovePlayerAttachedObject(playerid, 6);
			RemovePlayerAttachedObject(playerid, 7);
			RemovePlayerAttachedObject(playerid, 8);
			RemovePlayerAttachedObject(playerid, 9);
			return 1;
		}
		ACMD:armour[4](playerid, params[])
	    {
			SetPlayerAttachedObject(playerid, MISC_SLOT_1, 19142, 1, 0.1, 0.05, 0.0, 0.0, 0.0, 0.0);
			SetPlayerAttachedObject(playerid, MISC_SLOT_2, 19141, 2, 0.11, 0.0, 0.0, 0.0, 0.0, 0.0);
			SetPlayerAttachedObject(playerid, MISC_SLOT_3, 18637, 13, 0.35, 0.0, 0.0, 0.0, 0.0, 180.0);
			SetPlayerAttachedObject(playerid, MISC_SLOT_4, 18642, 7, 0.1, 0.0, -0.11, 0.0, -90.0, 90.0);
			return 1;
		}
		ACMD:setskill[4](playerid, params[])
		{
		    new d=strval(params);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			d);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED,	d);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE,		d);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN,			d);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	d);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN,	d);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		d);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5,				d);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47,				d);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_M4,				d);
			SetPlayerSkillLevel(playerid, WEAPONSKILL_SNIPERRIFLE,		d);
		    return 1;
		}
		ACMD:copgunanim[4](playerid, params[])
		{
		    SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 5000);
		    GivePlayerWeapon(playerid, WEAPON_COLT45, 17*5);
		    return 1;
		}

		new sro[42];
		ACMD:steamroll[4](playerid, params[])
		{
		    new pVehicleID = GetPlayerVehicleID(playerid);
			sro[0]=CreateObject(2937, 0.000000, 4.390404, -0.374200, 0.000000, 90.000000, 90.000000);
			AttachObjectToVehicle(sro[0], pVehicleID, 0.000000, 4.390404, -0.374200, 0.000000, 90.000000, 90.000000);
			sro[1]=CreateObject(2937, 0.000000, 4.471110, -0.152799, 0.000000, 100.000000, 90.000000);
			AttachObjectToVehicle(sro[1], pVehicleID, 0.000000, 4.471110, -0.152799, 0.000000, 100.000000, 90.000000);
			sro[2]=CreateObject(2937, 0.000000, 4.465988, -0.705200, 0.000000, 80.000000, 90.000000);
			AttachObjectToVehicle(sro[2], pVehicleID, 0.000000, 4.465988, -0.705200, 0.000000, 80.000000, 90.000000);
			sro[3]=CreateObject(2937, 0.000000, 4.688470, 0.320199, 0.000000, 130.000000, 90.000000);
			AttachObjectToVehicle(sro[3], pVehicleID, 0.000000, 4.688470, 0.320199, 0.000000, 130.000000, 90.000000);
			sro[4]=CreateObject(2937, 0.000000, 4.687227, -1.162001, 0.000000, 50.000000, 90.000000);
			AttachObjectToVehicle(sro[4], pVehicleID, 0.000000, 4.687227, -1.162001, 0.000000, 50.000000, 90.000000);
			sro[5]=CreateObject(3280, -0.010742, 2.643554, 0.491387, 299.998168, 0.000000, 0.000000);
			AttachObjectToVehicle(sro[5], pVehicleID, -0.010742, 2.643554, 0.491387, 299.998168, 0.000000, 0.000000);
			sro[6]=CreateObject(2937, 0.000000, 4.529251, 0.114999, 0.000000, 120.000000, 90.000000);
			AttachObjectToVehicle(sro[6], pVehicleID, 0.000000, 4.529251, 0.114999, 0.000000, 120.000000, 90.000000);
			sro[7]=CreateObject(2937, 0.000000, 4.416649, -0.694400, 0.000000, 90.000000, 90.000000);
			AttachObjectToVehicle(sro[7], pVehicleID, 0.000000, 4.416649, -0.694400, 0.000000, 90.000000, 90.000000);
			sro[8]=CreateObject(2937, 0.000000, 4.583421, -1.118801, 0.000000, 45.000000, 90.000000);
			AttachObjectToVehicle(sro[8], pVehicleID, 0.000000, 4.583421, -1.118801, 0.000000, 45.000000, 90.000000);
			sro[9]=CreateObject(2937, 0.000000, 5.043893, -1.433601, 0.000000, 15.000000, 90.000000);
			AttachObjectToVehicle(sro[9], pVehicleID, 0.000000, 5.043893, -1.433601, 0.000000, 15.000000, 90.000000);
			sro[10]=CreateObject(2228, 1.365761, -0.890789, 0.439335, 0.000000, 0.000000, 270.000000);
			AttachObjectToVehicle(sro[10], pVehicleID, 1.365761, -0.890789, 0.439335, 0.000000, 0.000000, 270.000000);
			sro[11]=CreateObject(2237, 1.405730, -1.287106, 0.989490, 0.000000, 0.000000, 90.000000);
			AttachObjectToVehicle(sro[11], pVehicleID, 1.405730, -1.287106, 0.989490, 0.000000, 0.000000, 90.000000);
			sro[12]=CreateObject(1650, -1.050109, 2.775264, 0.423850, 0.000000, 0.000000, 90.000000);
			AttachObjectToVehicle(sro[12], pVehicleID, -1.050109, 2.775264, 0.423850, 0.000000, 0.000000, 90.000000);
			sro[13]=CreateObject(3280, -0.010742, 2.643554, 0.491387, 299.998168, 0.000000, 0.000000);
			AttachObjectToVehicle(sro[13], pVehicleID, -0.010742, 2.643554, 0.491387, 299.998168, 0.000000, 0.000000);
			sro[14]=CreateObject(16637, -0.023021, -3.615131, -0.001335, 0.000000, 270.000000, 0.000000);
			AttachObjectToVehicle(sro[14], pVehicleID, -0.023021, -3.615131, -0.001335, 0.000000, 270.000000, 0.000000);
			sro[15]=CreateObject(2937, -0.282178, -5.531250, -0.233243, 0.000000, 90.000000, 90.000000);
			AttachObjectToVehicle(sro[15], pVehicleID, -0.282178, -5.531250, -0.233243, 0.000000, 90.000000, 90.000000);
			sro[16]=CreateObject(2937, 0.238750, -5.531250, -0.233243, 0.000000, 90.000000, 90.000000);
			AttachObjectToVehicle(sro[16], pVehicleID, 0.238750, -5.531250, -0.233243, 0.000000, 90.000000, 90.000000);
			sro[17]=CreateObject(2937, 0.238281, -5.531250, -0.785643, 0.000000, 90.000000, 90.000000);
			AttachObjectToVehicle(sro[17], pVehicleID, 0.238281, -5.531250, -0.785643, 0.000000, 90.000000, 90.000000);
			sro[18]=CreateObject(2937, -0.277918, -5.531250, -0.785643, 0.000000, 90.000000, 90.000000);
			AttachObjectToVehicle(sro[18], pVehicleID, -0.277918, -5.531250, -0.785643, 0.000000, 90.000000, 90.000000);
			sro[19]=CreateObject(2937, 1.517475, -4.297450, -0.785643, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(sro[19], pVehicleID, 1.517475, -4.297450, -0.785643, 0.000000, 90.000000, 0.000000);
			sro[20]=CreateObject(2937, 1.516601, -2.915673, -0.246243, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(sro[20], pVehicleID, 1.516601, -2.915673, -0.246243, 0.000000, 90.000000, 0.000000);
			sro[21]=CreateObject(2937, 1.516601, -4.296875, -0.246243, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(sro[21], pVehicleID, 1.516601, -4.296875, -0.246243, 0.000000, 90.000000, 0.000000);
			sro[22]=CreateObject(2937, 1.516601, -2.915081, -0.785643, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(sro[22], pVehicleID, 1.516601, -2.915081, -0.785643, 0.000000, 90.000000, 0.000000);
			sro[23]=CreateObject(2937, -1.573002, -4.296875, -0.246243, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(sro[23], pVehicleID, -1.573002, -4.296875, -0.246243, 0.000000, 90.000000, 0.000000);
			sro[24]=CreateObject(2937, -1.572265, -4.296875, -0.773243, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(sro[24], pVehicleID, -1.572265, -4.296875, -0.773243, 0.000000, 90.000000, 0.000000);
			sro[25]=CreateObject(2937, -1.572265, -2.975073, -0.246243, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(sro[25], pVehicleID, -1.572265, -2.975073, -0.246243, 0.000000, 90.000000, 0.000000);
			sro[26]=CreateObject(2937, -1.572265, -2.942673, -0.773243, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(sro[26], pVehicleID, -1.572265, -2.942673, -0.773243, 0.000000, 90.000000, 0.000000);
			sro[27]=CreateObject(2937, -1.572265, -4.296875, 0.316956, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(sro[27], pVehicleID, -1.572265, -4.296875, 0.316956, 0.000000, 90.000000, 0.000000);
			sro[28]=CreateObject(2937, 1.516601, -4.296875, 0.302356, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(sro[28], pVehicleID, 1.516601, -4.296875, 0.302356, 0.000000, 90.000000, 0.000000);
			sro[29]=CreateObject(2937, 1.516601, -2.915039, 0.307756, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(sro[29], pVehicleID, 1.516601, -2.915039, 0.307756, 0.000000, 90.000000, 0.000000);
			sro[30]=CreateObject(2937, -1.572265, -2.974609, 0.316956, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(sro[30], pVehicleID, -1.572265, -2.974609, 0.316956, 0.000000, 90.000000, 0.000000);
			sro[31]=CreateObject(2937, -0.369265, -1.720812, 0.316956, 0.000000, 90.000000, 270.000000);
			AttachObjectToVehicle(sro[31], pVehicleID, -0.369265, -1.720812, 0.316956, 0.000000, 90.000000, 270.000000);
			sro[32]=CreateObject(2937, 0.283659, -1.720703, 0.322356, 0.000000, 90.000000, 270.000000);
			AttachObjectToVehicle(sro[32], pVehicleID, 0.283659, -1.720703, 0.322356, 0.000000, 90.000000, 270.000000);
			sro[33]=CreateObject(2937, 0.304802, -5.542497, 0.300756, 0.000000, 90.000000, 270.000000);
			AttachObjectToVehicle(sro[33], pVehicleID, 0.304802, -5.542497, 0.300756, 0.000000, 90.000000, 270.000000);
			sro[34]=CreateObject(2937, -0.402112, -5.541992, 0.300756, 0.000000, 90.000000, 270.000000);
			AttachObjectToVehicle(sro[34], pVehicleID, -0.402112, -5.541992, 0.300756, 0.000000, 90.000000, 270.000000);
			sro[35]=CreateObject(1238, -1.255923, -2.083270, 0.362627, 0.000000, 0.000000, 0.000000);
			AttachObjectToVehicle(sro[35], pVehicleID, -1.255923, -2.083270, 0.362627, 0.000000, 0.000000, 0.000000);
			sro[36]=CreateObject(1238, -0.710937, -2.083007, 0.362627, 0.000000, 0.000000, 310.374755);
			AttachObjectToVehicle(sro[36], pVehicleID, -0.710937, -2.083007, 0.362627, 0.000000, 0.000000, 310.374755);
			sro[37]=CreateObject(2048, -0.523728, -5.608830, 0.084074, 0.000000, 0.000000, 0.000000);
			AttachObjectToVehicle(sro[37], pVehicleID, -0.523728, -5.608830, 0.084074, 0.000000, 0.000000, 0.000000);
			sro[38]=CreateObject(1437, 1.566547, -1.533209, -0.279983, 0.004516, 270.674926, 100.176818);
			AttachObjectToVehicle(sro[38], pVehicleID, 1.566547, -1.533209, -0.279983, 0.004516, 270.674926, 100.176818);
			sro[39]=CreateObject(2690, 0.718220, -1.261309, 0.787263, 0.000000, 0.000000, 0.000000);
			AttachObjectToVehicle(sro[39], pVehicleID, 0.718220, -1.261309, 0.787263, 0.000000, 0.000000, 0.000000);
			sro[40]=CreateObject(2057, 1.059925, -2.126123, 0.214900, 0.000000, 0.000000, 320.299987);
			AttachObjectToVehicle(sro[40], pVehicleID, 1.059925, -2.126123, 0.214900, 0.000000, 0.000000, 320.299987);
			sro[41]=CreateObject(2674, 0.103544, -3.772953, 0.066187, 0.000000, 0.000000, 0.000000);
			AttachObjectToVehicle(sro[41], pVehicleID, 0.103544, -3.772953, 0.066187, 0.000000, 0.000000, 0.000000);
		    return 1;
		}
		new ac[41];
		ACMD:armourcar[4](playerid, params[])
		{
		    new pVehicleID = GetPlayerVehicleID(playerid);
			ac[0]=CreateObject(2669, -0.024414, -0.427734, 1.070683, 0.000000, 0.000000, 0.000000);
			AttachObjectToVehicle(ac[0], pVehicleID, -0.024414, -0.427734, 1.070683, 0.000000, 0.000000, 0.000000);
			ac[1]=CreateObject(1414, 1.562428, -3.864668, 0.663436, 0.000000, 354.234985, 90.000000);
			AttachObjectToVehicle(ac[1], pVehicleID, 1.562428, -3.864668, 0.663436, 0.000000, 354.234985, 90.000000);
			ac[2]=CreateObject(1414, -1.596330, -3.633904, 0.663436, 0.000000, 0.000000, 271.984985);
			AttachObjectToVehicle(ac[2], pVehicleID, -1.596330, -3.633904, 0.663436, 0.000000, 0.000000, 271.984985);
			ac[3]=CreateObject(1414, 1.484788, -3.250230, 0.663436, 0.000000, 0.000000, 90.000000);
			AttachObjectToVehicle(ac[3], pVehicleID, 1.484788, -3.250230, 0.663436, 0.000000, 0.000000, 90.000000);
			ac[4]=CreateObject(1414, -1.621130, -3.019910, 0.816905, 0.000000, 7.940002, 270.000000);
			AttachObjectToVehicle(ac[4], pVehicleID, -1.621130, -3.019910, 0.816905, 0.000000, 7.940002, 270.000000);
			ac[5]=CreateObject(1414, -1.677827, -0.487285, 1.047109, 0.000000, 354.042602, 270.000000);
			AttachObjectToVehicle(ac[5], pVehicleID, -1.677827, -0.487285, 1.047109, 0.000000, 354.042602, 270.000000);
			ac[6]=CreateObject(1414, 1.561523, -0.717773, 1.047109, 0.000000, 354.226684, 90.000000);
			AttachObjectToVehicle(ac[6], pVehicleID, 1.561523, -0.717773, 1.047109, 0.000000, 354.226684, 90.000000);
			ac[7]=CreateObject(1411, 0.589201, -0.488340, 2.574161, 90.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(ac[7], pVehicleID, 0.589201, -0.488340, 2.574161, 90.000000, 90.000000, 0.000000);
			ac[8]=CreateObject(1411, -0.562153, -0.320397, 2.574161, 90.000000, 270.000000, 0.000000);
			AttachObjectToVehicle(ac[8], pVehicleID, -0.562153, -0.320397, 2.574161, 90.000000, 270.000000, 0.000000);
			ac[9]=CreateObject(3117, -0.088453, 5.272907, -0.786405, 308.433227, 0.000000, 1.984985);
			AttachObjectToVehicle(ac[9], pVehicleID, -0.088453, 5.272907, -0.786405, 308.433227, 0.000000, 1.984985);
			ac[10]=CreateObject(3302, 1.773437, 0.690429, 1.461668, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(ac[10], pVehicleID, 1.773437, 0.690429, 1.461668, 0.000000, 90.000000, 0.000000);
			ac[11]=CreateObject(3302, -1.602177, 0.920749, 1.077995, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(ac[11], pVehicleID, -1.602177, 0.920749, 1.077995, 0.000000, 90.000000, 0.000000);
			ac[12]=CreateObject(2937, 1.480766, -3.327510, -0.599208, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(ac[12], pVehicleID, 1.480766, -3.327510, -0.599208, 0.000000, 90.000000, 0.000000);
			ac[13]=CreateObject(2937, 1.477468, -3.319149, -1.145082, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(ac[13], pVehicleID, 1.477468, -3.319149, -1.145082, 0.000000, 90.000000, 0.000000);
			ac[14]=CreateObject(2937, -1.485089, -3.318359, -1.145082, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(ac[14], pVehicleID, -1.485089, -3.318359, -1.145082, 0.000000, 90.000000, 0.000000);
			ac[15]=CreateObject(2937, -1.484375, -3.318359, -0.603939, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(ac[15], pVehicleID, -1.484375, -3.318359, -0.603939, 0.000000, 90.000000, 0.000000);
			ac[16]=CreateObject(1308, 1.195017, 4.500000, -0.437594, 0.000000, 90.000000, 270.000000);
			AttachObjectToVehicle(ac[16], pVehicleID, 1.195017, 4.500000, -0.437594, 0.000000, 90.000000, 270.000000);
			ac[17]=CreateObject(3117, -0.011156, 3.661034, 1.644372, 340.190185, 0.000000, 1.983032);
			AttachObjectToVehicle(ac[17], pVehicleID, -0.011156, 3.661034, 1.644372, 340.190185, 0.000000, 1.983032);
			ac[18]=CreateObject(2678, 1.620639, 4.147448, -0.031380, 0.000000, 0.000000, 95.280029);
			AttachObjectToVehicle(ac[18], pVehicleID, 1.620639, 4.147448, -0.031380, 0.000000, 0.000000, 95.280029);
			ac[19]=CreateObject(2678, -0.987882, 4.734310, -0.031380, 0.000000, 0.000000, 182.614746);
			AttachObjectToVehicle(ac[19], pVehicleID, -0.987882, 4.734310, -0.031380, 0.000000, 0.000000, 182.614746);
			ac[20]=CreateObject(2679, -1.689812, 3.456997, 1.010974, 0.000000, 69.475036, 270.660583);
			AttachObjectToVehicle(ac[20], pVehicleID, -1.689812, 3.456997, 1.010974, 0.000000, 69.475036, 270.660583);
			ac[21]=CreateObject(2679, 1.686523, 3.456054, 1.010974, 0.000000, 69.466552, 270.653686);
			AttachObjectToVehicle(ac[21], pVehicleID, 1.686523, 3.456054, 1.010974, 0.000000, 69.466552, 270.653686);
			ac[22]=CreateObject(1351, -1.584633, 1.073079, -0.132812, 180.000000, 270.000000, 90.000000);
			AttachObjectToVehicle(ac[22], pVehicleID, -1.584633, 1.073079, -0.132812, 180.000000, 270.000000, 90.000000);
			ac[23]=CreateObject(16637, 0.044172, -5.049048, -0.199037, 180.000000, 270.000000, 0.000000);
			AttachObjectToVehicle(ac[23], pVehicleID, 0.044172, -5.049048, -0.199037, 180.000000, 270.000000, 0.000000);
			ac[24]=CreateObject(3260, -0.634765, -4.083984, 2.111146, 287.859863, 90.000000, 359.994506);
			AttachObjectToVehicle(ac[24], pVehicleID, -0.634765, -4.083984, 2.111146, 287.859863, 90.000000, 359.994506);
			ac[25]=CreateObject(2977, -0.842920, -5.165857, -0.312221, 0.000000, 0.000000, 0.000000);
			AttachObjectToVehicle(ac[25], pVehicleID, -0.842920, -5.165857, -0.312221, 0.000000, 0.000000, 0.000000);
			ac[26]=CreateObject(1550, -1.016228, 1.321895, 0.246377, 0.000000, 0.000000, 0.000000);
			AttachObjectToVehicle(ac[26], pVehicleID, -1.016228, 1.321895, 0.246377, 0.000000, 0.000000, 0.000000);
			ac[27]=CreateObject(2358, 0.359478, 1.208222, -0.030428, 0.000000, 0.000000, 326.255004);
			AttachObjectToVehicle(ac[27], pVehicleID, 0.359478, 1.208222, -0.030428, 0.000000, 0.000000, 326.255004);
			ac[28]=CreateObject(935, 1.003468, -3.570256, 0.418371, 0.000000, 0.000000, 262.599975);
			AttachObjectToVehicle(ac[28], pVehicleID, 1.003468, -3.570256, 0.418371, 0.000000, 0.000000, 262.599975);
			ac[29]=CreateObject(3062, -1.602945, 3.111838, 0.232619, 0.000000, 359.851989, 93.707031);
			AttachObjectToVehicle(ac[29], pVehicleID, -1.602945, 3.111838, 0.232619, 0.000000, 359.851989, 93.707031);
			ac[30]=CreateObject(2930, -1.042576, 4.555826, 1.398194, 84.028076, 85.694458, 186.420150);
			AttachObjectToVehicle(ac[30], pVehicleID, -1.042576, 4.555826, 1.398194, 84.028076, 85.694458, 186.420150);
			ac[31]=CreateObject(1448, -0.890625, -4.916992, 1.319680, 82.732543, 179.994506, 179.994506);
			AttachObjectToVehicle(ac[31], pVehicleID, -0.890625, -4.916992, 1.319680, 82.732543, 179.994506, 179.994506);
			ac[32]=CreateObject(2040, 0.365156, 1.212317, 0.208538, 0.000000, 0.000000, 0.000000);
			AttachObjectToVehicle(ac[32], pVehicleID, 0.365156, 1.212317, 0.208538, 0.000000, 0.000000, 0.000000);
			ac[33]=CreateObject(2042, -0.180212, 0.805307, -0.066984, 0.000000, 0.000000, 0.000000);
			AttachObjectToVehicle(ac[33], pVehicleID, -0.180212, 0.805307, -0.066984, 0.000000, 0.000000, 0.000000);
			ac[34]=CreateObject(2038, 0.492876, 0.855283, -0.069754, 0.000000, 0.000000, 327.574035);
			AttachObjectToVehicle(ac[34], pVehicleID, 0.492876, 0.855283, -0.069754, 0.000000, 0.000000, 327.574035);
			ac[35]=CreateObject(2937, 1.430837, 2.167968, -1.104960, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(ac[35], pVehicleID, 1.430837, 2.167968, -1.104960, 0.000000, 90.000000, 0.000000);
			ac[36]=CreateObject(2937, 1.430664, 2.167968, -0.554760, 0.000000, 90.000000, 0.000000);
			AttachObjectToVehicle(ac[36], pVehicleID, 1.430664, 2.167968, -0.554760, 0.000000, 90.000000, 0.000000);
			ac[37]=CreateObject(2228, -0.770392, -4.619262, 0.411040, 0.000000, 0.000000, 0.000000);
			AttachObjectToVehicle(ac[37], pVehicleID, -0.770392, -4.619262, 0.411040, 0.000000, 0.000000, 0.000000);
			ac[38]=CreateObject(2690, -1.103289, -4.322222, 0.214525, 0.000000, 0.000000, 127.579986);
			AttachObjectToVehicle(ac[38], pVehicleID, -1.103289, -4.322222, 0.214525, 0.000000, 0.000000, 127.579986);
			ac[39]=CreateObject(1449, -1.624322, 3.569086, -1.054249, 9.654998, 0.000000, 274.644958);
			AttachObjectToVehicle(ac[39], pVehicleID, -1.624322, 3.569086, -1.054249, 9.654998, 0.000000, 274.644958);
			return 1;
		}


new distobj[MAX_PLAYERS];
ACMD:mark[4](playerid, params[])
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if(IsValidObject(distobj[playerid]))DestroyDynamicObject(distobj[playerid]);
	distobj[playerid]=CreateDynamicObject(345, x, y, z, 0, 0, 0);
	return 1;
}
		ACMD:distance[4](playerid, params[])
		{
			new Float:px, Float:py, Float:pz, Float:ox, Float:oy, Float:oz;
			GetPlayerPos(playerid, px, py, pz);
			GetDynamicObjectPos(distobj[playerid], ox, oy, oz);
			new Float:distsum = floatsqroot((ox-px)*(ox-px)+(oy-py)*(oy-py)+(oz-pz)*(oz-pz));
			new str[64];
			format(str, 64, "%f", distsum);
			Msg(playerid, YELLOW, str);
			return 1;
		}
		ACMD:visob[4](playerid, params[])
		{
		    MsgF(playerid, YELLOW, "Current Visible Objects: %d", Streamer_CountVisibleItems(playerid, STREAMER_TYPE_OBJECT));
			return 1;
		}
		ACMD:dmon[4](playerid, params[])
		{
			PlayerLoop(i)
			bitTrue(bPlayerGameSettings[playerid], InDM);
			bitTrue(bServerGlobalSettings, dm_InProgress);
			return 1;
		}
		ACMD:dmoff[4](playerid, params[])
		{
			PlayerLoop(i)
			bitFalse(bPlayerGameSettings[playerid], InDM);
			return 1;
		}
		ACMD:resetscore[4](playerid, params[])
		{
			dm_TeamScore[score_Kills][0] = 0;
			dm_TeamScore[score_Kills][1] = 0;
			dm_TeamScore[score_Flags][0] = 0;
			dm_TeamScore[score_Flags][1] = 0;
			dm_TeamScore[score_Tickets][0] = 100;
			dm_TeamScore[score_Tickets][1] = 100;
			return 1;
		}
		ACMD:msgbox[4](playerid, params[])
		{
			ShowMsgBox(playerid, "This is a message~n~This is a new line~n~~g~h~r~e~b~l~y~l~p~o ~g~w~r~o~y~r~b~l~p~d~y~!", 3000);
		    return 1;
		}
		ACMD:decam[4](playerid, params[])
		{
		    new Float:cx, Float:cy, Float:cz, Float:px, Float:py, Float:pz;
		    GetPlayerCameraPos(playerid, cx, cy, cz);
		    GetPlayerPos(playerid, px, py, pz);
		    SetPlayerCameraPos(playerid, cx, cy, cz);
		    SetPlayerCameraLookAt(playerid, px, py, pz);
		    return 1;
		}
		ACMD:recam[4](playerid, params[])
		{
		    SetCameraBehindPlayer(playerid);
		    return 1;
		}
		ACMD:hidetd[4](playerid, params[])
		{
		    TextDrawHideForPlayer(playerid, InfoBar);
		    TextDrawHideForPlayer(playerid, ClockText);
			TextDrawHideForPlayer(playerid, ScoreBox);
			TextDrawHideForPlayer(playerid, LobbyText);
			TextDrawHideForPlayer(playerid, SpawnCount);
			TextDrawHideForPlayer(playerid, MatchTimeCounter);
			TextDrawHideForPlayer(playerid, ScoreStatus_Winning);
			TextDrawHideForPlayer(playerid, ScoreStatus_Tie);
			TextDrawHideForPlayer(playerid, ScoreStatus_Losing);
			PlayerTextDrawHide(playerid, dm_EquipText);
		    return 1;
		}
		ACMD:indm[4](playerid, params[])
		{
			if(bPlayerGameSettings[playerid]&InDM) Msg(playerid, YELLOW, "YES");
			else Msg(playerid, YELLOW, "NO");
			return 1;
		}
		ACMD:inlob[4](playerid, params[])
		{
			if(bPlayerDeathmatchSettings[playerid]&dm_InLobby) Msg(playerid, YELLOW, "YES");
			else Msg(playerid, YELLOW, "NO");
			return 1;
		}
		ACMD:dmdata[4](playerid, params[])
		{
			MsgF(playerid, YELLOW, "Mode: %d Map: %d DMstarted %d", dm_Mode, dm_Map, (bServerGlobalSettings & dm_Started));
			return 1;
		}
		//ScoreLevelers
		ACMD:setrav[4](playerid, params[])
		{
			dm_TeamScore[score_Kills][0] = strval(params);
			TeamScoreUpdate();
			return 1;
		}
ACMD:setval[4](playerid, params[])
{
	dm_TeamScore[score_Kills][1] = strval(params);
	TeamScoreUpdate();
	return 1;
}




ACMD:getdata[4](playerid, params[])
{
	new id;
	if (sscanf(params, "d", id)) Msg(playerid, YELLOW, "Usage: /getdata [playerid]");
	else if(!IsPlayerConnected(id)) return Msg(playerid, RED, "Invalid ID");
	else MsgF(playerid, ORANGE, "Team: %d - indm: %b - InLobby: %b - Interior: %d - VW: %d - State: %d - ReadyForDM: %d", dm_PlayerData[id][dm_Team], bPlayerGameSettings[id]&InDM, bPlayerDeathmatchSettings[id]&dm_InLobby, GetPlayerInterior(id), GetPlayerVirtualWorld(id), GetPlayerState(id), bPlayerDeathmatchSettings[id]&dm_Ready);
	return 1;
}
ACMD:loadmap[4](playerid, params[])
{
	new map;
	if(!sscanf(params, "d", map))LoadDM_Map(map);
	else return 0;
	return 1;
}
ACMD:telemap[4](playerid, params[])
{
	new map;
	if(!sscanf(params, "d", map))
	{
	    new Float:spawnX, Float:spawnY, Float:spawnZ, fname[64], lineData[256];

		format(fname, 64, DM_DATA_FILE, map, dm_MapNames[map]);

		file_Open(fname);
		file_GetStr("GEN_spawn1", lineData);
		file_Close();

		sscanf(lineData, "p<,>fff", spawnX, spawnY, spawnZ);
		SetPlayerPos(playerid, spawnX, spawnY, spawnZ);
		SetPlayerVirtualWorld(playerid, DEATHMATCH_WORLD);
	}
	else return 0;
	return 1;
}
ACMD:cob[4](playerid, params[])
{
	new o;
	if(!sscanf(params,"d",o))
	{
	    new Float:x, Float:y, Float:z;
	    GetPlayerPos(playerid, x, y, z);
	    CreateObject(o, x, y, z, 0, 0, 0);
	}
	return 1;
}
ACMD:setvw[4](playerid, params[])
{
	SetPlayerVirtualWorld(playerid, strval(params));
	return 1;
}
ACMD:setint[4](playerid, params[])
{
	SetPlayerInterior(playerid, strval(params));
	return 1;
}
ACMD:savepcar[4](playerid, params[])
{
	new n[24], c_1, c_2;
	if(sscanf(params, "s[24]dd", n, c_1, c_2))return Msg(playerid, YELLOW, "Usage: /savepcar [playername] [colour1] [colour2]");
	else
	{
		new str[100],
		m=GetVehicleModel(GetPlayerVehicleID(playerid));
		format(str, 100, "{\"/cmd\",\t\"%s\",\t%d,\t%d,\t%d}", n, m, c_1, c_2);
		file_Open("savedpositions.txt");
		file_SetStr(n, str);
		file_Save("savedpositions.txt");
		file_Close();
	    Msg(playerid, YELLOW, "Vehicle Saved");
	}
	return 1;
}
ACMD:up[4](playerid, params[])
{
	new Float:d=float(strval(params)), Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(playerid, x, y, z+d);
	return 1;
}
ACMD:ford[4](playerid, params[])
{
	new Float:d=float(strval(params)), Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);
	GetXYFromAngle(x, y, a, d);
	SetPlayerPos(playerid, x, y, z);
	return 1;
}


ACMD:sobj[4](playerid, params[])
{
	SelectObject(playerid);
	SendClientMessage(playerid, 0xFFFFFFFF, "SERVER: Please select the object you'd like to edit!");
	return 1;
}
public OnPlayerSelectObject(playerid, type, objectid, modelid, Float:fX, Float:fY, Float:fZ)
{
    printf("Player %d selected object %d", playerid, objectid);
    if(type == SELECT_OBJECT_GLOBAL_OBJECT)
    {
        EditObject(playerid, objectid);
    }
    else
    {
        EditPlayerObject(playerid, objectid);
    }
    SendClientMessage(playerid, 0xFFFFFFFF, "You now are able to edit your object!");
    return 1;
}
public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	new Float:oldX, Float:oldY, Float:oldZ,
		Float:oldRotX, Float:oldRotY, Float:oldRotZ;
	GetObjectPos(objectid, oldX, oldY, oldZ);
	GetObjectRot(objectid, oldRotX, oldRotY, oldRotZ);
	if(!playerobject) // If this is a global object, move it for other players
	{
	    if(!IsValidObject(objectid)) return;
	    MoveObject(objectid, fX, fY, fZ, 10.0, fRotX, fRotY, fRotZ);
	}

	if(response == EDIT_RESPONSE_FINAL)
	{
		// The player clicked on the save icon
		// Do anything here to save the updated object position (and rotation)
	}

	if(response == EDIT_RESPONSE_CANCEL)
	{
		//The player cancelled, so put the object back to it's old position
		if(!playerobject) //Object is not a playerobject
		{
			SetObjectPos(objectid, oldX, oldY, oldZ);
			SetObjectRot(objectid, oldRotX, oldRotY, oldRotZ);
		}
		else
		{
			SetPlayerObjectPos(playerid, objectid, oldX, oldY, oldZ);
			SetPlayerObjectRot(playerid, objectid, oldRotX, oldRotY, oldRotZ);
		}
	}
}

CMD:additem(playerid, params[])
{
	new
		ItemType:type = ItemType:strval(params),
		itemid,
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	itemid = CreateItem(type,
			x + (0.5 * floatsin(-r, degrees)),
			y + (0.5 * floatcos(-r, degrees)),
			z - 0.8568, .rz = r, .zoffset = 0.7);


	if(0 < _:type <= WEAPON_PARACHUTE)
		SetItemExtraData(itemid, WepData[_:type][MagSize]);

	return 1;
}


/*
ACMD:objtest[4](playerid, params[])
{
	new objtype, objid, hold, bone;
	if(sscanf(params, "dddd", objtype, objid, hold, bone))
	{
		Msg(playerid, YELLOW, "Usage: /objtest [objtype], [objid], [hold 0/1], [bone <if:'hold'=1>]");
		Msg(playerid, BLUE, " - objtypes: 0=Holding, 1=Lights, 2=Spraytags, 3=ParticleFX, 4=Misc, 5=DriveSections, 6=Stunting, 7=Clothing");
	}
	else
	{
	    new model, mName[20];
	    if(objtype==0)model = objects_Holding[objid][ob_id],		format(mName, 20, objects_Holding[objid][ob_name]);
	    if(objtype==1)model = objects_Lights[objid][ob_id],			format(mName, 20, objects_Lights[objid][ob_name]);
	    if(objtype==2)model = objects_Spraytags[objid][ob_id],		format(mName, 20, objects_Spraytags[objid][ob_name]);
	    if(objtype==3)model = objects_ParticleFX[objid][ob_id],		format(mName, 20, objects_ParticleFX[objid][ob_name]);
	    if(objtype==4)model = objects_Misc[objid][ob_id],			format(mName, 20, objects_Misc[objid][ob_name]);
	    if(objtype==5)model = objects_DriveSections[objid][ob_id],	format(mName, 20, objects_DriveSections[objid][ob_name]);
	    if(objtype==6)model = objects_Stunting[objid][ob_id],		format(mName, 20, objects_Stunting[objid][ob_name]);
	    if(objtype==7)model = objects_Clothing[objid][ob_id],		format(mName, 20, objects_Clothing[objid][ob_name]);

	    if(hold==1)
	    {
			if(objtype!=5||objtype!=6)SetPlayerAttachedObject(playerid, MISC_SLOT_1, model, bone);
		}
	    else
	    {
	        new Float:x, Float:y, Float:z;
	        GetPlayerPos(playerid, x, y, z);
	        GetXYInFrontOfPlayer(playerid, x, y, 10);
	        CreateObject(model, x, y, z, 0, 0, 0);
	    }
	    MsgF(playerid, YELLOW, "Object Created: %s (%d)", mName, model);
	}
	return 1;
}
*/


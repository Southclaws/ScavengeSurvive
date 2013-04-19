#include <YSI\y_hooks>


public OnPlayerConnect(playerid)
{
	SetPlayerColor(playerid, 0xB8B8B800);
	SetPlayerWeather(playerid, gWeatherID);
	GetPlayerName(playerid, gPlayerName[playerid], MAX_PLAYER_NAME);

	if(IsPlayerNPC(playerid))
		return 1;

	tick_ServerJoin[playerid] = tickcount();

	new
		tmpadminlvl,
		tmpIP[16],
		tmpByte[4],
		tmpCountry[32],
		tmpQuery[128],
		DBResult:tmpResult;

	GetPlayerIp(playerid, tmpIP, 16);

	sscanf(tmpIP, "p<.>a<d>[4]", tmpByte);
	gPlayerData[playerid][ply_IP] = ((tmpByte[0] << 24) | (tmpByte[1] << 16) | (tmpByte[2] << 8) | tmpByte[3]) ;

	format(tmpQuery, sizeof(tmpQuery), "SELECT * FROM `Bans` WHERE `"#ROW_NAME"` = '%s' OR `"#ROW_IPV4"` = '%d'",
		strtolower(gPlayerName[playerid]), gPlayerData[playerid][ply_IP]);

	tmpResult = db_query(gAccounts, tmpQuery);

	if(db_num_rows(tmpResult) > 0)
	{
		new
			str[256],
			tmptime[12],
			tm<timestamp>,
			timestampstr[64],
			reason[64],
			bannedby[24];

		db_get_field(tmpResult, 2, tmptime, 12);
		db_get_field(tmpResult, 3, reason, 64);
		db_get_field(tmpResult, 4, bannedby, 24);
		
		localtime(Time:strval(tmptime), timestamp);
		strftime(timestampstr, 64, "%A %b %d %Y at %X", timestamp);

		format(str, 256, "\
			"#C_YELLOW"Date:\n\t\t"#C_BLUE"%s\n\n\n\
			"#C_YELLOW"By:\n\t\t"#C_BLUE"%s\n\n\n\
			"#C_YELLOW"Reason:\n\t\t"#C_BLUE"%s", timestampstr, bannedby, reason);

		ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Banned", str, "Close", "");

		defer KickPlayerDelay(playerid);

		db_free_result(tmpResult);

		format(tmpQuery, sizeof(tmpQuery), "UPDATE `Bans` SET `"#ROW_IPV4"` = '%d' WHERE `"#ROW_NAME"` = '%s'",
			gPlayerData[playerid][ply_IP], strtolower(gPlayerName[playerid]));

		db_free_result(db_query(gAccounts, tmpQuery));

		return 1;
	}

	for(new i; i < gTotalAdmins; i++)
	{
		if(!strcmp(gPlayerName[playerid], gAdminData[i][admin_Name]))
		{
			tmpadminlvl = gAdminData[i][admin_Level];
			if(tmpadminlvl > 3) tmpadminlvl = 3;
			break;
		}
	}

	format(tmpQuery, sizeof(tmpQuery), "SELECT * FROM `Player` WHERE `"#ROW_NAME"` = '%s'", gPlayerName[playerid]);
	tmpResult = db_query(gAccounts, tmpQuery);

	ResetVariables(playerid);

	if(gPlayerData[playerid][ply_IP] == 2130706433)
		tmpCountry = "Localhost";

	else
		GetPlayerCountry(playerid, tmpCountry);

	if(isnull(tmpCountry))tmpCountry = "Unknown";

	if(db_num_rows(tmpResult) >= 1)
	{
		new
			tmpField[50],
			dbIP;

		db_get_field_assoc(tmpResult, #ROW_PASS, gPlayerData[playerid][ply_Password], MAX_PASSWORD_LEN);

		db_get_field_assoc(tmpResult, #ROW_GEND, tmpField, 2);

		if(strval(tmpField) == 0)
		{
			f:bPlayerGameSettings[playerid]<Gender>;
		}
		else
		{
			t:bPlayerGameSettings[playerid]<Gender>;
		}

		db_get_field_assoc(tmpResult, #ROW_IPV4, tmpField, 12);
		dbIP = strval(tmpField);

		db_get_field_assoc(tmpResult, #ROW_ALIVE, tmpField, 2);

		if(tmpField[0] == '1')
			t:bPlayerGameSettings[playerid]<Alive>;

		else
			f:bPlayerGameSettings[playerid]<Alive>;

		db_get_field_assoc(tmpResult, #ROW_SPAWN, tmpField, 50);
		sscanf(tmpField, "ffff",
			gPlayerData[playerid][ply_posX],
			gPlayerData[playerid][ply_posY],
			gPlayerData[playerid][ply_posZ],
			gPlayerData[playerid][ply_rotZ]);

		db_get_field_assoc(tmpResult, #ROW_ISVIP, tmpField, 2);

		if(tmpField[0] == '1')
			t:bPlayerGameSettings[playerid]<IsVip>;

		else
			f:bPlayerGameSettings[playerid]<IsVip>;

		t:bPlayerGameSettings[playerid]<HasAccount>;

		if(gPlayerData[playerid][ply_IP] == dbIP)
			Login(playerid);

		else
		{
			new str[128];
			format(str, 128, ""C_WHITE"Welcome Back %P"#C_WHITE", Please log into to your account below!\n\n"#C_YELLOW"Enjoy your stay :)", playerid);
			ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", str, "Accept", "Leave");
		}
	}
	else
	{
		new str[150];
		format(str, 150, ""#C_WHITE"Hello %P"#C_WHITE", You must be new here!\nPlease create an account by entering a "#C_BLUE"password"#C_WHITE" below:", playerid);
		ShowPlayerDialog(playerid, d_Register, DIALOG_STYLE_PASSWORD, "Register For A New Account", str, "Accept", "Leave");

		t:bPlayerGameSettings[playerid]<IsNewPlayer>;
	}
	if(bServerGlobalSettings & ServerLocked)
	{
		Msg(playerid, RED, " >  Server Locked by an admin "#C_WHITE"- Please try again soon.");
		MsgAdminsF(1, RED, " >  %s attempted to join the server while it was locked.", gPlayerName[playerid]);
		Kick(playerid);
		return false;
	}

	MsgAllF(WHITE, " >  %P (%d)"#C_WHITE" has joined [Country: %s]", playerid, playerid, tmpCountry);

	CheckForExtraAccounts(playerid, gPlayerName[playerid]);

	SetAllWeaponSkills(playerid, 500);
	LoadPlayerTextDraws(playerid);
	SetPlayerScore(playerid, 0);
	Streamer_ToggleIdleUpdate(playerid, true);


	db_free_result(tmpResult);

	file_Open(SETTINGS_FILE);
	file_IncVal("Connections", 1);
	file_Save(SETTINGS_FILE);
	file_Close();

	t:bPlayerGameSettings[playerid]<HelpTips>;
	t:bPlayerGameSettings[playerid]<ShowHUD>;

	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);
	SpawnPlayer(playerid);

	MsgF(playerid, YELLOW, " >  MoTD: "#C_BLUE"%s", gMessageOfTheDay);

	if(Iter_Count(Player) > 10 && gPingLimit != 350)
	{
		gPingLimit = 350;
		MsgAll(YELLOW, " >  Ping limit has been updated to 350 while more than 10 players are online.");
	}
	else if(gPingLimit != 600)
	{
		gPingLimit = 600;
		MsgAll(YELLOW, " >  Ping limit has been updated to 600 while less than 10 players are online.");
	}

	return 1;
}

timer KickPlayerDelay[100](playerid)
{
	Kick(playerid);
}

public OnPlayerDisconnect(playerid, reason)
{
	if(bPlayerGameSettings[playerid] & LoggedIn && !(bPlayerGameSettings[playerid] & AdminDuty))
	{
		SavePlayerData(playerid);
		DestroyItem(GetPlayerItem(playerid));
	}

	ResetVariables(playerid);
	UnloadPlayerTextDraws(playerid);

	if(bServerGlobalSettings & Restarting)
		return 0;

	switch(reason)
	{
		case 0:
			MsgAllF(GREY, " >  %p lost connection.", playerid);

		case 1:
			MsgAllF(GREY, " >  %p left the server.", playerid);

		case 2:
			MsgAllF(GREY, " >  %p was kicked.", playerid);
	}

	return 1;
}

ptask PlayerUpdate[100](playerid)
{
	new
		hour,
		minute,
		weather;

	if(GetPlayerPing(playerid) > gPingLimit && tickcount() - tick_ServerJoin[playerid] > 30000)
	{
		MsgF(playerid, YELLOW, " >  You have been kicked for having a ping of %d which is over the limit of %d.", GetPlayerPing(playerid), gPingLimit);
		defer KickPlayerDelay(playerid);
		return;
	}

	ResetPlayerMoney(playerid);

	if(IsPlayerInAnyVehicle(playerid))
	{
		PlayerVehicleUpdate(playerid);
	}

	if(gScreenBoxFadeLevel[playerid] <= 0)
	{
		if(gPlayerHP[playerid] < 40.0)
		{
			if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_PAINKILL))
			{
				PlayerTextDrawHide(playerid, ClassBackGround);

				if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_PAINKILL) > 60000)
					RemoveDrug(playerid, DRUG_TYPE_PAINKILL);
			}
			else if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
			{
				PlayerTextDrawHide(playerid, ClassBackGround);
			}
			else
			{
				PlayerTextDrawBoxColor(playerid, ClassBackGround, floatround((40.0 - gPlayerHP[playerid]) * 4.4));
				PlayerTextDrawShow(playerid, ClassBackGround);
			}
		}
		else
		{
			PlayerTextDrawHide(playerid, ClassBackGround);
		}
	}

	KnockOutUpdate(playerid);

	gettime(hour, minute);

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_LSD))
	{
		hour = 22;
		minute = 3;
		weather = 33;

		if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_LSD) > 120000)
			RemoveDrug(playerid, DRUG_TYPE_LSD);
	}
	else if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_HEROINE))
	{
		hour = 22;
		minute = 30;
		weather = 33;

		if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_HEROINE) > 120000)
			RemoveDrug(playerid, DRUG_TYPE_HEROINE);
	}
	else
	{
		weather = gWeatherID;
	}

	SetPlayerTime(playerid, hour, minute);
	SetPlayerWeather(playerid, weather);

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_AIR))
	{
		SetPlayerDrunkLevel(playerid, 100000);

		if(random(100) < 50)
			GivePlayerHP(playerid, -0.5);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_MORPHINE))
	{
		if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_MORPHINE) > 120000 || gPlayerHP[playerid] >= 100.0)
			RemoveDrug(playerid, DRUG_TYPE_MORPHINE);

		SetPlayerDrunkLevel(playerid, 2200);

		if(random(100) < 80)
			GivePlayerHP(playerid, 0.05, .msg = false);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
	{
		if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_ADRENALINE) > 120000 || gPlayerHP[playerid] >= 100.0)
			RemoveDrug(playerid, DRUG_TYPE_ADRENALINE);

		GivePlayerHP(playerid, 0.01, .msg = false);
	}

	if(bPlayerGameSettings[playerid] & Bleeding)
	{
		if(random(100) < 60)
			GivePlayerHP(playerid, -0.01, .msg = false);
	}

	if(GetPlayerCurrentWeapon(playerid) == 0 && GetPlayerWeapon(playerid))
	{
		RemovePlayerWeapon(playerid);
	}

	PlayerBagUpdate(playerid);

	return;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid))return 1;

	t:bPlayerGameSettings[playerid]<FirstSpawn>;

	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);

	return 0;
}
public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid))return 1;

	t:bPlayerGameSettings[playerid]<FirstSpawn>;

	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);

	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
		return 1;

	SetPlayerWeather(playerid, gWeatherID);

	if(bPlayerGameSettings[playerid] & AdminDuty)
	{
		SetPlayerPos(playerid, 0.0, 0.0, 3.0);
		gPlayerHP[playerid] = 100.0;
		return 1;
	}

	if(bPlayerGameSettings[playerid] & Dying)
	{
		TogglePlayerSpectating(playerid, true);

		defer SetDeathCamera(playerid);

		SetPlayerCameraPos(playerid,
			gPlayerDeathPos[playerid][0] - floatsin(-gPlayerDeathPos[playerid][3], degrees),
			gPlayerDeathPos[playerid][1] - floatcos(-gPlayerDeathPos[playerid][3], degrees),
			gPlayerDeathPos[playerid][2]);

		SetPlayerCameraLookAt(playerid, gPlayerDeathPos[playerid][0], gPlayerDeathPos[playerid][1], gPlayerDeathPos[playerid][2]);

		TextDrawShowForPlayer(playerid, DeathText);
		TextDrawShowForPlayer(playerid, DeathButton);
		SelectTextDraw(playerid, 0xFFFFFF88);
		gPlayerHP[playerid] = 1.0;
	}
	else
	{
		gScreenBoxFadeLevel[playerid] = 255;
		PlayerTextDrawBoxColor(playerid, ClassBackGround, gScreenBoxFadeLevel[playerid]);
		PlayerTextDrawShow(playerid, ClassBackGround);

		if(bPlayerGameSettings[playerid] & Alive)
		{
			PlayerSpawnExistingCharacter(playerid);
		}
		else
		{
			gPlayerHP[playerid] = 100.0;
			gPlayerAP[playerid] = 0.0;
			gPlayerFP[playerid] = 80.0;
			PlayerCreateNewCharacter(playerid);
		}
	}

	gPlayerFrequency[playerid] = 108.0;
	PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
	PreloadPlayerAnims(playerid);

	SetPlayerWeather(playerid, gWeatherID);

	Streamer_Update(playerid);
	SetAllWeaponSkills(playerid, 500);

	RemoveAllDrugs(playerid);

	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(bPlayerGameSettings[playerid] & Frozen)
		return 0;

	if(IsPlayerInAnyVehicle(playerid))
	{
		static
			str[8],
			Float:vx,
			Float:vy,
			Float:vz;

		GetVehicleVelocity(gPlayerVehicleID[playerid], vx, vy, vz);
		gPlayerVelocity[playerid] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
		format(str, 32, "%.0fkm/h", gPlayerVelocity[playerid]);
		PlayerTextDrawSetString(playerid, VehicleSpeedText, str);
	}

	if(bPlayerGameSettings[playerid] & Alive)
	{
		SetPlayerHealth(playerid, gPlayerHP[playerid]);
		SetPlayerArmour(playerid, gPlayerAP[playerid]);
	}
	else
	{
		SetPlayerHealth(playerid, 100.0);		
	}

	return 1;
}

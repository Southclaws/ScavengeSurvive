#include <YSI\y_hooks>


new
	LoginPasswordAttempts[MAX_PLAYERS];
	

LoadAccount(playerid)
{
	new
		exists,
		tmp_Ipv4,
		tmp_Alive,
		tmp_IsVIP;

	stmt_bind_value(gStmt_AccountExists, 0, DB::TYPE_STRING, gPlayerName[playerid], MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountExists, 0, DB::TYPE_INTEGER, exists);

	if(stmt_execute(gStmt_AccountExists))
	{
		stmt_fetch_row(gStmt_AccountExists);

		if(exists == 0)
			return 0;
	}
	else
	{
		print("ERROR: [LoadAccount] executing statement 'gStmt_AccountExists'.");
		return 0;
	}

	stmt_bind_value(gStmt_AccountLoad, 0, DB::TYPE_STRING, gPlayerName[playerid], MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_PASS, DB::TYPE_STRING, gPlayerData[playerid][ply_Password], MAX_PASSWORD_LEN);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_IPV4, DB::TYPE_INTEGER, tmp_Ipv4);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_ALIVE, DB::TYPE_INTEGER, tmp_Alive);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_REGDATE, DB::TYPE_INTEGER, gPlayerData[playerid][ply_RegisterTimestamp]);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_LASTLOG, DB::TYPE_INTEGER, gPlayerData[playerid][ply_LastLogin]);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_SPAWNTIME, DB::TYPE_INTEGER, gPlayerData[playerid][ply_CreationTimestamp]);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_TOTALSPAWNS, DB::TYPE_INTEGER, gPlayerData[playerid][ply_TotalSpawns]);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_WARNINGS, DB::TYPE_INTEGER, gPlayerData[playerid][ply_Warnings]);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_AIMSHOUT, DB::TYPE_STRING, gPlayerData[playerid][ply_AimShoutText], 128);

	if(!stmt_execute(gStmt_AccountLoad))
	{
		printf("ERROR: Loading player account for '%p' from database", playerid);

		return 0;
	}

	stmt_fetch_row(gStmt_AccountLoad);

	if(gWhitelist)
	{
		if(!IsNameInWhitelist(gPlayerName[playerid]))
			return 3;
	}

	if(tmp_Alive)
		t:gPlayerBitData[playerid]<Alive>;

	else
		f:gPlayerBitData[playerid]<Alive>;

	if(tmp_IsVIP)
		t:gPlayerBitData[playerid]<IsVip>;

	else
		f:gPlayerBitData[playerid]<IsVip>;

	t:gPlayerBitData[playerid]<HasAccount>;
	f:gPlayerBitData[playerid]<IsNewPlayer>;

	Tutorial_End(playerid);

	if(gPlayerData[playerid][ply_IP] == tmp_Ipv4)
		return 2;
	
	return 1;
}

CreateAccount(playerid, password[])
{
	new serial[129];

	gpci(playerid, serial, 129);

	stmt_bind_value(gStmt_AccountCreate, 0, DB::TYPE_STRING,	gPlayerName[playerid], MAX_PLAYER_NAME); 
	stmt_bind_value(gStmt_AccountCreate, 1, DB::TYPE_STRING,	password, MAX_PASSWORD_LEN); 
	stmt_bind_value(gStmt_AccountCreate, 2, DB::TYPE_INTEGER,	gPlayerData[playerid][ply_IP]); 
	stmt_bind_value(gStmt_AccountCreate, 3, DB::TYPE_INTEGER,	gettime()); 
	stmt_bind_value(gStmt_AccountCreate, 4, DB::TYPE_INTEGER,	gettime()); 
	stmt_bind_value(gStmt_AccountCreate, 5, DB::TYPE_STRING,	"Drop your weapon!", 18); 
	stmt_bind_value(gStmt_AccountCreate, 6, DB::TYPE_STRING,	serial); 
	stmt_execute(gStmt_AccountCreate);

	strcat(gPlayerData[playerid][ply_AimShoutText], "Drop your weapon!");

	if(gWhitelist)
	{
		if(!IsNameInWhitelist(gPlayerName[playerid]))
		{
			WhitelistKick(playerid);
			return 0;
		}
	}

	CheckAdminLevel(playerid);

	if(gPlayerData[playerid][ply_Admin] > 0)
		MsgF(playerid, BLUE, " >  Your admin level: %d", gPlayerData[playerid][ply_Admin]);

	t:gPlayerBitData[playerid]<LoggedIn>;
	t:gPlayerBitData[playerid]<HasAccount>;
	t:gPlayerBitData[playerid]<ToolTips>;

	PlayerCreateNewCharacter(playerid);

	return 1;
}

DeleteAccount(name[])
{
	if(!AccountExists(name))
		return 0;

	new file[MAX_PLAYER_FILE];

	stmt_bind_value(gStmt_AccountDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_execute(gStmt_AccountDelete);

	PLAYER_DAT_FILE(name, file);
	fremove(file);

	PLAYER_INV_FILE(name, file);
	fremove(file);

	format(file, sizeof(file), "SSS/Vehicles/%s.dat", name);
	fremove(file);

	format(file, sizeof(file), NOTEBOOK_FILE, name);
	fremove(file);

	return 1;
}

DisplayLoginPrompt(playerid)
{
	new str[128];
	format(str, 128, ""C_WHITE"Welcome Back %P"C_WHITE", Please log into to your account below!\n\n"C_YELLOW"Enjoy your stay :)", playerid);
	ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", str, "Accept", "Leave");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_Login)
	{
		if(response)
		{
			if(strlen(inputtext) < 4)
			{
				DisplayLoginPrompt(playerid);
				return 1;
			}

			new hash[MAX_PASSWORD_LEN];
			WP_Hash(hash, MAX_PASSWORD_LEN, inputtext);

			if(!strcmp(hash, gPlayerData[playerid][ply_Password]))
				Login(playerid);

			else
			{
				new str[64];

				format(str, 64, "Incorrect password! %d out of 5 tries", LoginPasswordAttempts[playerid]);
				ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", str, "Accept", "Quit");

				LoginPasswordAttempts[playerid]++;

				if(LoginPasswordAttempts[playerid] == 5)
				{
					MsgAllF(GREY, " >  %s left the server without logging in.", gPlayerName[playerid]);
					Kick(playerid);
				}
			}
		}
		else
		{
			MsgAllF(GREY, " >  %s left the server without logging in.", gPlayerName[playerid]);
			Kick(playerid);
		}
	}
	if(dialogid == d_Register)
	{
		if(response)
		{
			if(!(4 <= strlen(inputtext) <= 32))
			{
				ShowPlayerDialog(playerid, d_Register, DIALOG_STYLE_PASSWORD, ""C_RED"Password too short/long!\n"C_YELLOW"Password must be between 4 and 32 characters.", "Type your password below", "Accept", "Quit");
				return 0;
			}

			new buffer[MAX_PASSWORD_LEN];

			WP_Hash(buffer, MAX_PASSWORD_LEN, inputtext);

			if(CreateAccount(playerid, buffer))
				ShowWelcomeMessage(playerid, 10);
		}
		else
		{
			MsgAllF(GREY, " >  %s left the server without registering.", gPlayerName[playerid]);
			Kick(playerid);
		}
	}

	return 1;
}

Login(playerid)
{
	new serial[129];

	gpci(playerid, serial, 129);

	stmt_bind_value(gStmt_AccountSetIpv4, 0, DB::TYPE_INTEGER, gPlayerData[playerid][ply_IP]);
	stmt_bind_value(gStmt_AccountSetIpv4, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(gStmt_AccountSetIpv4);

	stmt_bind_value(gStmt_AccountSetGpci, 0, DB::TYPE_STRING, serial);
	stmt_bind_value(gStmt_AccountSetGpci, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(gStmt_AccountSetGpci);

	stmt_bind_value(gStmt_AccountSetLastLog, 0, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(gStmt_AccountSetLastLog, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(gStmt_AccountSetLastLog);

	CheckAdminLevel(playerid);

	if(gPlayerData[playerid][ply_Admin] > 0)
	{
		new
			reports = GetUnreadReports(),
			issues = GetBugReports();

		MsgF(playerid, BLUE, " >  Your admin level: %d", gPlayerData[playerid][ply_Admin]);

		if(reports > 0)
			MsgF(playerid, YELLOW, " >  %d unread reports, type "C_BLUE"/reports "C_YELLOW"to view.", reports);

		if(issues > 0)
			MsgF(playerid, YELLOW, " >  %d issues, type "C_BLUE"/issues "C_YELLOW"to view.", issues);
	}

	t:gPlayerBitData[playerid]<LoggedIn>;
	LoginPasswordAttempts[playerid] = 0;

	gPlayerData[playerid][ply_RadioFrequency] = 108.0;
	gPlayerData[playerid][ply_ScreenBoxFadeLevel] = 255;

	SpawnPlayer(playerid);
}

GetAccountAliasesByIP(name[], list[][], &count, max, &adminlevel)
{
	new
		ip,
		tempname[MAX_PLAYER_NAME],
		tempserial[41],
		templevel;

	stmt_bind_value(gStmt_AccountLoad, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_IPV4, DB::TYPE_INTEGER, ip);

	if(!stmt_execute(gStmt_AccountLoad))
		return 0;

	stmt_fetch_row(gStmt_AccountLoad);

	stmt_bind_value(gStmt_AccountGetAliasesIp, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(gStmt_AccountGetAliasesIp, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetAliasesIp, FIELD_ID_PLAYER_NAME, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetAliasesIp, FIELD_ID_PLAYER_GPCI, DB::TYPE_STRING, tempserial, 41);

	if(!stmt_execute(gStmt_AccountGetAliasesIp))
		return 0;

	while(stmt_fetch_row(gStmt_AccountGetAliasesIp))
	{
		if(tempserial[0] == '0')
			continue;

		strcat(list[count], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel)
			adminlevel = templevel;

		count++;

		if(count == max)
			break;
	}

	return 1;
}

stock GetAccountAliasesByPass(name[], list[][], &count, max, &adminlevel)
{
	new
		pass[129],
		tempname[MAX_PLAYER_NAME],
		tempserial[41],
		templevel;

	stmt_bind_value(gStmt_AccountLoad, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_PASS, DB::TYPE_STRING, pass, 129);

	if(!stmt_execute(gStmt_AccountLoad))
		return 0;

	stmt_fetch_row(gStmt_AccountLoad);

	stmt_bind_value(gStmt_AccountGetAliasesPass, 0, DB::TYPE_STRING, pass, 129);
	stmt_bind_value(gStmt_AccountGetAliasesPass, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetAliasesPass, FIELD_ID_PLAYER_NAME, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetAliasesPass, FIELD_ID_PLAYER_GPCI, DB::TYPE_STRING, tempserial, 41);

	if(!stmt_execute(gStmt_AccountGetAliasesPass))
		return 0;

	while(stmt_fetch_row(gStmt_AccountGetAliasesPass))
	{
		if(tempserial[0] == '0')
			continue;

		strcat(list[count], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel)
			adminlevel = templevel;

		count++;

		if(count == max)
			break;
	}

	return 1;
}

stock GetAccountAliasesByHash(name[], list[][], &count, max, &adminlevel)
{
	new
		serial[41],
		tempname[MAX_PLAYER_NAME],
		tempserial[41],
		templevel;

	stmt_bind_value(gStmt_AccountLoad, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_GPCI, DB::TYPE_STRING, serial, 41);

	if(!stmt_execute(gStmt_AccountLoad))
		return 0;

	stmt_fetch_row(gStmt_AccountLoad);

	if(isnull(serial))
		return 0;

	stmt_bind_value(gStmt_AccountGetAliasesHash, 0, DB::TYPE_STRING, serial, 41);
	stmt_bind_value(gStmt_AccountGetAliasesHash, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetAliasesHash, FIELD_ID_PLAYER_NAME, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetAliasesHash, FIELD_ID_PLAYER_GPCI, DB::TYPE_STRING, tempserial, 41);

	if(!stmt_execute(gStmt_AccountGetAliasesHash))
		return 0;

	while(stmt_fetch_row(gStmt_AccountGetAliasesHash))
	{
		if(tempserial[0] == '0')
			continue;

		strcat(list[count], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel)
			adminlevel = templevel;

		count++;

		if(count == max)
			break;
	}

	return 1;
}

CheckForExtraAccounts(playerid)
{
	new
		list[6][MAX_PLAYER_NAME],
		count,
		adminlevel,
		string[(MAX_PLAYER_NAME + 2) * 6];

	adminlevel = GetPlayerAdminLevel(playerid);

	GetAccountAliasesByIP(gPlayerName[playerid], list, count, 6, adminlevel);

	if(count == 0)
		return 0;

	if(count == 1)
		strcat(string, list[0]);

	if(count > 1)
	{
		for(new i; i < count; i++)
		{
			strcat(string, list[i]);
			strcat(string, ", ");
		}
	}

	if(adminlevel < 3)
		MsgAllF(YELLOW, " >  Aliases: "C_BLUE"(%d)"C_ORANGE" %s", count, string);

	return 1;
}

Logout(playerid)
{
	if(!(gPlayerBitData[playerid] & LoggedIn))
		return 0;

	if(gPlayerBitData[playerid] & AdminDuty)
		return 0;

	new
		lastattacker,
		lastweapon;

	if(IsPlayerCombatLogging(playerid, lastattacker, lastweapon))
	{
		OnPlayerDeath(playerid, lastattacker, lastweapon);
	}

	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(IsItemTypeSafebox(itemtype) || IsItemTypeBag(itemtype))
	{
		if(!IsContainerEmpty(GetItemExtraData(itemid)))
		{
			CreateItemInWorld(itemid,
				gPlayerData[playerid][ply_SpawnPosX] + floatsin(-gPlayerData[playerid][ply_SpawnRotZ], degrees),
				gPlayerData[playerid][ply_SpawnPosY] + floatcos(-gPlayerData[playerid][ply_SpawnRotZ], degrees),
				gPlayerData[playerid][ply_SpawnPosZ] - FLOOR_OFFSET, .zoffset = ITEM_BUTTON_OFFSET);

			itemid = INVALID_ITEM_ID;
		}
	}

	SavePlayerData(playerid);

	if(gPlayerBitData[playerid] & Alive)
	{
		DestroyItem(itemid);
		DestroyPlayerBag(playerid);
		RemovePlayerHolsterItem(playerid);
		RemovePlayerWeapon(playerid);

		for(new i; i < INV_MAX_SLOTS; i++)
		{
			DestroyItem(GetInventorySlotItem(playerid, 0));
			RemoveItemFromInventory(playerid, 0);
		}

		if(IsValidItem(GetPlayerHat(playerid)))
			RemovePlayerHat(playerid);

		if(IsValidItem(GetPlayerMask(playerid)))
			RemovePlayerMask(playerid);

		if(IsPlayerInAnyVehicle(playerid))
		{
			new Float:health;

			GetVehicleHealth(gPlayerData[playerid][ply_CurrentVehicle], health);

			if(health < VEHICLE_HEALTH_MIN)
				DestroyVehicle(gPlayerData[playerid][ply_CurrentVehicle]);

			else
				UpdateVehicleFile(gPlayerData[playerid][ply_CurrentVehicle]);
		}
	}

	return 1;
}


SavePlayerData(playerid)
{
	if(gPlayerBitData[playerid] & AdminDuty)
		return 0;

	if(!(gPlayerBitData[playerid] & LoadedData))
		return 0;

	GetPlayerPos(playerid, gPlayerData[playerid][ply_SpawnPosX], gPlayerData[playerid][ply_SpawnPosY], gPlayerData[playerid][ply_SpawnPosZ]);
	GetPlayerFacingAngle(playerid, gPlayerData[playerid][ply_SpawnRotZ]);

	if(IsAtDefaultPos(gPlayerData[playerid][ply_SpawnPosX], gPlayerData[playerid][ply_SpawnPosY], gPlayerData[playerid][ply_SpawnPosZ]))
		return 0;

	if(IsAtConnectionPos(gPlayerData[playerid][ply_SpawnPosX], gPlayerData[playerid][ply_SpawnPosY], gPlayerData[playerid][ply_SpawnPosZ]))
		return 0;

	SaveBlockAreaCheck(gPlayerData[playerid][ply_SpawnPosX], gPlayerData[playerid][ply_SpawnPosY], gPlayerData[playerid][ply_SpawnPosZ]);

	if(IsPlayerInAnyVehicle(playerid))
		gPlayerData[playerid][ply_SpawnPosZ] += 1.5;

	if(gPlayerBitData[playerid] & Alive)
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		{
			if(!gServerRestarting)
				return 0;
		}

		stmt_bind_value(gStmt_AccountUpdate, 0, DB::TYPE_INTEGER, 1);
		stmt_bind_value(gStmt_AccountUpdate, 1, DB::TYPE_INTEGER, gPlayerData[playerid][ply_Karma]);
		stmt_bind_value(gStmt_AccountUpdate, 2, DB::TYPE_INTEGER, gPlayerData[playerid][ply_Warnings]);
		stmt_bind_value(gStmt_AccountUpdate, 3, DB::TYPE_PLAYER_NAME, playerid);
		stmt_execute(gStmt_AccountUpdate);

		SavePlayerInventory(playerid);
		SavePlayerChar(playerid);
	}
	else
	{
		stmt_bind_value(gStmt_AccountUpdate, 0, DB::TYPE_INTEGER, 0);
		stmt_bind_value(gStmt_AccountUpdate, 1, DB::TYPE_INTEGER, gPlayerData[playerid][ply_Karma]);
		stmt_bind_value(gStmt_AccountUpdate, 2, DB::TYPE_INTEGER, gPlayerData[playerid][ply_Warnings]);
		stmt_bind_value(gStmt_AccountUpdate, 3, DB::TYPE_PLAYER_NAME, playerid);

		stmt_execute(gStmt_AccountUpdate);

		ClearPlayerInventoryFile(playerid);
	}

	return 1;
}


// Interface


AccountExists(name[])
{
	new exists;

	stmt_bind_value(gStmt_AccountExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountExists, 0, DB::TYPE_INTEGER, exists);

	if(stmt_execute(gStmt_AccountExists))
	{
		stmt_fetch_row(gStmt_AccountExists);

		if(exists)
			return 1;
	}

	return 0;
}

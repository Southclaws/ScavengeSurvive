#include <YSI\y_hooks>


new
	LoginPasswordAttempts[MAX_PLAYERS];
	

LoadAccount(playerid)
{
	new
		exists,
		tmp_Ipv4,		// 2
		tmp_Alive,		// 3
		tmp_Spawn[48],	// 5
		tmp_IsVIP;		// 6

	stmt_bind_value(gStmt_AccountExists, 0, DB::TYPE_STRING, gPlayerName[playerid], MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountExists, 0, DB::TYPE_INTEGER, exists);

	if(stmt_execute(gStmt_AccountExists))
	{
		stmt_fetch_row(gStmt_AccountExists);

		if(!exists)
			return 0;
	}

	stmt_bind_value(gStmt_AccountLoad, 0, DB::TYPE_STRING, gPlayerName[playerid], MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountLoad, 1, DB::TYPE_STRING, gPlayerData[playerid][ply_Password], MAX_PASSWORD_LEN);
	stmt_bind_result_field(gStmt_AccountLoad, 2, DB::TYPE_INTEGER, tmp_Ipv4);
	stmt_bind_result_field(gStmt_AccountLoad, 3, DB::TYPE_INTEGER, tmp_Alive);
	stmt_bind_result_field(gStmt_AccountLoad, 5, DB::TYPE_STRING, tmp_Spawn, 48);
	stmt_bind_result_field(gStmt_AccountLoad, 6, DB::TYPE_INTEGER, tmp_IsVIP);

	if(stmt_execute(gStmt_AccountLoad))
	{
		stmt_fetch_row(gStmt_AccountLoad);

		if(gWhitelist)
		{
			if(!IsNameInWhitelist(gPlayerName[playerid]))
				return 3;
		}

		if(tmp_Alive)
			t:bPlayerGameSettings[playerid]<Alive>;

		else
			f:bPlayerGameSettings[playerid]<Alive>;

		sscanf(tmp_Spawn, "ffff",
			gPlayerData[playerid][ply_SpawnPosX],
			gPlayerData[playerid][ply_SpawnPosY],
			gPlayerData[playerid][ply_SpawnPosZ],
			gPlayerData[playerid][ply_SpawnRotZ]);

		if(tmp_IsVIP)
			t:bPlayerGameSettings[playerid]<IsVip>;

		else
			f:bPlayerGameSettings[playerid]<IsVip>;

		t:bPlayerGameSettings[playerid]<HasAccount>;
		f:bPlayerGameSettings[playerid]<IsNewPlayer>;

		Tutorial_End(playerid);

		if(gPlayerData[playerid][ply_IP] == tmp_Ipv4)
			return 2;
		
		return 1;
	}

	printf("ERROR: Loading player account for '%p' from database", playerid);

	return 0;
}

CreateAccount(playerid, password[])
{
	stmt_bind_value(gStmt_AccountCreate, 0, DB::TYPE_STRING,	gPlayerName[playerid], MAX_PLAYER_NAME);
	stmt_bind_value(gStmt_AccountCreate, 1, DB::TYPE_STRING,	password, MAX_PASSWORD_LEN);
	stmt_bind_value(gStmt_AccountCreate, 2, DB::TYPE_INT,		gPlayerData[playerid][ply_IP]);
	stmt_bind_value(gStmt_AccountCreate, 3, DB::TYPE_INT,		(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0);

	stmt_execute(gStmt_AccountCreate);

	if(gWhitelist)
	{
		if(!IsNameInWhitelist(gPlayerName[playerid]))
		{
			ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Whitelist",
				""#C_YELLOW"You are not on the whitelist for this server.\n\
				This is in force to provide the best gameplay experience for all players.\n\n\
				"#C_WHITE"Please apply on "#C_BLUE"Empire-Bay.com"#C_WHITE".\n\
				Applications are always accepted as soon as possible\n\
				There are no requirements, just follow the rules.\n\
				Failure to do so will result in permanent removal from the whitelist.", "Close", "");

			defer KickPlayerDelay(playerid);

			return 0;
		}
	}

	for(new i; i < gTotalAdmins; i++)
	{
		if(!strcmp(gPlayerName[playerid], gAdminData[i][admin_Name]) && !isnull(gPlayerName[playerid]))
		{
			gPlayerData[playerid][ply_Admin] = gAdminData[i][admin_Level];
			break;
		}
	}

	if(gPlayerData[playerid][ply_Admin] > 0)
		MsgF(playerid, BLUE, " >  Your admin level: %d", gPlayerData[playerid][ply_Admin]);

	t:bPlayerGameSettings[playerid]<LoggedIn>;
	t:bPlayerGameSettings[playerid]<HasAccount>;
	t:bPlayerGameSettings[playerid]<ToolTips>;

	PlayerCreateNewCharacter(playerid);

	return 1;
}

DeleteAccount(name[])
{
	new file[MAX_PLAYER_FILE];

	stmt_bind_value(gStmt_AccountDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_execute(gStmt_AccountDelete);

	GetFile(name, file);
	fremove(file);

	GetInvFile(name, file);
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
	format(str, 128, ""C_WHITE"Welcome Back %P"#C_WHITE", Please log into to your account below!\n\n"#C_YELLOW"Enjoy your stay :)", playerid);
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
				ShowPlayerDialog(playerid, d_Register, DIALOG_STYLE_PASSWORD, ""#C_RED"Password too short/long!\n"C_YELLOW"Password must be between 4 and 32 characters.", "Type your password below", "Accept", "Quit");
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
	stmt_bind_value(gStmt_AccountSetIpv4, 0, DB::TYPE_INTEGER, gPlayerData[playerid][ply_IP]);
	stmt_bind_value(gStmt_AccountSetIpv4, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(gStmt_AccountSetIpv4);

	stmt_bind_value(gStmt_AccountSetLastLog, 0, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(gStmt_AccountSetLastLog, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(gStmt_AccountSetLastLog);

	for(new i; i < gTotalAdmins; i++)
	{
		if(!strcmp(gPlayerName[playerid], gAdminData[i][admin_Name]))
		{
			gPlayerData[playerid][ply_Admin] = gAdminData[i][admin_Level];
			break;
		}
	}

	if(gPlayerData[playerid][ply_Admin] > 0)
	{
		new
			reports = GetUnreadReports(),
			issues = GetBugReports();

		MsgF(playerid, BLUE, " >  Your admin level: %d", gPlayerData[playerid][ply_Admin]);

		if(reports > 0)
			MsgF(playerid, YELLOW, " >  %d unread reports, type "#C_BLUE"/reports "#C_YELLOW"to view.", reports);

		if(issues > 0)
			MsgF(playerid, YELLOW, " >  %d issues, type "#C_BLUE"/issues "#C_YELLOW"to view.", issues);
	}

	t:bPlayerGameSettings[playerid]<LoggedIn>;
	LoginPasswordAttempts[playerid] = 0;
	gPlayerData[playerid][ply_RadioFrequency] = 108.0;
	gPlayerData[playerid][ply_ScreenBoxFadeLevel] = 255;

	SpawnPlayer(playerid);
}

GetAccountAliases(name[], ip, list[][], &count, max, &adminlevel)
{
	new
		tempname[MAX_PLAYER_NAME],
		templevel;

	stmt_bind_value(gStmt_AccountGetAliases, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(gStmt_AccountGetAliases, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountGetAliases, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	stmt_execute(gStmt_AccountGetAliases);

	while(stmt_fetch_row(gStmt_AccountGetAliases))
	{
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

	GetAccountAliases(gPlayerName[playerid], gPlayerData[playerid][ply_IP], list, count, 6, adminlevel);

	if(count == 0)
	{
		return 0;
	}

	if(count == 1)
	{
		strcat(string, list[0]);
	}

	if(count > 1)
	{
		for(new i; i < count; i++)
		{
			strcat(string, list[i]);
			strcat(string, ", ");
		}
	}

	MsgAdminsF(adminlevel, YELLOW, " >  Aliases: "#C_BLUE"(%d)"#C_ORANGE" %s", count, string);

	return 1;
}

Logout(playerid)
{
	if(!(bPlayerGameSettings[playerid] & LoggedIn))
		return 0;

	if(!(bPlayerGameSettings[playerid] & Spawned))
		return 0;

	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 0;

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
				gPlayerData[playerid][ply_SpawnPosX],
				gPlayerData[playerid][ply_SpawnPosY],
				gPlayerData[playerid][ply_SpawnPosZ] - FLOOR_OFFSET, .zoffset = ITEM_BUTTON_OFFSET);

			itemid = INVALID_ITEM_ID;
		}
	}

	SavePlayerData(playerid);

	if(bPlayerGameSettings[playerid] & Alive)
	{
		DestroyItem(itemid);
		DestroyPlayerBackpack(playerid);
		RemovePlayerHolsterItem(playerid);
		RemovePlayerWeapon(playerid);

		for(new i; i < INV_MAX_SLOTS; i++)
		{
			DestroyItem(GetInventorySlotItem(playerid, 0));
			RemoveItemFromInventory(playerid, 0);
		}

		if(IsValidItem(GetPlayerHat(playerid)))
			RemovePlayerHat(playerid);

		if(IsPlayerInAnyVehicle(playerid))
			SavePlayerVehicle(gPlayerData[playerid][ply_CurrentVehicle], gPlayerName[playerid]);
	}

	return 1;
}


SavePlayerData(playerid)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 0;

	if(!(bPlayerGameSettings[playerid] & LoadedData))
		return 0;

	GetPlayerPos(playerid, gPlayerData[playerid][ply_SpawnPosX], gPlayerData[playerid][ply_SpawnPosY], gPlayerData[playerid][ply_SpawnPosZ]);
	GetPlayerFacingAngle(playerid, gPlayerData[playerid][ply_SpawnRotZ]);

	SaveBlockAreaCheck(gPlayerData[playerid][ply_SpawnPosX], gPlayerData[playerid][ply_SpawnPosY], gPlayerData[playerid][ply_SpawnPosZ]);

	if(IsPlayerInAnyVehicle(playerid))
		gPlayerData[playerid][ply_SpawnPosZ] += 2.5;

	if(bPlayerGameSettings[playerid] & Alive)
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		{
			if(!gServerRestarting)
				return 0;
		}

		new spawn[48];
		format(spawn, 48, "%f %f %f %f", gPlayerData[playerid][ply_SpawnPosX], gPlayerData[playerid][ply_SpawnPosY], gPlayerData[playerid][ply_SpawnPosZ], gPlayerData[playerid][ply_SpawnRotZ]);

		stmt_bind_value(gStmt_AccountUpdate, 0, DB::TYPE_INTEGER, 1);
		stmt_bind_value(gStmt_AccountUpdate, 1, DB::TYPE_INTEGER, 0);
		stmt_bind_value(gStmt_AccountUpdate, 2, DB::TYPE_STRING, spawn, 48);
		stmt_bind_value(gStmt_AccountUpdate, 3, DB::TYPE_INTEGER, (bPlayerGameSettings[playerid] & IsVip) ? 1 : 0);
		stmt_bind_value(gStmt_AccountUpdate, 4, DB::TYPE_INTEGER, gPlayerData[playerid][ply_Karma]);
		stmt_bind_value(gStmt_AccountUpdate, 5, DB::TYPE_PLAYER_NAME, playerid);
		stmt_execute(gStmt_AccountUpdate);

		SavePlayerInventory(playerid);
		SavePlayerChar(playerid);
	}
	else
	{
		stmt_bind_value(gStmt_AccountUpdate, 0, DB::TYPE_INTEGER, 0);
		stmt_bind_value(gStmt_AccountUpdate, 1, DB::TYPE_INTEGER, 0);
		stmt_bind_value(gStmt_AccountUpdate, 2, DB::TYPE_STRING, "0.0, 0.0, 0.0, 0.0", 32);
		stmt_bind_value(gStmt_AccountUpdate, 3, DB::TYPE_INTEGER, (bPlayerGameSettings[playerid] & IsVip) ? 1 : 0);
		stmt_bind_value(gStmt_AccountUpdate, 4, DB::TYPE_INTEGER, gPlayerData[playerid][ply_Karma]);
		stmt_bind_value(gStmt_AccountUpdate, 5, DB::TYPE_PLAYER_NAME, playerid);

		stmt_execute(gStmt_AccountUpdate);

		ClearPlayerInventoryFile(playerid);
	}

	return 1;
}

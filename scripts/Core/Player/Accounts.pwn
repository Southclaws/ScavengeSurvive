#include <YSI\y_hooks>


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
				ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", "Type your password below", "Accept", "Quit");
				return 1;
			}

			new hash[MAX_PASSWORD_LEN];
			WP_Hash(hash, MAX_PASSWORD_LEN, inputtext);

			if(!strcmp(hash, gPlayerData[playerid][ply_Password]))
				Login(playerid);

			else
			{
				new str[64];
				gPlayerPassAttempts[playerid]++;
				format(str, 64, "Incorrect password! %d out of 5 tries", gPlayerPassAttempts[playerid]);
				ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", str, "Accept", "Quit");
				if(gPlayerPassAttempts[playerid] == 5)
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

CreateAccount(playerid, password[])
{
	new
		query[400],
		DBResult:result,
		numrows;

	format(query, sizeof(query),
		"INSERT INTO `Player` (`"#ROW_NAME"`, `"#ROW_PASS"`, `"#ROW_IPV4"`, `"#ROW_ALIVE"`, `"#ROW_GEND"`, `"#ROW_SPAWN"`, `"#ROW_ISVIP"`, `"#ROW_KARMA"`) \
		VALUES('%s', '%s', '%d', '0', '0', '0.0, 0.0, 0.0, 0.0', '%d', '0')",
		gPlayerName[playerid], password, gPlayerData[playerid][ply_IP],
		(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0);

	db_free_result(db_query(gAccounts, query));

	if(gWhitelist)
	{
		format(query, sizeof(query), "SELECT * FROM `Whitelist` WHERE `"#ROW_NAME"` = '%s'", gPlayerName[playerid]);
		result = db_query(gAccounts, query);
		numrows = db_num_rows(result);
		db_free_result(result);

		if(numrows == 0)
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

	for(new i; i<gTotalAdmins; i++)
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

	PlayerCreateNewCharacter(playerid);

	return 1;
}

DeleteAccount(name[])
{
	new
		file[MAX_PLAYER_FILE],
		query[64],
		DBResult:result;

	format(query, sizeof(query), "DELETE FROM `Player` WHERE `"#ROW_NAME"` = '%s'", name);

	result = db_query(gAccounts, query);
	db_free_result(result);

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

Login(playerid)
{
	new
		query[256];

	format(query, sizeof(query), "UPDATE `Player` SET `"#ROW_IPV4"` = '%d' WHERE `"#ROW_NAME"` = '%s'", gPlayerData[playerid][ply_IP], gPlayerName[playerid]);
	db_free_result(db_query(gAccounts, query));

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
	gPlayerPassAttempts[playerid] = 0;
	gPlayerFrequency[playerid] = 108.0;
	gScreenBoxFadeLevel[playerid] = 255;

	SpawnPlayer(playerid);
}

CheckForExtraAccounts(playerid, name[])
{
	new
		numrows,
		query[128],
		tmpname[32],
		DBResult:dbresult,
		list[128],
		msglevel = 1;

	if(gPlayerData[playerid][ply_Admin] > 1)
		msglevel = gPlayerData[playerid][ply_Admin];

	format(query, 128,
		"SELECT * FROM `Player` WHERE `"#ROW_IPV4"` = '%d' AND `"#ROW_NAME"` != '%s'",
		gPlayerData[playerid][ply_IP], name);

	dbresult = db_query(gAccounts, query);
	numrows = db_num_rows(dbresult);

	if(numrows > 0)
	{
		for(new i; i < numrows && i < 5;i++)
		{
			db_get_field(dbresult, 0, tmpname, 24);

			for(new j; j < gTotalAdmins; j++)
			{
				if(!strcmp(tmpname, gAdminData[j][admin_Name]))
				{
					if(gAdminData[j][admin_Level] >= 3)
					{
						db_free_result(dbresult);
						return 0;
					}
				}
			}

			if(i > 0)
				strcat(list, ", ");

			strcat(list, tmpname);
			db_next_row(dbresult);
		}
		MsgAdminsF(msglevel, YELLOW, " >  Aliases: "#C_BLUE"(%d)"#C_ORANGE" %s", numrows, list);
	}

	db_free_result(dbresult);

	return 1;
}

Logout(playerid)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 0;

	SavePlayerData(playerid);

	if(bPlayerGameSettings[playerid] & Alive)
	{
		DestroyItem(GetPlayerItem(playerid));
		RemovePlayerHolsterItem(playerid);
		RemovePlayerWeapon(playerid);
		DestroyPlayerBackpack(playerid);

		for(new i; i < INV_MAX_SLOTS; i++)
		{
			DestroyItem(GetInventorySlotItem(playerid, 0));
			RemoveItemFromInventory(playerid, 0);
		}

		if(IsValidItem(GetPlayerHat(playerid)))
			RemovePlayerHat(playerid);

		if(IsPlayerInAnyVehicle(playerid))
			SavePlayerVehicle(gPlayerVehicleID[playerid], gPlayerName[playerid]);
	}

	return 1;
}


SavePlayerData(playerid)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 0;

	if(!(bPlayerGameSettings[playerid] & LoadedData))
		return 0;

	new
		query[256],
		Float:x,
		Float:y,
		Float:z,
		Float:a;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);

	SaveBlockAreaCheck(x, y, z);

	if(IsPlayerInAnyVehicle(playerid))
		z += 2.5;

	if(bPlayerGameSettings[playerid] & Alive)
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		{
			if(!gServerRestarting)
				return 0;
		}

		format(query, sizeof(query),
			"UPDATE `Player` SET \
			`"#ROW_ALIVE"` = '1', \
			`"#ROW_GEND"` = '%d', \
			`"#ROW_SPAWN"` = '%f %f %f %f', \
			`"#ROW_ISVIP"` = '%d', \
			`"#ROW_KARMA"` = '%d' \
			WHERE `"#ROW_NAME"` = '%s'",
			(bPlayerGameSettings[playerid] & Gender) ? 1 : 0,
			x, y, z, a,
			(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0,
			gPlayerData[playerid][ply_karma],
			gPlayerName[playerid]);

		SavePlayerInventory(playerid);
		SavePlayerChar(playerid);
	}
	else
	{
		format(query, sizeof(query),
			"UPDATE `Player` SET \
			`"#ROW_ALIVE"` = '0', \
			`"#ROW_GEND"` = '0', \
			`"#ROW_SPAWN"` = '0.0 0.0 0.0 0.0', \
			`"#ROW_ISVIP"` = '%d', \
			`"#ROW_KARMA"` = '%d' \
			WHERE `"#ROW_NAME"` = '%s'",
			(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0,
			gPlayerData[playerid][ply_karma],
			gPlayerName[playerid]);

		ClearPlayerInventoryFile(playerid);
	}

	db_free_result(db_query(gAccounts, query));

	return 1;
}

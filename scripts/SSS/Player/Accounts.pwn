CreateNewUserfile(playerid, password[])
{
	new
		file[MAX_PLAYER_FILE],
		query[300];

	GetFile(gPlayerName[playerid], file);

	fclose(fopen(file, io_write));

	format(query, 300,
		"INSERT INTO `Player` (`"#ROW_NAME"`, `"#ROW_PASS"`, `"#ROW_IPV4"`, `"#ROW_ALIVE"`, `"#ROW_SPAWN"`, `"#ROW_ISVIP"`) \
		VALUES('%s', '%s', '%d', '0', '0.0, 0.0, 0.0, 0.0', '%d')",
		gPlayerName[playerid], password, gPlayerData[playerid][ply_IP],
		(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0);

	db_free_result(db_query(gAccounts, query));

	for(new idx; idx<gTotalAdmins; idx++)
	{
		if(!strcmp(gPlayerName[playerid], gAdminData[idx][admin_Name]) && !isnull(gPlayerName[playerid]))
		{
			gPlayerData[playerid][ply_Admin] = gAdminData[idx][admin_Level];
			break;
		}
	}

	if(gPlayerData[playerid][ply_Admin] > 0)
		MsgF(playerid, BLUE, " >  Your admin level: %d", gPlayerData[playerid][ply_Admin]);

	t:bPlayerGameSettings[playerid]<LoggedIn>;
	t:bPlayerGameSettings[playerid]<HasAccount>;
}

DisplayLoginPrompt(playerid)
{
	new str[128];
	format(str, 128, ""C_WHITE"Welcome Back %P"#C_WHITE", Please log into to your account below!\n\n"#C_YELLOW"Enjoy your stay :)", playerid);
	ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", str, "Accept", "Leave");
}

Login(playerid)
{
	new
		query[256];

	format(query, sizeof(query), "UPDATE `Player` SET `"#ROW_IPV4"` = '%d' WHERE `"#ROW_NAME"` = '%s'", gPlayerData[playerid][ply_IP], gPlayerName[playerid]);
	db_free_result(db_query(gAccounts, query));

	for(new idx; idx<gTotalAdmins; idx++)
	{

		if(!strcmp(gPlayerName[playerid], gAdminData[idx][admin_Name]))
		{
			gPlayerData[playerid][ply_Admin] = gAdminData[idx][admin_Level];
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

	if(IsPlayerInAnyVehicle(playerid))
		z += 2.5;

	if(bPlayerGameSettings[playerid] & Alive)
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		{
			if(!(bServerGlobalSettings & Restarting))
				return 0;
		}

		format(query, sizeof(query),
			"UPDATE `Player` SET \
			`"#ROW_ALIVE"` = '1', \
			`"#ROW_GEND"` = '%d', \
			`"#ROW_SPAWN"` = '%f %f %f %f', \
			`"#ROW_ISVIP"` = '%d' \
			WHERE `"#ROW_NAME"` = '%s'",
			(bPlayerGameSettings[playerid] & Gender) ? 1 : 0,
			x, y, z, a,
			(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0,
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
			`"#ROW_ISVIP"` = '%d' \
			WHERE `"#ROW_NAME"` = '%s'",
			(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0,
			gPlayerName[playerid]);

		ClearPlayerInventoryFile(playerid);
	}

	db_free_result(db_query(gAccounts, query));

	return 1;
}

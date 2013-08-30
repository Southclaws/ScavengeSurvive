CMD:acmds(playerid, params[])
{
	new str[800];

	strcat(str, "/a [message] - Staff chat channel");

	if(gPlayerData[playerid][ply_Admin] >= 2)
	{
		strcat(str, "\n\n"#C_YELLOW"Administrator (level 3)"#C_BLUE"\n");
		strcat(str, gAdminCommandList_Lvl3);
	}
	if(gPlayerData[playerid][ply_Admin] >= 2)
	{
		strcat(str, "\n\n"#C_YELLOW"Administrator (level 2)"#C_BLUE"\n");
		strcat(str, gAdminCommandList_Lvl2);
	}
	if(gPlayerData[playerid][ply_Admin] >= 1)
	{
		strcat(str, "\n\n"#C_YELLOW"Game Master (level 1)"#C_BLUE"\n");
		strcat(str, gAdminCommandList_Lvl1);
	}
	
	if(gPlayerData[playerid][ply_Admin] > 0)
		ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Admin Commands List", str, "Close", "");

	else
		return 0;

	return 1;
}

ACMD:adminlist[3](playerid, params[])
{
	new
		title[20],
		line[52];

	gBigString[0] = EOS;

	format(title, 20, "Administrators (%d)", gTotalAdmins);

	for(new i; i < gTotalAdmins; i++)
	{
		if(gAdminData[i][admin_Level] == STAFF_LEVEL_SECRET)
			continue;

		format(line, sizeof(line), "%s %C(%d-%s)\n",
			gAdminData[i][admin_Name],
			AdminColours[gAdminData[i][admin_Level]],
			gAdminData[i][admin_Level],
			AdminName[gAdminData[i][admin_Level]]);

		if(GetPlayerIDFromName(gAdminData[i][admin_Name]) != INVALID_PLAYER_ID)
			strcat(gBigString, " >  ");

		strcat(gBigString, line);
	}

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_LIST, title, gBigString, "Close", "");

	return 1;
}

MsgAdmins(level, colour, string[])
{
	if(level == 0)
	{
		print("ERROR: MsgAdmins parameter 'level' cannot be 0");
		return 0;
	}

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

		foreach(new i : Player)
		{
			if(gPlayerData[i][ply_Admin] < level)
				continue;

			SendClientMessage(i, colour, string);
			SendClientMessage(i, colour, string2);
		}
	}
	else
	{
		foreach(new i : Player)
		{
			if(gPlayerData[i][ply_Admin] < level)
				continue;

			SendClientMessage(i, colour, string);
		}
	}

	return 1;
}

KickPlayer(playerid, reason[])
{
	MsgAdminsF(1, GREY, " >  %P"#C_GREY" kicked, reason: "#C_BLUE"%s", playerid, reason);
	MsgF(playerid, GREY, " >  Kicked, reason: "#C_BLUE"%s", reason);
	defer KickPlayerDelay(playerid);
}

timer KickPlayerDelay[50](playerid)
{
	Kick(playerid);
}

SetPlayerAdminLevel(playerid, level)
{
	if(!(0 <= level <= 4))return 0;

	gPlayerData[playerid][ply_Admin] = level;

	if(level == 0)
	{
	}
	else
	{

	}

	UpdateAdmin(gPlayerName[playerid], level);

	return 1;
}

UpdateAdmin(name[MAX_PLAYER_NAME], level)
{
	if(level == 0)
		RemoveAdminFromDatabase(name);

	new count;

	stmt_bind_value(gStmt_AdminExists, 0, DB::TYPE_STRING, name);
	stmt_bind_result_field(gStmt_AdminExists, 0, DB::TYPE_INTEGER, count);
	stmt_execute(gStmt_AdminExists);
	stmt_fetch_row(gStmt_AdminExists);

	if(count == 0)
	{
		stmt_bind_value(gStmt_AdminInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_value(gStmt_AdminInsert, 1, DB::TYPE_INTEGER, level);

		if(stmt_execute(gStmt_AdminInsert))
		{
			gAdminData[gTotalAdmins][admin_Name] = name;
			gAdminData[gTotalAdmins][admin_Level] = level;
			gTotalAdmins++;

			SortDeepArray(gAdminData, admin_Level, .order = SORT_DESC);

			return 1;
		}
	}
	else
	{
		stmt_bind_value(gStmt_AdminUpdate, 0, DB::TYPE_INTEGER, level);
		stmt_bind_value(gStmt_AdminUpdate, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

		if(stmt_execute(gStmt_AdminUpdate))
		{
			for(new i; i < gTotalAdmins; i++)
			{
				if(!strcmp(name, gAdminData[i][admin_Name]))
				{
					gAdminData[i][admin_Level] = level;

					break;
				}
			}

			SortDeepArray(gAdminData, admin_Level, .order = SORT_DESC);

			return 1;
		}
	}

	return 1;
}

RemoveAdminFromDatabase(name[])
{
	stmt_bind_value(gStmt_AdminDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(gStmt_AdminDelete))
	{
		gTotalAdmins--;

		new bool:found = false;

		for(new i; i < gTotalAdmins; i++)
		{
			if(!strcmp(name, gAdminData[i][admin_Name]))
				found = true;

			if(found && i < MAX_ADMIN-1)
			{
				format(gAdminData[i][admin_Name], 24, gAdminData[i+1][admin_Name]);
				gAdminData[i][admin_Level] = gAdminData[i+1][admin_Level];
			}
		}

		return 1;
	}

	return 0;
}

LoadAdminData()
{
	new
		name[MAX_PLAYER_NAME],
		level;

	stmt_bind_result_field(gStmt_AdminLoadAll, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AdminLoadAll, 1, DB::TYPE_INTEGER, level);

	if(stmt_execute(gStmt_AdminLoadAll))
	{
		while(stmt_fetch_row(gStmt_AdminLoadAll))
		{
			gAdminData[gTotalAdmins][admin_Name] = name;
			gAdminData[gTotalAdmins][admin_Level] = level;

			gTotalAdmins++;
		}
	}

	SortDeepArray(gAdminData, admin_Level, .order = SORT_DESC);
}

GetAdminLevelByName(name[MAX_PLAYER_NAME])
{
	new level;

	stmt_bind_value(gStmt_AdminGetLevel, 0, DB::TYPE_STRING, name);
	stmt_bind_result_field(gStmt_AdminGetLevel, 1, DB::TYPE_INTEGER, level);
	stmt_execute(gStmt_AdminGetLevel);
	stmt_fetch_row(gStmt_AdminGetLevel);

	return level;
}

CheckAdminLevel(playerid)
{
	for(new i; i < gTotalAdmins; i++)
	{
		if(!strcmp(gPlayerName[playerid], gAdminData[i][admin_Name]))
		{
			gPlayerData[playerid][ply_Admin] = gAdminData[i][admin_Level];
			break;
		}
	}
}

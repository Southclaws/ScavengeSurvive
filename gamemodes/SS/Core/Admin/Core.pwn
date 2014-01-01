#define MAX_ADMIN_LEVELS (5)

enum e_admin_data
{
	admin_Name[MAX_PLAYER_NAME],
	admin_Rank
}


static
	admin_Data[MAX_ADMIN][e_admin_data],
	admin_Total,
	admin_Names[MAX_ADMIN_LEVELS][14] =
	{
		"Player",			// 0 (Unused)
		"Game Master",		// 1
		"Moderator",		// 2
		"Administrator",	// 3
		"Developer"			// 4
	},
	admin_Colours[MAX_ADMIN_LEVELS] =
	{
		0xFFFFFFFF,			// 0 (Unused)
		0x5DFC0AFF,			// 1
		0x33CCFFAA,			// 2
		0x6600FFFF,			// 3
		0xFF0000FF			// 4
	};


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
			if(level > 0 && !isnull(name))
			{
				admin_Data[admin_Total][admin_Name] = name;
				admin_Data[admin_Total][admin_Rank] = level;

				admin_Total++;
			}
			else
			{
				RemoveAdminFromDatabase(name);
			}
		}
	}

	SortDeepArray(admin_Data, admin_Rank, .order = SORT_DESC);
}

SetPlayerAdminLevel(playerid, level)
{
	if(!(0 <= level < MAX_ADMIN_LEVELS))
		return 0;

	gPlayerData[playerid][ply_Admin] = level;

	UpdateAdmin(gPlayerName[playerid], level);

	return 1;
}

UpdateAdmin(name[MAX_PLAYER_NAME], level)
{
	if(level == 0)
		return RemoveAdminFromDatabase(name);

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
			admin_Data[admin_Total][admin_Name] = name;
			admin_Data[admin_Total][admin_Rank] = level;
			admin_Total++;

			SortDeepArray(admin_Data, admin_Rank, .order = SORT_DESC);

			return 1;
		}
	}
	else
	{
		stmt_bind_value(gStmt_AdminUpdate, 0, DB::TYPE_INTEGER, level);
		stmt_bind_value(gStmt_AdminUpdate, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

		if(stmt_execute(gStmt_AdminUpdate))
		{
			for(new i; i < admin_Total; i++)
			{
				if(!strcmp(name, admin_Data[i][admin_Name]))
				{
					admin_Data[i][admin_Rank] = level;

					break;
				}
			}

			SortDeepArray(admin_Data, admin_Rank, .order = SORT_DESC);

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
		new bool:found = false;

		for(new i; i < admin_Total; i++)
		{
			if(!strcmp(name, admin_Data[i][admin_Name]))
				found = true;

			if(found && i < MAX_ADMIN-1)
			{
				format(admin_Data[i][admin_Name], 24, admin_Data[i+1][admin_Name]);
				admin_Data[i][admin_Rank] = admin_Data[i+1][admin_Rank];
			}
		}

		admin_Total--;

		return 1;
	}

	return 0;
}

CheckAdminLevel(playerid)
{
	for(new i; i < admin_Total; i++)
	{
		if(!strcmp(gPlayerName[playerid], admin_Data[i][admin_Name]))
		{
			gPlayerData[playerid][ply_Admin] = admin_Data[i][admin_Rank];
			break;
		}
	}
}

KickPlayer(playerid, reason[])
{
	MsgAdminsF(1, GREY, " >  %P"C_GREY" kicked, reason: "C_BLUE"%s", playerid, reason);
	MsgF(playerid, GREY, " >  Kicked, reason: "C_BLUE"%s", reason);

	defer KickPlayerDelay(playerid);

	logf("[PART] %p (kick: %s)", playerid, reason);
}

timer KickPlayerDelay[10](playerid)
{
	Kick(playerid);
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


ACMD:acmds[1](playerid, params[])
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid], "/a [message] - Staff chat channel");

	if(gPlayerData[playerid][ply_Admin] >= 3)
	{
		strcat(gBigString[playerid], "\n\n"C_YELLOW"Administrator (level 3)"C_BLUE"\n");
		strcat(gBigString[playerid], gAdminCommandList_Lvl3);
	}
	if(gPlayerData[playerid][ply_Admin] >= 2)
	{
		strcat(gBigString[playerid], "\n\n"C_YELLOW"Administrator (level 2)"C_BLUE"\n");
		strcat(gBigString[playerid], gAdminCommandList_Lvl2);
	}
	if(gPlayerData[playerid][ply_Admin] >= 1)
	{
		strcat(gBigString[playerid], "\n\n"C_YELLOW"Game Master (level 1)"C_BLUE"\n");
		strcat(gBigString[playerid], gAdminCommandList_Lvl1);
	}
	
	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Admin Commands List", gBigString[playerid], "Close", "");

	return 1;
}

ACMD:adminlist[3](playerid, params[])
{
	new
		title[20],
		line[52];

	gBigString[playerid][0] = EOS;

	format(title, 20, "Administrators (%d)", admin_Total);

	for(new i; i < admin_Total; i++)
	{
		if(admin_Data[i][admin_Rank] == STAFF_LEVEL_SECRET)
			continue;

		format(line, sizeof(line), "%s %C(%d-%s)\n",
			admin_Data[i][admin_Name],
			admin_Colours[admin_Data[i][admin_Rank]],
			admin_Data[i][admin_Rank],
			admin_Names[admin_Data[i][admin_Rank]]);

		if(GetPlayerIDFromName(admin_Data[i][admin_Name]) != INVALID_PLAYER_ID)
			strcat(gBigString[playerid], " >  ");

		strcat(gBigString[playerid], line);
	}

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_LIST, title, gBigString[playerid], "Close", "");

	return 1;
}

stock GetAdminLevelByName(name[MAX_PLAYER_NAME])
{
	new level;

	stmt_bind_value(gStmt_AdminGetLevel, 0, DB::TYPE_STRING, name);
	stmt_bind_result_field(gStmt_AdminGetLevel, 1, DB::TYPE_INTEGER, level);
	stmt_execute(gStmt_AdminGetLevel);
	stmt_fetch_row(gStmt_AdminGetLevel);

	return level;
}

stock GetAdminTotal()
{
	return admin_Total;
}

stock GetAdminRankName(rank)
{
	if(!(0 < rank < MAX_ADMIN_LEVELS))
		return admin_Names[0];

	return admin_Names[rank];
}

stock GetAdminRankColour(rank)
{
	if(!(0 < rank < MAX_ADMIN_LEVELS))
		return admin_Colours[0];

	return admin_Colours[rank];
}


MsgAdmins(level, colour, string[])
{
	if(level == 0)
		print("ERROR: MsgAdmins paramter 'level' cannot be 0");

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
}


ACMD:admins[3](playerid, params[])
{
	new
		title[20],
		list[(64+1)*MAX_ADMIN + 22],
		offline[(64+1)*MAX_ADMIN],
		tmpstr[64],
		j,
		bool:isonline;

	for(new i; i < gTotalAdmins; i++)
	{
		isonline = false;
		foreach(j : Player)
		{
			if(!strcmp(gAdminData[i][admin_Name], gPlayerName[j]) && !isnull(gAdminData[i][admin_Name]))
			{
				isonline = true;
				break;
			}
		}
		if(isonline)
		{
			format(tmpstr, 64, "%P %C(level %d - %s)\n",
				j,
				AdminColours[gPlayerData[i][ply_Admin]],
				gAdminData[i][admin_Level],
				AdminName[gAdminData[i][admin_Level]]);

			strcat(list, tmpstr);
		}
		else
		{
			format(tmpstr, 64, ""#C_WHITE"%s %C(level %d - %s)\n",
				gAdminData[i][admin_Name],
				AdminColours[gAdminData[i][admin_Level]],
				gAdminData[i][admin_Level],
				AdminName[gAdminData[i][admin_Level]]);

			strcat(offline, tmpstr);
		}
	}
	
	strcat(list, "\n\n"#C_YELLOW"Offline:\n\n");
	strcat(list, offline);
	
	format(title, 20, "Administrators (%d)", gTotalAdmins);

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, title, list, "Close", "");
	return 1;
}

SetPlayerAdminLevel(playerid, level)
{
	if(!(0 <= level <= 4))return 0;

	gPlayerData[playerid][ply_Admin] = level;
	if(level == 0)
	{
		new bool:updated = false;

		for(new i; i<gTotalAdmins; i++)
		{
			if(!strcmp(gPlayerName[playerid], gAdminData[i][admin_Name]))updated = true;

			if(updated && i < MAX_ADMIN-1)
			{
				format(gAdminData[i][admin_Name], 24, gAdminData[i+1][admin_Name]);
				gAdminData[i][admin_Level] = gAdminData[i+1][admin_Level];
			}
		}

		file_Open(ADMIN_DATA_FILE);
		file_Remove(gPlayerName[playerid]);
		file_Save(ADMIN_DATA_FILE);
		file_Close();

		gTotalAdmins--;
	}
	else
	{
		for(new i; i<gTotalAdmins+1; i++)
		{
			if(!isnull(gAdminData[i][admin_Name]))
			{
				if(!strcmp(gPlayerName[playerid], gAdminData[i][admin_Name]))
				{
					gAdminData[i][admin_Name] = gPlayerName[playerid];
					gAdminData[i][admin_Level] = level;
					break;
				}
			}
			else
			{
				gAdminData[i][admin_Name] = gPlayerName[playerid];
				gAdminData[i][admin_Level] = level;
				gTotalAdmins++;
				break;
			}
		}
		file_Open(ADMIN_DATA_FILE);
		file_SetVal(gPlayerName[playerid], level);
		file_Save(ADMIN_DATA_FILE);
		file_Close();
	}
	SortDeepArray(gAdminData, admin_Level, .order = SORT_DESC);
	return 1;
}

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
	
	printf("%d", strlen(str));
	
	if(gPlayerData[playerid][ply_Admin] > 0)
		ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Admin Commands List", str, "Close", "");

	else
		return 0;

	return 1;
}

ACMD:a[1](playerid, params[])
{
	if(isnull(params))
	{
		Msg(playerid, YELLOW, " >  Usage: /a [message] - Sends a message to all admins");
	}

	foreach(new i : Player)
	{
		if(gPlayerData[i][ply_Admin] > 0)
			MsgF(i, WHITE, "%C(A) %P"#C_WHITE": %s", AdminColours[gPlayerData[playerid][ply_Admin]], playerid, TagScan(params));
	}

	return 1;
}

KickPlayer(playerid, reason[])
{
	MsgAdminsF(1, GREY, " >  %P"#C_GREY" kicked, reason: "#C_BLUE"%s", playerid, reason);
	MsgF(playerid, GREY, " >  %P"#C_GREY" kicked, reason: "#C_BLUE"%s", playerid, reason);
	defer KickPlayerDelay(playerid);
}

timer KickPlayerDelay[50](playerid)
{
	Kick(playerid);
}

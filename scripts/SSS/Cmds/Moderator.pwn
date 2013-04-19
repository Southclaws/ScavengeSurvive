ACMD:kick[1](playerid, params[])
{
	new
		id,
		reason[64],
		highestadmin;

	foreach(new i : Player)
	{
		if(gPlayerData[i][ply_Admin] > gPlayerData[highestadmin][ply_Admin])
			highestadmin = i;
	}

	if(sscanf(params, "ds[64]", id, reason))
		return Msg(playerid, YELLOW, " >  Usage: /kick [playerid] [reason]");

	if(gPlayerData[id][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(gPlayerData[playerid][ply_Admin]!=gPlayerData[highestadmin][ply_Admin])
		return MsgF(highestadmin, YELLOW, " >  %P"#C_YELLOW" Is trying to kick %P"#C_YELLOW", You are the highest online admin, it's your decision.", playerid, id);


	if(playerid == id)
		MsgAllF(PINK, " >  %P"#C_PINK" failed and kicked themselves", playerid);

	else
		MsgF(id, YELLOW, " >  You were kicked, reason: %s", reason);

	Kick(id);

	return 1;
}
ACMD:freeze[1](playerid, params[])
{
	new id, delay;

	if(sscanf(params, "dD(0)", id, delay))
		return Msg(playerid, YELLOW, " >  Usage: /freeze [playerid] (seconds)");

	if(gPlayerData[id][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	TogglePlayerControllable(id, false);
	t:bPlayerGameSettings[id]<Frozen>;
	
	if(delay > 0)
	{
		defer CmdDelay_unfreeze(id, delay * 1000);
		MsgF(playerid, YELLOW, " >  Frozen %P for %d seconds", id, delay);
		MsgF(id, YELLOW, " >  %P"#C_YELLOW" has Frozen you for %d seconds", playerid, delay);
	}
	else
	{
		MsgF(playerid, YELLOW, " >  Frozen %P", id);
		MsgF(id, YELLOW, " >  %P"#C_YELLOW" has Frozen you", playerid);
	}

	return 1;
}

timer CmdDelay_unfreeze[time](playerid, time)
{
	#pragma unused time

	TogglePlayerControllable(playerid, true);
	f:bPlayerGameSettings[playerid]<Frozen>;

	Msg(playerid, YELLOW, " >  You are now unfrozen.");
}

ACMD:unfreeze[1](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /unfreeze [playerid]");

	if(!IsPlayerConnected(id))
		return 4;

	TogglePlayerControllable(id, true);
	f:bPlayerGameSettings[id]<Frozen>;

	MsgF(playerid, YELLOW, " >  Unfrozen %P", id);
	MsgF(id, YELLOW, " >  %P"#C_YELLOW" has Unfrozen you", playerid);

	return 1;
}
ACMD:mute[1](playerid, params[])
{
	new
		id,
		delay,
		reason[128];


	if(sscanf(params, "dds[128]", id, delay, reason))
		return Msg(playerid,YELLOW," >  Usage: /mute [playerid] [seconds] [reason]");

	if(!IsPlayerConnected(id))
		return Msg(playerid,RED, " >  Invalid ID");

	if(gPlayerData[id][ply_Admin] >= gPlayerData[playerid][ply_Admin])
		return 3;

	if(bPlayerGameSettings[id]&Muted)
		return Msg(playerid, YELLOW, " >  Player Aready Muted");

	t:bPlayerGameSettings[id]<Muted>;

	if(delay > 0)
	{
		defer CmdDelay_unmute(id, delay * 1000);
		MsgAllF(YELLOW, " >  %P"#C_YELLOW" Muted %P"#C_YELLOW" for "#C_ORANGE"%d "#C_YELLOW"seconds, Reason: %s", playerid, id, delay, reason);
	}
	else
	{
		MsgAllF(YELLOW, " >  %P"#C_YELLOW" Muted %P"#C_YELLOW", Reason: %s", playerid, id, reason);
	}

	return 1;
}

timer CmdDelay_unmute[time](playerid, time)
{
	#pragma unused time
	
	f:bPlayerGameSettings[playerid]<Muted>;

	Msg(playerid, YELLOW, " >  You are now un-muted.");

}

ACMD:unmute[1](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /unmute [playerid]");

	if(gPlayerData[id][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != id)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	f:bPlayerGameSettings[id]<Muted>;

	MsgF(playerid, YELLOW, " >  Un-muted %P", id);
	MsgF(id, YELLOW, " >  %P"#C_YELLOW" has un-muted you.", id);

	return 1;
}
ACMD:warn[1](playerid, params[])
{
	new
		id,
		reason[128];

	if(sscanf(params, "ds[128]", id, reason))
		return Msg(playerid, YELLOW, " >  Usage: /warn [playerid] [reason]");

	if(!IsPlayerConnected(id))
		return Msg(playerid,RED, " >  Invalid ID");

	if(gPlayerData[id][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != id)
		return 3;

	gPlayerWarnings[id]++;

	MsgF(playerid, ORANGE, " >  %P"#C_YELLOW" Has been warned (%d/5) for: %s", id, gPlayerWarnings[id], reason);
	MsgF(id, ORANGE, " >  You been warned (%d/5) for: %s", id, gPlayerWarnings[id], reason);

	if(gPlayerWarnings[id] >= 5)
	{
		Msg(id, YELLOW, " >  Kicked for having too many warnings.");
		Kick(id);
	}

	return 1;
}

ACMD:aliases[1](playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return Msg(playerid, YELLOW, " >  Usage: /aliases [playerid]");

	if(!IsPlayerConnected(id))
		return Msg(playerid,RED, " >  Invalid ID");

	if(gPlayerData[id][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != id)
		return 3;

	new
		rowCount,
		tmpIpQuery[128],
		tmpIpField[32],
		DBResult:tmpIpResult,
		tmpNameList[128];

	format(tmpIpQuery, 128,
		"SELECT * FROM `Player` WHERE `"#ROW_IPV4"` = '%d' AND `"#ROW_NAME"` != '%s'",
		gPlayerData[id][ply_IP], gPlayerName[playerid]);

	tmpIpResult = db_query(gAccounts, tmpIpQuery);

	rowCount = db_num_rows(tmpIpResult);

	if(rowCount > 0)
	{
		for(new i; i < rowCount && i < 5;i++)
		{
			db_get_field(tmpIpResult, 0, tmpIpField, 128);

			if(i > 0)
				strcat(tmpNameList, ", ");

			strcat(tmpNameList, tmpIpField);
			db_next_row(tmpIpResult);
		}
		MsgF(playerid, YELLOW, " >  Aliases: "#C_BLUE"(%d)"#C_ORANGE" %s", rowCount, tmpNameList);
	}
	db_free_result(tmpIpResult);

	return 1;
}

ACMD:weather[1](playerid, params[])
{
	if(strlen(params) > 2)
	{
		for(new i;i<sizeof(WeatherData);i++)
		{
			if(strfind(WeatherData[i], params, true) != -1)
			{
				foreach(new j : Player)
				{
					SetPlayerWeather(j, i);
				}

				gWeatherID = i;
				MsgAdminsF(gPlayerData[playerid][ply_Admin], YELLOW, " >  Weather set to "#C_BLUE"%s", WeatherData[i]);

				return 1;
			}
		}
		Msg(playerid, RED, " >  Invalid weather!");
	}

	return 1;
}

ACMD:msg[1](playerid, params[])
{
	if(!(0 < strlen(params) < 128))
		Msg(playerid,YELLOW," >  Usage: /msg [Message]");

	new str[130] = {" >  "#C_BLUE""};

	strcat(str, TagScan(params));

	MsgAll(YELLOW, str);
	return 1;
}

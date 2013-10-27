ShowPlayerProfile(playerid, name[])
{
	if(!AccountExists(name))
		return 0;

	new
		body[512],
		targetid,

		ipv4,
		alive,
		karma,
		regdate,
		lastlog,
		spawntimestamp,
		dayslived,
		spawns,
		warnings;

	targetid = GetPlayerIDFromName(name);

	if(IsPlayerConnected(targetid))
	{
		ipv4			= gPlayerData[targetid][ply_IP];
		alive			= IsPlayerAlive(targetid);
		karma			= gPlayerData[targetid][ply_Karma];
		regdate			= gPlayerData[targetid][ply_RegisterTimestamp];
		lastlog			= gPlayerData[targetid][ply_LastLogin];
		spawntimestamp	= gPlayerData[targetid][ply_CreationTimestamp];
		spawns			= gPlayerData[targetid][ply_TotalSpawns];
		warnings		= gPlayerData[targetid][ply_Warnings];
	}
	else
	{
		stmt_bind_value(gStmt_AccountLoad, FIELD_ID_PLAYER_NAME, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_IPV4, DB::TYPE_INTEGER, ipv4);
		stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_ALIVE, DB::TYPE_INTEGER, alive);
		stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_KARMA, DB::TYPE_INTEGER, karma);
		stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_REGDATE, DB::TYPE_INTEGER, regdate);
		stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_LASTLOG, DB::TYPE_INTEGER, lastlog);
		stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_SPAWNTIME, DB::TYPE_INTEGER, spawntimestamp);
		stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_TOTALSPAWNS, DB::TYPE_INTEGER, spawns);
		stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_WARNINGS, DB::TYPE_INTEGER, warnings);
	}

	stmt_execute(gStmt_AccountLoad);
	stmt_fetch_row(gStmt_AccountLoad);

	dayslived = (gettime() > spawntimestamp) ? (0) : ((gettime() - spawntimestamp) / 86400);

	format(body, sizeof(body), "\
		Alive:\t\t\t%s\n\
		Karma:\t\t\t%d\n\
		Registered:\t\t%s\n\
		Last Login:\t\t%s\n\
		Days Survived:\t%d\n\
		Lives Lived:\t\t%d\n\
		Warnings:\t\t%d",

		alive ? ("Yes") : ("No"),
		karma,
		TimestampToDateTime(regdate),
		TimestampToDateTime(lastlog),
		dayslived,
		spawns,
		warnings);

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, name, body, "Close", "");

	return 1;
}

CMD:profile(playerid, params[])
{
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name))
	{
		Msg(playerid, YELLOW, " >  Usage: /profile [name]");
		return 1;
	}

	if(ShowPlayerProfile(playerid, name))
		MsgF(playerid, YELLOW, " >  Displaying character profile information for "#C_BLUE"%s"#C_YELLOW".", name);

	else
		Msg(playerid, YELLOW, " >  That account does not exist.");

	return 1;
}

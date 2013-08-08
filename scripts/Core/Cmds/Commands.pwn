new gBigString[2048];

CMD:welcome(playerid, params[])
{
	ShowWelcomeMessage(playerid, 0);
	return 1;
}

CMD:help(playerid, params[])
{
	gBigString[0] = EOS;

	strcat(gBigString,
		""#C_YELLOW"General Information:\n\n\n"#C_WHITE"\
		\t"#C_RED"/rules for a list of server rules.\n\n\
		\t"#C_BLUE"/chatinfo for information on chat.\n\n\
		\t"#C_ORANGE"/restartinfo for information on server restarts and item saving\n\n\
		\t"#C_YELLOW"/tooltips to enable and disable helpful tooltips\n\n\n\
		"#C_WHITE"Server script coded and owned by "#C_GREEN"Southclaw "#C_WHITE"(jaz636@gmail.com) all rights reserved.");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Rules", gBigString, "Close", "");

	return 1;
}

CMD:rules(playerid, params[])
{
	gBigString[0] = EOS;

	strcat(gBigString,
		""#C_YELLOW"Server Rules:\n\n\n"\
		""#C_WHITE"No global chat use if local or radio is available. (/chatinfo) You'll be muted for global spam.\n"#C_BLUE"\tPunishment: Mute, kick for repeated offence, ban for further repeated offence.\n\n"\
		""#C_WHITE"No hacking, cheating or client modifications that give you advantages.\n"#C_BLUE"\tPunishment: Permanent ban, no appeal.\n\n");

	strcat(gBigString,
		""#C_WHITE"No exploiting of map bugs such as hiding/building bases inside models.\n"#C_BLUE"\tPunishment: Account and base deleted, perma-ban for second offence.\n\n"\
		""#C_WHITE"No exploiting server bugs, report them using the /bug command.\n"#C_BLUE"\tPunishment: Week long ban.\n\n");

	strcat(gBigString,
		""#C_WHITE"Only English in global chat. Please use the radio (/chatinfo) for other languages.\n"#C_BLUE"\tPunishment: Mute, kick for repeated offence, ban for further repeated offence.\n\n"\
		""#C_WHITE"No flaming, racism, discrimination towards players or admins. However friendly trash talk is allowed.\n"#C_BLUE"\tPunishment: Permanent ban, no appeal.\n\n");

	strcat(gBigString,
		""#C_WHITE"Don't kill admins on duty with the unique black skin with \"STAFF\" on the back\n"#C_BLUE"\tPunishment: Kick, ban for repeated offence.\n\n"\
		""#C_WHITE"Report all hackers, failure to report hackers or playing with/alongside them will be punished.\n"#C_BLUE"\tPunishment: Exactly the same as hacking punishment.");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Rules", gBigString, "Close", "");

	return 1;
}

CMD:restartinfo(playerid, params[])
{
	gBigString[0] = EOS;

	strcat(gBigString,
		""#C_WHITE"The server restarts "#C_YELLOW"every 5 hours."#C_WHITE"\n\n\
		Your character data such as position, clothes etc will be saved just like when you log out.\n\
		All your held items, holstered weapon, inventory and bag items will be saved.\n\
		The last car you exited will be saved along with all items inside.\n");

	strcat(gBigString,
		"Items within containers within containers "#C_RED"WILL NOT SAVE!"#C_WHITE"\n\
		Items on the floor "#C_RED"WILL NOT SAVE! "#C_WHITE"Put everything you want saved inside a box or near a tent.\n\n\n\
		Recap on All Saved Things: Your last vehicle, Boxes, Fort Parts, Tents, Signs.\n\n\
		Thank you for reading this message, good luck out there survivors!");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Information about "#C_BLUE"Server Restarts", gBigString, "Close", "");

	return 1;
}

CMD:chatinfo(playerid, params[])
{
	gBigString[0] = EOS;

	strcat(gBigString,
		""#C_YELLOW"Communication Information:\n\n\n"#C_WHITE"\
		Chat is split into 3 types: Global, Local and Radio.\n\n\
		\t"#C_GREEN"Global chat (/G) is chat everyone can see, you can ignore it with "#C_WHITE"/quiet\n\n\
		\t"#C_BLUE"Local chat (/L) is only visible in a 40m radius of the sender.\n\n\
		\t"#C_ORANGE"Radio chat (/R) is sent on specific frequencies, useful for private or clan chat.\n\n\n");

	strcat(gBigString,
		""#C_WHITE"You can type the command on it's own to switch to that mode\n\
		Or type the command followed by some text to send a message to that specific chat.\n\n\
		If you are talking to someone next to you, "#C_YELLOW"USE LOCAL OR RADIO!\n\
		"#C_WHITE"If you send unnecessary chat to global, you will be muted.");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Information about "#C_BLUE"Server Restarts", gBigString, "Close", "");

	return 1;
}

CMD:die(playerid, params[])
{
	if(tickcount() - GetPlayerSpawnTick(playerid) < 60000)
		return 2;

	SetPlayerWeapon(playerid, 4, 1);
	ApplyAnimation(playerid, "FOOD", "EAT_Burger", 1.0, 0, 0, 0, 0, 0);
	defer Suicide(playerid);

	return 1;
}
timer Suicide[3000](playerid)
{
	RemovePlayerWeapon(playerid);
	SetPlayerHP(playerid, 0.0);
}

CMD:changepass(playerid,params[])
{
	new
		oldpass[32],
		newpass[32],
		buffer[MAX_PASSWORD_LEN];

	if(!(gPlayerBitData[playerid] & LoggedIn))
		return Msg(playerid, YELLOW, " >  You must be logged in to use that command");

	if(sscanf(params, "s[32]s[32]", oldpass, newpass))
	{
		Msg(playerid, YELLOW, "Usage: /changepass [old pass] [new pass]");
		return 1;
	}
	else
	{
		WP_Hash(buffer, MAX_PASSWORD_LEN, oldpass);
		
		if(!strcmp(buffer, gPlayerData[playerid][ply_Password]))
		{
			WP_Hash(buffer, MAX_PASSWORD_LEN, newpass);

			stmt_bind_value(gStmt_AccountSetPassword, 0, DB::TYPE_STRING, buffer, MAX_PASSWORD_LEN);
			stmt_bind_value(gStmt_AccountSetPassword, 1, DB::TYPE_PLAYER_NAME, playerid);
			
			if(stmt_execute(gStmt_AccountSetPassword))
			{
				gPlayerData[playerid][ply_Password] = buffer;
				MsgF(playerid, YELLOW, " >  Password succesfully changed to "#C_BLUE"%s"#C_YELLOW"!", newpass);
			}
			else
			{
				Msg(playerid, RED, " >  An error occurred! Please contact an administrator");
			}
		}
		else
		{
			Msg(playerid, RED, " >  The entered password you typed doesn't match your current password.");
		}
	}
	return 1;
}

CMD:country(playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
	{
		Msg(playerid, YELLOW, " >  Usage: /country [id]");
		return 1;
	}

	if(!IsPlayerConnected(id))
	{
		return 4;
	}

	new country[32];

	if(gPlayerData[id][ply_Admin] > gPlayerData[playerid][ply_Admin])
		country = "Unknown";

	else
		GetPlayerCountry(id, country);

	MsgF(playerid, YELLOW, " >  %P"#C_YELLOW"'s current GeoIP location: "#C_BLUE"%s", id, country);

	return 1;
}

CMD:allcountry(playerid, params[])
{
	new
		country[32],
		list[(MAX_PLAYER_NAME + 3 + 32 + 1) * MAX_PLAYERS];

	foreach(new i : Player)
	{
		if(gPlayerData[i][ply_Admin] > gPlayerData[playerid][ply_Admin])
			country = "Unknown";

		else
			GetPlayerCountry(i, country);

		format(list, sizeof(list), "%s%p - %s\n", list, i, country);
	}

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_LIST, "Countries", list, "Close", "");

	return 1;
}

CMD:tooltips(playerid, params[])
{
	if(gPlayerBitData[playerid] & ToolTips)
	{
		Msg(playerid, YELLOW, " >  Tooltips disabled");
		f:gPlayerBitData[playerid]<ToolTips>;
	}
	else
	{
		Msg(playerid, YELLOW, " >  Tooltips enabled");
		t:gPlayerBitData[playerid]<ToolTips>;
	}
	return 1;
}

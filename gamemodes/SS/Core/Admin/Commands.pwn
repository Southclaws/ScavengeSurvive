CMD:welcome(playerid, params[])
{
	ShowWelcomeMessage(playerid, 0);
	return 1;
}

CMD:help(playerid, params[])
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid],
		""C_YELLOW"General Information:\n\n\n"#C_WHITE"\
		\t"#C_RED"/rules for a list of server rules.\n\n\
		\t"#C_BLUE"/chatinfo for information on chat.\n\n\
		\t"#C_ORANGE"/restartinfo for information on server restarts and item saving\n\n\
		\t"#C_YELLOW"/tooltips to enable and disable helpful tooltips\n\n\n\
		"#C_WHITE"Server script coded and owned by "#C_GREEN"Southclaw "#C_WHITE"(SouthclawJK@gmail.com) all rights reserved.");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Rules", gBigString[playerid], "Close", "");

	return 1;
}

CMD:rules(playerid, params[])
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid],
		""C_YELLOW"Server Rules:\n\n\n"\
		""C_WHITE"1. No global chat use if local or radio is available. (/chatinfo) You'll be muted for global spam.\n\
		"#C_BLUE"\tPunishment: Mute, kick for repeated offence, ban for further repeated offence.\n\n\
		"#C_WHITE"2. No hacking, cheating or client modifications that give you advantages.\n\
		"#C_BLUE"\tPunishment: Permanent ban.\n\n");

	strcat(gBigString[playerid],
		""C_WHITE"3. No exploiting of map bugs such as hiding/building bases inside models.\n\
		"#C_BLUE"\tPunishment: Account and base deleted, perma-ban for second offence.\n\n\
		"#C_WHITE"4. No exploiting server bugs, report them using the /bug command.\n\
		"#C_BLUE"\tPunishment: Week long ban.\n\n");

	strcat(gBigString[playerid],
		""C_WHITE"5. Only English in global chat. Please use the radio (/chatinfo) for other languages.\n\
		"#C_BLUE"\tPunishment: Mute, kick for repeated offence, ban for further repeated offence.\n\n\
		"#C_WHITE"6. No flaming, racism, discrimination towards players or admins. However friendly trash talk is allowed.\n\
		"#C_BLUE"\tPunishment: Permanent ban, no appeal.\n\n");

	strcat(gBigString[playerid],
		""C_WHITE"7. Don't kill admins on duty with the unique black skin with \"STAFF\" on the back\n\
		"#C_BLUE"\tPunishment: Kick, ban for repeated offence.\n\n\
		"#C_WHITE"8. Report all hackers, failure to report hackers or playing with/alongside them will be punished.\n\
		"#C_BLUE"\tPunishment: Exactly the same as hacking punishment.");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Rules", gBigString[playerid], "Close", "");

	return 1;
}

CMD:restartinfo(playerid, params[])
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid],
		""C_WHITE"The server restarts "#C_YELLOW"every 5 hours."#C_WHITE"\n\n\
		Your character data such as position, clothes etc will be saved just like when you log out.\n\
		All your held items, holstered weapon, inventory and bag items will be saved.\n\
		The last car you exited will be saved along with all items inside.\n");

	strcat(gBigString[playerid],
		"Box items save over restarts only if they are not empty.\n\
		Tents save 8 items that are placed inside.\n\n\
		The contents of bags saved in tents / boxes "#C_RED"WILL NOT SAVE!"#C_WHITE"\n\
		Items within containers within containers "#C_RED"WILL NOT SAVE!"#C_WHITE"\n\
		Items on the floor "#C_RED"WILL NOT SAVE!");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Information about "#C_BLUE"Server Restarts", gBigString[playerid], "Close", "");

	return 1;
}

CMD:chatinfo(playerid, params[])
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid],
		""C_YELLOW"Communication Information:\n\n\n"#C_WHITE"\
		Chat is split into 3 types: Global, Local and Radio.\n\n\
		\t"#C_GREEN"Global chat (/G) is chat everyone can see, you can ignore it with "#C_WHITE"/quiet\n\n\
		\t"#C_BLUE"Local chat (/L) is only visible in a 40m radius of the sender.\n\n\
		\t"#C_ORANGE"Radio chat (/R) is sent on specific frequencies, useful for private or clan chat.\n\n\n");

	strcat(gBigString[playerid],
		""C_WHITE"You can type the command on it's own to switch to that mode\n\
		Or type the command followed by some text to send a message to that specific chat.\n\n\
		If you are talking to someone next to you, "#C_YELLOW"USE LOCAL OR RADIO!\n\
		"#C_WHITE"If you send unnecessary chat to global, you will be muted.");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Information about "#C_BLUE"Server Restarts", gBigString[playerid], "Close", "");

	return 1;
}

CMD:die(playerid, params[])
{
	if(GetTickCountDifference(tickcount(), GetPlayerSpawnTick(playerid)) < 60000)
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

CMD:admins(playerid, params[])
{
	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Admins",
		""C_YELLOW"Server Staff:\n\n\n"#C_WHITE"\
		\t"#C_BLUE"Southclaw - Developer\n\n\
		\t"#C_BLUE"Dogmeat - Admin\n\n\
		\t"#C_BLUE"Tezza - Admin\n\n\
		\t"#C_BLUE"Cagatay - Admin\n\n\
		\t"#C_BLUE"Prolama - Mod\n\n\
		\t"#C_BLUE"Civod - Mod", "Close", "");

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

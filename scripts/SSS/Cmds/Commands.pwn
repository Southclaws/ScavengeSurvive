CMD:die(playerid, params[])
{
	SetPlayerWeapon(playerid, 4, 1);
	ApplyAnimation(playerid, "FOOD", "EAT_Burger", 1.0, 0, 0, 0, 0, 0);
	defer Suicide(playerid);

	return 1;
}
timer Suicide[5000](playerid)
{
	SetPlayerHP(playerid, 0.0);
}

CMD:idea(playerid, params[])
{
	new idea[128];
	if(sscanf(params, "s[128]", idea))
	{
		Msg(playerid, YELLOW, "Usage: /idea [idea]");
		return 1;
	}

	new
		File:tmpfile,
		str[128+MAX_PLAYER_NAME+5];

	format(str, sizeof(str), "%p : %s\r\n", playerid, idea);

	if(!fexist("ideas.txt"))
		tmpfile = fopen("ideas.txt", io_write);

	else
		tmpfile = fopen("ideas.txt", io_append);

	fwrite(tmpfile, str);
	fclose(tmpfile);

	Msg(playerid, YELLOW, " >  Your idea has been submitted, thank you!");

	return 1;
}

CMD:bug(playerid, params[])
{
	new bug[128];
	if(sscanf(params, "s[128]", bug))
	{
		Msg(playerid, YELLOW, "Usage: /bug [bug]");
		return 1;
	}

	new
		File:tmpfile,
		str[128+MAX_PLAYER_NAME+5];
	
	format(str, sizeof(str), "%p : %s\r\n", playerid, bug);

	if(!fexist("bugs.txt"))
		tmpfile = fopen("bugs.txt", io_write);

	else
		tmpfile = fopen("bugs.txt", io_append);

	fwrite(tmpfile, str);
	fclose(tmpfile);
	
	Msg(playerid, YELLOW, " >  Your bug report has been submitted! "#C_BLUE"Southclaw "#C_YELLOW"will fix this when he can.");

	return 1;
}

CMD:help(playerid, params[])
{
	ShowWelcomeMessage(playerid, 0);
	return 1;
}

CMD:rules(playerid, params[])
{
	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Rules",
		""#C_YELLOW"Server Rules:\n\n\n"#C_WHITE"\
		\tNo hacking, cheating or client modifications that give you advantages.\n\n\
		\tNo exploiting of map bugs such as hiding inside collision-less models.\n\n\
		\tNo exploiting server bugs, report them using the "#C_BLUE"/bug "#C_WHITE"command.\n\n\
		\tOnly English in the Chat Box. Please use the radio feature inside your inventory for private chat.\n\n\
		\tNo flaming, racism, discrimination towards players or admins. However friendly trash talk is allowed.",
		"Close", "");
	return 1;
}

CMD:changepass(playerid,params[])
{
	new
		oldpass[32],
		newpass[32],
		buffer[MAX_PASSWORD_LEN];

	if(!(bPlayerGameSettings[playerid] & LoggedIn))
		return Msg(playerid, YELLOW, " >  You must be logged in to use that command");

	if(sscanf(params, "s[32]s[32]", oldpass, newpass)) return Msg(playerid, YELLOW, "Usage: /changepass [old pass] [new pass]");
	else
	{
		WP_Hash(buffer, MAX_PASSWORD_LEN, oldpass);
		
		if(!strcmp(buffer, gPlayerData[playerid][ply_Password]))
		{
			new
				tmpQuery[256];

			WP_Hash(buffer, MAX_PASSWORD_LEN, newpass);

			format(tmpQuery, 256, "UPDATE `Player` SET `"#ROW_PASS"` = '%s' WHERE `"#ROW_NAME"` = '%s'",
			buffer, gPlayerName[playerid]);

			db_free_result(db_query(gAccounts, tmpQuery));
			
			gPlayerData[playerid][ply_Password] = buffer;

			MsgF(playerid, YELLOW, " >  Password succesfully changed to "#C_BLUE"%s"#C_YELLOW"!", newpass);
		}
		else
		{
			Msg(playerid, RED, " >  The entered password you typed doesn't match your current password.");
		}
	}
	return 1;
}

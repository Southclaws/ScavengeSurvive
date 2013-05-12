CMD:die(playerid, params[])
{
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

CMD:welcome(playerid, params[])
{
	ShowWelcomeMessage(playerid, 0);
	return 1;
}

CMD:help(playerid, params[])
{
	new str[577];

	strcat(str,
		""#C_YELLOW"General Information:\n\n\n"#C_WHITE"\
		\t"#C_RED"/rules for a list of server rules.\n\n\
		\t"#C_BLUE"/chatinfo for information on chat.\n\n\
		\t"#C_ORANGE"/restartinfo for information on server restarts and item saving\n\n\n\
		"#C_WHITE"Server script coded and owned by "#C_GREEN"Southclaw "#C_WHITE"(jaz636@gmail.com) all rights reserved.");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Rules", str, "Close", "");

	return 1;
}

CMD:rules(playerid, params[])
{
	new str[577];

	strcat(str,
		""#C_YELLOW"Server Rules:\n\n\n"#C_WHITE"\
		\tNo global chat use if local or radio is available. ("#C_BLUE"/chatinfo"#C_WHITE") You'll be muted for global spam.\n\n\
		\tNo hacking, cheating or client modifications that give you advantages.\n\n\
		\tNo exploiting of map bugs such as hiding inside collision-less models.\n\n");

	strcat(str,
		"\tNo exploiting server bugs, report them using the "#C_BLUE"/bug "#C_WHITE"command.\n\n\
		\tOnly English in global chat. Please use the radio ("#C_BLUE"/chatinfo"#C_WHITE") for other languages.\n\n\
		\tNo flaming, racism, discrimination towards players or admins. However friendly trash talk is allowed.");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Rules", str, "Close", "");

	return 1;
}

CMD:restartinfo(playerid, params[])
{
	new str[471];

	strcat(str,
		""#C_WHITE"The server restarts "#C_YELLOW"every 5 hours."#C_WHITE"\n\n\
		Your character data such as position, clothes etc will be saved just like when you log out.\n\
		All your held items, holstered weapon, inventory and bag items will be saved.\n\
		The last car you exited will be saved along with all items inside.\n");

	strcat(str,
		"Items within containers within containers "#C_RED"WILL NOT SAVE!"#C_WHITE"\n\
		Items on the floor "#C_RED"WILL NOT SAVE! "#C_WHITE"Ensure you put everything you want to keep inside a box.\n\n\n\
		Recap on All Saved Things: Your last vehicle, Boxes, Fort Parts, Tents, Signs.\n\n\
		Thank you for reading this message, good luck out there survivors!");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Information about "#C_BLUE"Server Restarts", str, "Close", "");

	return 1;
}

CMD:chatinfo(playerid, params[])
{
	new str[638];

	strcat(str,
		""#C_YELLOW"Communication Information:\n\n\n"#C_WHITE"\
		Chat is split into 3 types: Global, Local and Radio.\n\n\
		\t"#C_GREEN"Global chat (/G) is chat everyone can see at all times and write into\n\n\
		\t"#C_BLUE"Local chat (/L) is only visible in a 40m radius of the sender.\n\n\
		\t"#C_ORANGE"Radio chat (/R) is sent on specific frequencies, useful for private or clan chat.\n\n\n");

	strcat(str,
		""#C_WHITE"You can type the command on it's own to switch to that mode\n\
		Or type the command followed by some text to send a message to that specific chat.\n\n\
		If you are talking to someone next to you, "#C_YELLOW"USE LOCAL OR RADIO!\n\
		"#C_WHITE"If you send unnecessary chat to global, you will be muted.");

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Information about "#C_BLUE"Server Restarts", str, "Close", "");

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
			new
				query[256];

			WP_Hash(buffer, MAX_PASSWORD_LEN, newpass);

			format(query, 256, "UPDATE `Player` SET `"#ROW_PASS"` = '%s' WHERE `"#ROW_NAME"` = '%s'",
			buffer, gPlayerName[playerid]);

			db_free_result(db_query(gAccounts, query));
			
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

CMD:country(playerid, params[])
{
	new id;

	if(sscanf(params, "d", id))
		return 4;

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

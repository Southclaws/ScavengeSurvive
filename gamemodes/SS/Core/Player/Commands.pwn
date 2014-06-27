CMD:welcome(playerid, params[])
{
	ShowWelcomeMessage(playerid, 0);
	return 1;
}

CMD:help(playerid, params[])
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid],
		""C_YELLOW"General Information:\n\n\n"C_WHITE"\
		\t"C_RED"/rules - list of server rules\n\n\
		\t"C_GREEN"/admins - server staff\n\n\
		\t"C_BLUE"/chatinfo - information on chat\n\n\
		\t"C_ORANGE"/restartinfo - information on server restarts/item saving\n\n");

	strcat(gBigString[playerid],
		"\t"C_YELLOW"/tooltips - enable and disable helpful tooltips\n\n\
		\t"C_BROWN"/die - kill yourself\n\n\
		\t"C_LGREEN"/changepass - change your password\n\n\n\
		"C_WHITE"Server script coded and owned by "C_GREEN"Southclaw "C_WHITE"(SouthclawJK@gmail.com) all rights reserved.");

	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Rules", gBigString[playerid], "Close", "");

	return 1;
}

CMD:rules(playerid, params[])
{
	MsgF(playerid, YELLOW, " >  Rules List (total: %d)", gTotalRules);

	for(new i; i < gTotalRules; i++)
		Msg(playerid, BLUE, sprintf(" >  "C_ORANGE"%s", gRuleList[i]));
	
	return 1;
}

CMD:admins(playerid, params[])
{
	MsgF(playerid, YELLOW, " >  Staff List (total: %d)", gTotalStaff);

	for(new i; i < gTotalStaff; i++)
		Msg(playerid, BLUE, sprintf(" >  "C_ORANGE"%s", gStaffList[i]));
	
	return 1;
}

CMD:chatinfo(playerid, params[])
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid],
		""C_YELLOW"Communication Information:\n\n\n"C_WHITE"\
		Chat is split into 3 types: Global, Local and Radio.\n\n\
		\t"C_GREEN"Global chat (/G) is chat everyone can see, you can ignore it with "C_WHITE"/quiet\n\n\
		\t"C_BLUE"Local chat (/L) is only visible in a 40m radius of the sender.\n\n\
		\t"C_ORANGE"Radio chat (/R) is sent on specific frequencies, useful for private or clan chat.\n\n\n");

	strcat(gBigString[playerid],
		""C_WHITE"You can type the command on it's own to switch to that mode\n\
		Or type the command followed by some text to send a message to that specific chat.\n\n\
		If you are talking to someone next to you, "C_YELLOW"USE LOCAL OR RADIO!\n\
		"C_WHITE"If you send unnecessary chat to global, you will be muted.");

	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Information about "C_BLUE"Server Restarts", gBigString[playerid], "Close", "");

	return 1;
}

CMD:restartinfo(playerid, params[])
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid],
		sprintf(""C_WHITE"The server restarts "C_YELLOW"every %d hours."C_WHITE"\n\n\
		Your character data such as position, clothes etc will be saved just like when you log out.\n\
		All your held items, holstered weapon, inventory and bag items will be saved.\n\
		The last car you exited will be saved along with all items inside.\n", (gServerMaxUptime / 3600)));

	strcat(gBigString[playerid],
		"Box items save over restarts only if they are not empty.\n\
		Tents save 8 items that are placed inside.\n\n\
		The contents of bags saved in tents / boxes "C_RED"WILL NOT SAVE!"C_WHITE"\n\
		Items within containers within containers "C_RED"WILL NOT SAVE!"C_WHITE"\n\
		Items on the floor "C_RED"WILL NOT SAVE!");

	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Information about "C_BLUE"Server Restarts", gBigString[playerid], "Close", "");

	return 1;
}

CMD:tooltips(playerid, params[])
{
	if(GetPlayerBitFlag(playerid, ToolTips))
	{
		Msg(playerid, YELLOW, " >  Tooltips disabled");
		SetPlayerBitFlag(playerid, ToolTips, false);
	}
	else
	{
		Msg(playerid, YELLOW, " >  Tooltips enabled");
		SetPlayerBitFlag(playerid, ToolTips, true);
	}
	return 1;
}

/*CMD:die(playerid, params[])
{
	if(GetTickCountDifference(GetTickCount(), GetPlayerSpawnTick(playerid)) < 60000)
		return 2;

	SetPlayerWeapon(playerid, 4, 1);
	ApplyAnimation(playerid, "FOOD", "EAT_Burger", 1.0, 0, 0, 0, 0, 0);
	defer Suicide(playerid);

	return 1;
}
timer Suicide[3000](playerid)
{
	RemovePlayerWeapon(playerid);
	SetPlayerHP(playerid, -100.0);
}
*/
CMD:changepass(playerid,params[])
{
	new
		oldpass[32],
		newpass[32],
		buffer[MAX_PASSWORD_LEN];

	if(!IsPlayerLoggedIn(playerid))
		return Msg(playerid, YELLOW, " >  You must be logged in to use that command");

	if(sscanf(params, "s[32]s[32]", oldpass, newpass))
	{
		Msg(playerid, YELLOW, "Usage: /changepass [old pass] [new pass]");
		return 1;
	}
	else
	{
		new storedhash[MAX_PASSWORD_LEN];

		GetPlayerPassHash(playerid, storedhash);
		WP_Hash(buffer, MAX_PASSWORD_LEN, oldpass);
		
		if(!strcmp(buffer, storedhash))
		{
			new name[MAX_PLAYER_NAME];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			WP_Hash(buffer, MAX_PASSWORD_LEN, newpass);
			
			if(SetAccountPassword(name, buffer))
			{
				SetPlayerPassHash(playerid, buffer);
				MsgF(playerid, YELLOW, " >  Password successfully changed to "C_BLUE"%s"C_YELLOW"!", newpass);
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

CMD:pos(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	MsgF(playerid, YELLOW, " >  Position: "C_BLUE"%.2f, %.2f, %.2f", x, y, z);

	return 1;
}


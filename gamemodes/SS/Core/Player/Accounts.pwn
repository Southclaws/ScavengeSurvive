#include <YSI\y_hooks>


new
	LoginPasswordAttempts[MAX_PLAYERS];
	

LoadAccount(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		exists,
		password[129],
		ipv4,
		alive,
		regdate,
		lastlog,
		spawntime,
		spawns,
		warnings,
		aimshout[128];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	stmt_bind_value(gStmt_AccountExists, 0, DB::TYPE_STRING, gPlayerName[playerid], MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountExists, 0, DB::TYPE_INTEGER, exists);

	if(stmt_execute(gStmt_AccountExists))
	{
		stmt_fetch_row(gStmt_AccountExists);

		if(exists == 0)
			return 0;
	}
	else
	{
		print("ERROR: [LoadAccount] executing statement 'gStmt_AccountExists'.");
		return 0;
	}

	stmt_bind_value(gStmt_AccountLoad, 0, DB::TYPE_STRING, gPlayerName[playerid], MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_PASS, DB::TYPE_STRING, password, MAX_PASSWORD_LEN);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_IPV4, DB::TYPE_INTEGER, ipv4);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_ALIVE, DB::TYPE_INTEGER, alive);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_REGDATE, DB::TYPE_INTEGER, regdate);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_LASTLOG, DB::TYPE_INTEGER, lastlog);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_SPAWNTIME, DB::TYPE_INTEGER, spawntime);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_TOTALSPAWNS, DB::TYPE_INTEGER, spawns);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_WARNINGS, DB::TYPE_INTEGER, warnings);
	stmt_bind_result_field(gStmt_AccountLoad, FIELD_ID_PLAYER_AIMSHOUT, DB::TYPE_STRING, aimshout, 128);

	if(!stmt_execute(gStmt_AccountLoad))
	{
		printf("ERROR: Loading player account for '%p' from database", playerid);

		return 0;
	}

	stmt_fetch_row(gStmt_AccountLoad);

	if(gWhitelist)
	{
		if(!IsNameInWhitelist(gPlayerName[playerid]))
			return 3;
	}

	SetPlayerBitFlag(playerid, Alive, alive);
	SetPlayerBitFlag(playerid, HasAccount, true);
	SetPlayerBitFlag(playerid, IsNewPlayer, false);

	SetPlayerPassHash(playerid, password);
	SetPlayerRegTimestamp(playerid, regdate);
	SetPlayerLastLogin(playerid, lastlog);
	SetPlayerCreationTimestamp(playerid, spawntime);
	SetPlayerTotalSpawns(playerid, spawns);
	SetPlayerWarnings(playerid, warnings);
	SetPlayerAimShoutText(playerid, aimshout);

	Tutorial_End(playerid);

	if(GetPlayerIpAsInt(playerid) == ipv4)
		return 2;
	
	return 1;
}

CreateAccount(playerid, password[])
{
	new serial[129];

	gpci(playerid, serial, 129);

	stmt_bind_value(gStmt_AccountCreate, 0, DB::TYPE_STRING,	gPlayerName[playerid], MAX_PLAYER_NAME); 
	stmt_bind_value(gStmt_AccountCreate, 1, DB::TYPE_STRING,	password, MAX_PASSWORD_LEN); 
	stmt_bind_value(gStmt_AccountCreate, 2, DB::TYPE_INTEGER,	GetPlayerIpAsInt(playerid)); 
	stmt_bind_value(gStmt_AccountCreate, 3, DB::TYPE_INTEGER,	gettime()); 
	stmt_bind_value(gStmt_AccountCreate, 4, DB::TYPE_INTEGER,	gettime()); 
	stmt_bind_value(gStmt_AccountCreate, 5, DB::TYPE_STRING,	"Drop your weapon!", 18); 
	stmt_bind_value(gStmt_AccountCreate, 6, DB::TYPE_STRING,	serial); 
	stmt_execute(gStmt_AccountCreate);

	SetPlayerAimShoutText(playerid, "Drop your weapon!");

	if(gWhitelist)
	{
		if(!IsNameInWhitelist(gPlayerName[playerid]))
		{
			WhitelistKick(playerid);
			return 0;
		}
	}

	CheckAdminLevel(playerid);

	if(GetPlayerAdminLevel(playerid) > 0)
		MsgF(playerid, BLUE, " >  Your admin level: %d", GetPlayerAdminLevel(playerid));

	SetPlayerBitFlag(playerid, LoggedIn, true);
	SetPlayerBitFlag(playerid, HasAccount, true);
	SetPlayerBitFlag(playerid, ToolTips, true);

	PlayerCreateNewCharacter(playerid);

	return 1;
}

DeleteAccount(name[])
{
	if(!AccountExists(name))
		return 0;

	new file[MAX_PLAYER_FILE];

	stmt_bind_value(gStmt_AccountDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_execute(gStmt_AccountDelete);

	PLAYER_DAT_FILE(name, file);
	fremove(file);

	PLAYER_INV_FILE(name, file);
	fremove(file);

	format(file, sizeof(file), "SSS/Vehicles/%s.dat", name);
	fremove(file);

	format(file, sizeof(file), NOTEBOOK_FILE, name);
	fremove(file);

	return 1;
}

DisplayLoginPrompt(playerid)
{
	new str[128];
	format(str, 128, ""C_WHITE"Welcome Back %P"C_WHITE", Please log into to your account below!\n\n"C_YELLOW"Enjoy your stay :)", playerid);
	ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD, "Login To Your Account", str, "Accept", "Leave");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_Login)
	{
		if(response)
		{
			if(strlen(inputtext) < 4)
			{
				DisplayLoginPrompt(playerid);
				return 1;
			}

			new
				inputhash[MAX_PASSWORD_LEN],
				storedhash[MAX_PASSWORD_LEN];

			WP_Hash(inputhash, MAX_PASSWORD_LEN, inputtext);
			GetPlayerPassHash(playerid, storedhash);

			if(!strcmp(inputhash, storedhash))
			{
				Login(playerid);
			}
			else
			{
				ShowPlayerDialog(playerid, d_Login, DIALOG_STYLE_PASSWORD,
					"Login To Your Account",
					sprintf("Incorrect password! %d out of 5 tries", LoginPasswordAttempts[playerid]),
					"Accept", "Quit");

				LoginPasswordAttempts[playerid]++;

				if(LoginPasswordAttempts[playerid] == 5)
				{
					MsgAllF(GREY, " >  %s left the server without logging in.", gPlayerName[playerid]);
					Kick(playerid);
				}
			}
		}
		else
		{
			MsgAllF(GREY, " >  %s left the server without logging in.", gPlayerName[playerid]);
			Kick(playerid);
		}
	}
	if(dialogid == d_Register)
	{
		if(response)
		{
			if(!(4 <= strlen(inputtext) <= 32))
			{
				ShowPlayerDialog(playerid, d_Register, DIALOG_STYLE_PASSWORD, ""C_RED"Password too short/long!\n"C_YELLOW"Password must be between 4 and 32 characters.", "Type your password below", "Accept", "Quit");
				return 0;
			}

			new buffer[MAX_PASSWORD_LEN];

			WP_Hash(buffer, MAX_PASSWORD_LEN, inputtext);

			if(CreateAccount(playerid, buffer))
				ShowWelcomeMessage(playerid, 10);
		}
		else
		{
			MsgAllF(GREY, " >  %s left the server without registering.", gPlayerName[playerid]);
			Kick(playerid);
		}
	}

	return 1;
}

Login(playerid)
{
	new serial[129];

	gpci(playerid, serial, 129);

	stmt_bind_value(gStmt_AccountSetIpv4, 0, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
	stmt_bind_value(gStmt_AccountSetIpv4, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(gStmt_AccountSetIpv4);

	stmt_bind_value(gStmt_AccountSetGpci, 0, DB::TYPE_STRING, serial);
	stmt_bind_value(gStmt_AccountSetGpci, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(gStmt_AccountSetGpci);

	stmt_bind_value(gStmt_AccountSetLastLog, 0, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(gStmt_AccountSetLastLog, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(gStmt_AccountSetLastLog);

	CheckAdminLevel(playerid);

	if(GetPlayerAdminLevel(playerid) > 0)
	{
		new
			reports = GetUnreadReports(),
			issues = GetBugReports();

		MsgF(playerid, BLUE, " >  Your admin level: %d", GetPlayerAdminLevel(playerid));

		if(reports > 0)
			MsgF(playerid, YELLOW, " >  %d unread reports, type "C_BLUE"/reports "C_YELLOW"to view.", reports);

		if(issues > 0)
			MsgF(playerid, YELLOW, " >  %d issues, type "C_BLUE"/issues "C_YELLOW"to view.", issues);
	}

	SetPlayerBitFlag(playerid, LoggedIn, true);
	LoginPasswordAttempts[playerid] = 0;

	SetPlayerRadioFrequency(playerid, 107.0);
	SetPlayerScreenFadeLevel(playerid, 255);

	SpawnLoggedInPlayer(playerid);
}

Logout(playerid, docombatlogcheck = 1)
{
	if(!GetPlayerBitFlag(playerid, LoggedIn))
		return 0;

	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(docombatlogcheck)
	{
		new
			lastattacker,
			lastweapon;

		if(IsPlayerCombatLogging(playerid, lastattacker, lastweapon))
		{
			OnPlayerDeath(playerid, lastattacker, lastweapon);
		}
	}

	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(IsItemTypeSafebox(itemtype) || IsItemTypeBag(itemtype))
	{
		if(!IsContainerEmpty(GetItemExtraData(itemid)))
		{
			new
				Float:x,
				Float:y,
				Float:z,
				Float:r;

			GetPlayerPos(playerid, x, y, z);
			GetPlayerFacingAngle(playerid, r);

			CreateItemInWorld(itemid, x + floatsin(-r, degrees), y + floatcos(-r, degrees), z - FLOOR_OFFSET, .zoffset = ITEM_BUTTON_OFFSET);

			itemid = INVALID_ITEM_ID;
		}
	}

	SavePlayerData(playerid);

	if(IsPlayerAlive(playerid))
	{
		DestroyItem(itemid);
		DestroyPlayerBag(playerid);
		RemovePlayerHolsterItem(playerid);
		RemovePlayerWeapon(playerid);

		for(new i; i < INV_MAX_SLOTS; i++)
		{
			DestroyItem(GetInventorySlotItem(playerid, 0));
			RemoveItemFromInventory(playerid, 0);
		}

		if(IsValidItem(GetPlayerHat(playerid)))
			RemovePlayerHat(playerid);

		if(IsValidItem(GetPlayerMask(playerid)))
			RemovePlayerMask(playerid);

		if(IsPlayerInAnyVehicle(playerid))
		{
			new Float:health;

			GetVehicleHealth(GetPlayerLastVehicle(playerid), health);

			if(health < VEHICLE_HEALTH_MIN)
				DestroyVehicle(GetPlayerLastVehicle(playerid));

			else
				UpdateVehicleFile(GetPlayerLastVehicle(playerid));
		}
	}

	return 1;
}


SavePlayerData(playerid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(!GetPlayerBitFlag(playerid, LoadedData))
		return 0;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	if(IsAtDefaultPos(x, y, z))
		return 0;

	if(IsAtConnectionPos(x, y, z))
		return 0;

	SaveBlockAreaCheck(x, y, z);

	if(IsPlayerInAnyVehicle(playerid))
		x += 1.5;

	if(IsPlayerAlive(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		{
			if(!gServerRestarting)
				return 0;
		}

		stmt_bind_value(gStmt_AccountUpdate, 0, DB::TYPE_INTEGER, 1);
		stmt_bind_value(gStmt_AccountUpdate, 1, DB::TYPE_INTEGER, GetPlayerKarma(playerid));
		stmt_bind_value(gStmt_AccountUpdate, 2, DB::TYPE_INTEGER, GetPlayerWarnings(playerid));
		stmt_bind_value(gStmt_AccountUpdate, 3, DB::TYPE_PLAYER_NAME, playerid);
		stmt_execute(gStmt_AccountUpdate);

		SavePlayerInventory(playerid);
		SavePlayerChar(playerid);
	}
	else
	{
		stmt_bind_value(gStmt_AccountUpdate, 0, DB::TYPE_INTEGER, 0);
		stmt_bind_value(gStmt_AccountUpdate, 1, DB::TYPE_INTEGER, GetPlayerKarma(playerid));
		stmt_bind_value(gStmt_AccountUpdate, 2, DB::TYPE_INTEGER, GetPlayerWarnings(playerid));
		stmt_bind_value(gStmt_AccountUpdate, 3, DB::TYPE_PLAYER_NAME, playerid);

		stmt_execute(gStmt_AccountUpdate);

		ClearPlayerInventoryFile(playerid);
	}

	return 1;
}


// Interface


AccountExists(name[])
{
	new exists;

	stmt_bind_value(gStmt_AccountExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_AccountExists, 0, DB::TYPE_INTEGER, exists);

	if(stmt_execute(gStmt_AccountExists))
	{
		stmt_fetch_row(gStmt_AccountExists);

		if(exists)
			return 1;
	}

	return 0;
}

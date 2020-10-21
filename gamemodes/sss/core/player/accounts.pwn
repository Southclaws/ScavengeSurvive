/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define ACCOUNTS_TABLE_PLAYER		"Player"
#define FIELD_PLAYER_NAME			"name"		// 00
#define FIELD_PLAYER_PASS			"pass"		// 01
#define FIELD_PLAYER_IPV4			"ipv4"		// 02
#define FIELD_PLAYER_ALIVE			"alive"		// 03
#define FIELD_PLAYER_REGDATE		"regdate"	// 04
#define FIELD_PLAYER_LASTLOG		"lastlog"	// 05
#define FIELD_PLAYER_SPAWNTIME		"spawntime"	// 06
#define FIELD_PLAYER_TOTALSPAWNS	"spawns"	// 07
#define FIELD_PLAYER_WARNINGS		"warnings"	// 08
#define FIELD_PLAYER_GPCI			"gpci"		// 19
#define FIELD_PLAYER_ACTIVE			"active"	// 10

enum
{
	FIELD_ID_PLAYER_NAME,
	FIELD_ID_PLAYER_PASS,
	FIELD_ID_PLAYER_IPV4,
	FIELD_ID_PLAYER_ALIVE,
	FIELD_ID_PLAYER_REGDATE,
	FIELD_ID_PLAYER_LASTLOG,
	FIELD_ID_PLAYER_SPAWNTIME,
	FIELD_ID_PLAYER_TOTALSPAWNS,
	FIELD_ID_PLAYER_WARNINGS,
	FIELD_ID_PLAYER_GPCI,
	FIELD_ID_PLAYER_ACTIVE
}


static
				acc_LoginAttempts[MAX_PLAYERS],
				acc_IsNewPlayer[MAX_PLAYERS],
				acc_HasAccount[MAX_PLAYERS],
				acc_LoggedIn[MAX_PLAYERS],

// ACCOUNTS_TABLE_PLAYER
DBStatement:	stmt_AccountExists,
DBStatement:	stmt_AccountCreate,
DBStatement:	stmt_AccountLoad,
DBStatement:	stmt_AccountUpdate,

DBStatement:	stmt_AccountGetPassword,
DBStatement:	stmt_AccountSetPassword,

DBStatement:	stmt_AccountGetIpv4,
DBStatement:	stmt_AccountSetIpv4,

DBStatement:	stmt_AccountGetAliveState,
DBStatement:	stmt_AccountSetAliveState,

DBStatement:	stmt_AccountGetRegdate,
DBStatement:	stmt_AccountSetRegdate,

DBStatement:	stmt_AccountGetLastLog,
DBStatement:	stmt_AccountSetLastLog,

DBStatement:	stmt_AccountGetSpawnTime,
DBStatement:	stmt_AccountSetSpawnTime,

DBStatement:	stmt_AccountGetTotalSpawns,
DBStatement:	stmt_AccountSetTotalSpawns,

DBStatement:	stmt_AccountGetWarnings,
DBStatement:	stmt_AccountSetWarnings,

DBStatement:	stmt_AccountGetGpci,
DBStatement:	stmt_AccountSetGpci,

DBStatement:	stmt_AccountGetActiveState,
DBStatement:	stmt_AccountSetActiveState,

DBStatement:	stmt_AccountGetAliasData;
	

forward OnPlayerLoadAccount(playerid);
forward OnPlayerRegister(playerid);
forward OnPlayerLogin(playerid);


hook OnGameModeInit()
{
	db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_PLAYER" (\
		"FIELD_PLAYER_NAME" TEXT,\
		"FIELD_PLAYER_PASS" TEXT,\
		"FIELD_PLAYER_IPV4" INTEGER,\
		"FIELD_PLAYER_ALIVE" INTEGER,\
		"FIELD_PLAYER_REGDATE" INTEGER,\
		"FIELD_PLAYER_LASTLOG" INTEGER,\
		"FIELD_PLAYER_SPAWNTIME" INTEGER,\
		"FIELD_PLAYER_TOTALSPAWNS" INTEGER,\
		"FIELD_PLAYER_WARNINGS" INTEGER,\
		"FIELD_PLAYER_GPCI" TEXT,\
		"FIELD_PLAYER_ACTIVE")");

	db_query(gAccounts, "CREATE INDEX IF NOT EXISTS "ACCOUNTS_TABLE_PLAYER"_index ON "ACCOUNTS_TABLE_PLAYER"("FIELD_PLAYER_NAME")");

	DatabaseTableCheck(gAccounts, ACCOUNTS_TABLE_PLAYER, 11);

	stmt_AccountExists			= db_prepare(gAccounts, "SELECT COUNT(*) FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountCreate			= db_prepare(gAccounts, "INSERT INTO "ACCOUNTS_TABLE_PLAYER" VALUES(?,?,?,1,?,?,0,0,0,?,1)");
	stmt_AccountLoad			= db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountUpdate			= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_ALIVE"=?, "FIELD_PLAYER_WARNINGS"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetPassword		= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_PASS" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetPassword		= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_PASS"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetIpv4			= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_IPV4" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetIpv4			= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_IPV4"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetAliveState	= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_ALIVE" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetAliveState	= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_ALIVE"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetRegdate		= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_REGDATE" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetRegdate		= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_REGDATE"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetLastLog		= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_LASTLOG" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetLastLog		= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_LASTLOG"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetSpawnTime	= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_SPAWNTIME" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetSpawnTime	= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_SPAWNTIME"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetTotalSpawns	= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_TOTALSPAWNS" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetTotalSpawns	= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_TOTALSPAWNS"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetWarnings		= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_WARNINGS" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetWarnings		= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_WARNINGS"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetGpci			= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_GPCI" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetGpci			= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_GPCI"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetActiveState	= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_ACTIVE" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetActiveState	= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_ACTIVE"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetAliasData	= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_IPV4", "FIELD_PLAYER_PASS", "FIELD_PLAYER_GPCI" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? AND "FIELD_PLAYER_ACTIVE" COLLATE NOCASE");
}

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /accounts");

	acc_LoginAttempts[playerid] = 0;
	acc_IsNewPlayer[playerid] = false;
	acc_HasAccount[playerid] = false;
	acc_LoggedIn[playerid] = false;
}


/*==============================================================================

	Loads database data into memory and applies it to the player.

==============================================================================*/


LoadAccount(playerid)
{
	if(CallLocalFunction("OnPlayerLoadAccount", "d", playerid))
		return -1;

	new
		name[MAX_PLAYER_NAME],
		exists,
		password[MAX_PASSWORD_LEN],
		ipv4,
		bool:alive,
		regdate,
		lastlog,
		spawntime,
		spawns,
		warnings,
		active;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	stmt_bind_value(stmt_AccountExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountExists, 0, DB::TYPE_INTEGER, exists);

	if(!stmt_execute(stmt_AccountExists))
	{
		err("[LoadAccount] executing statement 'stmt_AccountExists'.");
		return -1;
	}

	if(!stmt_fetch_row(stmt_AccountExists))
	{
		err("[LoadAccount] fetching statement result 'stmt_AccountExists'.");
		return -1;
	}

	if(exists == 0)
	{
		log("[LoadAccount] %p (account does not exist)", playerid);
		return 0;
	}

	stmt_bind_value(stmt_AccountLoad, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_PASS, DB::TYPE_STRING, password, MAX_PASSWORD_LEN);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_IPV4, DB::TYPE_INTEGER, ipv4);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_ALIVE, DB::TYPE_INTEGER, alive);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_REGDATE, DB::TYPE_INTEGER, regdate);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_LASTLOG, DB::TYPE_INTEGER, lastlog);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_SPAWNTIME, DB::TYPE_INTEGER, spawntime);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_TOTALSPAWNS, DB::TYPE_INTEGER, spawns);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_WARNINGS, DB::TYPE_INTEGER, warnings);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_ACTIVE, DB::TYPE_INTEGER, active);

	if(!stmt_execute(stmt_AccountLoad))
	{
		err("[LoadAccount] executing statement 'stmt_AccountLoad'.");
		return -1;
	}

	if(!stmt_fetch_row(stmt_AccountLoad))
	{
		err("[LoadAccount] fetching statement result 'stmt_AccountLoad'.");
		return -1;
	}

	if(!active)
	{
		log("[LoadAccount] %p (account inactive) Alive: %d Last login: %T", playerid, alive, lastlog);
		return 4;
	}

	if(IsWhitelistActive())
	{
		ChatMsgLang(playerid, YELLOW, "WHITELISTAC");

		if(!IsPlayerInWhitelist(playerid))
		{
			ChatMsgLang(playerid, YELLOW, "WHITELISTNO");
			log("[LoadAccount] %p (account not whitelisted) Alive: %d Last login: %T", playerid, alive, lastlog);
			return 3;
		}
	}

	SetPlayerAliveState(playerid, alive);
	acc_IsNewPlayer[playerid] = false;
	acc_HasAccount[playerid] = true;

	SetPlayerPassHash(playerid, password);
	SetPlayerRegTimestamp(playerid, regdate);
	SetPlayerLastLogin(playerid, lastlog);
	SetPlayerCreationTimestamp(playerid, spawntime);
	SetPlayerTotalSpawns(playerid, spawns);
	SetPlayerWarnings(playerid, warnings);

//	if(GetPlayerIpAsInt(playerid) == ipv4)
//	{
//		log("[LoadAccount] %p (account exists, auto login)", playerid);
//		return 2;
//	}

	log("[LoadAccount] %p (account exists, prompting login) Alive: %d Last login: %T", playerid, alive, lastlog);

	return 1;
}


/*==============================================================================

	Creates a new account for a player with the specified password hash.

==============================================================================*/


CreateAccount(playerid, const password[])
{
	new
		name[MAX_PLAYER_NAME],
		serial[MAX_GPCI_LEN];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	gpci(playerid, serial, MAX_GPCI_LEN);

	log("[REGISTER] %p registered", playerid);

	stmt_bind_value(stmt_AccountCreate, 0, DB::TYPE_STRING,		name, MAX_PLAYER_NAME); 
	stmt_bind_value(stmt_AccountCreate, 1, DB::TYPE_STRING,		password, MAX_PASSWORD_LEN); 
	stmt_bind_value(stmt_AccountCreate, 2, DB::TYPE_INTEGER,	GetPlayerIpAsInt(playerid)); 
	stmt_bind_value(stmt_AccountCreate, 3, DB::TYPE_INTEGER,	gettime()); 
	stmt_bind_value(stmt_AccountCreate, 4, DB::TYPE_INTEGER,	gettime()); 
	stmt_bind_value(stmt_AccountCreate, 5, DB::TYPE_STRING,		serial, MAX_GPCI_LEN); 

	if(!stmt_execute(stmt_AccountCreate))
	{
		err("[CreateAccount] executing statement 'stmt_AccountCreate'.");
		KickPlayer(playerid, "An error occurred while executing statement 'stmt_AccountCreate'. Please contact an admin on IRC or the forum.");
		return 0;
	}

	SetPlayerAimShoutText(playerid, "Drop your weapon!");

	if(IsWhitelistActive())
	{
		ChatMsgLang(playerid, YELLOW, "WHITELISTAC");
		if(!IsPlayerInWhitelist(playerid))
		{
			ChatMsgLang(playerid, YELLOW, "WHITELISTNO");
			WhitelistKick(playerid);
			return 0;
		}
	}

	CheckAdminLevel(playerid);

	if(GetPlayerAdminLevel(playerid) > 0)
		ChatMsg(playerid, BLUE, " >  Your admin level: %d", GetPlayerAdminLevel(playerid));

	acc_IsNewPlayer[playerid] = true;
	acc_HasAccount[playerid] = true;
	acc_LoggedIn[playerid] = true;
	SetPlayerToolTips(playerid, true);

	PlayerCreateNewCharacter(playerid);

	CallLocalFunction("OnPlayerRegister", "d", playerid);

	return 1;
}

DisplayRegisterPrompt(playerid)
{
	new str[150];
	format(str, 150, ls(playerid, "ACCREGIBODY"), playerid);

	log("[REGPROMPT] %p is registering", playerid);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			if(!(4 <= strlen(inputtext) <= 32))
			{
				ChatMsgLang(playerid, YELLOW, "PASSWORDREQ");
				DisplayRegisterPrompt(playerid);
				return 0;
			}

			new buffer[MAX_PASSWORD_LEN];

			WP_Hash(buffer, MAX_PASSWORD_LEN, inputtext);

			if(CreateAccount(playerid, buffer))
				ShowWelcomeMessage(playerid, 10);
		}
		else
		{
			ChatMsgAll(GREY, " >  %p left the server without registering.", playerid);
			Kick(playerid);
		}

		return 1;
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_PASSWORD, ls(playerid, "ACCREGITITL"), str, "Accept", "Leave");

	return 1;
}

DisplayLoginPrompt(playerid, badpass = 0)
{
	new str[128];

	if(badpass)
		format(str, 128, ls(playerid, "ACCLOGWROPW"), acc_LoginAttempts[playerid]);

	else
		format(str, 128, ls(playerid, "ACCLOGIBODY"), playerid);

	log("[LOGPROMPT] %p is logging in", playerid);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			if(strlen(inputtext) < 4)
			{
				acc_LoginAttempts[playerid]++;

				if(acc_LoginAttempts[playerid] < 5)
				{
					DisplayLoginPrompt(playerid, 1);
				}
				else
				{
					ChatMsgAll(GREY, " >  %p left the server without logging in.", playerid);
					Kick(playerid);
				}

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
				acc_LoginAttempts[playerid]++;

				if(acc_LoginAttempts[playerid] < 5)
				{
					DisplayLoginPrompt(playerid, 1);
				}
				else
				{
					ChatMsgAll(GREY, " >  %p left the server without logging in.", playerid);
					Kick(playerid);
				}
			}
		}
		else
		{
			ChatMsgAll(GREY, " >  %p left the server without logging in.", playerid);
			Kick(playerid);
		}

		return 1;
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_PASSWORD, ls(playerid, "ACCLOGITITL"), str, "Accept", "Leave");

	return 1;
}


/*==============================================================================

	Loads a player's account, updates some data and spawns them.

==============================================================================*/


Login(playerid)
{
	new serial[MAX_GPCI_LEN];

	gpci(playerid, serial, MAX_GPCI_LEN);

	log("[LOGIN] %p logged in, alive: %d", playerid, IsPlayerAlive(playerid));

	// TODO: move to a single query
	stmt_bind_value(stmt_AccountSetIpv4, 0, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
	stmt_bind_value(stmt_AccountSetIpv4, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(stmt_AccountSetIpv4);

	stmt_bind_value(stmt_AccountSetGpci, 0, DB::TYPE_STRING, serial);
	stmt_bind_value(stmt_AccountSetGpci, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(stmt_AccountSetGpci);

	stmt_bind_value(stmt_AccountSetLastLog, 0, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_AccountSetLastLog, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(stmt_AccountSetLastLog);

	CheckAdminLevel(playerid);

	if(GetPlayerAdminLevel(playerid) > 0)
	{
		new
			reports = GetUnreadReports(),
			issues = GetBugReports();

		ChatMsg(playerid, BLUE, " >  Your admin level: %d", GetPlayerAdminLevel(playerid));

		if(reports > 0)
			ChatMsg(playerid, YELLOW, " >  %d unread reports, type "C_BLUE"/reports "C_YELLOW"to view.", reports);

		if(issues > 0)
			ChatMsg(playerid, YELLOW, " >  %d issues, type "C_BLUE"/issues "C_YELLOW"to view.", issues);
	}

	acc_LoggedIn[playerid] = true;
	acc_LoginAttempts[playerid] = 0;

	SetPlayerRadioFrequency(playerid, 107.0);
	SetPlayerBrightness(playerid, 255);

	SpawnLoggedInPlayer(playerid);

	CallLocalFunction("OnPlayerLogin", "d", playerid);
}


/*==============================================================================

	Logs the player out, saving their data and deleting their items.

==============================================================================*/


Logout(playerid, docombatlogcheck = 1)
{
	if(!acc_LoggedIn[playerid])
	{
		log("[LOGOUT] %p not logged in.", playerid);
		return 0;
	}

	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	log("[LOGOUT] %p logged out at %.1f, %.1f, %.1f (%.1f) Logged In: %d Alive: %d Knocked Out: %d",
		playerid, x, y, z, r, acc_LoggedIn[playerid], IsPlayerAlive(playerid), IsPlayerKnockedOut(playerid));

	if(IsPlayerOnAdminDuty(playerid))
	{
		dbg("accounts", 1, "[LOGOUT] ERROR: Player on admin duty, aborting save.");
		return 0;
	}

	if(docombatlogcheck)
	{
		if(gServerMaxUptime - gServerUptime > 30)
		{
			new
				lastattacker,
				lastweapon;

			if(IsPlayerCombatLogging(playerid, lastattacker, Item:lastweapon))
			{
				log("[LOGOUT] Player '%p' combat logged!", playerid);
				ChatMsgAll(YELLOW, " >  %p combat logged!", playerid);
				// TODO: make this correct, lastweapon is an item ID but
				// OnPlayerDeath takes a GTA weapon ID.
				OnPlayerDeath(playerid, lastattacker, lastweapon);
			}
		}
	}

	new
		Item:itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(IsItemTypeSafebox(itemtype))
	{
		dbg("accounts", 1, "[LOGOUT] Player is holding a box.");

		new Container:containerid;
		GetItemExtraData(itemid, _:containerid);
		if(!IsContainerEmpty(containerid))
		{
			dbg("accounts", 1, "[LOGOUT] Player is holding an unempty box, dropping in world.");
			CreateItemInWorld(itemid, x + floatsin(-r, degrees), y + floatcos(-r, degrees), z - ITEM_FLOOR_OFFSET);
			itemid = INVALID_ITEM_ID;
			itemtype = INVALID_ITEM_TYPE;
		}
	}

	if(IsItemTypeBag(itemtype))
	{
		dbg("accounts", 1, "[LOGOUT] Player is holding a bag.");
		new Container:containerid;
		GetItemArrayDataAtCell(itemid, _:containerid, 1);
		if(!IsContainerEmpty(containerid))
		{
			if(IsValidItem(GetPlayerBagItem(playerid)))
			{
				dbg("accounts", 1, "[LOGOUT] Player is holding an unempty bag and is wearing one, dropping in world.");
				CreateItemInWorld(itemid, x + floatsin(-r, degrees), y + floatcos(-r, degrees), z - ITEM_FLOOR_OFFSET);
				itemid = INVALID_ITEM_ID;
				itemtype = INVALID_ITEM_TYPE;
			}
			else
			{
				dbg("accounts", 1, "[LOGOUT] Player is holding an unempty bag but is not wearing one, calling GivePlayerBag.");
				GivePlayerBag(playerid, itemid);
				itemid = INVALID_ITEM_ID;
				itemtype = INVALID_ITEM_TYPE;
			}
		}
	}

	SavePlayerData(playerid);

	if(IsPlayerAlive(playerid))
	{
		DestroyItem(itemid);
		DestroyItem(GetPlayerHolsterItem(playerid));
		DestroyPlayerBag(playerid);
		RemovePlayerHolsterItem(playerid);
		RemovePlayerWeapon(playerid);

		for(new i; i < INV_MAX_SLOTS; i++)
		{
			new Item:subitemid;
			GetInventorySlotItem(playerid, 0, subitemid);
			DestroyItem(subitemid);
		}

		if(IsValidItem(GetPlayerHatItem(playerid)))
			RemovePlayerHatItem(playerid);

		if(IsValidItem(GetPlayerMaskItem(playerid)))
			RemovePlayerMaskItem(playerid);

		if(IsPlayerInAnyVehicle(playerid))
		{
			new
				vehicleid = GetPlayerLastVehicle(playerid),
				Float:health;

			GetVehicleHealth(vehicleid, health);

			if(IsVehicleUpsideDown(vehicleid) || health < 300.0)
			{
				DestroyVehicle(vehicleid);
			}
			else
			{
				if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
					SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);
			}

			UpdatePlayerVehicle(playerid, vehicleid);
		}
	}

	return 1;
}


/*==============================================================================

	Updates the database and calls the binary save functions if required.

==============================================================================*/


SavePlayerData(playerid)
{
	dbg("accounts", 1, "[SavePlayerData] Saving '%p'", playerid);

	if(!acc_LoggedIn[playerid])
	{
		dbg("accounts", 1, "[SavePlayerData] ERROR: Player isn't logged in");
		return 0;
	}

	if(IsPlayerOnAdminDuty(playerid))
	{
		dbg("accounts", 1, "[SavePlayerData] ERROR: On admin duty");
		return 0;
	}

	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	if(IsAtConnectionPos(x, y, z))
	{
		dbg("accounts", 1, "[SavePlayerData] ERROR: At connection pos");
		return 0;
	}

	SaveBlockAreaCheck(x, y, z);

	if(IsPlayerInAnyVehicle(playerid))
		x += 1.5;

	if(IsPlayerAlive(playerid) && !IsPlayerInTutorial(playerid))
	{
		dbg("accounts", 2, "[SavePlayerData] Player is alive");
		if(IsAtDefaultPos(x, y, z))
		{
			dbg("accounts", 2, "[SavePlayerData] ERROR: Player at default position");
			return 0;
		}

		if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		{
			dbg("accounts", 2, "[SavePlayerData] Player is spectating");
			if(!gServerRestarting)
			{
				dbg("accounts", 2, "[SavePlayerData] Server is not restarting, aborting save");
				return 0;
			}
		}

		stmt_bind_value(stmt_AccountUpdate, 0, DB::TYPE_INTEGER, 1);
		stmt_bind_value(stmt_AccountUpdate, 1, DB::TYPE_INTEGER, GetPlayerWarnings(playerid));
		stmt_bind_value(stmt_AccountUpdate, 2, DB::TYPE_PLAYER_NAME, playerid);

		if(!stmt_execute(stmt_AccountUpdate))
		{
			err("Statement 'stmt_AccountUpdate' failed to execute.");
		}

		dbg("accounts", 2, "[SavePlayerData] Saving character data");
		SavePlayerChar(playerid);
	}
	else
	{
		dbg("accounts", 2, "[SavePlayerData] Player is dead");
		stmt_bind_value(stmt_AccountUpdate, 0, DB::TYPE_INTEGER, 0);
		stmt_bind_value(stmt_AccountUpdate, 1, DB::TYPE_INTEGER, GetPlayerWarnings(playerid));
		stmt_bind_value(stmt_AccountUpdate, 2, DB::TYPE_PLAYER_NAME, playerid);

		if(!stmt_execute(stmt_AccountUpdate))
		{
			err("Statement 'stmt_AccountUpdate' failed to execute.");
		}
	}

	return 1;
}


/*==============================================================================

	Interface functions

==============================================================================*/


stock GetAccountData(name[], pass[], &ipv4, &alive, &regdate, &lastlog, &spawntime, &totalspawns, &warnings, gpci[], &active)
{
	stmt_bind_value(stmt_AccountLoad, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_PASS, DB::TYPE_STRING, pass, MAX_PASSWORD_LEN);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_IPV4, DB::TYPE_INTEGER, ipv4);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_ALIVE, DB::TYPE_INTEGER, alive);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_REGDATE, DB::TYPE_INTEGER, regdate);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_LASTLOG, DB::TYPE_INTEGER, lastlog);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_SPAWNTIME, DB::TYPE_INTEGER, spawntime);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_TOTALSPAWNS, DB::TYPE_INTEGER, totalspawns);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_WARNINGS, DB::TYPE_INTEGER, warnings);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_GPCI, DB::TYPE_STRING, gpci, 41);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_ACTIVE, DB::TYPE_INTEGER, active);

	if(!stmt_execute(stmt_AccountLoad))
	{
		err("[GetAccountData] executing statement 'stmt_AccountLoad'.");
		return 0;
	}

	stmt_fetch_row(stmt_AccountLoad);

	return 1;
}

// FIELD_ID_PLAYER_NAME
stock AccountExists(name[])
{
	new exists;

	stmt_bind_value(stmt_AccountExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountExists, 0, DB::TYPE_INTEGER, exists);

	if(stmt_execute(stmt_AccountExists))
	{
		stmt_fetch_row(stmt_AccountExists);

		if(exists)
			return 1;
	}

	return 0;
}

// FIELD_ID_PLAYER_PASS
stock GetAccountPassword(name[], password[MAX_PASSWORD_LEN])
{
	stmt_bind_result_field(stmt_AccountGetPassword, 0, DB::TYPE_STRING, password, MAX_PASSWORD_LEN);
	stmt_bind_value(stmt_AccountGetPassword, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetPassword))
		return 0;

	stmt_fetch_row(stmt_AccountGetPassword);

	return 1;
}

stock SetAccountPassword(const name[], password[MAX_PASSWORD_LEN])
{
	stmt_bind_value(stmt_AccountSetPassword, 0, DB::TYPE_STRING, password, MAX_PASSWORD_LEN);
	stmt_bind_value(stmt_AccountSetPassword, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetPassword);
}

// FIELD_ID_PLAYER_IPV4
stock GetAccountIP(const name[], &ip)
{
	stmt_bind_result_field(stmt_AccountGetIpv4, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AccountGetIpv4, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetIpv4))
		return 0;

	stmt_fetch_row(stmt_AccountGetIpv4);

	return 1;
}

stock SetAccountIP(const name[], ip)
{
	stmt_bind_value(stmt_AccountSetIpv4, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AccountSetIpv4, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetIpv4);
}

// FIELD_ID_PLAYER_ALIVE
stock GetAccountAliveState(const name[], &alivestate)
{
	stmt_bind_result_field(stmt_AccountGetAliveState, 0, DB::TYPE_INTEGER, alivestate);
	stmt_bind_value(stmt_AccountGetAliveState, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetAliveState))
		return 0;

	stmt_fetch_row(stmt_AccountGetAliveState);

	return 1;
}

stock SetAccountAliveState(const name[], alivestate)
{
	stmt_bind_value(stmt_AccountSetAliveState, 0, DB::TYPE_INTEGER, alivestate);
	stmt_bind_value(stmt_AccountSetAliveState, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetAliveState);
}

// FIELD_ID_PLAYER_REGDATE
stock GetAccountRegistrationDate(const name[], &timestamp)
{
	stmt_bind_result_field(stmt_AccountGetRegdate, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountGetRegdate, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetRegdate))
		return 0;

	stmt_fetch_row(stmt_AccountGetRegdate);

	return 1;
}

stock SetAccountRegistrationDate(const name[], timestamp)
{
	stmt_bind_value(stmt_AccountSetRegdate, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountSetRegdate, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetRegdate);
}

// FIELD_ID_PLAYER_LASTLOG
stock GetAccountLastLogin(const name[], &timestamp)
{
	stmt_bind_result_field(stmt_AccountGetLastLog, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountGetLastLog, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetLastLog))
		return 0;

	stmt_fetch_row(stmt_AccountGetLastLog);

	return 1;
}

stock SetAccountLastLogin(const name[], timestamp)
{
	stmt_bind_value(stmt_AccountSetLastLog, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountSetLastLog, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetLastLog);
}

// FIELD_ID_PLAYER_SPAWNTIME
stock GetAccountLastSpawnTimestamp(const name[], &timestamp)
{
	stmt_bind_result_field(stmt_AccountGetSpawnTime, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountGetSpawnTime, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetSpawnTime))
		return 0;

	stmt_fetch_row(stmt_AccountGetSpawnTime);

	return 1;
}

stock SetAccountLastSpawnTimestamp(const name[], timestamp)
{
	stmt_bind_value(stmt_AccountSetSpawnTime, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountSetSpawnTime, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetSpawnTime);
}

// FIELD_ID_PLAYER_TOTALSPAWNS
stock GetAccountTotalSpawns(const name[], &spawns)
{
	stmt_bind_result_field(stmt_AccountGetTotalSpawns, 0, DB::TYPE_INTEGER, spawns);
	stmt_bind_value(stmt_AccountGetTotalSpawns, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetTotalSpawns))
		return 0;

	stmt_fetch_row(stmt_AccountGetTotalSpawns);

	return 1;
}

stock SetAccountTotalSpawns(const name[], spawns)
{
	stmt_bind_value(stmt_AccountSetTotalSpawns, 0, DB::TYPE_INTEGER, spawns);
	stmt_bind_value(stmt_AccountSetTotalSpawns, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetTotalSpawns);
}

// FIELD_ID_PLAYER_WARNINGS
stock GetAccountWarnings(const name[], &warnings)
{
	stmt_bind_result_field(stmt_AccountGetWarnings, 0, DB::TYPE_INTEGER, warnings);
	stmt_bind_value(stmt_AccountGetWarnings, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetWarnings))
		return 0;

	stmt_fetch_row(stmt_AccountGetWarnings);

	return 1;
}

stock SetAccountWarnings(const name[], warnings)
{
	stmt_bind_value(stmt_AccountSetWarnings, 0, DB::TYPE_INTEGER, warnings);
	stmt_bind_value(stmt_AccountSetWarnings, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetWarnings);
}

// FIELD_ID_PLAYER_GPCI
stock GetAccountGPCI(const name[], gpci[MAX_GPCI_LEN])
{
	stmt_bind_result_field(stmt_AccountGetGpci, 0, DB::TYPE_STRING, gpci, MAX_GPCI_LEN);
	stmt_bind_value(stmt_AccountGetGpci, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetGpci))
		return 0;

	stmt_fetch_row(stmt_AccountGetGpci);

	return 1;
}

stock SetAccountGPCI(const name[], gpci[MAX_GPCI_LEN])
{
	stmt_bind_value(stmt_AccountSetGpci, 0, DB::TYPE_STRING, gpci, MAX_GPCI_LEN);
	stmt_bind_value(stmt_AccountSetGpci, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetGpci);
}

// FIELD_ID_PLAYER_ACTIVE
stock GetAccountActiveState(const name[], &active)
{
	stmt_bind_result_field(stmt_AccountGetActiveState, 0, DB::TYPE_INTEGER, active);
	stmt_bind_value(stmt_AccountGetActiveState, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetActiveState))
		return 0;

	stmt_fetch_row(stmt_AccountGetActiveState);

	return 1;
}

stock SetAccountActiveState(const name[], active)
{
	stmt_bind_value(stmt_AccountSetActiveState, 0, DB::TYPE_INTEGER, active);
	stmt_bind_value(stmt_AccountSetActiveState, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetActiveState);
}

// Pass, IP and gpci
stock GetAccountAliasData(const name[], pass[129], &ip, gpci[MAX_GPCI_LEN])
{
	stmt_bind_value(stmt_AccountGetAliasData, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountGetAliasData, 0, DB::TYPE_STRING, pass, MAX_PASSWORD_LEN);
	stmt_bind_result_field(stmt_AccountGetAliasData, 1, DB::TYPE_INTEGER, ip);
	stmt_bind_result_field(stmt_AccountGetAliasData, 2, DB::TYPE_STRING, gpci, MAX_GPCI_LEN);

	if(!stmt_execute(stmt_AccountGetAliasData))
		return 0;

	stmt_fetch_row(stmt_AccountGetAliasData);

	return 1;
}

// acc_IsNewPlayer
stock IsNewPlayer(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return acc_IsNewPlayer[playerid];
}

// acc_HasAccount
stock IsPlayerRegistered(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return acc_HasAccount[playerid];
}

// acc_LoggedIn
stock IsPlayerLoggedIn(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return acc_LoggedIn[playerid];
}

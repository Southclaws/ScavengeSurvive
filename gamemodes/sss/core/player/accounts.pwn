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


#include <YSI\y_hooks>


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
	acc_LoggedIn[MAX_PLAYERS];


forward OnPlayerLoadAccount(playerid);
forward OnPlayerLoadedAccount(playerid, loadresult);
forward OnPlayerRegister(playerid);
forward OnPlayerLogin(playerid);


hook OnGameModeInit()
{
	//
}

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/player/accounts.pwn");

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

	defer LoadAccountDelay(playerid);
}

timer LoadAccountDelay[1000](playerid)
{
	if(gServerInitialising || GetTickCountDifference(GetTickCount(), gServerInitialiseTick) < 5000)
	{
		defer LoadAccountDelay(playerid);
		return;
	}

	if(!IsPlayerConnected(playerid))
	{
		log("[LoadAccount] Player %d not connected any more.", playerid);
		return;
	}

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

	if(exists == 0)
	{
		log("[LoadAccount] %p (account does not exist)", playerid);
		return 0;
	}
/*
	if()
	{
		err("[LoadAccount] error.");
		return -1;
	}
*/
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

	log("[LoadAccount] %p (account exists, prompting login) Alive: %d Last login: %T", playerid, alive, lastlog);

	return 1;
}


/*==============================================================================

	Creates a new account for a player with the specified password hash.

==============================================================================*/


CreateAccount(playerid, password[])
{
	new
		name[MAX_PLAYER_NAME],
		serial[MAX_GPCI_LEN];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	gpci(playerid, serial, MAX_GPCI_LEN);

	log("[REGISTER] %p registered", playerid);

	// name, MAX_PLAYER_NAME
	// password, MAX_PASSWORD_LEN
	// GetPlayerIpAsInt(playerid
	// gettime()
	// gettime()
	// serial, MAX_GPCI_LEN

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

	// AccountSetIpv4, 0, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
	// AccountSetGpci, 0, DB::TYPE_STRING, serial);
	// AccountSetLastLog, 0, DB::TYPE_INTEGER, gettime());

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

			if(IsPlayerCombatLogging(playerid, lastattacker, lastweapon))
			{
				log("[LOGOUT] Player '%p' combat logged!", playerid);
				ChatMsgAll(YELLOW, " >  %p combat logged!", playerid);
				OnPlayerDeath(playerid, lastattacker, lastweapon);
			}
		}
	}

	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(IsItemTypeSafebox(itemtype))
	{
		dbg("accounts", 1, "[LOGOUT] Player is holding a box.");
		if(!IsContainerEmpty(GetItemExtraData(itemid)))
		{
			dbg("accounts", 1, "[LOGOUT] Player is holding an unempty box, dropping in world.");
			CreateItemInWorld(itemid, x + floatsin(-r, degrees), y + floatcos(-r, degrees), z - FLOOR_OFFSET);
			itemid = INVALID_ITEM_ID;
			itemtype = INVALID_ITEM_TYPE;
		}
	}

	if(IsItemTypeBag(itemtype))
	{
		dbg("accounts", 1, "[LOGOUT] Player is holding a bag.");
		if(!IsContainerEmpty(GetItemArrayDataAtCell(itemid, 1)))
		{
			if(IsValidItem(GetPlayerBagItem(playerid)))
			{
				dbg("accounts", 1, "[LOGOUT] Player is holding an unempty bag and is wearing one, dropping in world.");
				CreateItemInWorld(itemid, x + floatsin(-r, degrees), y + floatcos(-r, degrees), z - FLOOR_OFFSET);
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
			DestroyItem(GetInventorySlotItem(playerid, 0));

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

		dbg("accounts", 2, "[SavePlayerData] Saving character data");
		SavePlayerChar(playerid);
	}
	else
	{
		dbg("accounts", 2, "[SavePlayerData] Player is dead");
	}

	return 1;
}


/*==============================================================================

	Interface functions

==============================================================================*/


stock GetAccountData(name[], pass[], &ipv4, &alive, &regdate, &lastlog, &spawntime, &totalspawns, &warnings, gpci[], &active)
{
	// FIELD_ID_PLAYER_PASS, DB::TYPE_STRING, pass, MAX_PASSWORD_LEN);
	// FIELD_ID_PLAYER_IPV4, DB::TYPE_INTEGER, ipv4);
	// FIELD_ID_PLAYER_ALIVE, DB::TYPE_INTEGER, alive);
	// FIELD_ID_PLAYER_REGDATE, DB::TYPE_INTEGER, regdate);
	// FIELD_ID_PLAYER_LASTLOG, DB::TYPE_INTEGER, lastlog);
	// FIELD_ID_PLAYER_SPAWNTIME, DB::TYPE_INTEGER, spawntime);
	// FIELD_ID_PLAYER_TOTALSPAWNS, DB::TYPE_INTEGER, totalspawns);
	// FIELD_ID_PLAYER_WARNINGS, DB::TYPE_INTEGER, warnings);
	// FIELD_ID_PLAYER_GPCI, DB::TYPE_STRING, gpci, 41);
	// FIELD_ID_PLAYER_ACTIVE, DB::TYPE_INTEGER, active);

	return 1;
}

// FIELD_ID_PLAYER_NAME
stock AccountExists(name[])
{
	return 0;
}

// FIELD_ID_PLAYER_PASS
stock GetAccountPassword(name[], password[MAX_PASSWORD_LEN])
{
	return 0;
}

stock SetAccountPassword(name[], password[MAX_PASSWORD_LEN])
{
	return 0;
}

// FIELD_ID_PLAYER_IPV4
stock GetAccountIP(name[], &ip)
{
	return 0;
}

stock SetAccountIP(name[], ip)
{
	return 0;
}

// FIELD_ID_PLAYER_ALIVE
stock GetAccountAliveState(name[], &alivestate)
{
	return 0;
}

stock SetAccountAliveState(name[], alivestate)
{
	return 0;
}

// FIELD_ID_PLAYER_REGDATE
stock GetAccountRegistrationDate(name[], &timestamp)
{
	return 0;
}

stock SetAccountRegistrationDate(name[], timestamp)
{
	return 0;
}

// FIELD_ID_PLAYER_LASTLOG
stock GetAccountLastLogin(name[], &timestamp)
{
	return 0;
}

stock SetAccountLastLogin(name[], timestamp)
{
	return 0;
}

// FIELD_ID_PLAYER_SPAWNTIME
stock GetAccountLastSpawnTimestamp(name[], &timestamp)
{
	return 0;
}

stock SetAccountLastSpawnTimestamp(name[], timestamp)
{
	return 0;
}

// FIELD_ID_PLAYER_TOTALSPAWNS
stock GetAccountTotalSpawns(name[], &spawns)
{
	return 0;
}

stock SetAccountTotalSpawns(name[], spawns)
{
	return 0;
}

// FIELD_ID_PLAYER_WARNINGS
stock GetAccountWarnings(name[], &warnings)
{
	return 0;
}

stock SetAccountWarnings(name[], warnings)
{
	return 0;
}

// FIELD_ID_PLAYER_GPCI
stock GetAccountGPCI(name[], gpci[MAX_GPCI_LEN])
{
	return 0;
}

stock SetAccountGPCI(name[], gpci[MAX_GPCI_LEN])
{
	return 0;
}

// FIELD_ID_PLAYER_ACTIVE
stock GetAccountActiveState(name[], &active)
{
	return 0;
}

stock SetAccountActiveState(name[], active)
{
	return 0;
}

// Pass, IP and gpci
stock GetAccountAliasData(name[], pass[129], &ip, gpci[MAX_GPCI_LEN])
{
	return 0;
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

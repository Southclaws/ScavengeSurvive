/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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


static
	acc_LoginAttempts[MAX_PLAYERS],
	acc_IsNewPlayer[MAX_PLAYERS],
	acc_HasAccount[MAX_PLAYERS],
	acc_LoggedIn[MAX_PLAYERS];


forward OnPlayerLoadAccount(playerid);
forward OnPlayerLoadedAccount(playerid, loadresult);
forward OnPlayerRegister(playerid);
forward OnPlayerLogin(playerid);

forward OnLoadAccount(playerid, loadresult);


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
		return;

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

	AccountIO_Load(playerid, "OnLoadAccount");

	return;
}

public OnLoadAccount(playerid, loadresult)
{
	if(loadresult == ACCOUNT_LOAD_RESULT_NO_EXIST) // Account does not exist
		acc_HasAccount[playerid] = false;

	else
		acc_HasAccount[playerid] = true;

	acc_IsNewPlayer[playerid] = false;

	CallLocalFunction("OnPlayerLoadedAccount", "dd", playerid, loadresult);
}


/*==============================================================================

	Creates a new account for a player with the specified password hash.

==============================================================================*/


DisplayRegisterPrompt(playerid)
{
	new str[150];
	format(str, 150, ls(playerid, "ACCREGIBODY"), playerid);

	log("[DisplayRegisterPrompt] %p is registering", playerid);

	Dialog_Show(playerid, RegisterPrompt, DIALOG_STYLE_PASSWORD, ls(playerid, "ACCREGITITL"), str, "Accept", "Leave");

	return 1;
}

Dialog:RegisterPrompt(playerid, response, listitem, inputtext[])
{
	log("[RegisterPrompt] %p Response: %d", playerid, response);

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

		if(!CreateAccount(playerid, buffer))
			ShowWelcomeMessage(playerid, 10);

		else
			KickPlayer(playerid, "Account creation failed");
	}
	else
	{
		ChatMsgAll(GREY, " >  %p left the server without registering.", playerid);
		Kick(playerid);
	}

	return 0;
}

DisplayLoginPrompt(playerid, badpass = 0)
{
	new str[128];

	if(badpass)
		format(str, 128, ls(playerid, "ACCLOGWROPW"), acc_LoginAttempts[playerid]);

	else
		format(str, 128, ls(playerid, "ACCLOGIBODY"), playerid);

	log("[DisplayLoginPrompt] %p is logging in", playerid);

	Dialog_Show(playerid, LoginPrompt, DIALOG_STYLE_PASSWORD, ls(playerid, "ACCLOGITITL"), str, "Accept", "Leave");

	return 1;
}

Dialog:LoginPrompt(playerid, response, listitem, inputtext[])
{
	log("[LoginPrompt] %p Response: %d", playerid, response);

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

			return 1;
		}
	}
	else
	{
		ChatMsgAll(GREY, " >  %p left the server without logging in.", playerid);
		Kick(playerid);
	}

	return 0;
}


/*==============================================================================

	Loads a player's account, updates some data and spawns them.

==============================================================================*/


CreateAccount(playerid, pass[])
{
	new
		name[MAX_PLAYER_NAME],
		ipv4[16],
		regdate,
		lastlog,
		hash[MAX_GPCI_LEN],
		ret;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	regdate = lastlog = gettime();
	GetPlayerIp(playerid, ipv4, 16);
	gpci(playerid, hash, MAX_GPCI_LEN);

	ret = AccountIO_Create(name, pass, ipv4, regdate, lastlog, hash);
	if(ret != 0)
		return ret;

	acc_IsNewPlayer[playerid] = true;
	acc_HasAccount[playerid] = true;
	SetPlayerToolTips(playerid, true);

	CallLocalFunction("OnPlayerRegister", "d", playerid);
	Login(playerid);

	return 0;
}

Login(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		hash[MAX_GPCI_LEN],
		ipv4[16];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	gpci(playerid, hash, MAX_GPCI_LEN);
	GetPlayerIp(playerid, ipv4, 16);

	log("[LOGIN] %p logged in, alive: %d", playerid, IsPlayerAlive(playerid));

	SetAccountIP(name, ipv4);
	SetAccountGPCI(name, hash);
	SetAccountLastLogin(name, gettime());

	if(GetPlayerAdminLevel(playerid) > 0)
	{
		new
			reports = GetUnreadReports();

		ChatMsg(playerid, BLUE, " >  Your admin level: %d", GetPlayerAdminLevel(playerid));

		if(reports > 0)
			ChatMsg(playerid, YELLOW, " >  %d unread reports, type "C_BLUE"/reports "C_YELLOW"to view.", reports);
	}

	acc_LoggedIn[playerid] = true;
	acc_LoginAttempts[playerid] = 0;

	SetPlayerRadioFrequency(playerid, 107.0);
	SetPlayerBrightness(playerid, 255);

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


stock GetAccountData(name[], pass[], ipv4[], &alive, &regdate, &lastlog, &spawntime, &totalspawns, &warnings, hash[], &active, &banned, &admin, &whitelist, &reported)
{
	return AccountIO_Get(name, pass, ipv4, alive, regdate, lastlog, spawntime, totalspawns, warnings, hash, active, banned, admin, whitelist, reported);
}

// FIELD_PLAYER_NAME
stock AccountExists(name[])
{
	return AccountIO_Exists(name);
}

// FIELD_PLAYER_PASS
stock GetAccountPassword(name[], password[MAX_PASSWORD_LEN])
{
	return AccountIO_GetField(name, FIELD_PLAYER_PASS, password, MAX_PASSWORD_LEN);
}

stock SetAccountPassword(name[], password[MAX_PASSWORD_LEN])
{
	return AccountIO_SetField(name, FIELD_PLAYER_PASS, password);
}

// FIELD_PLAYER_IPV4
stock GetAccountIP(name[], ipv4[16])
{
	return AccountIO_GetField(name, FIELD_PLAYER_IPV4, ipv4, 16);
}

stock SetAccountIP(name[], ipv4[16])
{
	return AccountIO_SetField(name, FIELD_PLAYER_IPV4, ipv4);
}

// FIELD_PLAYER_ALIVE
stock GetAccountAliveState(name[], &alivestate)
{
	new
		str_alivestate[12],
		ret;

	ret = AccountIO_GetField(name, FIELD_PLAYER_ALIVE, str_alivestate, 12);
	alivestate = strval(str_alivestate);

	return ret;
}

stock SetAccountAliveState(name[], alivestate)
{
	new ret;

	if(alivestate)
		ret = AccountIO_SetField(name, FIELD_PLAYER_ALIVE, "1");
	else
		ret = AccountIO_SetField(name, FIELD_PLAYER_ALIVE, "0");

	return ret;
}

// FIELD_PLAYER_REGDATE
stock GetAccountRegistrationDate(name[], &timestamp)
{
	new
		str_timestamp[12],
		ret;

	ret = AccountIO_GetField(name, FIELD_PLAYER_REGDATE, str_timestamp, 12);
	timestamp = strval(str_timestamp);

	return ret;
}

stock SetAccountRegistrationDate(name[], timestamp)
{
	return AccountIO_SetField(name, FIELD_PLAYER_REGDATE, sprintf("%d", timestamp));
}

// FIELD_PLAYER_LASTLOG
stock GetAccountLastLogin(name[], &timestamp)
{
	new
		str_timestamp[12],
		ret;

	ret = AccountIO_GetField(name, FIELD_PLAYER_LASTLOG, str_timestamp, 12);
	timestamp = strval(str_timestamp);

	return ret;
}

stock SetAccountLastLogin(name[], timestamp)
{
	return AccountIO_SetField(name, FIELD_PLAYER_LASTLOG, sprintf("%d", timestamp));
}

// FIELD_PLAYER_SPAWNTIME
stock GetAccountLastSpawnTimestamp(name[], &timestamp)
{
	new
		str_timestamp[12],
		ret;

	ret = AccountIO_GetField(name, FIELD_PLAYER_SPAWNTIME, str_timestamp, 12);
	timestamp = strval(str_timestamp);

	return ret;
}

stock SetAccountLastSpawnTimestamp(name[], timestamp)
{
	return AccountIO_SetField(name, FIELD_PLAYER_SPAWNTIME, sprintf("%d", timestamp));
}

// FIELD_PLAYER_TOTALSPAWNS
stock GetAccountTotalSpawns(name[], &spawns)
{
	new
		str_spawns[12],
		ret;

	ret = AccountIO_GetField(name, FIELD_PLAYER_TOTALSPAWNS, str_spawns, 12);
	spawns = strval(str_spawns);

	return ret;
}

stock SetAccountTotalSpawns(name[], spawns)
{
	return AccountIO_SetField(name, FIELD_PLAYER_TOTALSPAWNS, sprintf("%d", spawns));
}

// FIELD_PLAYER_WARNINGS
stock GetAccountWarnings(name[], &warnings)
{
	new
		str_warnings[12],
		ret;

	ret = AccountIO_GetField(name, FIELD_PLAYER_WARNINGS, str_warnings, 12);
	warnings = strval(str_spawns);

	return ret;
}

stock SetAccountWarnings(name[], warnings)
{
	return AccountIO_SetField(name, FIELD_PLAYER_WARNINGS, sprintf("%d", warnings));
}

// FIELD_PLAYER_GPCI
stock GetAccountGPCI(name[], hash[MAX_GPCI_LEN])
{
	return AccountIO_GetField(name, FIELD_PLAYER_GPCI, hash, MAX_GPCI_LEN);
}

stock SetAccountGPCI(name[], hash[MAX_GPCI_LEN])
{
	return AccountIO_SetField(name, FIELD_PLAYER_GPCI, hash);
}

// FIELD_PLAYER_ACTIVE
stock GetAccountActiveState(name[], &activestate)
{
	new
		str_activestate[12],
		ret;

	ret = AccountIO_GetField(name, FIELD_PLAYER_ACTIVE, str_activestate, 12);
	activestate = strval(str_activestate);

	return ret;
}

stock SetAccountActiveState(name[], activestate)
{
	new ret;

	if(activestate)
		ret = AccountIO_SetField(name, FIELD_PLAYER_ACTIVE, "1");
	else
		ret = AccountIO_SetField(name, FIELD_PLAYER_ACTIVE, "0");

	return ret;
}

// FIELD_PLAYER_BANNED
stock GetAccountBannedState(name[], &bannedstate)
{
	new
		str_bannedstate[12],
		ret;

	ret = AccountIO_GetField(name, FIELD_PLAYER_BANNED, str_bannedstate);
	bannedstate = strval(str_bannedstate);

	return ret;
}

stock SetAccountBannedState(name[], bannedstate)
{
	new ret;

	if(bannedstate)
		ret = AccountIO_SetField(name, FIELD_PLAYER_BANNED, "1");
	else
		ret = AccountIO_SetField(name, FIELD_PLAYER_BANNED, "0");

	return ret;
}

// FIELD_PLAYER_ADMIN
stock GetAccountAdminLevel(name[], &level)
{
	new
		str_level[12],
		ret;

	ret = AccountIO_GetField(name, FIELD_PLAYER_ADMIN, str_level);
	level = strval(str_level);

	return ret;
}

stock SetAccountAdminLevel(name[], level)
{
	new ret = AccountIO_UpdateAdminList();
	if(ret)
		err("AccountIO_UpdateAdminList returned %d", ret);

	return AccountIO_SetField(name, FIELD_PLAYER_ADMIN, sprintf("%d", level));
}

// FIELD_PLAYER_WHITELIST
stock GetAccountWhitelisted(name[], &whitelisted)
{
	new
		str_whitelisted[12],
		ret;

	ret = AccountIO_GetField(name, FIELD_PLAYER_WHITELIST, str_whitelisted);
	whitelisted = strval(str_whitelisted);

	return ret;
}

stock SetAccountWhitelisted(name[], whitelisted)
{
	new ret;

	if(whitelisted)
		ret = AccountIO_SetField(name, FIELD_PLAYER_WHITELIST, "1");
	else
		ret = AccountIO_SetField(name, FIELD_PLAYER_WHITELIST, "0");

	return ret;
}

// FIELD_PLAYER_REPORTED
stock GetAccountReported(name[], &reported)
{
	new
		str_reported[12],
		ret;

	ret = AccountIO_GetField(name, FIELD_PLAYER_REPORTED, str_reported);
	reported = strval(str_reported);

	return ret;
}

stock SetAccountReported(name[], reported)
{
	new ret;

	if(reported)
		ret = AccountIO_SetField(name, FIELD_PLAYER_WHITELIST, "1");
	else
		ret = AccountIO_SetField(name, FIELD_PLAYER_WHITELIST, "0");

	return ret;
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

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


#define REDIS_DOMAIN_ACCOUNTS		"account"
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

#define ACCOUNT_LOAD_RESULT_EXIST		(0) // Account does exist, prompt login
#define ACCOUNT_LOAD_RESULT_EXIST_AL	(1) // Account does exist, auto login
#define ACCOUNT_LOAD_RESULT_EXIST_WL	(2) // Account does exist, but not in whitelist
#define ACCOUNT_LOAD_RESULT_EXIST_DA	(3) // Account does exist, but is disabled
#define ACCOUNT_LOAD_RESULT_NO_EXIST	(4) // Account does not exist
#define ACCOUNT_LOAD_RESULT_ERROR		(5) // LoadAccount aborted, kick player.


forward OnAccountResponse(data[]);


hook OnScriptInit()
{
	Redis_BindMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_ACCOUNTS".response", "OnAccountResponse");
}


stock AccountIO_Create(name[], pass[], ipv4, regdate, lastlog, gpci[])
{
	if(isnull(name))
	{
		err("name is null");
		return 1;
	}

	new
		key[MAX_PLAYER_NAME + 32],
		ret = 0;

	format(key, sizeof(key), REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_ACCOUNTS".%s", name);

	ret += Redis_SetHashValue(gRedis, key, FIELD_PLAYER_PASS, pass);
	ret += Redis_SetHashValue(gRedis, key, FIELD_PLAYER_IPV4, sprintf("%d", ipv4));
	ret += Redis_SetHashValue(gRedis, key, FIELD_PLAYER_ALIVE, "1");
	ret += Redis_SetHashValue(gRedis, key, FIELD_PLAYER_REGDATE, sprintf("%d", regdate));
	ret += Redis_SetHashValue(gRedis, key, FIELD_PLAYER_LASTLOG, sprintf("%d", lastlog));
	ret += Redis_SetHashValue(gRedis, key, FIELD_PLAYER_GPCI, gpci);

	return ret;
}

stock AccountIO_Load(playerid, callback[])
{
	if(!IsPlayerConnected(playerid))
	{
		err("player not connected");
		return;
	}

	if(isnull(callback))
	{
		err("callback is null");
		return;
	}

	new
		name[MAX_PLAYER_NAME],
		key[MAX_PLAYER_NAME + 32];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	format(key, sizeof(key), REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_ACCOUNTS".%s", name);

	if(!Redis_Exists(gRedis, key))
	{
		CallLocalFunction(callback, "dd", playerid, ACCOUNT_LOAD_RESULT_NO_EXIST);
		return;
	}

	new
		ret,
		passhash[MAX_PASSWORD_LEN],
		alive_str[2],
		regdate_str[12],
		lastlog_str[12],
		spawntime_str[12],
		spawns_str[12],
		warnings_str[12],
		active_str[12],
		gpci_str[MAX_GPCI_LEN],
		bool:alive,
		regdate,
		lastlog,
		spawntime,
		spawns,
		warnings;

	ret += Redis_GetHashValue(gRedis, key, FIELD_PLAYER_PASS, passhash);
	ret += Redis_GetHashValue(gRedis, key, FIELD_PLAYER_ALIVE, alive_str);
	ret += Redis_GetHashValue(gRedis, key, FIELD_PLAYER_REGDATE, regdate_str);
	ret += Redis_GetHashValue(gRedis, key, FIELD_PLAYER_LASTLOG, lastlog_str);
	ret += Redis_GetHashValue(gRedis, key, FIELD_PLAYER_SPAWNTIME, spawntime_str);
	ret += Redis_GetHashValue(gRedis, key, FIELD_PLAYER_TOTALSPAWNS, spawns_str);
	ret += Redis_GetHashValue(gRedis, key, FIELD_PLAYER_WARNINGS, warnings_str);
	ret += Redis_GetHashValue(gRedis, key, FIELD_PLAYER_GPCI, gpci_str);
	ret += Redis_GetHashValue(gRedis, key, FIELD_PLAYER_ACTIVE, active_str);

	alive = !!strval(alive_str);
	regdate = strval(regdate_str);
	lastlog = strval(lastlog_str);
	spawntime = strval(spawntime_str);
	spawns = strval(spawns_str);
	warnings = strval(warnings_str);

	if(active_str[0] == '0')
	{
		log("[LoadAccount] %p (account inactive) Last login: %T", playerid, lastlog);
		CallLocalFunction(callback, "dd", playerid, ACCOUNT_LOAD_RESULT_EXIST_DA);
		return;
	}

	if(IsWhitelistActive())
	{
		ChatMsgLang(playerid, YELLOW, "WHITELISTAC");

		if(!IsPlayerInWhitelist(playerid))
		{
			ChatMsgLang(playerid, YELLOW, "WHITELISTNO");
			log("[LoadAccount] %p (account not whitelisted) Alive: %d Last login: %T", playerid, alive, lastlog);
			CallLocalFunction(callback, "dd", playerid, ACCOUNT_LOAD_RESULT_EXIST_WL);
			return;
		}
	}

	SetPlayerAliveState(playerid, alive);
	SetPlayerPassHash(playerid, passhash);
	SetPlayerRegTimestamp(playerid, regdate);
	SetPlayerLastLogin(playerid, lastlog);
	SetPlayerCreationTimestamp(playerid, spawntime);
	SetPlayerTotalSpawns(playerid, spawns);
	SetPlayerWarnings(playerid, warnings);

	log("[LoadAccount] %p (account exists, prompting login) Alive: %d Last login: %T", playerid, alive, lastlog);

	CallLocalFunction(callback, "dd", playerid, ACCOUNT_LOAD_RESULT_EXIST);
	return;
}

stock AccountIO_UpdateCache(name[], callback[])
{
	return Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_ACCOUNTS".response", sprintf("AccountIO_UpdateCache %s %s", name, callback));
}

stock AccountIO_UpdateCacheAll(callback[])
{
	return Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_ACCOUNTS".response", sprintf("AccountIO_UpdateCacheAll %s", callback));
}

public OnAccountResponse(data[])
{
	new
		op[32],
		args[256];

	if(sscanf(data, "s[32]s[256]", op, args))
	{
		err("OnAccountResponse sscanf failed on '%s'", data);
		return 1;
	}

	if(!strcmp(op, "AccountIO_UpdateCache"))
	{
		if(strcmp(args, "success"))
		{
			err("AccountIO_UpdateCache failed: '%s'", args);
		}
	}

	if(!strcmp(op, "AccountIO_UpdateCacheAll"))
	{
		if(strcmp(args, "success"))
		{
			err("AccountIO_UpdateCacheAll failed: '%s'", args);
		}
	}

	return 0;
}
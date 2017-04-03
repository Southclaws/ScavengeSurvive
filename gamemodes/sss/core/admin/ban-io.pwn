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


#define REDIS_DOMAIN_BANS			"banned"
#define FIELD_BANS_NAME				"name"		// 00
#define FIELD_BANS_IPV4				"ipv4"		// 01
#define FIELD_BANS_DATE				"date"		// 02
#define FIELD_BANS_REASON			"reason"	// 03
#define FIELD_BANS_BY				"by"		// 04
#define FIELD_BANS_DURATION			"duration"	// 05
#define FIELD_BANS_ACTIVE			"active"	// 06


forward OnBanResponse(data[]);


hook OnScriptInit()
{
	Redis_BindMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".response", "OnBanResponse");
}

BanIO_Create(name[], ipv4, timestamp, reason[], by[], duration)
{
	if(isnull(name))
	{
		err("name is null");
		return 1;
	}

	new
		key[MAX_PLAYER_NAME + 32],
		ret = 0;

	format(key, sizeof(key), REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".%s", name);

	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_NAME, name);
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_IPV4, sprintf("%d", ipv4));
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_DATE, sprintf("%d", timestamp));
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_REASON, reason);
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_BY, by);
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_DURATION, sprintf("%d", duration));
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_ACTIVE, "1");

	return ret;
}

BanIO_UpdateReasonDuration(name[], reason[], duration)
{
	if(isnull(name))
	{
		err("name is null");
		return 1;
	}

	new
		key[MAX_PLAYER_NAME + 32],
		ret = 0;

	format(key, sizeof(key), REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".%s", name);

	if(!Redis_Exists(gRedis, key))
		return 1;

	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_REASON, reason);
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_DURATION, sprintf("%d", duration));

	return ret;
}

BanIO_UpdateIpv4(name[], ipv4)
{
	if(isnull(name))
	{
		err("name is null");
		return 1;
	}

	new
		key[MAX_PLAYER_NAME + 32],
		ret = 0;

	format(key, sizeof(key), REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".%s", name);

	if(!Redis_Exists(gRedis, key))
		return 1;

	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_IPV4, sprintf("%d", ipv4));

	return ret;
}

BanIO_Remove(name[])
{
	if(isnull(name))
	{
		err("name is null");
		return 1;
	}

	new
		key[MAX_PLAYER_NAME + 32],
		ret = 0;

	format(key, sizeof(key), REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".%s", name);

	if(!Redis_Exists(gRedis, key))
		return 1;

	// ret = Redis_Delete(key);
	return ret;
}

BanIO_ShowBanInfo(playerid, callback[])
{
	if(!IsPlayerConnected(playerid))
	{
		err("player not connected");
		return 1;
	}

	new
		name[MAX_PLAYER_NAME],
		key[MAX_PLAYER_NAME + 32];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	format(key, sizeof(key), REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".%s", name);

	if(!Redis_Exists(gRedis, key))
		return 1;

	return Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".response", sprintf("BanIO_ShowBanInfo %s %d %s", name, playerid, callback));
}

public OnBanResponse(data[])
{
	new
		op[32],
		args[256];

	if(sscanf(data, "s[32]s[256]", op, args))
	{
		err("OnBanResponse sscanf failed on '%s'", data);
		return Y_HOOKS_CONTINUE_RETURN_1;
	}

	if(!strcmp(op, "BanIO_ShowBanInfo"))
	{
		if(strcmp(args, "success"))
		{
			err("BanIO_ShowBanInfo failed: '%s'", args);
			return Y_HOOKS_CONTINUE_RETURN_1;
		}

		new
			callback[32],
			playerid,
			bool:banned,
			timestamp,
			reason[MAX_BAN_REASON],
			duration;

		if(sscanf(args, "s[32]ddds[128]d", callback, playerid, banned, timestamp, reason, duration))
		{
			err("BanIO_ShowBanInfo sscanf failed with '%s'", args);
			return Y_HOOKS_CONTINUE_RETURN_1;
		}

		return CallLocalFunction(callback, "dddsd", playerid, banned, timestamp, reason, duration);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

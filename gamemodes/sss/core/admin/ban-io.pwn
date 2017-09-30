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

BanIO_Create(name[], ipv4[], timestamp, reason[], by[], duration)
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
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_IPV4, ipv4);
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_DATE, sprintf("%d", timestamp));
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_REASON, reason);
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_BY, by);
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_DURATION, sprintf("%d", duration));
	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_ACTIVE, "1");
	Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".request", sprintf("BanIO_Create %s", name));

	if(SetAccountBannedState(name, true))
	{
		err("failed to update account banned state");
	}

	return ret;
}

BanIO_UpdateReason(name[], reason[])
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
	Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".request", sprintf("BanIO_Update %s", name));

	return ret;
}

BanIO_UpdateDuration(name[], duration)
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

	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_DURATION, sprintf("%d", duration));
	Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".request", sprintf("BanIO_Update %s", name));

	return ret;
}

BanIO_UpdateIpv4(name[], ipv4[])
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

	ret += Redis_SetHashValue(gRedis, key, FIELD_BANS_IPV4, ipv4);
	Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".request", sprintf("BanIO_Update %s", name));

	return ret;
}

BanIO_Remove(name[])
{
	if(isnull(name))
	{
		err("name is null");
		return 1;
	}

	if(SetAccountBannedState(name, false))
	{
		err("failed to update account banned state");
	}

	return Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".response", sprintf("BanIO_Remove %s", name));
}

BanIO_GetList(playerid, limit, offset, callback[])
{
	return Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".response", sprintf("BanIO_GetList %d %d %d %s", playerid, limit, offset, callback));
}

BanIO_GetInfo(playerid, name[], callback[])
{
	if(!IsPlayerConnected(playerid))
	{
		err("player not connected");
		return 1;
	}

	new key[MAX_PLAYER_NAME + 32];

	format(key, sizeof(key), REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".%s", name);

	if(!Redis_Exists(gRedis, key))
		return 1;

	return Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BANS".response", sprintf("BanIO_GetInfo %d %s %s", playerid, name, callback));
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

	if(!strcmp(op, "BanIO_GetList"))
	{
		new
			callback[32],
			playerid,
			totalbans,
			listitems,
			index,
			list[32 * (MAX_PLAYER_NAME + 1)];

		if(sscanf(args, "s[32]dddds[832]", callback, playerid, totalbans, listitems, index, list))
		{
			err("BanIO_GetList sscanf failed with '%s'", args);
			return Y_HOOKS_CONTINUE_RETURN_1;
		}

		return CallLocalFunction(callback, "dddds", playerid, totalbans, listitems, index, list);
	}
	else if(!strcmp(op, "BanIO_GetInfo"))
	{
		if(strcmp(args, "success"))
		{
			err("BanIO_GetInfo failed: '%s'", args);
			return Y_HOOKS_CONTINUE_RETURN_1;
		}

		new
			callback[32],
			playerid,
			name[MAX_PLAYER_NAME],
			timestamp,
			reason[MAX_BAN_REASON],
			bannedby[MAX_PLAYER_NAME],
			duration;

		if(sscanf(args, "s[32]ds[24]ds[128]s[24]d", callback, playerid, name, timestamp, reason, bannedby, duration))
		{
			err("BanIO_GetInfo sscanf failed with '%s'", args);
			return Y_HOOKS_CONTINUE_RETURN_1;
		}

		return CallLocalFunction(callback, "dsddsd", playerid, name, timestamp, reason, bannedby, duration);
	}
	
	return Y_HOOKS_CONTINUE_RETURN_0;
}

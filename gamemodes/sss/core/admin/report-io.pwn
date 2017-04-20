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


#define REDIS_DOMAIN_REPORTS		"report"
#define FIELD_REPORTS_NAME			"name"
#define FIELD_REPORTS_REASON		"reason"
#define FIELD_REPORTS_DATE			"date"
#define FIELD_REPORTS_READ			"read"
#define FIELD_REPORTS_TYPE			"type"
#define FIELD_REPORTS_POSX			"posx"
#define FIELD_REPORTS_POSY			"posy"
#define FIELD_REPORTS_POSZ			"posz"
#define FIELD_REPORTS_POSW			"world"
#define FIELD_REPORTS_POSI			"interior"
#define FIELD_REPORTS_INFO			"info"
#define FIELD_REPORTS_BY			"by"
#define FIELD_REPORTS_ACTIVE		"active"


forward OnReportResponse(data[]);


hook OnScriptInit()
{
	Redis_BindMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".response", "OnReportResponse");
}

stock ReportIO_Create(name[], reason[], timestamp, type[], Float:posx, Float:posy, Float:posz, world, interior, info[], by[])
{
	if(isnull(name))
	{
		err("name is null");
		return 1;
	}

	if(isnull(reason))
	{
		err("reason is null");
		return 1;
	}

	new
		id[GEID_LEN],
		key[MAX_PLAYER_NAME + 32],
		ret = 0;

	mkgeid(random(2147483647), id);

	format(key, sizeof(key), REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".%s", id);

	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_NAME, name);
	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_REASON, reason);
	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_DATE, sprintf("%d", timestamp));
	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_READ, "0");
	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_TYPE, type);
	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_POSX, sprintf("%f", posx));
	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_POSY, sprintf("%f", posy));
	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_POSZ, sprintf("%f", posz));
	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_POSW, sprintf("%d", world));
	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_POSI, sprintf("%d", interior));
	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_INFO, info);
	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_BY, by);
	ret += Redis_SetHashValue(gRedis, key, FIELD_REPORTS_ACTIVE, "1");
	Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".request", sprintf("ReportIO_Create %s", id));

	SetAccountReported(name, 1);

	return ret;
}

stock ReportIO_Remove(id[])
{
	if(isnull(id))
	{
		err("id is null");
		return 1;
	}

	return Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".response", sprintf("ReportIO_Remove %s", id));
}

stock ReportIO_RemoveOfName(name[])
{
	if(isnull(name))
	{
		err("name is null");
		return 1;
	}

	return Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".response", sprintf("ReportIO_RemoveOfName %s", name));
}

stock ReportIO_RemoveRead()
{
	return Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".response", "ReportIO_RemoveRead");
}

stock ReportIO_SetRead(id[], read)
{
	if(isnull(id))
	{
		err("id is null");
		return 1;
	}

	new key[MAX_PLAYER_NAME + 32];

	format(key, sizeof(key), REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".%s", id);

	if(!Redis_Exists(gRedis, key))
	{
		err("report key '%s' does not exist", key);
		return 1;
	}

	return Redis_SetHashValue(gRedis, key, FIELD_REPORTS_READ, read ? ("1") : ("0"));
}

stock ReportIO_GetUnread(&unread)
{
	return Redis_GetInt(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".__unread", unread);
}

stock ReportIO_GetList(playerid, limit, offset, callback[])
{
	if(isnull(callback))
	{
		err("callback is null");
		return 1;
	}
	return Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".response", sprintf("ReportIO_GetList %d %d %d %s", playerid, limit, offset, callback));
}

stock ReportIO_GetInfo(playerid, id[], callback[])
{
	if(!IsPlayerConnected(playerid))
	{
		err("player not connected");
		return 1;
	}

	new key[MAX_PLAYER_NAME + 32];

	format(key, sizeof(key), REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".%s", id);

	if(!Redis_Exists(gRedis, key))
	{
		err("report key '%s' does not exist", key);
		return 1;
	}

	return Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".response", sprintf("ReportIO_GetInfo %d %s %s", playerid, id, callback));
}

public OnReportResponse(data[])
{
	new
		op[32],
		args[256];

	if(sscanf(data, "s[32]s[256]", op, args))
	{
		err("OnReportResponse sscanf failed on '%s'", data);
		return Y_HOOKS_CONTINUE_RETURN_1;
	}

	if(!strcmp(op, "ReportIO_GetList"))
	{
		new
			callback[32],
			playerid,
			totalreports,
			listitems,
			index,
			dialog_string_key[64],
			idlist_string_key[64];

		if(sscanf(args, "s[32]dddds[64]s[64]", callback, playerid, totalreports, listitems, index, dialog_string_key, idlist_string_key))
		{
			err("ReportIO_GetList sscanf failed with '%s'", args);
			return Y_HOOKS_CONTINUE_RETURN_1;
		}

		return CallLocalFunction(callback, "ddddss", playerid, totalreports, listitems, index, dialog_string_key, idlist_string_key);
	}
	else if(!strcmp(op, "ReportIO_GetInfo"))
	{
		if(strcmp(args, "success"))
		{
			err("ReportIO_GetInfo failed: '%s'", args);
			return Y_HOOKS_CONTINUE_RETURN_1;
		}

		new
			callback[32],
			playerid,
			name[MAX_PLAYER_NAME],
			reason[MAX_REPORT_REASON_LENGTH],
			date,
			read,
			type[MAX_REPORT_TYPE_LENGTH]
			Float:posx,
			Float:posy,
			Float:posz,
			posw,
			posi,
			info[MAX_REPORT_INFO_LENGTH],
			by[MAX_PLAYER_NAME],
			active;

		if(sscanf(args, "p<\n>s[32]ds[24]s[128]dds[10]fffdds[128]s[24]d", callback, playerid, name, reason, date, read, type, posx, posy, posz, posw, posi, info, by, active))
		{
			err("ReportIO_GetInfo sscanf failed with '%s'", args);
			return Y_HOOKS_CONTINUE_RETURN_1;
		}

		return CallLocalFunction(callback, "dsddsd", playerid, name, timestamp, reason, bannedby, duration);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
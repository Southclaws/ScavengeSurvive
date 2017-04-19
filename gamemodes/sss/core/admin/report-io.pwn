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
		key[MAX_PLAYER_NAME + 32],
		ret = 0;

	format(key, sizeof(key), REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".%s", name);

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
	Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_REPORTS".request", sprintf("BanIO_Create %s", name));

	return ret;
}
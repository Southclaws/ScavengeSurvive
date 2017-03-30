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

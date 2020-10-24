/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static
DBStatement:	stmt_AliasesFromIp,
DBStatement:	stmt_AliasesFromPass,
DBStatement:	stmt_AliasesFromHash,
DBStatement:	stmt_AliasesFromAll;


hook OnGameModeInit()
{
	stmt_AliasesFromIp = db_prepare(gAccounts, "SELECT "FIELD_PLAYER_NAME" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_IPV4"=? AND "FIELD_PLAYER_ACTIVE"=1 AND "FIELD_PLAYER_NAME"!=? COLLATE NOCASE");
	stmt_AliasesFromPass = db_prepare(gAccounts, "SELECT "FIELD_PLAYER_NAME" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_PASS"=? AND "FIELD_PLAYER_ACTIVE"=1 AND "FIELD_PLAYER_NAME"!=? COLLATE NOCASE");
	stmt_AliasesFromHash = db_prepare(gAccounts, "SELECT "FIELD_PLAYER_NAME" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_GPCI"=? AND "FIELD_PLAYER_ACTIVE"=1 AND "FIELD_PLAYER_NAME"!=? COLLATE NOCASE");
	stmt_AliasesFromAll = db_prepare(gAccounts, "SELECT "FIELD_PLAYER_NAME" FROM "ACCOUNTS_TABLE_PLAYER" WHERE ("FIELD_PLAYER_PASS"=? OR "FIELD_PLAYER_IPV4"=? OR "FIELD_PLAYER_GPCI" = ?) AND "FIELD_PLAYER_ACTIVE"=1 AND "FIELD_PLAYER_NAME"!=? COLLATE NOCASE");
}

stock GetAccountAliasesByIP(name[], list[][MAX_PLAYER_NAME], &count, max, &adminlevel)
{
	new
		ip,
		tempname[MAX_PLAYER_NAME],
		templevel;

	GetAccountIP(name, ip);

	if(ip == 0)
		return 0;

	stmt_bind_value(stmt_AliasesFromIp, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AliasesFromIp, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AliasesFromIp, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AliasesFromIp))
		return 0;

	while(stmt_fetch_row(stmt_AliasesFromIp))
	{
		if(count < max)
			strcat(list[count], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel)
			adminlevel = templevel;

		count++;
	}

	return 1;
}

stock GetAccountAliasesByPass(name[], list[][MAX_PLAYER_NAME], &count, max, &adminlevel)
{
	new
		pass[129],
		tempname[MAX_PLAYER_NAME],
		templevel;

	GetAccountPassword(name, pass);

	if(isnull(pass))
		return 0;

	stmt_bind_value(stmt_AliasesFromPass, 0, DB::TYPE_STRING, pass, 129);
	stmt_bind_value(stmt_AliasesFromPass, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AliasesFromPass, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AliasesFromPass))
		return 0;

	while(stmt_fetch_row(stmt_AliasesFromPass))
	{
		if(count < max)
			strcat(list[count], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel)
			adminlevel = templevel;

		count++;
	}

	return 1;
}

stock GetAccountAliasesByHash(name[], list[][MAX_PLAYER_NAME], &count, max, &adminlevel)
{
	new
		serial[41],
		tempname[MAX_PLAYER_NAME],
		templevel;

	GetAccountGPCI(name, serial);

	if(isnull(serial))
		return 0;

	if(serial[0] == '0')
		return 0;

	stmt_bind_value(stmt_AliasesFromHash, 0, DB::TYPE_STRING, serial, 41);
	stmt_bind_value(stmt_AliasesFromHash, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AliasesFromHash, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AliasesFromHash))
		return 0;

	while(stmt_fetch_row(stmt_AliasesFromHash))
	{
		if(count < max)
			strcat(list[count], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel)
			adminlevel = templevel;

		count++;
	}

	return 1;
}

stock GetAccountAliasesByAll(name[], list[][MAX_PLAYER_NAME], &count, max, &adminlevel)
{
	new
		pass[129],
		ip,
		serial[41],
		tempname[MAX_PLAYER_NAME],
		templevel;

	GetAccountAliasData(name, pass, ip, serial);

	if(isnull(serial))
		return 0;

	if(serial[0] == '0')
		return 0;

	stmt_bind_value(stmt_AliasesFromAll, 0, DB::TYPE_STRING, pass, sizeof(pass));
	stmt_bind_value(stmt_AliasesFromAll, 1, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AliasesFromAll, 2, DB::TYPE_STRING, serial, sizeof(serial));
	stmt_bind_value(stmt_AliasesFromAll, 3, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AliasesFromAll, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AliasesFromAll))
		return 0;

	while(stmt_fetch_row(stmt_AliasesFromAll))
	{
		if(count < max)
			strcat(list[count], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel)
			adminlevel = templevel;

		count++;
	}

	return 1;
}

CheckForExtraAccounts(playerid)
{
	if(!IsPlayerRegistered(playerid) || !IsPlayerLoggedIn(playerid))
		return 0;

	new
		name[MAX_PLAYER_NAME],
		list[6][MAX_PLAYER_NAME],
		count,
		adminlevel,
		bool:donewarning,
		string[(MAX_PLAYER_NAME + 2) * 6];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	GetAccountAliasesByAll(name, list, count, 6, adminlevel);

	if(count == 0)
		return 0;

	if(count == 1)
		strcat(string, list[0]);

	if(count > 1)
	{
		for(new i; i < count && i < sizeof(list); i++)
		{
			strcat(string, list[i]);
			strcat(string, ", ");

			if(IsPlayerBanned(list[i]) && !donewarning)
			{
				ChatMsgAdmins(1, RED, " >  Warning: One or more of those aliases is banned!");
				donewarning = true;
			}
		}
	}

	if(donewarning && GetAdminsOnline() == 0)
	{
		KickPlayer(playerid, "One of your previously used accounts is banned.");
		return 0;
	}

	ChatMsgAdmins(adminlevel, YELLOW, " >  Aliases: "C_BLUE"(%d)"C_ORANGE" %s", count, string);

	return 1;
}


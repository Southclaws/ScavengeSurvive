/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define ACCOUNTS_TABLE_GPCI_WHITELIST	"gpci_whitelist"
#define FIELD_WHITELIST_HASH			"hash"		// 00


static
DBStatement:	stmt_WhitelistExists,
DBStatement:	stmt_WhitelistInsert,
DBStatement:	stmt_WhitelistDelete,
DBStatement:	stmt_WhitelistGetAll;


hook OnScriptInit()
{
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_GPCI_WHITELIST" (\
		"FIELD_WHITELIST_HASH" TEXT)"));

	DatabaseTableCheck(gAccounts, ACCOUNTS_TABLE_GPCI_WHITELIST, 1);

	stmt_WhitelistExists = db_prepare(gAccounts, "SELECT COUNT(*) FROM "ACCOUNTS_TABLE_GPCI_WHITELIST" WHERE "FIELD_WHITELIST_HASH" = ? COLLATE NOCASE");
	stmt_WhitelistInsert = db_prepare(gAccounts, "INSERT INTO "ACCOUNTS_TABLE_GPCI_WHITELIST" ("FIELD_WHITELIST_HASH") VALUES(?)");
	stmt_WhitelistDelete = db_prepare(gAccounts, "DELETE FROM "ACCOUNTS_TABLE_GPCI_WHITELIST" WHERE "FIELD_WHITELIST_HASH" = ?");
	stmt_WhitelistGetAll = db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_GPCI_WHITELIST"");
}

stock IsGpciInWhitelist(hash[])
{
	new count;

	stmt_bind_value(stmt_WhitelistExists, 0, DB::TYPE_STRING, hash, MAX_GPCI_LEN);
	stmt_bind_result_field(stmt_WhitelistExists, 0, DB::TYPE_INTEGER, count);

	if(!stmt_execute(stmt_WhitelistExists))
	{
		err("Executing statement 'stmt_WhitelistExists'.");
		return 0;
	}

	stmt_fetch_row(stmt_WhitelistExists);

	if(count > 0)
		return 1;

	return 0;
}

stock AddGpciToWhitelist(hash[])
{
	stmt_bind_value(stmt_WhitelistInsert, 0, DB::TYPE_STRING, hash, MAX_GPCI_LEN);

	if(!stmt_execute(stmt_WhitelistInsert))
	{
		err("Executing statement 'stmt_WhitelistInsert'.");
		return 0;
	}

	return 1;
}

stock RemoveGpciFromWhitelist(hash[])
{
	stmt_bind_value(stmt_WhitelistDelete, 0, DB::TYPE_STRING, hash, MAX_GPCI_LEN);

	if(!stmt_execute(stmt_WhitelistDelete))
	{
		err("Executing statement 'stmt_WhitelistDelete'.");
		return -1;
	}

	stmt_free_result(stmt_WhitelistDelete);

	return 1;
}

stock GetGpciWhitelist(output[][])
{
	new
		hash[MAX_GPCI_LEN],
		count;

	stmt_bind_result_field(stmt_WhitelistGetAll, 0, DB::TYPE_STRING, hash, MAX_GPCI_LEN);

	if(!stmt_execute(stmt_WhitelistGetAll))
	{
		err("Executing statement 'stmt_WhitelistGetAll'.");
		return 0;
	}

	while(stmt_fetch_row(stmt_WhitelistGetAll))
	{
		strcat(output[count], hash, MAX_GPCI_LEN);
		count++;
	}

	return count;
}

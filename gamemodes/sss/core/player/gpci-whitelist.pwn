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


#define ACCOUNTS_TABLE_GPCI_WHITELIST	"gpci_whitelist"
#define FIELD_WHITELIST_HASH			"hash"		// 00


static
DBStatement:	stmt_WhitelistExists,
DBStatement:	stmt_WhitelistInsert,
DBStatement:	stmt_WhitelistDelete,
DBStatement:	stmt_WhitelistGetAll;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'gpci-whitelist'...");

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
		print("ERROR: Executing statement 'stmt_WhitelistExists'.");
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
		print("ERROR: Executing statement 'stmt_WhitelistInsert'.");
		return 0;
	}

	return 1;
}

stock RemoveGpciFromWhitelist(hash[])
{
	stmt_bind_value(stmt_WhitelistDelete, 0, DB::TYPE_STRING, hash, MAX_GPCI_LEN);

	if(!stmt_execute(stmt_WhitelistDelete))
	{
		print("ERROR: Executing statement 'stmt_WhitelistDelete'.");
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
		print("ERROR: Executing statement 'stmt_WhitelistGetAll'.");
		return 0;
	}

	while(stmt_fetch_row(stmt_WhitelistGetAll))
	{
		strcat(output[count], hash, MAX_GPCI_LEN);
		count++;
	}

	return count;
}

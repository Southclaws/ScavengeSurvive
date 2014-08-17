#include <YSI\y_hooks>


#define ACCOUNTS_TABLE_GPCI		"gpci_log"
#define FIELD_GPCI_NAME			"name"		// 00
#define FIELD_GPCI_GPCI			"hash"		// 01
#define FIELD_GPCI_DATE			"date"		// 02

enum e_gpci_list_output_structure
{
	gpci_name[MAX_PLAYER_NAME],
	gpci_gpci[MAX_GPCI_LEN],
	gpci_date
}


static
DBStatement:	stmt_GpciInsert,
DBStatement:	stmt_GpciCheckName,
DBStatement:	stmt_GpciGetRecordsFromGpci,
DBStatement:	stmt_GpciGetRecordsFromName;


hook OnGameModeInit()
{
	db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_GPCI" (\
		"FIELD_GPCI_NAME" TEXT,\
		"FIELD_GPCI_GPCI" TEXT,\
		"FIELD_GPCI_DATE" INTEGER)");

	DatabaseTableCheck(gAccounts, ACCOUNTS_TABLE_GPCI, 3);

	stmt_GpciInsert				= db_prepare(gAccounts, "INSERT INTO "ACCOUNTS_TABLE_GPCI" VALUES(?,?,?)");
	stmt_GpciCheckName			= db_prepare(gAccounts, "SELECT COUNT(*) FROM "ACCOUNTS_TABLE_GPCI" WHERE "FIELD_GPCI_NAME"=? AND "FIELD_GPCI_GPCI"=?");
	stmt_GpciGetRecordsFromGpci	= db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_GPCI" WHERE "FIELD_GPCI_GPCI"=?");
	stmt_GpciGetRecordsFromName	= db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_GPCI" WHERE "FIELD_GPCI_NAME"=? COLLATE NOCASE");
}

hook OnPlayerConnect(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		hash[MAX_GPCI_LEN],
		count;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	gpci(playerid, hash, MAX_GPCI_LEN);

	stmt_bind_result_field(stmt_GpciCheckName, 0, DB::TYPE_INTEGER, count);
	stmt_bind_value(stmt_GpciCheckName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_GpciCheckName, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);

	stmt_execute(stmt_GpciCheckName);

	stmt_fetch_row(stmt_GpciCheckName);

	if(count == 0)
	{
		stmt_bind_value(stmt_GpciInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_value(stmt_GpciInsert, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);
		stmt_bind_value(stmt_GpciInsert, 2, DB::TYPE_INTEGER, gettime());

		if(!stmt_execute(stmt_GpciInsert))
			print("ERROR: Failed to execute statement 'stmt_GpciInsert'.");
	}

	return 1;
}

stock GetAccountGpciHistoryFromGpci(inputgpci[MAX_GPCI_LEN], output[][e_gpci_list_output_structure], max, &count)
{
	new
		name[MAX_PLAYER_NAME],
		hash,
		date;

	stmt_bind_result_field(stmt_GpciGetRecordsFromGpci, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_GpciGetRecordsFromGpci, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);
	stmt_bind_result_field(stmt_GpciGetRecordsFromGpci, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_GpciGetRecordsFromGpci, 0, DB::TYPE_INTEGER, inputgpci, MAX_GPCI_LEN);

	if(!stmt_execute(stmt_GpciGetRecordsFromGpci))
		return 0;

	while(stmt_fetch_row(stmt_GpciGetRecordsFromGpci) && count < max)
	{
		output[count][gpci_name] = name;
		output[count][gpci_gpci] = hash;
		output[count][gpci_date] = date;

		count++;
	}

	return 1;
}

stock GetAccountGpciHistoryFromName(inputname[], output[][e_gpci_list_output_structure], max, &count)
{
	new
		name[MAX_PLAYER_NAME],
		hash[MAX_GPCI_LEN],
		date;

	stmt_bind_result_field(stmt_GpciGetRecordsFromName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_GpciGetRecordsFromName, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);
	stmt_bind_result_field(stmt_GpciGetRecordsFromName, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_GpciGetRecordsFromName, 0, DB::TYPE_STRING, inputname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_GpciGetRecordsFromName))
		return 0;

	while(stmt_fetch_row(stmt_GpciGetRecordsFromName) && count < max)
	{
		output[count][gpci_name] = name;
		output[count][gpci_gpci] = hash;
		output[count][gpci_date] = date;

		count++;
	}

	return 1;
}

ACMD:ghg[4](playerid, params[])
{
	new
		hash[MAX_GPCI_LEN],
		list[48][e_gpci_list_output_structure],
		count;

	GetAccountGPCI(params, hash);

	if(!GetAccountGpciHistoryFromGpci(hash, list, 48, count))
	{
		Msg(playerid, YELLOW, " >  Failed");
		return 1;
	}

	if(count == 0)
	{
		Msg(playerid, YELLOW, " >  No results");
		return 1;
	}

	gBigString[playerid][0] = EOS;

	for(new i; i < count; i++)
	{
		format(gBigString[playerid], sizeof(gBigString[]), "%s%s: %s (%s)\n",
			gBigString[playerid],
			list[i][gpci_name],
			list[i][gpci_gpci],
			TimestampToDateTime(list[i][gpci_date], "%x"));
	}

	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, params, gBigString[playerid], "Close", "");

	return 1;	
}

ACMD:ghname[4](playerid, params[])
{
	new
		list[48][e_gpci_list_output_structure],
		count;

	if(!GetAccountGpciHistoryFromName(params, list, 48, count))
	{
		Msg(playerid, YELLOW, " >  Failed");
		return 1;
	}

	if(count == 0)
	{
		Msg(playerid, YELLOW, " >  No results");
		return 1;
	}

	gBigString[playerid][0] = EOS;

	for(new i; i < count; i++)
	{
		format(gBigString[playerid], sizeof(gBigString[]), "%s%s: %s (%s)\n",
			gBigString[playerid],
			list[i][gpci_name],
			list[i][gpci_gpci],
			TimestampToDateTime(list[i][gpci_date], "%x"));
	}

	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, params, gBigString[playerid], "Close", "");

	return 1;	
}


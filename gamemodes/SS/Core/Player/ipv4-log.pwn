#include <YSI\y_hooks>


#define ACCOUNTS_TABLE_IPV4		"ipv4_log"
#define FIELD_IPV4_NAME			"name"		// 00
#define FIELD_IPV4_IPV4			"ipv4"		// 01
#define FIELD_IPV4_DATE			"date"		// 02

enum e_ipv4_list_output_structure
{
	ipv4_name[MAX_PLAYER_NAME],
	ipv4_ipv4,
	ipv4_date
}


static
DBStatement:	stmt_Ipv4Insert,
DBStatement:	stmt_Ipv4CheckName,
DBStatement:	stmt_Ipv4GetRecordsFromIP,
DBStatement:	stmt_Ipv4GetRecordsFromName;


hook OnGameModeInit()
{
	db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_IPV4" (\
		"FIELD_IPV4_NAME" TEXT,\
		"FIELD_IPV4_IPV4" INTEGER,\
		"FIELD_IPV4_DATE" INTEGER)");

	DatabaseTableCheck(gAccounts, ACCOUNTS_TABLE_IPV4, 3);

	stmt_Ipv4Insert				= db_prepare(gAccounts, "INSERT INTO "ACCOUNTS_TABLE_IPV4" VALUES(?,?,?)");
	stmt_Ipv4CheckName			= db_prepare(gAccounts, "SELECT COUNT(*) FROM "ACCOUNTS_TABLE_IPV4" WHERE "FIELD_IPV4_NAME"=? AND "FIELD_IPV4_IPV4"=?");
	stmt_Ipv4GetRecordsFromIP	= db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_IPV4" WHERE "FIELD_IPV4_IPV4"=?");
	stmt_Ipv4GetRecordsFromName	= db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_IPV4" WHERE "FIELD_IPV4_NAME"=? COLLATE NOCASE");
}

hook OnPlayerConnect(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		ipstring[16],
		ipbyte[4],
		ip,
		count;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	GetPlayerIp(playerid, ipstring, 16);

	sscanf(ipstring, "p<.>a<d>[4]", ipbyte);
	ip = ((ipbyte[0] << 24) | (ipbyte[1] << 16) | (ipbyte[2] << 8) | ipbyte[3]);

	stmt_bind_result_field(stmt_Ipv4CheckName, 0, DB::TYPE_INTEGER, count);
	stmt_bind_value(stmt_Ipv4CheckName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_Ipv4CheckName, 1, DB::TYPE_INTEGER, ip);

	stmt_execute(stmt_Ipv4CheckName);

	stmt_fetch_row(stmt_Ipv4CheckName);

	if(count == 0)
	{
		stmt_bind_value(stmt_Ipv4Insert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_value(stmt_Ipv4Insert, 1, DB::TYPE_INTEGER, ip);
		stmt_bind_value(stmt_Ipv4Insert, 2, DB::TYPE_INTEGER, gettime());

		if(!stmt_execute(stmt_Ipv4Insert))
			print("ERROR: Failed to execute statement 'stmt_Ipv4Insert'.");
	}

	return 1;
}

stock GetAccountIPHistoryFromIP(inputipv4, output[][e_ipv4_list_output_structure], max, &count)
{
	new
		name[MAX_PLAYER_NAME],
		ipv4,
		date;

	stmt_bind_result_field(stmt_Ipv4GetRecordsFromIP, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_Ipv4GetRecordsFromIP, 1, DB::TYPE_INTEGER, ipv4);
	stmt_bind_result_field(stmt_Ipv4GetRecordsFromIP, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_Ipv4GetRecordsFromIP, 0, DB::TYPE_INTEGER, inputipv4);

	if(!stmt_execute(stmt_Ipv4GetRecordsFromIP))
		return 0;

	while(stmt_fetch_row(stmt_Ipv4GetRecordsFromIP) && count < max)
	{
		output[count][ipv4_name] = name;
		output[count][ipv4_ipv4] = ipv4;
		output[count][ipv4_date] = date;

		count++;
	}

	return 1;
}

stock GetAccountIPHistoryFromName(inputname[], output[][e_ipv4_list_output_structure], max, &count)
{
	new
		name[MAX_PLAYER_NAME],
		ipv4,
		date;

	stmt_bind_result_field(stmt_Ipv4GetRecordsFromName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_Ipv4GetRecordsFromName, 1, DB::TYPE_INTEGER, ipv4);
	stmt_bind_result_field(stmt_Ipv4GetRecordsFromName, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_Ipv4GetRecordsFromName, 0, DB::TYPE_STRING, inputname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_Ipv4GetRecordsFromName))
		return 0;

	while(stmt_fetch_row(stmt_Ipv4GetRecordsFromName) && count < max)
	{
		output[count][ipv4_name] = name;
		output[count][ipv4_ipv4] = ipv4;
		output[count][ipv4_date] = date;

		count++;
	}

	return 1;
}

ACMD:iphip[4](playerid, params[])
{
	new
		ip,
		list[48][e_ipv4_list_output_structure],
		count;

	GetAccountIP(params, ip);

	if(!GetAccountIPHistoryFromIP(ip, list, 48, count))
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
			list[i][ipv4_name],
			IpIntToStr(list[i][ipv4_ipv4]),
			TimestampToDateTime(list[i][ipv4_date], "%x"));
	}

	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, params, gBigString[playerid], "Close", "");

	return 1;	
}

ACMD:iphname[4](playerid, params[])
{
	new
		list[48][e_ipv4_list_output_structure],
		count;

	if(!GetAccountIPHistoryFromName(params, list, 48, count))
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
			list[i][ipv4_name],
			IpIntToStr(list[i][ipv4_ipv4]),
			TimestampToDateTime(list[i][ipv4_date], "%x"));
	}

	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, params, gBigString[playerid], "Close", "");

	return 1;	
}

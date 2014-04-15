#include <YSI\y_hooks>


#define ACCOUNTS_TABLE_WHITELIST	"Whitelist"
#define FIELD_WHITELIST_NAME		"name"		// 00


static
// ACCOUNTS_TABLE_WHITELIST
DBStatement:	stmt_WhitelistExists,
DBStatement:	stmt_WhitelistInsert,
DBStatement:	stmt_WhitelistDelete;


hook OnGameModeInit()
{
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_WHITELIST" (\
		"FIELD_WHITELIST_NAME" TEXT)"));

	DatabaseTableCheck(gAccounts, ACCOUNTS_TABLE_WHITELIST, 1);

	stmt_WhitelistExists = db_prepare(gAccounts, "SELECT COUNT(*) FROM "ACCOUNTS_TABLE_WHITELIST" WHERE "FIELD_WHITELIST_NAME" = ? COLLATE NOCASE");
	stmt_WhitelistInsert = db_prepare(gAccounts, "INSERT INTO "ACCOUNTS_TABLE_WHITELIST" ("FIELD_WHITELIST_NAME") VALUES(?)");
	stmt_WhitelistDelete = db_prepare(gAccounts, "DELETE FROM "ACCOUNTS_TABLE_WHITELIST" WHERE "FIELD_WHITELIST_NAME" = ?");
}


stock AddNameToWhitelist(name[])
{
	if(IsNameInWhitelist(name))
		return 0;

	stmt_bind_value(stmt_WhitelistInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_WhitelistInsert, true, false))
	{
		stmt_free_result(stmt_WhitelistInsert);
		return 1;
	}

	return -1;
}

stock RemoveNameFromWhitelist(name[])
{
	if(!IsNameInWhitelist(name))
		return 0;

	stmt_bind_value(stmt_WhitelistDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_WhitelistDelete, true, false))
	{
		stmt_free_result(stmt_WhitelistDelete);
		return 1;
	}

	return -1;
}

stock IsNameInWhitelist(name[])
{
	new count;

	stmt_bind_value(stmt_WhitelistExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_WhitelistExists, 0, DB::TYPE_INTEGER, count);
	stmt_execute(stmt_WhitelistExists, true, false);
	stmt_fetch_row(stmt_WhitelistExists);
	stmt_free_result(stmt_WhitelistExists);

	if(count > 0)
		return 1;

	return 0;
}

WhitelistKick(playerid)
{
	new str[512];

	format(str, 512,
		""C_YELLOW"You are not on the whitelist for this server.\n\
		This is in force to provide the best gameplay experience for all players.\n\n\
		"C_WHITE"Please apply on "C_BLUE"%s"C_WHITE".\n\
		Applications are always accepted as soon as possible\n\
		There are no requirements, just follow the rules.\n\
		Failure to do so will result in permanent removal from the whitelist.", gWebsiteURL);

	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Whitelist", str, "Close", "");

	defer KickPlayerDelay(playerid);
}

/*
	If auto whitelist toggle is on, turn the whitelist off when an admin joins
	and turn it back on when there are no admins on the server.

	Works for level 2 admins and higher since level 1 admins don't have any
	anti-hack tools at disposal.
*/

hook OnPlayerConnect(playerid)
{
	// Used a timer here because the admin hook may be called afterwards.
	defer Connect_AutoWhitelist();
}
timer Connect_AutoWhitelist[10]()
{
	if(gWhitelistAutoToggle)
	{
		if(gWhitelist && GetAdminsOnline(2)) // turn off if whitelist is on and are admins online
			gWhitelist = false;
	}
}

hook OnPlayerDisconnect(playerid)
{
	// Again, a timer in case the GetAdminsOnline func returns 1 even though
	// that 1 admin is quitting (Admin/Core.pwn hook maybe called after this)
	defer Disconnect_AutoWhitelist();
}

timer Disconnect_AutoWhitelist[10]()
{
	if(gWhitelistAutoToggle)
	{
		if(!gWhitelist && !GetAdminsOnline(2)) // turn on if whitelist is off and no admins remain online
			gWhitelist = true;
	}
}

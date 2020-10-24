/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define ACCOUNTS_TABLE_WHITELIST	"Whitelist"
#define FIELD_WHITELIST_NAME		"name"		// 00


static
bool:			wl_Active,
bool:			wl_Auto,
				wl_NonWhitelistTime = 300,
bool:			wl_Whitelisted[MAX_PLAYERS],
				wl_Countdown[MAX_PLAYERS],
PlayerText:		wl_CountdownUI[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
Timer:			wl_CountdownTimer[MAX_PLAYERS],
// ACCOUNTS_TABLE_WHITELIST
DBStatement:	stmt_WhitelistExists,
DBStatement:	stmt_WhitelistInsert,
DBStatement:	stmt_WhitelistDelete;


hook OnScriptInit()
{
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_WHITELIST" (\
		"FIELD_WHITELIST_NAME" TEXT)"));

	DatabaseTableCheck(gAccounts, ACCOUNTS_TABLE_WHITELIST, 1);

	stmt_WhitelistExists = db_prepare(gAccounts, "SELECT COUNT(*) FROM "ACCOUNTS_TABLE_WHITELIST" WHERE "FIELD_WHITELIST_NAME" = ? COLLATE NOCASE");
	stmt_WhitelistInsert = db_prepare(gAccounts, "INSERT INTO "ACCOUNTS_TABLE_WHITELIST" ("FIELD_WHITELIST_NAME") VALUES(?)");
	stmt_WhitelistDelete = db_prepare(gAccounts, "DELETE FROM "ACCOUNTS_TABLE_WHITELIST" WHERE "FIELD_WHITELIST_NAME" = ?");

	GetSettingInt("server/whitelist", 0, wl_Active);
	GetSettingInt("server/whitelist-auto-toggle", 0, wl_Auto);
}

hook OnPlayerConnect(playerid)
{
	defer _WhitelistConnect(playerid);

	wl_CountdownUI[playerid]		=CreatePlayerTextDraw(playerid, 430.0, 40.0, "Not whitelisted~n~Time remaining: 00:00");
	PlayerTextDrawAlignment			(playerid, wl_CountdownUI[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, wl_CountdownUI[playerid], 255);
	PlayerTextDrawFont				(playerid, wl_CountdownUI[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, wl_CountdownUI[playerid], 0.20, 1.0);
	PlayerTextDrawColor				(playerid, wl_CountdownUI[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, wl_CountdownUI[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, wl_CountdownUI[playerid], 1);
}

hook OnPlayerDisconnect(playerid)
{
	wl_Whitelisted[playerid] = false;

	// Again, a timer in case the GetAdminsOnline func returns 1 even though
	// that 1 admin is quitting (Admin/Core.pwn hook maybe called after this)
	defer _WhitelistDisconnect(playerid);

	return 1;
}


/*
	Core
*/


stock AddPlayerToWhitelist(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	wl_Whitelisted[playerid] = true;
	AddNameToWhitelist(name, false);

	return 1;
}

stock AddNameToWhitelist(name[], doplayeridcheck = true)
{
	if(IsNameInWhitelist(name) == 1)
		return 0;

	stmt_bind_value(stmt_WhitelistInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_WhitelistInsert))
	{
		err("Executing statement 'stmt_WhitelistInsert'.");
		return -1;
	}

	stmt_free_result(stmt_WhitelistInsert);

	if(doplayeridcheck)
	{
		new tmpname[MAX_PLAYER_NAME];

		foreach(new i : Player)
		{
			GetPlayerName(i, tmpname, MAX_PLAYER_NAME);

			if(!strcmp(name, tmpname))
			{
				wl_Whitelisted[i] = true;
				stop wl_CountdownTimer[i];
				PlayerTextDrawHide(i, wl_CountdownUI[i]);
				break;
			}
		}
	}

	return 1;
}

stock RemovePlayerFromWhitelist(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	wl_Whitelisted[playerid] = false;
	RemoveNameFromWhitelist(name, false);

	return 1;
}

stock RemoveNameFromWhitelist(name[], doplayeridcheck = true)
{
	if(IsNameInWhitelist(name) == 0)
		return 0;

	stmt_bind_value(stmt_WhitelistDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_WhitelistDelete))
	{
		err("Executing statement 'stmt_WhitelistDelete'.");
		return -1;
	}

	stmt_free_result(stmt_WhitelistDelete);

	if(doplayeridcheck)
	{
		new tmpname[MAX_PLAYER_NAME];

		foreach(new i : Player)
		{
			GetPlayerName(i, tmpname, MAX_PLAYER_NAME);

			if(!strcmp(name, tmpname))
			{
				wl_Whitelisted[i] = false;

				if(wl_Active)
				{
					stop wl_CountdownTimer[i];
					wl_CountdownTimer[i] = repeat _UpdateWhitelistCountdown(i);
				}

				break;
			}
		}
	}

	return 1;
}

stock IsPlayerInWhitelist(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return wl_Whitelisted[playerid];
}

stock IsNameInWhitelist(name[])
{
	if(isnull(name))
		return 2;

	new count;

	stmt_bind_value(stmt_WhitelistExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_WhitelistExists, 0, DB::TYPE_INTEGER, count);

	if(!stmt_execute(stmt_WhitelistExists))
	{
		err("Executing statement 'stmt_WhitelistExists'.");
		return -1;
	}

	stmt_fetch_row(stmt_WhitelistExists);
	stmt_free_result(stmt_WhitelistExists);

	if(count > 0)
		return 1;

	return 0;
}

stock WhitelistKick(playerid)
{
	new str[512];

	format(str, 512,
		""C_YELLOW"You are not on the whitelist for this server.\n\
		This is in force to provide the best gameplay experience for all players.\n\n\
		"C_WHITE"Please apply on "C_BLUE"%s"C_WHITE".\n\
		Applications are always accepted as soon as possible\n\
		There are no requirements, just follow the rules.\n\
		Failure to do so will result in permanent removal from the whitelist.", gWebsiteURL);

	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Whitelist", str, "Close", "");

	KickPlayer(playerid, "Not in whitelist");
}

stock ToggleWhitelist(bool:toggle)
{
	wl_Active = toggle;

	if(toggle)
	{
		foreach(new i : Player)
		{
			if(!wl_Whitelisted[i])
			{
				wl_Countdown[i] = wl_NonWhitelistTime;
				PlayerTextDrawSetString(i, wl_CountdownUI[i], sprintf("Not whitelisted~n~Time remaining: %02d:%02d", wl_Countdown[i] / 60, wl_Countdown[i] % 60));
				PlayerTextDrawShow(i, wl_CountdownUI[i]);
				stop wl_CountdownTimer[i];
				wl_CountdownTimer[i] = repeat _UpdateWhitelistCountdown(i);
			}
		}
	}
	else
	{
		foreach(new i : Player)
		{
			if(!wl_Whitelisted[i])
			{
				stop wl_CountdownTimer[i];
				PlayerTextDrawHide(i, wl_CountdownUI[i]);
			}
		}
	}
}

stock ToggleAutoWhitelist(bool:toggle)
{
	wl_Auto = toggle;

	// If auto whitelist is being turned on.
	if(toggle)
	{
		// If the whitelist is on and admins are on, turn it off.
		if(wl_Active && GetAdminsOnline(2))
			ToggleWhitelist(false);

		// If the whitelist is off and there are no admins, turn it on.
		else
			ToggleWhitelist(true);
	}
}


/*
	Internal
*/


timer _UpdateWhitelistCountdown[1000](playerid)
{
	if(!IsPlayerLoggedIn(playerid))
	{
		stop wl_CountdownTimer[playerid];
		return;
	}

	if(wl_Whitelisted[playerid])
	{
		stop wl_CountdownTimer[playerid];
		PlayerTextDrawHide(playerid, wl_CountdownUI[playerid]);
	}

	if(wl_Countdown[playerid] == 0)
	{
		WhitelistKick(playerid);
		stop wl_CountdownTimer[playerid];
		return;
	}

	PlayerTextDrawSetString(playerid, wl_CountdownUI[playerid], sprintf("Not whitelisted~n~Time remaining: %02d:%02d", wl_Countdown[playerid] / 60, wl_Countdown[playerid] % 60));
	PlayerTextDrawShow(playerid, wl_CountdownUI[playerid]);

	wl_Countdown[playerid]--;

	return;
}

/*
	If auto whitelist toggle is on, turn the whitelist off when an admin joins
	and turn it back on when there are no admins on the server.

	Works for level 2 admins and higher since level 1 admins don't have any
	anti-hack tools at disposal.
*/

timer _WhitelistConnect[100](playerid)
{
	if(!IsPlayerConnected(playerid))
	{
		log("[_WhitelistConnect] Player %d not connected any more.", playerid);
		return;
	}

	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	if(IsNameInWhitelist(name) == 1)
		wl_Whitelisted[playerid] = true;

	else
		wl_Whitelisted[playerid] = false;
}

hook OnPlayerLogin(playerid)
{
	if(wl_Auto && wl_Active)
	{
		if(GetAdminsOnline(2) > 0) // turn off if whitelist is on and are admins online
		{
			ChatMsg(playerid, YELLOW, " >  Auto-whitelist: Deactivated the whitelist.");
			ToggleWhitelist(false);
			log("[AUTOWHITELIST] Whitelist turned off by %p joining", playerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

timer _WhitelistDisconnect[100](playerid)
{
	if(wl_Auto && !wl_Active)
	{
		if(GetAdminsOnline(2) == 0) // turn on if whitelist is off and no admins remain online
		{
			ToggleWhitelist(true);
			log("[AUTOWHITELIST] Whitelist turned on by %d quitting.", playerid);
		}
	}
}


/*
	Interface
*/


stock IsWhitelistAuto()
{
	return wl_Auto;
}

stock IsWhitelistActive()
{
	return wl_Active;
}

stock SetNonWhitelistTime(value)
{
	wl_NonWhitelistTime = value;
}

stock GetNonWhitelistTime()
{
	return wl_NonWhitelistTime;
}

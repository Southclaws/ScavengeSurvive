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


hook OnGameModeInit()
{
	//
}

stock GetAccountAliasesByIP(name[], list[][MAX_PLAYER_NAME], &count, max, &adminlevel)
{
}

stock GetAccountAliasesByPass(name[], list[][MAX_PLAYER_NAME], &count, max, &adminlevel)
{
	return 1;
}

stock GetAccountAliasesByHash(name[], list[][MAX_PLAYER_NAME], &count, max, &adminlevel)
{
}

stock GetAccountAliasesByAll(name[], list[][MAX_PLAYER_NAME], &count, max, &adminlevel)
{
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


/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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


#define MAX_GPCI_LOG_RESULTS	(32)

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


hook OnGameModeInit()
{
	//
}

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/player/gpci-log.pwn");

	new
		name[MAX_PLAYER_NAME],
		hash[MAX_GPCI_LEN],
		count;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	gpci(playerid, hash, MAX_GPCI_LEN);

	// GpciCheckName, 0, DB::TYPE_INTEGER, count
	// GpciCheckName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME
	// GpciCheckName, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN

	if(count == 0)
	{
		// GpciInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME
		// GpciInsert, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN
		// GpciInsert, 2, DB::TYPE_INTEGER, gettime()
	}

	return 1;
}

stock GetAccountGpciHistoryFromGpci(inputname[], output[][e_gpci_list_output_structure], max, &count)
{
	return 1;
}

stock GetAccountGpciHistoryFromName(inputname[], output[][e_gpci_list_output_structure], max, &count)
{
	return 1;
}

stock ShowAccountGpciHistoryFromGpci(playerid, name[])
{
	new
		list[MAX_GPCI_LOG_RESULTS][e_gpci_list_output_structure],
		newlist[MAX_GPCI_LOG_RESULTS][MAX_PLAYER_NAME],
		count;

	if(!GetAccountGpciHistoryFromGpci(name, list, MAX_GPCI_LOG_RESULTS, count))
	{
		ChatMsg(playerid, YELLOW, " >  Failed");
		return 1;
	}

	if(count == 0)
	{
		ChatMsg(playerid, YELLOW, " >  No results");
		return 1;
	}

	for(new i; i < count; i++)
	{
		strcat(newlist[i], list[i][gpci_name], MAX_PLAYER_NAME);
	}

	ShowPlayerList(playerid, newlist, count, true);

	return 1;
}

stock ShowAccountGpciHistoryFromName(playerid, name[])
{
	new
		list[MAX_GPCI_LOG_RESULTS][e_gpci_list_output_structure],
		newlist[MAX_GPCI_LOG_RESULTS][MAX_PLAYER_NAME],
		count;

	if(!GetAccountGpciHistoryFromName(name, list, MAX_GPCI_LOG_RESULTS, count))
	{
		ChatMsg(playerid, YELLOW, " >  Failed");
		return 1;
	}

	if(count == 0)
	{
		ChatMsg(playerid, YELLOW, " >  No results");
		return 1;
	}

	gBigString[playerid][0] = EOS;

	for(new i; i < count; i++)
	{
		strcat(newlist[i], list[i][gpci_name], MAX_PLAYER_NAME);
	}

	ShowPlayerList(playerid, newlist, count, true);

	return 1;
}

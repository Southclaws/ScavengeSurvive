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


#define MAX_IPV4_LOG_RESULTS	(32)

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


hook OnGameModeInit()
{
	//
}

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/player/ipv4-log.pwn");

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

	// Ipv4CheckName, 0, DB::TYPE_INTEGER, count
	// Ipv4CheckName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME
	// Ipv4CheckName, 1, DB::TYPE_INTEGER, ip

	if(count == 0)
	{
		// Ipv4Insert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME
		// Ipv4Insert, 1, DB::TYPE_INTEGER, ip
		// Ipv4Insert, 2, DB::TYPE_INTEGER, gettime()
	}

	return 1;
}

stock GetAccountIPHistoryFromIP(inputname[], output[][e_ipv4_list_output_structure], max, &count)
{
	return 1;
}

stock GetAccountIPHistoryFromName(inputname[], output[][e_ipv4_list_output_structure], max, &count)
{
	return 1;
}

stock ShowAccountIPHistoryFromIP(playerid, name[])
{
	new
		list[MAX_IPV4_LOG_RESULTS][e_ipv4_list_output_structure],
		newlist[MAX_IPV4_LOG_RESULTS][MAX_PLAYER_NAME],
		count;

	if(!GetAccountIPHistoryFromIP(name, list, MAX_IPV4_LOG_RESULTS, count))
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
		strcat(newlist[i], list[i][ipv4_name], MAX_PLAYER_NAME);
	}

	ShowPlayerList(playerid, newlist, count, true);

	return 1;
}

stock ShowAccountIPHistoryFromName(playerid, name[])
{
	new
		list[MAX_IPV4_LOG_RESULTS][e_ipv4_list_output_structure],
		newlist[MAX_IPV4_LOG_RESULTS][MAX_PLAYER_NAME],
		count;

	if(!GetAccountIPHistoryFromName(name, list, MAX_IPV4_LOG_RESULTS, count))
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
		strcat(newlist[i], list[i][ipv4_name], MAX_PLAYER_NAME);
	}

	ShowPlayerList(playerid, newlist, count, true);

	return 1;
}

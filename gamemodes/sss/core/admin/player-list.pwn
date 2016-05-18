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


#define PLAYER_LIST_MAX_ITEMS	(32)
#define PLAYER_LIST_ITEM_LEN	(MAX_PLAYER_NAME + 40) // 100ish max extra chars


static
	pls_String[MAX_PLAYERS][PLAYER_LIST_MAX_ITEMS * PLAYER_LIST_ITEM_LEN],
	pls_List[MAX_PLAYERS][PLAYER_LIST_MAX_ITEMS][MAX_PLAYER_NAME],
	pls_Length[MAX_PLAYERS];


stock ShowPlayerList(playerid, list[][], size = sizeof(list), bool:highlightbanned = false)
{
	new item[PLAYER_LIST_ITEM_LEN];

	pls_String[playerid][0] = EOS;
	pls_Length[playerid] = size;

	for(new i; i < size; i++)
	{
		// Copy the input list to global storage
		pls_List[playerid][i][0] = EOS;
		strcat(pls_List[playerid][i], list[i]);

		// Format the list item
		_FormatPlayerListItem(list[i], item, highlightbanned);

		// Concat the list item onto the big string
		strcat(pls_String[playerid], item);
	}

	_ShowCurrentList(playerid);
}

_ShowCurrentList(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			_ShowPlayerListItem(playerid, listitem);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Player list", pls_String[playerid], "Select", "Close");
}

stock HidePlayerList(playerid)
{
	// hide controls
}

stock _ShowPlayerListControls(playerid)
{
	// deactivate all, or whatever
}

stock _HidePlayerListControls(playerid)
{

}

_ShowPlayerListItem(playerid, item)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			// Show some options.
			_ShowPlayerListItemOptions(playerid, item);
		}
		else
		{
			// Send them back to the original list using the global list.
			_ShowCurrentList(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, pls_List[playerid][item], GetPlayerInfo(pls_List[playerid][item]), "Options", "Back");
}

GetPlayerInfo(name[])
{
	new
		info[512],
		dayslived,

		pass[129],
		ipv4,
		ip[17],
		country[32],
		alive,
		karma,
		regdate,
		lastlog,
		spawntime,
		totalspawns,
		warnings,
		aimshout[128],
		hash[41],
		active;

	GetAccountData(name, pass, ipv4, alive, karma, regdate, lastlog, spawntime, totalspawns, warnings, aimshout, hash, active);

	ip = IpIntToStr(ipv4);
	GetIPCountry(ip, country);

	dayslived = (gettime() > spawntime) ? (0) : ((gettime() - spawntime) / 86400);

	format(info, sizeof(info), "\
		IP:\t\t\t%s\n\
		Country:\t\t%s\n\
		Alive:\t\t\t%s\n\
		Karma:\t\t\t%d\n\
		Registered:\t\t%s\n\
		Last Login:\t\t%s\n\
		Days Survived:\t%d\n\
		Lives Lived:\t\t%d\n\
		Warnings:\t\t%d",

		ip,
		country,
		alive ? ("Yes") : ("No"),
		karma,
		TimestampToDateTime(regdate),
		TimestampToDateTime(lastlog),
		dayslived,
		totalspawns,
		warnings);

	return info;
}

_ShowPlayerListItemOptions(playerid, item)
{
	new options[256] = {"\
		Go to spawn\n\
		Set spawn\n\
		List accounts used by this IP\n\
		List accounts used by this GPCI\n\
		List IPs used by this name\n\
		List GPCIs used by this name\n\
		Ban\n\
		Toggle alive\n\
		Toggle active\n\
		"};

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(!response)
		{
			_ShowPlayerListItem(playerid, item);
			return 1;
		}

		switch(listitem)
		{
			case 0:// Go to spawn
			{
				ChatMsg(playerid, YELLOW, " >  Not implemented.");
			}
			case 1:// Set spawn
			{
				ChatMsg(playerid, YELLOW, " >  Not implemented.");
			}
			case 2:// List accounts used by this IP
			{
				new ip;
				GetAccountIP(pls_List[playerid][item], ip);
				ShowAccountIPHistoryFromIP(playerid, ip);
			}
			case 3:// List accounts used by this GPCI
			{
				new hash[MAX_GPCI_LEN];
				GetAccountGPCI(pls_List[playerid][item], hash);
				ShowAccountGpciHistoryFromGpci(playerid, hash);
			}
			case 4:// List IPs used by this name
			{
				ShowAccountIPHistoryFromName(playerid, pls_List[playerid][item]);
			}
			case 5:// List GPCIs used by this name
			{
				ShowAccountGpciHistoryFromName(playerid, pls_List[playerid][item]);
			}
			case 6:// Ban
			{
				BanAndEnterInfo(playerid, pls_List[playerid][item]);
				return 1;
			}
			case 7:// Toggle alive
			{
				new alivestate;

				GetAccountAliveState(pls_List[playerid][item], alivestate);

				if(alivestate)
				{
					SetAccountAliveState(pls_List[playerid][item], 0);
					ChatMsg(playerid, YELLOW, " >  Player alive state set to dead.");
				}
				else
				{
					SetAccountAliveState(pls_List[playerid][item], 1);
					ChatMsg(playerid, YELLOW, " >  Player alive state set to alive.");
				}
			}
			case 8: // Toggle active
			{
				new activestate;

				GetAccountActiveState(pls_List[playerid][item], activestate);

				if(activestate)
				{
					SetAccountActiveState(pls_List[playerid][item], 0);
					ChatMsg(playerid, YELLOW, " >  Player active state set to inactive.");
				}
				else
				{
					SetAccountActiveState(pls_List[playerid][item], 1);
					ChatMsg(playerid, YELLOW, " >  Player active state set to active.");
				}
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Options", options, "Select", "Back");

	return 1;
}

_FormatPlayerListItem(name[], output[], highlightbanned)
{
	new
		ip,
		ipstr[17];

	GetAccountIP(name, ip);
	ipstr = IpIntToStr(ip);

	format(output, PLAYER_LIST_ITEM_LEN, "%s%s: %s\n",
		((highlightbanned && IsPlayerBanned(name)) ? (C_RED):(C_WHITE)),
		ipstr,
		name);
}


// Testing

ACMD:testplist[5](playerid, params[])
{
	new list[3][MAX_PLAYER_NAME];

	list[0] = "Southclaw";
	list[1] = "Dogmeat";
	list[2] = "Atomsk";

	ShowPlayerList(playerid, list);
}

ACMD:players[4](playerid, params[])
{
	new
		idx,
		list[MAX_PLAYERS][MAX_PLAYER_NAME];

	foreach(new i : Player)
		GetPlayerName(i, list[idx++], MAX_PLAYER_NAME);

	ShowPlayerList(playerid, list, idx);

	return 1;
}

ACMD:profile[2](playerid, params[])
{
	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, params, GetPlayerInfo(params), "Close");

	return 1;
}

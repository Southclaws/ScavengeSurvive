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
	pls_CurrentItem[MAX_PLAYERS],
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
	Dialog_Show(playerid, PlayerList, DIALOG_STYLE_LIST, "Player list", pls_String[playerid], "Select", "Close");
}

Dialog:PlayerList(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		_ShowPlayerListItem(playerid, listitem);
	}
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
	pls_CurrentItem[playerid] = item;
	Dialog_Show(playerid, PlayerListItem, DIALOG_STYLE_MSGBOX, pls_List[playerid][item], GetPlayerInfo(pls_List[playerid][item]), "Options", "Back");
}

Dialog:PlayerListItem(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		// Show some options.
		_ShowPlayerListItemOptions(playerid, pls_CurrentItem[playerid]);
	}
	else
	{
		// Send them back to the original list using the global list.
		_ShowCurrentList(playerid);
	}
}

GetPlayerInfo(name[])
{
	new
		info[512],
		dayslived,

		pass[129],
		ipv4[16],
		country[32],
		alive,
		regdate,
		lastlog,
		spawntime,
		totalspawns,
		warnings,
		hash[41],
		active,
		banned,
		admin,
		whitelist,
		reported;

	GetAccountData(name, pass, ipv4, alive, regdate, lastlog, spawntime, totalspawns, warnings, hash, active, banned, admin, whitelist, reported);

	GetIPCountry(ipv4, country);

	dayslived = (gettime() > spawntime) ? (0) : ((gettime() - spawntime) / 86400);

	format(info, sizeof(info), "\
		IP:\t\t\t%s\n\
		Country:\t\t%s\n\
		Alive:\t\t\t%s\n\
		Registered:\t\t%s\n\
		Last Login:\t\t%s\n\
		Days Survived:\t%d\n\
		Lives Lived:\t\t%d\n\
		Warnings:\t\t%d",

		ipv4,
		country,
		alive ? ("Yes") : ("No"),
		TimestampToDateTime(regdate),
		TimestampToDateTime(lastlog),
		dayslived,
		totalspawns,
		warnings);

	return info;
}

_ShowPlayerListItemOptions(playerid, item)
{
	pls_CurrentItem[playerid] = item;
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

	Dialog_Show(playerid, PlayerListItemOptions, DIALOG_STYLE_LIST, "Options", options, "Select", "Back");
	return 1;
}

Dialog:PlayerListItemOptions(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
		_ShowPlayerListItem(playerid, pls_CurrentItem[playerid]);
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
			//
		}
		case 3:// List accounts used by this GPCI
		{
			//
		}
		case 4:// List IPs used by this name
		{
			//
		}
		case 5:// List GPCIs used by this name
		{
			//
		}
		case 6:// Ban
		{
			BanAndEnterInfo(playerid, pls_List[playerid][pls_CurrentItem[playerid]]);
			return 1;
		}
		case 7:// Toggle alive
		{
			new alivestate;

			GetAccountAliveState(pls_List[playerid][pls_CurrentItem[playerid]], alivestate);

			if(alivestate)
			{
				SetAccountAliveState(pls_List[playerid][pls_CurrentItem[playerid]], 0);
				ChatMsg(playerid, YELLOW, " >  Player alive state set to dead.");
			}
			else
			{
				SetAccountAliveState(pls_List[playerid][pls_CurrentItem[playerid]], 1);
				ChatMsg(playerid, YELLOW, " >  Player alive state set to alive.");
			}
		}
		case 8: // Toggle active
		{
			new activestate;

			GetAccountActiveState(pls_List[playerid][pls_CurrentItem[playerid]], activestate);

			if(activestate)
			{
				SetAccountActiveState(pls_List[playerid][pls_CurrentItem[playerid]], 0);
				ChatMsg(playerid, YELLOW, " >  Player active state set to inactive.");
			}
			else
			{
				SetAccountActiveState(pls_List[playerid][pls_CurrentItem[playerid]], 1);
				ChatMsg(playerid, YELLOW, " >  Player active state set to active.");
			}
		}
	}

	return 0;
}

_FormatPlayerListItem(name[], output[], highlightbanned)
{
	new ipv4[16];

	GetAccountIP(name, ipv4);

	format(output, PLAYER_LIST_ITEM_LEN, "%s%s: %s\n",
		((highlightbanned && IsPlayerBanned(name)) ? (C_RED):(C_WHITE)),
		ipv4,
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
	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, params, GetPlayerInfo(params), "Close", "");

	return 1;
}

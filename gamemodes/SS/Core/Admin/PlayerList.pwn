#define PLAYER_LIST_MAX_ITEMS	(32)
#define PLAYER_LIST_ITEM_LEN	(MAX_PLAYER_NAME + 64) // 100ish max extra chars


static
	pls_String[MAX_PLAYERS][PLAYER_LIST_MAX_ITEMS * PLAYER_LIST_ITEM_LEN],
	pls_List[MAX_PLAYERS][PLAYER_LIST_MAX_ITEMS][MAX_PLAYER_NAME],
	pls_Length[MAX_PLAYERS];


stock ShowPlayerList(playerid, list[][], size = sizeof(list))
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
		_FormatPlayerListItem(list[i], item);

		// Concat the list item onto the big string
		strcat(pls_String[playerid], item);
	}

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
			ShowPlayerList(playerid, pls_List[playerid], pls_Length[playerid]);
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

	dayslived = (gettime() > spawntime) ? (0) : ((gettime() - spawntime) / 86400);

	format(info, sizeof(info), "\
		IP:\t\t\t%s\n\
		Alive:\t\t\t%s\n\
		Karma:\t\t\t%d\n\
		Registered:\t\t%s\n\
		Last Login:\t\t%s\n\
		Days Survived:\t%d\n\
		Lives Lived:\t\t%d\n\
		Warnings:\t\t%d",

		IpIntToStr(ipv4),
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
				Msg(playerid, YELLOW, " >  Not implemented.");
			}
			case 1:// Set spawn
			{
				Msg(playerid, YELLOW, " >  Not implemented.");
			}
			case 2:// List accounts used by this IP
			{
				Msg(playerid, YELLOW, " >  Not implemented.");
			}
			case 3:// List accounts used by this GPCI
			{
				Msg(playerid, YELLOW, " >  Not implemented.");
			}
			case 4:// List IPs used by this name
			{
				Msg(playerid, YELLOW, " >  Not implemented.");
			}
			case 5:// List GPCIs used by this name
			{
				Msg(playerid, YELLOW, " >  Not implemented.");
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
					Msg(playerid, YELLOW, " >  Player alive state set to dead.");
				}
				else
				{
					SetAccountAliveState(pls_List[playerid][item], 1);
					Msg(playerid, YELLOW, " >  Player alive state set to alive.");
				}
			}
			case 8: // Toggle active
			{
				new activestate;

				GetAccountActiveState(pls_List[playerid][item], activestate);

				if(activestate)
				{
					SetAccountActiveState(pls_List[playerid][item], 0);
					Msg(playerid, YELLOW, " >  Player active state set to inactive.");
				}
				else
				{
					SetAccountActiveState(pls_List[playerid][item], 1);
					Msg(playerid, YELLOW, " >  Player active state set to active.");
				}
			}
		}

		_ShowPlayerListItem(playerid, item);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Options", options, "Select", "Back");

	return 1;
}

_FormatPlayerListItem(name[], output[])
{
	new
		tabs[6],
		ip,
		ipstr[17];

	GetAccountIP(name, ip);
	ipstr = IpIntToStr(ip);

	for(new i, j = floatround((24 - strlen(name)) / 8, floatround_floor); i < j; i++)
		tabs[i] = '\t';

	format(output, PLAYER_LIST_ITEM_LEN, "%s%s%s\n", name, tabs, ipstr);
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

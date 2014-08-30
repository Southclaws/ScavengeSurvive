#define PLAYER_LIST_MAX_ITEMS	(32)
#define PLAYER_LIST_ITEM_LEN	(MAX_PLAYER_NAME + 64) // 100ish max extra chars


static
	pls_String[MAX_PLAYERS][PLAYER_LIST_MAX_ITEMS * PLAYER_LIST_ITEM_LEN],
	pls_List[MAX_PLAYERS][MAX_PLAYER_NAME];


stock ShowPlayerList(playerid, list[][], size = sizeof(list[]))
{
	new
		listitem[PLAYER_LIST_ITEM_LEN];

	for(new i; i < size; i++)
	{
		// Copy the input list to global storage
		pls_List[playerid][i][0] = EOS;
		strcat(pls_List[playerid][i], list[i]);

		// Format the list item
		_FormatPlayerListItem(list[i], listitem);

		// Concat the list item onto the big string
		strcat(pls_String[playerid], listitem);
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			ban_CurrentReason[playerid][0] = EOS;
			strcat(ban_CurrentReason[playerid], inputtext);

			FormatBanDurationDialog(playerid);
		}
		else
		{
			ResetBanVariables(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Player list", pls_String[playerid], "Select", "Close");
}

stock HidePlayerList(playerid)
{
	// hide controls
}

_ShowPlayerListControls(playerid)
{
	// deactivate all, or whatever
}

_HidePlayerListControls(playerid)
{

}

_ShowPlayerListItem(playerid, item)
{
	// Show some more info about the player

	new item[128];

	// TODO: add more info
	format(item, sizeof(item), "Name: %s\nOther info: none", pls_List[playerid][item]);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			// Send them back to the original list using the global list.
			ShowPlayerList(playerid, pls_List[playerid]);
			// ShowPlayerListItemOptions(playerid, item);
		}
		else
		{
			// Send them back to the original list using the global list.
			ShowPlayerList(playerid, pls_List[playerid]);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, pls_List[playerid][item], info, "Options", "Back");
}

_FormatPlayerListItem(name[], output[])
{
	new tabs[5];

	for(new i, j = floatround((24 - strlen(name)) / 4); i < j i++)
		tabs[i] = '\t';

	format(output, PLAYER_LIST_ITEM_LEN, "%s%s")
}


// Testing

CMD:testplist(playerid, params[])
{
	new list[3][MAX_PLAYER_NAME];

	list[0] = "Southclaw";
	list[1] = "Dogmeat";
	list[2] = "Atomsk";

	ShowPlayerList(playerid, list);
}

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


#define MAX_BANS_PER_PAGE (20)


static
	banlist_ViewingList[MAX_PLAYERS],
	banlist_CurrentIndex[MAX_PLAYERS],
	banlist_CurrentName[MAX_PLAYERS][MAX_PLAYER_NAME];


forward OnBanListShow(playerid, totalbans, listitems, index, list[]);
forward OnBanInfoShow(playerid, name[], timestamp, reason[], bannedby[], duration);


ShowListOfBans(playerid, index = 0)
{
	return GetBanList(playerid, MAX_BANS_PER_PAGE, index, "OnBanListShow");
}

public OnBanListShow(playerid, totalbans, listitems, index, list[])
{
	if(listitems == 0 || listitems == -1)
	{
		ChatMsg(playerid, YELLOW, " >  No bans to show");
		return 0;
	}

	banlist_ViewingList[playerid] = true;
	banlist_CurrentIndex[playerid] = index;

	ShowPlayerPageButtons(playerid);
	Dialog_Show(playerid, ListOfBans, DIALOG_STYLE_LIST, sprintf("Bans (%d-%d of %d)", index, index + listitems, totalbans), list, "Open", "Close");

	return 1;
}

Dialog:ListOfBans(playerid, dialogid, response, listitem, inputtext[])
{
	if(response)
	{
		new name[MAX_PLAYER_NAME];
		strmid(name, inputtext, 0, MAX_PLAYER_NAME);
		ShowBanInfo(playerid, name);
	}

	banlist_ViewingList[playerid] = false;
	HidePlayerPageButtons(playerid);
	CancelSelectTextDraw(playerid);
}

ShowBanInfo(playerid, name[MAX_PLAYER_NAME])
{
	return GetBanInfo(playerid, name, "OnBanInfoShow");
}

public OnBanInfoShow(playerid, name[], timestamp, reason[], bannedby[], duration)
{
	new str[256];

	format(str, 256, "\
		"C_YELLOW"Date:\n\t\t"C_BLUE"%s - %s\n\n\n\
		"C_YELLOW"By:\n\t\t"C_BLUE"%s\n\n\n\
		"C_YELLOW"Reason:\n\t\t"C_BLUE"%s",
		TimestampToDateTime(timestamp),
		duration ? TimestampToDateTime(timestamp + duration) : "Never",
		bannedby,
		reason);

	banlist_CurrentName[playerid][0] = EOS;
	strcat(banlist_CurrentName[playerid], name, MAX_PLAYER_NAME);

	Dialog_Show(playerid, BanInfo, DIALOG_STYLE_MSGBOX, name, str, "Options", "Back");

	return 1;
}

Dialog:BanInfo(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		ShowBanOptions(playerid);
	}
	else
	{
		ShowListOfBans(playerid);
	}
}

ShowBanOptions(playerid)
{
	Dialog_Show(playerid, BanOptions, DIALOG_STYLE_LIST, banlist_CurrentName[playerid], "Edit reason\nEdit duration\nSet unban\nUnban\n", "Select", "Back");

	return 1;
}

Dialog:BanOptions(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0: // Edit reason
				ShowBanReasonEdit(playerid);

			case 1: // Edit duration
				ShowBanDurationEdit(playerid);

			case 2: // Edit set unban
				ShowBanDateEdit(playerid);

			case 3: // Unban
				ShowUnbanPrompt(playerid);
		}
	}
	else
	{
		ShowBanInfo(playerid, banlist_CurrentName[playerid]);
	}
}

ShowBanReasonEdit(playerid)
{
	Dialog_Show(playerid, BanReasonEdit, DIALOG_STYLE_INPUT, "Edit ban reason", "Enter the new ban reason below.", "Enter", "Cancel");

	return 1;
}

Dialog:BanReasonEdit(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		SetBanReason(banlist_CurrentName[playerid], inputtext);
	}

	ShowBanOptions(playerid);
}

ShowBanDurationEdit(playerid)
{
	Dialog_Show(playerid, BanDurationEdit, DIALOG_STYLE_INPUT, "Edit ban reason", "Enter the new ban duration below in format <number> <days/weeks/months>", "Enter", "Cancel");

	return 1;
}

Dialog:BanDurationEdit(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new duration;

		if(!strcmp(inputtext, "forever", true))
			duration = 0;

		else
			duration = GetDurationFromString(inputtext);

		if(duration == -1)
		{
			ChatMsg(playerid, YELLOW, " >  Invalid input. Please use <number> <days/weeks/months>.");
			ShowBanDurationEdit(playerid);
		}
		else
		{
			SetBanDuration(banlist_CurrentName[playerid], duration);
			ShowBanOptions(playerid);
		}
	}

	ShowBanOptions(playerid);
}

ShowBanDateEdit(playerid)
{
	Dialog_Show(playerid, BanDateEdit, DIALOG_STYLE_INPUT, "Edit unban date", "Please enter a date in format: dd/mm/yy", "Enter", "Cancel");

	return 1;
}

Dialog:BanDateEdit(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		ChatMsg(playerid, YELLOW, " >  Not implemented.");
	}

	ShowBanOptions(playerid);
}

ShowUnbanPrompt(playerid)
{
	Dialog_Show(playerid, UnbanPrompt, DIALOG_STYLE_MSGBOX, "Unban", "Please confirm unban.", "Enter", "Cancel");

	return 1;
}

Dialog:UnbanPrompt(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		UnBanPlayer(banlist_CurrentName[playerid]);
	}

	ShowBanOptions(playerid);
}

hook OnPlayerDialogPage(playerid, direction)
{
	dbg("global", CORE, "[OnPlayerDialogPage] in /gamemodes/sss/core/admin/ban-list.pwn");

	if(banlist_ViewingList[playerid])
	{
		if(direction == 0)
			banlist_CurrentIndex[playerid] -= MAX_BANS_PER_PAGE;

		else
			banlist_CurrentIndex[playerid] += MAX_BANS_PER_PAGE;

		ShowListOfBans(playerid, banlist_CurrentIndex[playerid]);
	}
}

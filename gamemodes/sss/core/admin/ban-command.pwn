/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static
	ban_CurrentName[MAX_PLAYERS][MAX_PLAYER_NAME], // Store the name in case the player quits mid-ban
	ban_CurrentReason[MAX_PLAYERS][MAX_BAN_REASON],
	ban_CurrentDuration[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	ResetBanVariables(playerid);
}

BanAndEnterInfo(playerid, const name[MAX_PLAYER_NAME])
{
	BanPlayerByName(name, "Pending", playerid, 0);
	FormatBanReasonDialog(playerid);

	ban_CurrentName[playerid] = name;
}

ResetBanVariables(playerid)
{
	ban_CurrentName[playerid][0] = EOS;
	ban_CurrentReason[playerid][0] = EOS;
	ban_CurrentDuration[playerid] = 0;
}

FormatBanReasonDialog(playerid)
{
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
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Please enter ban reason", "Enter the ban reason below. The character limit is 128. After this screen you can choose the ban duration.", "Continue", "Cancel");
}

FormatBanDurationDialog(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			if(!strcmp(inputtext, "forever", true))
			{
				ban_CurrentDuration[playerid] = 0;
				FinaliseBan(playerid);
				return 1;
			}

			new duration = GetDurationFromString(inputtext);

			if(duration == -1)
			{
				FormatBanDurationDialog(playerid);
			}
			else
			{
				ban_CurrentDuration[playerid] = duration;
				FinaliseBan(playerid);
			}
		}
		else
		{
			FormatBanReasonDialog(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Please enter ban duration", "Enter the ban duration below. You can type a number then one of either: 'days', 'weeks' or 'months'. Type 'forever' for perma-ban.", "Continue", "Back");

	return 1;
}

FinaliseBan(playerid)
{
	if(isnull(ban_CurrentName[playerid]))
	{
		ChatMsg(playerid, RED, " >  An error occurred: 'ban_CurrentName' is null.");
		return 0;
	}

	if(!UpdateBanInfo(ban_CurrentName[playerid], ban_CurrentReason[playerid], ban_CurrentDuration[playerid]))
	{
		ChatMsg(playerid, RED, " >  An error occurred: 'UpdateBanInfo' returned 0.");
		return 0;
	}

	ChatMsg(playerid, YELLOW, " >  Banned "C_BLUE"%s", ban_CurrentName[playerid]);

	log("[BAN] %p banned %s reason: %s", playerid, ban_CurrentName[playerid], ban_CurrentReason[playerid]);

	return 1;
}

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


#define MAX_ISSUE_LENGTH			(128)
#define MAX_ISSUES_PER_PAGE			(32)
#define REDIS_DOMAIN_BUGS			"bug"


/*==============================================================================

	Submitting reports

==============================================================================*/


CMD:bug(playerid, params[])
{
	Dialog_Show(playerid, BugReport, DIALOG_STYLE_INPUT, "Bug report", ls(playerid, "BUGREPORTDI"), "Submit", "Cancel");

	return 1;
}

Dialog:BugReport(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		ReportBug(playerid, inputtext);
		ChatMsgLang(playerid, YELLOW, "BUGREPORTSU");
	}
}

ReportBug(playerid, bug[])
{
	new
		name[MAX_PLAYER_NAME],
		timestamp;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	timestamp = gettime();

	Redis_SendMessage(gRedis, REDIS_DOMAIN_ROOT"."REDIS_DOMAIN_BUGS".request", sprintf("BugIO_Create %s %d \"%s\"", name, timestamp, bug));

	ChatMsgAdmins(1, YELLOW, " >  %P"C_YELLOW" reported bug %s", playerid, bug);
}

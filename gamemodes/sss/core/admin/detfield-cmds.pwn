/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_DETFIELD_PAGESIZE		(20)
#define MAX_DETFIELD_LOG_PAGESIZE	(32)


// dfm = detection field management

enum
{
	DFM_MENU_DFLIST,
	DFM_MENU_DFOPTS,
	DFM_MENU_EXCEPTIONS,
	DFM_MENU_EXCEPTION_OPTIONS,
	DFM_MENU_EXCEPTION_ADD,
	DFM_MENU_EXCEPTION_DEL,
	DFM_MENU_DFRENAME,
	DFM_MENU_DFDELETE,
	DFM_MENU_DFLOG,
	DFM_MENU_LOGOPTS
}


static
		dfm_CurrentMenu		[MAX_PLAYERS],
		dfm_CurrentDetfield	[MAX_PLAYERS],
		// Field list
		dfm_FieldList		[MAX_PLAYERS][MAX_DETFIELD_PAGESIZE],
		dfm_PageIndex		[MAX_PLAYERS],
		// Log list
		dfm_LogIndex		[MAX_PLAYERS],
		dfm_LogBuffer		[MAX_PLAYERS][MAX_DETFIELD_LOG_PAGESIZE][E_DETLOG_BUFFER_DATA],
		// Adding
bool:	dfm_Editing			[MAX_PLAYERS],
		dfm_Name			[MAX_PLAYERS][MAX_DETFIELD_NAME],
Float:	dfm_Points			[MAX_PLAYERS][10],
		dfm_CurrentPoint	[MAX_PLAYERS],
Float:	dfm_MinZ			[MAX_PLAYERS],
Float:	dfm_MaxZ			[MAX_PLAYERS],
		dfm_Exceptions		[MAX_PLAYERS][MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME];


hook OnPlayerConnect(playerid)
{
	for(new i; i < MAX_DETFIELD_PAGESIZE; i++)
		dfm_FieldList[playerid][i] = -1;

	dfm_CurrentMenu[playerid]		= -1;
	dfm_CurrentDetfield[playerid]	= -1;

	dfm_LogIndex[playerid]			= 0;
	dfm_PageIndex[playerid]			= 0;
	dfm_Editing[playerid]			= false;
	dfm_Name[playerid][0]			= EOS;
	dfm_Points[playerid]			= Float:{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
	dfm_MinZ[playerid]				= 0.0;
	dfm_MaxZ[playerid]				= 0.0;
}

ACMD:field[2](playerid, params[])
{
	if(isnull(params))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /field list/add/remove/log");
		return 1;
	}

	if(!strcmp(params, "list", true, 4))
	{
		new ret = ShowDetfieldList(playerid);

		if(ret == 0)
			ChatMsg(playerid, YELLOW, " >  There are no detection fields to list.");
	}

	if(!strcmp(params, "log", true, 3))
	{
		new
			name[MAX_DETFIELD_NAME],
			id;

		if(sscanf(params, "{s[4]}s[24]", name))
		{
			ChatMsg(playerid, YELLOW, " >  Usage: /field log [name]");
			return 1;
		}

		id = GetDetectionFieldIdFromName(name);

		if(!IsValidDetectionField(id))
		{
			ChatMsg(playerid, YELLOW, " >  Invalid detection field name");
			return 1;
		}


		new ret = ShowDetfieldLog(playerid, id);

		if(ret == 1)
			ChatMsg(playerid, YELLOW, " >  Displaying log entries for detection field '%s'.", name);

		else
			ChatMsg(playerid, YELLOW, " >  There are no log entries in '%s'.", name);
	}

	if(!strcmp(params, "add", true, 3))
	{
		new name[MAX_DETFIELD_NAME];

		if(sscanf(params, "{s[4]}s[24]", name))
		{
			ChatMsg(playerid, YELLOW, " >  Usage: /field add [name]");
			return 1;
		}

		GetPlayerPos(playerid, dfm_MinZ[playerid], dfm_MinZ[playerid], dfm_MinZ[playerid]);

		dfm_Editing[playerid] = true;
		dfm_Name[playerid] = name;
		dfm_MinZ[playerid] -= 0.8;
		dfm_MaxZ[playerid] = dfm_MinZ[playerid] + 1.2;
		dfm_CurrentPoint[playerid] = 0;

		AddNewDetectionFieldPoint(playerid);

		return 1;
	}

	if(!strcmp(params, "remove", true, 6))
	{
		new
			name[MAX_DETFIELD_NAME],
			id;

		if(sscanf(params, "{s[7]}s[24]", name))
		{
			ChatMsg(playerid, YELLOW, " >  Usage: /field remove [name]");
			return 1;
		}

		id = GetDetectionFieldIdFromName(name);

		if(!IsValidDetectionField(id))
		{
			ChatMsg(playerid, YELLOW, " >  Invalid detection field name");
			return 1;
		}

		ShowDetfieldDeletePrompt(playerid, id);
	}

	if(!strcmp(params, "rename", true, 6))
	{
		new
			name[MAX_DETFIELD_NAME],
			id;

		if(sscanf(params, "{s[7]}s[24]", name))
		{
			ChatMsg(playerid, YELLOW, " >  Usage: /field remove [name]");
			return 1;
		}

		id = GetDetectionFieldIdFromName(name);

		if(!IsValidDetectionField(id))
		{
			ChatMsg(playerid, YELLOW, " >  Invalid detection field name");
			return 1;
		}

		ShowDetfieldRenamePrompt(playerid, id);
	}

	if(!strcmp(params, "name", true, 4))
	{
		new
			name[MAX_PLAYER_NAME];

		if(sscanf(params, "{s[8]}s[24]", name))
		{
			ChatMsg(playerid, YELLOW, " >  Usave: /field name [name]");
			return 1;
		}

		new count = ShowDetfieldNameFields(playerid, name);

		if(count == 0)
			ChatMsg(playerid, YELLOW, " >  No field records found for '"C_BLUE"%s"C_YELLOW"'.", name);
	}

	return 1;
}

ShowDetfieldList(playerid)
{
	dfm_CurrentMenu[playerid] = DFM_MENU_DFLIST;

	new
		total,
		count,
		title[34],
		list[MAX_DETFIELD_PAGESIZE * (MAX_DETFIELD_NAME + 1)];

	total = GetTotalDetectionFields();
	count = GetDetectionFieldList(dfm_FieldList[playerid], list, MAX_DETFIELD_PAGESIZE, dfm_PageIndex[playerid]);

	if(count == 0)
	{
		dfm_PageIndex[playerid] = 0;
		return 0;
	}

	format(title, sizeof(title), "Detection Fields (%d-%d of %d)",
		dfm_PageIndex[playerid],
		(dfm_PageIndex[playerid] + count > total) ? (total) : (dfm_PageIndex[playerid] + count),
		total);

	ShowPlayerPageButtons(playerid);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			dfm_CurrentDetfield[playerid] = dfm_FieldList[playerid][listitem];
			ShowDetfieldListOptions(playerid, dfm_FieldList[playerid][listitem]);
			HidePlayerPageButtons(playerid);
			CancelSelectTextDraw(playerid);
		}
		else
		{
			for(new i; i < MAX_DETFIELD_PAGESIZE; i++)
				dfm_FieldList[playerid][i] = -1;

			dfm_CurrentMenu[playerid]		= -1;
			dfm_CurrentDetfield[playerid]	= -1;
			dfm_LogIndex[playerid]			= 0;
			dfm_PageIndex[playerid]			= 0;

			HidePlayerPageButtons(playerid);
			CancelSelectTextDraw(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, title, list, "Options", "Close");

	return 1;
}

ShowDetfieldListOptions(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_DFOPTS;

	new
		name[MAX_DETFIELD_NAME],
		exceptioncount;

	GetDetectionFieldName(detfieldid, name);
	exceptioncount = GetDetectionFieldExceptionCount(detfieldid);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					if(!ShowDetfieldLog(playerid, detfieldid))
					{
						ChatMsg(playerid, YELLOW, " >  There are no log entries in '%s'.", name);
						ShowDetfieldListOptions(playerid, detfieldid);
					}
				}

				case 1:
				{
					if(IsPlayerOnAdminDuty(playerid))
					{
						new
							Float:x,
							Float:y,
							Float:z;

						GetDetectionFieldPos(detfieldid, x, y, z);
						SetPlayerPos(playerid, x, y, z);
					}
					else
					{
						ChatMsg(playerid, RED, " >  You must be on admin duty to do that.");
					}
				}

				case 2:
				{
 					if(exceptioncount > 0)
						ShowDetfieldExceptions(playerid, detfieldid);
					else
						ShowDetfieldAddException(playerid, detfieldid, -1); 
				}

				case 3:
				{
					ShowDetfieldRenamePrompt(playerid, detfieldid);
				}

				case 4:
				{
					ShowDetfieldDeletePrompt(playerid, detfieldid);
				}
			}
		}
		else
		{
			ShowDetfieldList(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, name, sprintf("View Log\nGo to\nExceptions (%d)\nRename\nDelete", exceptioncount), "Select", "Back");

	return 1;
}

ShowDetfieldExceptions(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_EXCEPTIONS;

	new
		name[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldid, name);

	if(GetDetectionFieldExceptionCount(detfieldid) == 0)
	{
		ChatMsg(playerid, YELLOW, " >  No exceptions for '%s'.", name);
		ShowDetfieldListOptions(playerid, detfieldid);
		return 0;
	}

	new
		list[MAX_DETFIELD_EXCEPTIONS * (MAX_PLAYER_NAME + 3)],
		count;

	count = GetDetectionFieldExceptionsList(detfieldid, list, sizeof(list), '\n');

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			ShowDetfieldExceptionOptions(playerid, detfieldid, listitem);
		}
		else
		{
			ShowDetfieldListOptions(playerid, detfieldid);
		}
	}

	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, sprintf("%s Exceptions (%d)", name, count), list, "Options", "Back");

	return 1;
}

ShowDetfieldExceptionOptions(playerid, detfieldid, exceptionid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_EXCEPTION_OPTIONS;

	new name[MAX_PLAYER_NAME];

	GetDetectionFieldExceptionName(detfieldid, exceptionid, name);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					ShowDetfieldAddException(playerid, detfieldid, exceptionid);
				}

				case 1:
				{
					ShowDetfieldDeleteException(playerid, detfieldid, exceptionid);
				}
			}
		}
		else
		{
			ShowDetfieldExceptions(playerid, detfieldid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, name, sprintf("Add exception\nDelete '%s'", name), "Select", "Back");

	return 1;
}

ShowDetfieldAddException(playerid, detfieldid, exceptionid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_EXCEPTION_ADD;

	new
		name[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldid, name);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			new tmp[MAX_PLAYER_NAME];
			strcat(tmp, inputtext);

			new ret = AddDetectionFieldException(detfieldid, tmp);

			if(ret)
			{
				ShowDetfieldExceptions(playerid, detfieldid);
				return 1;
			}

			if(ret == 0)
			{
				ChatMsg(playerid, RED, " >  Invalid detection field (error code 0)");
				ShowDetfieldAddException(playerid, detfieldid, exceptionid);
			}

			if(ret == -1)
			{
				ChatMsg(playerid, RED, " >  Exception list is full (error code -1)");
				ShowDetfieldExceptionOptions(playerid, detfieldid, exceptionid);
			}

			if(ret == -2)
			{
				ChatMsg(playerid, RED, " >  Invalid username (error code -2)");
				ShowDetfieldAddException(playerid, detfieldid, exceptionid);
			}

			if(ret == -3)
			{
				ChatMsg(playerid, RED, " >  Username already in list (error code -3)");
				ShowDetfieldAddException(playerid, detfieldid, exceptionid);
			}
		}
		else
		{
 			if(exceptionid != -1)
				ShowDetfieldExceptionOptions(playerid, detfieldid, exceptionid);
			else
				ShowDetfieldListOptions(playerid, detfieldid); 
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, sprintf("Add exception for %s", name), "Type a username:", "Add", "Back");

	return 1;
}

ShowDetfieldDeleteException(playerid, detfieldid, exceptionid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_EXCEPTION_DEL;

	new name[MAX_PLAYER_NAME];

	GetDetectionFieldExceptionName(detfieldid, exceptionid, name);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(!response)
			RemoveDetectionFieldExceptionID(detfieldid, exceptionid);

		ShowDetfieldExceptions(playerid, detfieldid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, sprintf("Delete '%s'", name), "Are you sure?", "Back", "Delete");

	return 1;
}

ShowDetfieldRenamePrompt(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_DFRENAME;

	new name[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldid, name);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			new
				tmp[MAX_DETFIELD_NAME],
				ret;

			strcat(tmp, inputtext);

			ret = SetDetectionFieldName(detfieldid, tmp);

			if(ret == -1)
				ChatMsg(playerid, RED, " >  A field with that name already exists.");

			if(ret == -2)
				ChatMsg(playerid, RED, " >  Invalid detection field name. Must start with an alphabetic character and can contain only alphanumeric characters.");
		}

		ShowDetfieldListOptions(playerid, detfieldid);
	}

	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, sprintf("Rename %s", name), "Enter new name:", "Rename", "Back");

	return 1;
}

ShowDetfieldDeletePrompt(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_DFDELETE;

	new name[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldid, name);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(!response)
			RemoveDetectionField(detfieldid);

		ShowDetfieldList(playerid);
	}
	
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, sprintf("Delete %s", name), "Are you sure?", "Back", "Delete");

	return 1;
}

ShowDetfieldLog(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_DFLOG;

	new
		list[MAX_DETFIELD_LOG_PAGESIZE * (MAX_DETFIELD_NAME + 1)],
		name[MAX_DETFIELD_NAME],
		title[MAX_DETFIELD_NAME + 32],
		count,
		total;

	count = GetDetectionFieldLogBuffer(detfieldid, dfm_LogBuffer[playerid], MAX_DETFIELD_LOG_PAGESIZE, dfm_LogIndex[playerid]);
	GetDetectionFieldName(detfieldid, name);
	total = GetDetectionFieldLogEntries(detfieldid);

	for(new i; i < count; i++)
	{
		format(list, sizeof(list), "%s%06d:%s %s (%.1f,%.1f,%.1f)\n",
			list,
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_ROW_ID],
			TimestampToDateTime(dfm_LogBuffer[playerid][i][DETLOG_BUFFER_DATE], "%d/%m/%y %X"),
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_NAME],
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_POS_X],
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_POS_Y],
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_POS_Z]);
	}

	format(title, sizeof(title), "%s (%d-%d of %d)", name, dfm_LogIndex[playerid], dfm_LogIndex[playerid] + count, total);

	if(count == 0)
	{
		dfm_LogIndex[playerid] = 0;
		return 0;
	}

	ShowPlayerPageButtons(playerid);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, response, listitem, inputtext

		if(response)
		{
			ShowDetfieldLogOptions(playerid, detfieldid, listitem);
		}
		else
		{
			ShowDetfieldListOptions(playerid, detfieldid);
		}

		HidePlayerPageButtons(playerid);
		CancelSelectTextDraw(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, title, list, "Select", "Back");

	return 1;
}

ShowDetfieldLogOptions(playerid, detfieldid, logentry)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_LOGOPTS;

	new name[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldid, name);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, response, inputtext

		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					if(IsPlayerOnAdminDuty(playerid))
					{
						SetPlayerPos(playerid,
							dfm_LogBuffer[playerid][logentry][DETLOG_BUFFER_POS_X],
							dfm_LogBuffer[playerid][logentry][DETLOG_BUFFER_POS_Y],
							dfm_LogBuffer[playerid][logentry][DETLOG_BUFFER_POS_Z]);
					}
					else
					{
						ChatMsg(playerid, RED, " >  You must be on admin duty to do that.");
					}
				}

				case 1:
				{
					DeleteDetectionFieldLogEntry(detfieldid, dfm_LogBuffer[playerid][logentry][DETLOG_BUFFER_ROW_ID]);

					ShowDetfieldLog(playerid, detfieldid);
				}

				case 2:
				{
					DeleteDetectionFieldLogsOfName(detfieldid, dfm_LogBuffer[playerid][logentry][DETLOG_BUFFER_NAME]);

					ShowDetfieldLog(playerid, detfieldid);
				}
			}
		}
		else
		{
			ShowDetfieldLog(playerid, detfieldid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, name, "Go to\nDelete\nDelete all of this name", "Select", "Close");

	return 1;
}

ShowDetfieldNameFields(playerid, name[])
{
	new
		count,
		title[64],
		list[MAX_DETFIELD_PAGESIZE * (MAX_DETFIELD_NAME + 16)];

	count = GetDetectionFieldNameLog(name, list, MAX_DETFIELD_PAGESIZE, dfm_PageIndex[playerid], sizeof(list));

	format(title, sizeof(title), "%s (last %d fields from index %d)", name, count, dfm_PageIndex[playerid]);

	if(count == 0)
	{
		return 0;
	}

	// TODO: make proper pagination for this menu.
	// ShowPlayerPageButtons(playerid);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, response, listitem, inputtext

		// TODO: do something with the data (jump to field log or something).
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, title, list, "Select", "Back");

	return 1;
}

hook OnPlayerDialogPage(playerid, direction)
{
	if(dfm_CurrentMenu[playerid] == DFM_MENU_DFLIST)
	{
		if(direction == 0)
		{
			dfm_PageIndex[playerid] -= MAX_DETFIELD_PAGESIZE;

			if(dfm_PageIndex[playerid] < 0)
				dfm_PageIndex[playerid] = 0;
		}
		else
		{
			dfm_PageIndex[playerid] += MAX_DETFIELD_PAGESIZE;
		}

		ShowDetfieldList(playerid);
	}

	if(dfm_CurrentMenu[playerid] == DFM_MENU_DFLOG)
	{
		if(direction == 0)
		{
			dfm_LogIndex[playerid] -= MAX_DETFIELD_LOG_PAGESIZE;

			if(dfm_LogIndex[playerid] < 0)
				dfm_LogIndex[playerid] = 0;
		}
		else
		{
			dfm_LogIndex[playerid] += MAX_DETFIELD_LOG_PAGESIZE;
		}

		ShowDetfieldLog(playerid, dfm_CurrentDetfield[playerid]);
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(dfm_Editing[playerid])
	{
		if(newkeys == 128)
		{
			AddNewDetectionFieldPoint(playerid);
		}
	}

	return 1;
}

AddNewDetectionFieldPoint(playerid)
{
	new Float:z;

	GetPlayerPos(playerid,
		dfm_Points[playerid][dfm_CurrentPoint[playerid] * 2],
		dfm_Points[playerid][(dfm_CurrentPoint[playerid] * 2) + 1],
		z);

	if(dfm_CurrentPoint[playerid] == 3)
	{
		dfm_Points[playerid][8] = dfm_Points[playerid][0];
		dfm_Points[playerid][9] = dfm_Points[playerid][1];

		GetPlayerName(playerid, dfm_Exceptions[playerid][0], MAX_PLAYER_NAME);

		dfm_Editing[playerid] = false;

		new ret = AddDetectionField(dfm_Name[playerid], dfm_Points[playerid], dfm_MinZ[playerid], dfm_MaxZ[playerid], dfm_Exceptions[playerid]);

		if(ret < 0)
		{
			ChatMsg(playerid, RED, " >  An error occurred (code: %d)", ret);
		}
		else
		{
			ChatMsg(playerid, YELLOW, " >  Point %d set to %f, %f. Field '%s' created.",
				dfm_CurrentPoint[playerid] + 1,
				dfm_Points[playerid][dfm_CurrentPoint[playerid] * 2],
				dfm_Points[playerid][(dfm_CurrentPoint[playerid] * 2) + 1],
				dfm_Name[playerid]);
		}
	}
	else
	{
		ChatMsg(playerid, YELLOW, " >  Point %d set to %f, %f. Move to the next point and press "C_BLUE"~k~~PED_LOCK_TARGET~", dfm_CurrentPoint[playerid] + 1, dfm_Points[playerid][dfm_CurrentPoint[playerid] * 2], dfm_Points[playerid][(dfm_CurrentPoint[playerid] * 2) + 1]);
	}

	dfm_CurrentPoint[playerid]++;
}

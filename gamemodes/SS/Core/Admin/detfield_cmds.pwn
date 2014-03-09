#include <YSI\y_hooks>


// dfm = detection field management

static
		// Field list
		dfm_FieldList		[MAX_PLAYERS][MAX_DETFIELD_PAGESIZE],
		dfm_PageIndex		[MAX_PLAYERS],
		// Log list
		dfm_LogIndex		[MAX_PLAYERS],
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

	dfm_LogIndex[playerid]		= 0;
	dfm_PageIndex[playerid]		= 0;
	dfm_Editing[playerid]		= false;
	dfm_Name[playerid][0]		= EOS;
	dfm_Points[playerid]		= Float:{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
	dfm_MinZ[playerid]			= 0.0;
	dfm_MaxZ[playerid]			= 0.0;
}

ACMD:field[2](playerid, params[])
{
	if(isnull(params))
	{
		Msg(playerid, YELLOW, " >  Usage: /field list/add/remove/log");
		return 1;
	}

	if(!strcmp(params, "list", true, 4))
	{
		ShowDetfieldList(playerid);
	}

	if(!strcmp(params, "log", true, 3))
	{
		new
			name[MAX_DETFIELD_NAME],
			id;

		if(sscanf(params, "{s[4]}s[24]", name))
		{
			Msg(playerid, YELLOW, " >  Usage: /field log [name]");
			return 1;
		}

		id = GetDetectionFieldIdFromName(name);

		if(!IsValidDetectionField(id))
		{
			Msg(playerid, YELLOW, " >  Invalid detection field name");
			return 1;
		}

		MsgF(playerid, YELLOW, " >  Displaying log entries for detection field '%s'.", name);

		ShowDetfieldLog(playerid, id);
	}

	if(!strcmp(params, "add", true, 3))
	{
		new name[MAX_DETFIELD_NAME];

		if(sscanf(params, "{s[4]}s[24]", name))
		{
			Msg(playerid, YELLOW, " >  Usage: /field add [name]");
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
			Msg(playerid, YELLOW, " >  Usage: /field remove [name]");
			return 1;
		}

		id = GetDetectionFieldIdFromName(name);

		if(!IsValidDetectionField(id))
		{
			Msg(playerid, YELLOW, " >  Invalid detection field name");
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
			Msg(playerid, YELLOW, " >  Usage: /field remove [name]");
			return 1;
		}

		id = GetDetectionFieldIdFromName(name);

		if(!IsValidDetectionField(id))
		{
			Msg(playerid, YELLOW, " >  Invalid detection field name");
			return 1;
		}

		ShowDetfieldRenamePrompt(playerid, id);
	}

	return 1;
}

ShowDetfieldList(playerid)
{
	new
		total,
		count,
		title[34],
		list[MAX_DETFIELD_PAGESIZE * (MAX_DETFIELD_NAME + 1)];

	total = GetTotalDetectionFields();
	count = GetDetectionFieldList(dfm_FieldList[playerid], list, MAX_DETFIELD_PAGESIZE, dfm_PageIndex[playerid]);

	if(count == 0)
	{
		Msg(playerid, YELLOW, " >  There are no detection fields to list.");
		return 0;
	}

	format(title, sizeof(title), "Detection Fields (%d-%d of %d)",
		count,
		(count + MAX_DETFIELD_PAGESIZE > total) ? (total) : (count + MAX_DETFIELD_PAGESIZE),
		total);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			ShowDetfieldListOptions(playerid, dfm_FieldList[playerid][listitem]);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, title, list, "Options", "Close");

	return 1;
}

ShowDetfieldListOptions(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

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
					ShowDetfieldLog(playerid, detfieldid);
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
						Msg(playerid, RED, " >  You must be on admin duty to do that.");
					}
				}

				case 2:
				{
					ShowDetfieldExceptions(playerid, detfieldid);
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

	new
		name[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldid, name);

	if(GetDetectionFieldExceptionCount(detfieldid) == 0)
	{
		MsgF(playerid, YELLOW, " >  No exceptions for '%s'.", name);
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
				Msg(playerid, RED, " >  Invalid detection field (error code 0)");
				ShowDetfieldAddException(playerid, detfieldid, exceptionid);
			}

			if(ret == -1)
			{
				Msg(playerid, RED, " >  Exception list is full (error code -1)");
				ShowDetfieldExceptionOptions(playerid, detfieldid, exceptionid);
			}

			if(ret == -2)
			{
				Msg(playerid, RED, " >  Invalid username (error code -2)");
				ShowDetfieldAddException(playerid, detfieldid, exceptionid);
			}

			if(ret == -3)
			{
				Msg(playerid, RED, " >  Username already in list (error code -3)");
				ShowDetfieldAddException(playerid, detfieldid, exceptionid);
			}
		}
		else
		{
			ShowDetfieldExceptionOptions(playerid, detfieldid, exceptionid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, sprintf("Add exception for %s", name), "Type a username:", "Add", "Back");

	return 1;
}

ShowDetfieldDeleteException(playerid, detfieldid, exceptionid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

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
				Msg(playerid, RED, " >  A field with that name already exists.");

			if(ret == -2)
				Msg(playerid, RED, " >  Invalid detection field name. Must start with an alphabetic character and can contain only alphanumeric characters.");
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

	new
		list[MAX_DETFIELD_LOG_PAGESIZE * (MAX_DETFIELD_NAME + 1)],
		name[MAX_DETFIELD_NAME],
		count;

	count = GetDetectionFieldLog(detfieldid, list, MAX_DETFIELD_PAGESIZE, dfm_LogIndex[playerid]);
	GetDetectionFieldName(detfieldid, name);

	if(count == 0)
	{
		MsgF(playerid, YELLOW, " >  There are no log entries in '%s'.", name);
		ShowDetfieldListOptions(playerid, detfieldid);
		return 0;
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, response, listitem, inputtext

		if(response)
		{
			ShowDetfieldLogOptions(playerid, detfieldid, dfm_LogIndex[playerid] + listitem + 1);
		}
		else
		{
			ShowDetfieldListOptions(playerid, detfieldid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, name, list, "Select", "Back");

	return 1;
}

ShowDetfieldLogOptions(playerid, detfieldid, logentry)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

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
					new
						Float:x,
						Float:y,
						Float:z;

					GetDetectionFieldLogEntryPos(detfieldid, logentry, x, y, z);
					SetPlayerPos(playerid, x, y, z);
				}

				case 1:
				{
					// DeleteDetectionFieldLogEntry(detfieldid, logentry);
					Msg(playerid, YELLOW, " >  That feature is currently unavailable.");

					ShowDetfieldLog(playerid, detfieldid);
				}

				case 2:
				{
					// new logname[MAX_PLAYER_NAME];
					// GetDetectionFieldLogEntryName(detfieldid, logentry, logname);
					// DeleteDetectionFieldLogsOfName(detfieldid, logname);
					Msg(playerid, YELLOW, " >  That feature is currently unavailable.");

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
			MsgF(playerid, RED, " >  An error occurred (code: %d)", ret);
		}
		else
		{
			MsgF(playerid, YELLOW, " >  Point %d set to %f, %f. Field '%s' created.",
				dfm_CurrentPoint[playerid] + 1,
				dfm_Points[playerid][dfm_CurrentPoint[playerid] * 2],
				dfm_Points[playerid][(dfm_CurrentPoint[playerid] * 2) + 1],
				dfm_Name[playerid]);
		}
	}
	else
	{
		MsgF(playerid, YELLOW, " >  Point %d set to %f, %f. Move to the next point and press "C_BLUE"~k~~PED_LOCK_TARGET~", dfm_CurrentPoint[playerid] + 1, dfm_Points[playerid][dfm_CurrentPoint[playerid] * 2], dfm_Points[playerid][(dfm_CurrentPoint[playerid] * 2) + 1]);
	}

	dfm_CurrentPoint[playerid]++;
}

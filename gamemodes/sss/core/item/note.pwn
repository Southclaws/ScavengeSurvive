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


#include <YSI\y_hooks>


static note_CurrentItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Note"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Note"), 256);
}

hook OnPlayerUseItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerUseItem] in /gamemodes/sss/core/item/note.pwn");

	if(GetItemType(itemid) == item_Note)
	{
		_ShowNoteDialog(playerid, itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_ShowNoteDialog(playerid, itemid)
{
	new string[256];

	GetItemArrayData(itemid, string);
	note_CurrentItem[playerid] = itemid;

	if(strlen(string))
		Dialog_Show(playerid, Note, DIALOG_STYLE_MSGBOX, "Note", string, "Close", "Tear");

	else
		Dialog_Show(playerid, NoteSet, DIALOG_STYLE_INPUT, "Note", "Write a message onto the note:", "Done", "Cancel");

	return 1;
}

Dialog:Note(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
		DestroyItem(note_CurrentItem[playerid]);
		note_CurrentItem[playerid] = INVALID_ITEM_ID;
	}
}

Dialog:NoteSet(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		SetItemArrayData(note_CurrentItem[playerid], inputtext, strlen(inputtext));
		note_CurrentItem[playerid] = INVALID_ITEM_ID;
	}
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{
	dbg("global", CORE, "[OnItemNameRender] in /gamemodes/sss/core/item/note.pwn");

	if(itemtype == item_Note)
	{
		new
			string[256],
			len;

		GetItemArrayData(itemid, string);
		len = strlen(string);

		if(len == 0)
		{
			SetItemNameExtra(itemid, "Blank");
		}
		else if(len > 8)
		{
			strins(string, "(...)", 8);
			string[13] = EOS;
			SetItemNameExtra(itemid, string);
		}
	}
}

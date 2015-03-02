#include <YSI\y_hooks>


#define MAX_NOTE_TEXT (64)


static
	note_Text[MAX_NOTE_TEXT][256],
	note_Total;


hook OnScriptInit()
{
	note_Text[0] = "Have you tried using the 'Combine' option to use a knife with clothes? You'll get a bandage! Always useful to have a bandage...";
	note_Text[1] = "If anyone offers to meet up to trade... ALWAYS HAVE A PLAN B.";
	note_Text[2] = "Too many people have opinions on things they know nothing about. And the more ignorant they are, the more opinions they have.";

	GetSettingStringArray("items/note/messages", note_Text, 3, note_Text, note_Total);
}


public OnItemCreate(itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_Note)
		{
			if(random(2) == 1 && note_Total > 0)
			{
				new noteid = random(note_Total);

				SetItemArrayData(itemid, note_Text[noteid], strlen(note_Text[noteid]));
			}
		}
	}

	#if defined note_OnItemCreate
		return note_OnItemCreate(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate note_OnItemCreate
#if defined note_OnItemCreate
	forward note_OnItemCreate(itemid);
#endif
public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Note)
	{
		_ShowNoteDialog(playerid, itemid);
	}

	#if defined note_OnPlayerUseItem
		return note_OnPlayerUseItem(playerid, itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
 
#define OnPlayerUseItem note_OnPlayerUseItem
#if defined note_OnPlayerUseItem
	forward note_OnPlayerUseItem(playerid, itemid);
#endif


_ShowNoteDialog(playerid, itemid)
{
	new string[256];

	GetItemArrayData(itemid, string);

	if(strlen(string) == 0)
	{
		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, listitem

			if(response)
			{
				SetItemArrayData(itemid, inputtext, strlen(inputtext));
			}
		}
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Note", "Write a message onto the note:", "Done", "Cancel");
	}
	else
	{
		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, listitem, inputtext

			if(!response)
			{
				DestroyItem(itemid);
			}
		}
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Note", string, "Close", "Tear");
	}

	return 1;
}

public OnItemNameRender(itemid, ItemType:itemtype)
{
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

	#if defined note_OnItemNameRender
		return note_OnItemNameRender(itemid, itemtype);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
 
#define OnItemNameRender note_OnItemNameRender
#if defined note_OnItemNameRender
	forward note_OnItemNameRender(itemid, ItemType:itemtype);
#endif

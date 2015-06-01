#include <YSI\y_hooks>


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

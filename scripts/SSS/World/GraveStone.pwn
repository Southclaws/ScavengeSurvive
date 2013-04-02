#include <YSI\y_hooks>


#define MAX_RIP			(128)
#define MAX_RIP_REASON	(128)
#define INVALID_RIP_ID	(-1)


enum E_RIP_DATA
{
			rip_item,
			rip_name[MAX_PLAYER_NAME],
			rip_reason[MAX_RIP_REASON]
}


static
			rip_Data[MAX_RIP][E_RIP_DATA],
Iterator:	rip_Index<MAX_RIP>;

static
Timer:		rip_PickUpTimer[MAX_PLAYERS],
			rip_CurrentStone[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	rip_CurrentStone[playerid] = -1;
}


stock CreateGravestone(playerid, reason[], Float:x, Float:y, Float:z, Float:rz, Float:zoffset = ITEM_BTN_OFFSET_Z)
{
	new id = Iter_Free(rip_Index);

	if(id == -1)
		return INVALID_RIP_ID;

	rip_Data[id][rip_item] = CreateItem(item_Torso, x, y, z, 0.0, 0.0, rz, .zoffset = zoffset);
	SetItemExtraData(rip_Data[id][rip_item], 1);
	GetPlayerName(playerid, rip_Data[id][rip_name], MAX_PLAYER_NAME);
	rip_Data[id][rip_reason][0] = EOS;
	strcat(rip_Data[id][rip_reason], reason, MAX_RIP_REASON);

	Iter_Add(rip_Index, id);

	return id;
}

stock DestroyGravestone(id)
{
	if(!Iter_Contains(rip_Index, id);
		return 0;

	if(GetItemExtraData(rip_Data[id][rip_item]) == 1)
		DestroyItem(rip_Data[id][rip_item]);

	rip_Data[id][rip_name][0] = EOS;
	rip_Data[id][rip_reason][0] = EOS;

	Iter_Remove(rip_Index, id);

	return 1;
}

ShowGravestoneMsg(playerid, id)
{
	if(!Iter_Contains(rip_Index, id))
		return 0;

	ShowPlayerDialog(playerid, d_GraveStone, DIALOG_STYLE_MSGBOX, rip_Data[id][rip_name], rip_Data[id][rip_reason], "Close", "");

	return 1;
}

public OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Torso)
	{
		foreach(new i : rip_Index)
		{
			if(itemid == rip_Data[i][rip_item])
			{
				rip_CurrentStone[playerid] = i;
				rip_PickUpTimer[playerid] = defer rip_PickUpItem(playerid, itemid);
				return 1;
			}
		}
	}

	return CallLocalFunction("rip_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem rip_OnPlayerPickUpItem
forward rip_OnPlayerPickUpItem(playerid, itemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys == 16)
	{
		if(rip_CurrentStone[playerid] != -1)
		{
			ShowGravestoneMsg(playerid, rip_CurrentStone[playerid]);
			stop rip_PickUpTimer[playerid];
			rip_CurrentStone[playerid] = INVALID_RIP_ID;
		}
	}
}

timer rip_PickUpItem[250](playerid, itemid)
{
	PlayerPickUpItem(playerid, itemid);
	SetItemExtraData(itemid, 0);
	rip_CurrentStone[playerid] = INVALID_RIP_ID;
}

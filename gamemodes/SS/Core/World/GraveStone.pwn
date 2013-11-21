#include <YSI\y_hooks>


#define MAX_RIP			(128)
#define MAX_RIP_REASON	(128)
#define INVALID_RIP_ID	(-1)


enum E_RIP_DATA
{
			rip_name[MAX_PLAYER_NAME],
			rip_reason[MAX_RIP_REASON],
			rip_spawnTick
}


new
			rip_Data[MAX_RIP][E_RIP_DATA],
Iterator:	rip_Index<MAX_RIP>;


hook OnGameModeInit()
{
	Iter_Add(rip_Index, 0);
}


stock CreateGravestone(playerid, reason[], Float:x, Float:y, Float:z, Float:rz, Float:zoffset = ITEM_BUTTON_OFFSET)
{
	new id = Iter_Free(rip_Index);

	if(id == -1)
		return INVALID_RIP_ID;

	new itemid = CreateItem(item_Torso, x, y, z, 0.0, 0.0, rz, .zoffset = zoffset);

	SetItemExtraData(itemid, id);
	GetPlayerName(playerid, rip_Data[id][rip_name], MAX_PLAYER_NAME);
	rip_Data[id][rip_reason][0] = EOS;
	strcat(rip_Data[id][rip_reason], reason, MAX_RIP_REASON);
	rip_Data[id][rip_spawnTick] = GetTickCount();

	Iter_Add(rip_Index, id);

	return id;
}

stock DestroyGravestone(id)
{
	if(!Iter_Contains(rip_Index, id);
		return 0;

	rip_Data[id][rip_name][0] = EOS;
	rip_Data[id][rip_reason][0] = EOS;

	Iter_Remove(rip_Index, id);

	return 1;
}

ShowGravestoneMsg(playerid, id)
{
	if(id == 0)
		return 0;

	if(!Iter_Contains(rip_Index, id))
		return 0;

	ShowPlayerDialog(playerid, d_GraveStone, DIALOG_STYLE_MSGBOX, rip_Data[id][rip_name], rip_Data[id][rip_reason], "Close", "");

	return 1;
}

IsValidGraveStone(id)
{
	if(!Iter_Contains(rip_Index, id))
		return 0;

	return 1;
}

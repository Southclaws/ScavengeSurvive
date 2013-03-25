#include <YSI\y_hooks>


static
Timer:	scr_Timer[MAX_PLAYERS],
Float:	scr_Progress[MAX_PLAYERS];


public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_Screwdriver && GetItemType(withitemid) == item_PhoneBomb)
	{
		if(GetItemExtraData(withitemid) == 1)
		{
			scr_StartDisarmingBomb(playerid, withitemid);
		}
	}
	return CallLocalFunction("scr_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem scr_OnPlayerUseItemWithItem
forward scr_OnPlayerUseItemWithItem(playerid, itemid, withitemid);


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		scr_StopDisarmingBomb(playerid);
	}

	return 1;
}


scr_StartDisarmingBomb(playerid, bombid)
{
	stop scr_Timer[playerid];
	scr_Timer[playerid] = repeat scr_Update(playerid, bombid);
	scr_Progress[playerid] = 1.0;

	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, 20.0);
	SetPlayerProgressBarValue(playerid, ActionBar, 0.0);
	ShowPlayerProgressBar(playerid, ActionBar);
}

scr_StopDisarmingBomb(playerid)
{
	stop scr_Timer[playerid];

	if(scr_Progress[playerid] > 0.0)
	{
		scr_Progress[playerid] = 0.0;

		ClearAnimations(playerid);
		HidePlayerProgressBar(playerid, ActionBar);
	}
}


timer scr_Update[100](playerid, bombid)
{
	if(scr_Progress[playerid] == 20)
	{
		scr_StopDisarmingBomb(playerid);
		SetItemExtraData(bombid, 0);
		return;
	}

	SetPlayerProgressBarMaxValue(playerid, ActionBar, 20.0);
	SetPlayerProgressBarValue(playerid, ActionBar, scr_Progress[playerid]);
	ShowPlayerProgressBar(playerid, ActionBar);

	scr_Progress[playerid] += 1.0;

	return;
}

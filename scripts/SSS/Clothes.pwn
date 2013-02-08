#include <YSI\y_hooks>


#define MAX_SKINS		(22)
#define MAX_SKIN_NAME	(32)


enum E_SKIN_DATA
{
			skin_model,
			skin_name[MAX_SKIN_NAME],
			skin_gender,
Float:		skin_lootSpawnChance
}


new
			gPlayerCurrentSkin[MAX_PLAYERS],
Timer:		skin_UpdateTimer[MAX_PLAYERS],
			skin_CurrentlyUsing[MAX_PLAYERS],
Float:		skin_UseProgress[MAX_PLAYERS],
			skin_Total,
			skin_Data[MAX_SKINS][E_SKIN_DATA];


DefineSkinItem(modelid, name[MAX_SKIN_NAME], gender, Float:spawnchance)
{
	skin_Data[skin_Total][skin_model] = modelid;
	skin_Data[skin_Total][skin_name] = name;
	skin_Data[skin_Total][skin_gender] = gender;
	skin_Data[skin_Total][skin_lootSpawnChance] = spawnchance;
	return skin_Total++;
}

stock IsValidClothes(skinid)
{
	if(!(0 <= skinid < skin_Total))
		return 0;

	return 1;
}

stock GetPlayerClothes(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	return gPlayerCurrentSkin[playerid];
}
stock SetPlayerClothes(playerid, skinid)
{
	if(!(0 <= skinid < skin_Total))
		return 0;

	SetPlayerSkin(playerid, skin_Data[skinid][skin_model]);
	gPlayerCurrentSkin[playerid] = skinid;

	return 1;
}
stock GetClothesModel(skinid)
{
	if(!(0 <= skinid < skin_Total))
		return -1;

	return skin_Data[skinid][skin_model];
}
stock GetClothesName(skinid, name[])
{
	if(!(0 <= skinid < skin_Total))
		return 0;

	name[0] = EOS;
	strcat(name, skin_Data[skinid][skin_name], MAX_SKIN_NAME);

	return 1;
}

public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_Clothes)
	{
		new
			list[MAX_SKINS],
			idx,
			skinid;

		for(new i; i < skin_Total; i++)
		{
			if(frandom(1.0) < skin_Data[i][skin_lootSpawnChance])
			{
				list[idx++] = i;
			}
		}

		skinid = list[random(idx)];

		SetItemExtraData(itemid, skinid);
	}

	return CallLocalFunction("skin_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate skin_OnItemCreate
forward skin_OnItemCreate(itemid);


public OnItemCreateInWorld(itemid)
{
	if(GetItemType(itemid) == item_Clothes)
	{
		new
			skinid = GetItemExtraData(itemid),
			itemname[ITM_MAX_NAME];

		strcat(itemname, skin_Data[skinid][skin_name]);

		if(skin_Data[skinid][skin_gender] == 1)
			strcat(itemname, " clothes (male)");

		else
			strcat(itemname, " clothes (female)");

		SetItemLabel(itemid, itemname, .range = 2.0);
	}

	return CallLocalFunction("skin_OnItemCreateInWorld", "d", itemid);
}
#if defined _ALS_OnItemCreateInWorld
	#undef OnItemCreateInWorld
#else
	#define _ALS_OnItemCreateInWorld
#endif
#define OnItemCreateInWorld skin_OnItemCreateInWorld
forward skin_OnItemCreateInWorld(itemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == 16)
	{
		new itemid = GetPlayerItem(playerid);
		if(GetItemType(itemid) == item_Clothes)
		{
			new skinid = GetItemExtraData(itemid);

			if((skin_Data[skinid][skin_gender] == 1 && bPlayerGameSettings[playerid] & Gender) || (skin_Data[skinid][skin_gender] == 0 && !(bPlayerGameSettings[playerid] & Gender)))
				StartUsingClothes(playerid, itemid);

			else
				ShowMsgBox(playerid, "Wrong gender for clothes", 3000, 130);
		}
	}
	if(oldkeys == 16)
	{
		if(skin_CurrentlyUsing[playerid])
		{
			StopUsingClothes(playerid);
		}
	}
}

StartUsingClothes(playerid, itemid)
{
	SetPlayerProgressBarValue(playerid, ActionBar, 0.0);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, 20.0);
	ShowPlayerProgressBar(playerid, ActionBar);
	CancelPlayerMovement(playerid);

	skin_CurrentlyUsing[playerid] = 1;
	skin_UseProgress[playerid] = 0.0;
	stop skin_UpdateTimer[playerid];
	skin_UpdateTimer[playerid] = repeat UseClothesUpdate(playerid, itemid);
}
StopUsingClothes(playerid)
{
	HidePlayerProgressBar(playerid, ActionBar);

	skin_CurrentlyUsing[playerid] = 0;
	skin_UseProgress[playerid] = 0.0;
	stop skin_UpdateTimer[playerid];
}

timer UseClothesUpdate[100](playerid, itemid)
{
	if(skin_UseProgress[playerid] == 20.0)
	{
		new currentclothes = gPlayerCurrentSkin[playerid];
		SetPlayerClothes(playerid, GetItemExtraData(itemid));
		SetItemExtraData(itemid, currentclothes);
		StopUsingClothes(playerid);
		return;
	}

	SetPlayerProgressBarValue(playerid, ActionBar, skin_UseProgress[playerid]);
	SetPlayerProgressBarMaxValue(playerid, ActionBar, 20.0);
	ShowPlayerProgressBar(playerid, ActionBar);

	skin_UseProgress[playerid] += 1.0;
	return;
}


CMD:getexdat(playerid, params[])
{
	new id = strval(params);

	if(IsValidItem(id))
	{
		printf("EXTRA DATA FOR %d: %d", id, GetItemExtraData(id));
	}
	return 1;
}

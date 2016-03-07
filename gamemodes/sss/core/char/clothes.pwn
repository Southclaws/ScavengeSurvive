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


#define MAX_SKINS		(22)
#define MAX_SKIN_NAME	(32)


enum E_SKIN_DATA
{
			skin_model,
			skin_name[MAX_SKIN_NAME],
			skin_gender,
Float:		skin_lootSpawnChance
}


static
			skin_Total,
			skin_Data[MAX_SKINS][E_SKIN_DATA];

static
			skin_CurrentSkin[MAX_PLAYERS],
			skin_CurrentlyUsing[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	skin_CurrentlyUsing[playerid] = INVALID_ITEM_ID;
}


DefineClothesType(modelid, name[MAX_SKIN_NAME], gender, Float:spawnchance)
{
	skin_Data[skin_Total][skin_model] = modelid;
	skin_Data[skin_Total][skin_name] = name;
	skin_Data[skin_Total][skin_gender] = gender;
	skin_Data[skin_Total][skin_lootSpawnChance] = spawnchance;
	return skin_Total++;
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

	#if defined skin_OnItemCreate
		return skin_OnItemCreate(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate skin_OnItemCreate
#if defined skin_OnItemCreate
	forward skin_OnItemCreate(itemid);
#endif


public OnItemNameRender(itemid, ItemType:itemtype)
{
	if(itemtype == item_Clothes)
	{
		new
			exname[32];

		if(skin_Data[GetItemExtraData(itemid)][skin_gender] == GENDER_MALE)
			strcat(exname, "Male ");

		else
			strcat(exname, "Female ");

		strcat(exname, skin_Data[GetItemExtraData(itemid)][skin_name]);

		SetItemNameExtra(itemid, exname);
	}

	#if defined clo_OnItemNameRender
		return clo_OnItemNameRender(itemid, itemtype);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender clo_OnItemNameRender
#if defined clo_OnItemNameRender
	forward clo_OnItemNameRender(itemid, ItemType:itemtype);
#endif

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == 16)
	{
		new itemid = GetPlayerItem(playerid);

		if(GetItemType(itemid) == item_Clothes)
		{
			new skinid = GetItemExtraData(itemid);

			if(skin_Data[skinid][skin_gender] == GetPlayerGender(playerid))
				StartUsingClothes(playerid, itemid);

			else
				ShowActionText(playerid, "Wrong gender for clothes", 3000, 130);
		}
	}

	if(oldkeys == 16)
	{
		if(skin_CurrentlyUsing[playerid] != INVALID_ITEM_ID)
		{
			StopUsingClothes(playerid);
		}
	}

	return 1;
}

StartUsingClothes(playerid, itemid)
{
	StartHoldAction(playerid, 3000);
	CancelPlayerMovement(playerid);
	skin_CurrentlyUsing[playerid] = itemid;
}
StopUsingClothes(playerid)
{
	if(skin_CurrentlyUsing[playerid] != INVALID_ITEM_ID)
	{
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		skin_CurrentlyUsing[playerid] = INVALID_ITEM_ID;
	}
}

public OnHoldActionFinish(playerid)
{
	if(skin_CurrentlyUsing[playerid] != INVALID_ITEM_ID)
	{
		new currentclothes = skin_CurrentSkin[playerid];
		SetPlayerClothes(playerid, GetItemExtraData(skin_CurrentlyUsing[playerid]));
		SetItemExtraData(skin_CurrentlyUsing[playerid], currentclothes);
		StopUsingClothes(playerid);

		return 1;
	}

	#if defined clo_OnHoldActionFinish
		return clo_OnHoldActionFinish(playerid);
	#else
		return 0;
	#endif
}

#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish clo_OnHoldActionFinish
#if defined clo_OnHoldActionFinish
	forward clo_OnHoldActionFinish(playerid);
#endif


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

	return skin_CurrentSkin[playerid];
}
stock SetPlayerClothes(playerid, skinid)
{
	if(!(0 <= skinid < skin_Total))
		return 0;

	SetPlayerSkin(playerid, skin_Data[skinid][skin_model]);
	skin_CurrentSkin[playerid] = skinid;

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

stock GetClothesGender(skinid)
{
	if(!(0 <= skinid < skin_Total))
		return -1;

	return skin_Data[skinid][skin_gender];
}

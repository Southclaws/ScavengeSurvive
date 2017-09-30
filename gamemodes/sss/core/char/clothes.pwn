/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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


#define MAX_SKINS		(29)
#define MAX_SKIN_NAME	(32)


enum E_SKIN_DATA
{
			skin_model,
			skin_name[MAX_SKIN_NAME],
			skin_gender,
Float:		skin_lootSpawnChance,
			skin_canWearHats,
			skin_canWearMasks
}


static
			skin_Total,
			skin_Data[MAX_SKINS][E_SKIN_DATA];

static
			skin_CurrentSkin[MAX_PLAYERS],
			skin_CurrentlyUsing[MAX_PLAYERS];


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Clothes"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Clothes"), 1);
}

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/char/clothes.pwn");

	skin_CurrentlyUsing[playerid] = INVALID_ITEM_ID;
}


DefineClothesType(modelid, name[MAX_SKIN_NAME], gender, Float:spawnchance, bool:wearhats, bool:wearmasks)
{
	skin_Data[skin_Total][skin_model] = modelid;
	skin_Data[skin_Total][skin_name] = name;
	skin_Data[skin_Total][skin_gender] = gender;
	skin_Data[skin_Total][skin_lootSpawnChance] = spawnchance;
	skin_Data[skin_Total][skin_canWearHats] = wearhats;
	skin_Data[skin_Total][skin_canWearMasks] = wearmasks;
	return skin_Total++;
}

hook OnItemCreate(itemid)
{
	dbg("global", CORE, "[OnItemCreate] in /gamemodes/sss/core/char/clothes.pwn");

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

	return 1;
}


hook OnItemNameRender(itemid, ItemType:itemtype)
{
	dbg("global", CORE, "[OnItemNameRender] in /gamemodes/sss/core/char/clothes.pwn");

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

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/char/clothes.pwn");

	if(newkeys == 16)
	{
		new itemid = GetPlayerItem(playerid);

		if(GetItemType(itemid) == item_Clothes)
		{
			new skinid = GetItemExtraData(itemid);

			if(skin_Data[skinid][skin_gender] == GetPlayerGender(playerid))
				StartUsingClothes(playerid, itemid);

			else
				ShowActionText(playerid, ls(playerid, "CLOTHESWRGE", true), 3000, 130);
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

hook OnHoldActionFinish(playerid)
{
	dbg("global", CORE, "[OnHoldActionFinish] in /gamemodes/sss/core/char/clothes.pwn");

	if(skin_CurrentlyUsing[playerid] != INVALID_ITEM_ID)
	{
		new currentclothes = skin_CurrentSkin[playerid];
		SetPlayerClothes(playerid, GetItemExtraData(skin_CurrentlyUsing[playerid]));
		SetItemExtraData(skin_CurrentlyUsing[playerid], currentclothes);
		StopUsingClothes(playerid);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
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

stock GetClothesHatStatus(skinid)
{
	if(!(0 <= skinid < skin_Total))
		return false;

	return skin_Data[skinid][skin_canWearHats];
}

stock GetClothesMaskStatus(skinid)
{
	if(!(0 <= skinid < skin_Total))
		return false;

	return skin_Data[skinid][skin_canWearMasks];
}

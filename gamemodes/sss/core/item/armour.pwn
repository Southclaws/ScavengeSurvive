/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static
	Item:arm_PlayerArmourItem[MAX_PLAYERS];


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Armour"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Armour"), 1);
}

hook OnItemCreate(Item:itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_Armour)
		{
			SetItemExtraData(itemid, 25 + random(75));
		}
	}
}


hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_Armour)
	{
		if(GetPlayerAP(playerid) <= 0.0)
		{
			new data;
			GetItemExtraData(itemid, data);
			if(data > 0)
			{
				SetPlayerArmourItem(playerid, itemid);
				SetPlayerAP(playerid, float(data));
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemNameRender(Item:itemid, ItemType:itemtype)
{
	if(itemtype == item_Armour)
	{
		new
			amount,
			str[11];

		GetItemExtraData(itemid, amount);
		format(str, sizeof(str), "%d", amount);
		
		SetItemNameExtra(itemid, str);
	}
}


hook OnPlayerShootPlayer(playerid, targetid, bodypart, Float:bleedrate, Float:knockmult, Float:bulletvelocity, Float:distance)
{
	if(bodypart == 3)
	{
		new Float:ap = GetPlayerAP(targetid);

		if(ap > 0.0)
		{
			new Float:penetration = GetAmmoTypePenetration(GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(GetPlayerItem(playerid))));

			bleedrate *= penetration;
			ap -= ((ap + 10) * (bleedrate * 10.0));

			SetPlayerAP(targetid, ap);
			SetItemExtraData(arm_PlayerArmourItem[playerid], floatround(ap));

			if(ap <= 0.0)
				DestroyItem(RemovePlayerArmourItem(playerid));

			DMG_FIREARM_SetBleedRate(targetid, bleedrate);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


new Float:ArmourSkinData[17][9]=
{
	{0.072999, 0.036000, 0.002999,  0.000000, 0.000000, 4.400002,  1.043000, 1.190000, 1.139000},		// skin_Civ0M
	{0.117000, 0.062000, 0.009000,  -1.199999, 0.500000, -3.199997,  1.043000, 1.101000, 0.895000},		// skin_Civ0F
	{0.072999, 0.036000, 0.002999,  0.000000, 0.000000, 4.400002,  1.043000, 1.190000, 1.139000},		// skin_Civ1M
	{0.073000, 0.052000, 0.009000,  -1.199999, -0.500000, 2.500002,  1.064000, 1.107001, 1.030000},		// skin_Civ2M
	{0.036000, 0.061999, 0.014999,  -1.199999, -0.500000, -1.399994,  0.967000, 1.180001, 0.912000},	// skin_Civ3M
	{0.082000, 0.061999, 0.003999,  -1.199999, -0.500000, -1.399994,  0.967000, 1.180001, 0.912000},	// skin_Civ4M
	{0.044000, 0.068999, -0.001000,  -1.199999, -1.900001, -1.399994,  1.248000, 1.539002, 1.128000},	// skin_MechM
	{0.064000, 0.049000, 0.005999,  -1.199999, -1.300001, -0.899995,  1.138000, 1.294001, 1.108000},	// skin_BikeM
	{0.064000, 0.022000, 0.005999,  -1.199999, -1.300001, 3.800003,  1.138000, 1.294001, 1.108000},		// skin_ArmyM
	{0.064000, 0.036000, 0.005999,  -1.199999, -1.300001, 2.100000,  1.138000, 1.399002, 1.265000},		// skin_ClawM
	{0.057999, 0.048000, 0.005999,  -0.299999, -0.800000, 2.399999,  1.138000, 1.419002, 1.072000},		// skin_FreeM
	{0.090999, 0.048000, 0.005999,  -0.299999, -0.800000, 2.399999,  1.231001, 1.234003, 0.998000},		// skin_Civ1F
	{0.117000, 0.062000, 0.009000,  -1.199999, 0.500000, -3.199997,  1.043000, 1.101000, 0.895000},		// skin_Civ2F
	{0.117000, 0.062000, 0.009000,  -1.199999, 0.500000, -3.199997,  1.043000, 1.101000, 0.895000},		// skin_Civ3F
	{0.117000, 0.062000, 0.009000,  -1.199999, 0.500000, -3.199997,  1.043000, 1.101000, 0.895000},		// skin_Civ4F
	{0.117000, 0.041000, 0.009000,  -1.199999, 0.500000, 2.500001,  1.064000, 1.067001, 0.965000},		// skin_ArmyF
	{0.089000, 0.079999, 0.009000,  -1.199999, 0.500000, -4.299999,  1.064000, 1.107001, 0.965000}		// skin_IndiF
};

stock CreatePlayerArmour(playerid)
{
	return SetPlayerArmourItem(playerid, CreateItem(item_Armour));
}

stock SetPlayerArmourItem(playerid, Item:itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	new skin = GetPlayerClothes(playerid);

	SetPlayerAttachedObject(playerid, ATTACHSLOT_ARMOUR, 19515, 1,
		ArmourSkinData[skin][0], ArmourSkinData[skin][1], ArmourSkinData[skin][2],
		ArmourSkinData[skin][3], ArmourSkinData[skin][4], ArmourSkinData[skin][5],
		ArmourSkinData[skin][6], ArmourSkinData[skin][7], ArmourSkinData[skin][8]);

	RemoveItemFromWorld(itemid);
	RemoveCurrentItem(GetItemHolder(itemid));
	arm_PlayerArmourItem[playerid] = itemid;

	return 1;
}

stock Item:RemovePlayerArmourItem(playerid)
{
	new Item:itemid = arm_PlayerArmourItem[playerid];

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_ARMOUR);
	arm_PlayerArmourItem[playerid] = INVALID_ITEM_ID;

	return itemid;
}

stock Item:GetPlayerArmourItem(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_ITEM_ID;

	return arm_PlayerArmourItem[playerid];
}

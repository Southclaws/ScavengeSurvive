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

#define MAX_EXPLOSIVE_ITEM		(16)
#define INVALID_EXPLOSIVE_TYPE	(-1)

enum EXP_TRIGGER
{
	TIMED,
	RADIO,
	PROXIMITY,
	MOTION
}

enum EXP_PRESET
{
	EXP_SMALL,
	EXP_MEDIUM,
	EXP_LARGE,
	EXP_INCEN,
	EXP_THERM,
	EXP_EMP,
	EXP_SHRAP
}


enum EXP_PRESET_DATA
{
			exp_type,
Float:		exp_size,
			exp_defdmg
}

static		exp_Presets[EXP_PRESET][EXP_PRESET_DATA] =
{
	{12, 12.0, 1},	// EXP_SMALL
	{11, 16.0, 2},	// EXP_MEDIUM
	{06, 24.0, 3},	// EXP_LARGE
	{00, 00.0, 0},	// EXP_INCEN
	{00, 00.0, 0},	// EXP_THERM
	{00, 00.0, 0},	// EXP_EMP
	{00, 00.0, 0}	// EXP_SHRAP
};

enum E_EXPLOSIVE_ITEM_DATA
{
ItemType:	exp_itemtype,
EXP_TRIGGER:exp_trigger,
EXP_PRESET:	exp_preset
}


static
			exp_Data[MAX_EXPLOSIVE_ITEM][E_EXPLOSIVE_ITEM_DATA],
			exp_Total,
			exp_ItemTypeExplosive[ITM_MAX_TYPES] = {INVALID_EXPLOSIVE_TYPE, ...},
ItemType:	exp_RadioTriggerItemType;

static
			exp_ArmingItem[MAX_PLAYERS],
			exp_ArmTick[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	exp_ArmingItem[playerid] = INVALID_ITEM_ID;
}

hook OnItemCreate(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
	{
		if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == RADIO)
			SetItemExtraData(itemid, INVALID_ITEM_ID);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock DefineExplosiveItem(ItemType:itemtype, EXP_TRIGGER:trigger, EXP_PRESET:preset)
{
	if(0 <= exp_Total >= MAX_EXPLOSIVE_ITEM - 1)
	{
		print("ERROR: Explosive item definition limit reached!");
		return -1;
	}

	exp_Data[exp_Total][exp_itemtype] = itemtype;
	exp_Data[exp_Total][exp_trigger] = trigger;
	exp_Data[exp_Total][exp_preset] = preset;

	exp_ItemTypeExplosive[itemtype] = exp_Total;

	return exp_Total++;
}

stock SetRadioExplosiveTriggerItem(ItemType:itemtype)
{
	exp_RadioTriggerItemType = itemtype;
}

stock SetItemToExplode(itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	new
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		parent,
		parenttype[32];

	itemtype = GetItemType(itemid);
	GetItemAbsolutePos(itemid, x, y, z, parent, parenttype);

	logf("[EXPLOSIVE] Item %d Type %d detonated at %f, %f, %f", itemid, _:exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger], x, y, z);

	if(!isnull(parenttype))
	{
		if(!strcmp(parenttype, "containerid"))
		{
			DestroyContainer(parent);
		}

		if(!strcmp(parenttype, "vehicleid"))
		{
			SetVehicleHealth(parent, 0.0);
		}

		if(!strcmp(parenttype, "playerid"))
		{
			SetPlayerHP(parent, 0.0);
		}
	}

	DestroyItem(itemid);
	CreateExplosionOfPreset(x, y, z, exp_Data[exp_ItemTypeExplosive[itemtype]][exp_preset]);

	return 0;
}


/*==============================================================================

	Type-specific Code for Trigger Types

==============================================================================*/


hook OnPlayerUseItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(exp_ItemTypeExplosive[itemtype] != -1)
	{
		if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == TIMED)
		{
			PlayerDropItem(playerid);
			exp_ArmingItem[playerid] = itemid;

			StartHoldAction(playerid, 1000);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
			ShowActionText(playerid, ls(playerid, "ARMINGBOMB"));
		}
	}
	else if(GetItemType(itemid) == exp_RadioTriggerItemType)
	{
		if(GetTickCountDifference(GetTickCount(), exp_ArmTick[playerid]) < 1000)
			return 0;

		new
			bombitem,
			ItemType:bombitemtype;

		bombitem = GetItemExtraData(itemid);
		bombitemtype = GetItemType(bombitem);

		if(!IsValidItem(bombitem))
		{
			ShowActionText(playerid, ls(playerid, "RADIONOSYNC"));
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		if(exp_ItemTypeExplosive[bombitemtype] == INVALID_EXPLOSIVE_TYPE)
		{
			ShowActionText(playerid, ls(playerid, "RADIONOSYNC"));
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		if(exp_Data[exp_ItemTypeExplosive[bombitemtype]][exp_trigger] != RADIO)
		{
			ShowActionText(playerid, ls(playerid, "RADIONOSYNC"));
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		if(GetItemExtraData(bombitem) != 1)
		{
			ShowActionText(playerid, ls(playerid, "RADIONOSYNC"));
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		logf("[EXPLOSIVE] Player %p triggering remote explosive item %d", playerid, itemid);
		SetItemToExplode(bombitem);
		SetItemExtraData(itemid, INVALID_ITEM_ID);

		ShowActionText(playerid, ls(playerid, "RADIOTRIGGD"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItemWithItem] in /gamemodes/sss/core/item/tntphonebomb.pwn");

	if(GetItemType(itemid) != exp_RadioTriggerItemType)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new ItemType:itemtype = GetItemType(withitemid);

	if(exp_ItemTypeExplosive[itemtype] == INVALID_EXPLOSIVE_TYPE)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] != RADIO)
		return Y_HOOKS_CONTINUE_RETURN_0;

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
	SetItemExtraData(itemid, withitemid);
	SetItemExtraData(withitemid, 1);
	exp_ArmTick[playerid] = GetTickCount();

	ChatMsgLang(playerid, YELLOW, "ARMEDRADIOB");

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	if(IsValidItem(exp_ArmingItem[playerid]))
	{
		new ItemType:itemtype = GetItemType(exp_ArmingItem[playerid]);

		if(exp_ItemTypeExplosive[itemtype] != -1)
		{
			if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == TIMED)
			{
				logf("[EXPLOSIVE] TNT TIMEBOMB placed by %p", playerid);
				exp_ArmTick[playerid] = GetTickCount();
				defer TimeBombExplode(exp_ArmingItem[playerid]);
				ClearAnimations(playerid);
				ShowActionText(playerid, ls(playerid, "ARMEDBOMB5S"), 3000);

				exp_ArmingItem[playerid] = INVALID_ITEM_ID;
			}
		}
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(RELEASED(16) && IsValidItem(exp_ArmingItem[playerid]))
	{
		StopHoldAction(playerid);
		exp_ArmingItem[playerid] = INVALID_ITEM_ID;
	}
}

timer TimeBombExplode[5000](itemid)
{
	SetItemToExplode(itemid);
}


/*==============================================================================

	Explosion functions

==============================================================================*/


stock CreateExplosionOfPreset(Float:x, Float:y, Float:z, EXP_PRESET:preset)
{
	switch(preset)
	{
		case EXP_INCEN:
			print("EXP_INCEN not implemented");

		case EXP_THERM:
			print("EXP_THERM not implemented");

		case EXP_EMP:
			CreateEmpExplosion(x, y, z, exp_Presets[preset][exp_size]);

		default:
			CreateExplosion(x, y, z, exp_Presets[preset][exp_type], exp_Presets[preset][exp_size]);
	}

	new
		defenceid,
		newhitpoints;

	defenceid = GetClosestDefence(x, y, z, exp_Presets[preset][exp_size]);

	if(defenceid == -1)
		return 0;

	newhitpoints = GetDefenceHitPoints(defenceid) - exp_Presets[preset][exp_defdmg];

	if(newhitpoints <= 0)
	{
		new
			defencetype = GetDefenceType(defenceid),
			ItemType:itemtype = GetDefenceTypeItemType(defencetype),
			Float:vrotx,
			Float:vroty,
			Float:vrotz,
			Float:rotz;

		GetDefenceTypeVerticalRot(defencetype, vrotx, vroty, vrotz);
		rotz = GetDefenceRot(defenceid);

		logf("[DESTRUCTION] Defence %d From %.1f, %.1f, %.1f (GEID: %d) type %d (%d, %f, %f, %f, %f, %f, %f)",
			defenceid, x, y, z,
			GetDefenceGEID(defenceid),
			_:itemtype,
			GetItemTypeModel(itemtype),
			x, y, z + GetDefenceTypeOffsetZ(defencetype),
			vrotx, vroty, vrotz + rotz);

		DestroyDefence(defenceid);
	}
	else
	{
		SetDefenceHitPoints(defenceid, newhitpoints);
	}

	return 1;
}


/*==============================================================================

	Interface functions

==============================================================================*/


//

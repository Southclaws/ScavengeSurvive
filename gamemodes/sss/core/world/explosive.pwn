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

enum
{
	EXPLOSION_PRESET_NORMAL,
	EXPLOSION_PRESET_STRUCTURAL,
	EXPLOSION_PRESET_EMP
}

enum EXP_TRIGGER
{
	TIMED,
	RADIO,
	PROXIMITY,
	MOTION
}

enum E_EXPLOSIVE_ITEM_DATA
{
ItemType:	exp_itemtype,
EXP_TRIGGER:exp_trigger,
			exp_preset
}


static
			exp_Data[MAX_EXPLOSIVE_ITEM][E_EXPLOSIVE_ITEM_DATA],
			exp_Total,
			exp_ItemTypeExplosive[ITM_MAX] = {INVALID_EXPLOSIVE_TYPE, ...};


stock DefineExplosiveItem(ItemType:itemtype, EXP_TRIGGER:trigger, preset)
{
	if(0 <= exp_Total >= MAX_EXPLOSIVE_ITEM - 1)
	{
		print("ERROR: Explosive item definition limit reached!");
		return -1;
	}

	exp_Data[exp_Total][exp_itemtype] = itemtype;
	exp_Data[exp_Total][exp_trigger] = trigger;
	exp_Data[exp_Total][exp_preset] = preset;

	exp_ItemTypeExplosive[_:itemtype] = exp_Total;

	return exp_Total++;
}

stock SetItemToExplode(itemid, type, Float:size, preset, hitpoints)
{
	if(!IsValidItem(itemid))
		return 0;

	new
		Float:x,
		Float:y,
		Float:z,
		parent,
		parenttype[32];

	GetItemAbsolutePos(itemid, x, y, z, parent, parenttype);

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

	CreateExplosionOfPreset(x, y, z, type, size, preset, hitpoints);

	return 0;
}

stock CreateExplosionOfPreset(Float:x, Float:y, Float:z, type, Float:size, preset, hitpoints)
{
	switch(preset)
	{
		case EXPLOSION_PRESET_NORMAL:
			CreateExplosion(x, y, z, type, size);

		case EXPLOSION_PRESET_STRUCTURAL:
			CreateStructuralExplosion(x, y, z, type, size, hitpoints);

		case EXPLOSION_PRESET_EMP:
			CreateEmpExplosion(x, y, z, size);
	}
}

stock CreateStructuralExplosion(Float:x, Float:y, Float:z, type, Float:size, hitpoints = 1)
{
	CreateExplosion(x, y, z, type, size);

	new
		defenceid,
		newhitpoints;

	defenceid = GetClosestDefence(x, y, z, size);

	if(defenceid == -1)
		return 0;

	newhitpoints = GetDefenceHitPoints(defenceid) - hitpoints;

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

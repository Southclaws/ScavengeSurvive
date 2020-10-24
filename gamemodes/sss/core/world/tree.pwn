/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_TREE_CATEGORIES				(5)
#define MAX_TREE_SPECIES				(100)
#define MAX_TREES						(20000)
#define MAX_TREE_CATEGORY_NAME			(32)
#define INVALID_TREE_SPECIES_ID			(-1)
#define INVALID_TREE_ID					(-1)

#define TREE_STREAMER_AREA_IDENTIFIER	(600)
#define HARVEST_DROP_MAX_SPHERE_SIZE	(1.5)


enum E_FALL_TYPE
{
	FALL_TYPE_ROTATE,
	FALL_TYPE_ZDROP
}

enum E_TREE_SPECIES_DATA
{
			tree_model,
Float:		tree_diameter,
Float:		tree_max_health,
Float:		tree_chop_damage,
			tree_pieces,
			tree_category,
E_FALL_TYPE:tree_falltype,
ItemType:	tree_harvest_item,
ItemType:	tree_result_item,
Float:		tree_zoffset
}

enum E_TREE_DATA
{
			tree_species,
			tree_objectid,
			tree_areaid,
Text3D:		tree_labelid,
Float:		tree_health
}


static
			treeCategory_Data[MAX_TREE_CATEGORIES][MAX_TREE_CATEGORY_NAME],
			treeCategory_Species[MAX_TREE_CATEGORIES][MAX_TREE_SPECIES],
			treeCategory_SpeciesCount[MAX_TREE_CATEGORIES],
			treeCategory_Total,

			treeSpecies_Data[MAX_TREE_SPECIES][E_TREE_SPECIES_DATA],
			treeSpecies_Total,

			tree_Data[MAX_TREES][E_TREE_DATA],
Iterator:   tree_Index<MAX_TREES>,

			tree_AtTree[MAX_PLAYERS],
			tree_CuttingTree[MAX_PLAYERS];


forward OnPlayerEnterTreeArea(playerid, treeid);
forward OnPlayerLeaveTreeArea(playerid, treeid);

forward Float:GetTreeHealth(treeid);
forward Float:GetTreeSpeciesDiameter(speciesid);
forward Float:GetTreeSpeciesMaxHealth(speciesid);
forward Float:GetTreeSpeciesChopDamage(speciesid);
forward ItemType:GetTreeSpeciesHarvestItem(speciesid);
forward ItemType:GetTreeSpeciesResultItem(speciesid);


hook OnPlayerConnect(playerid)
{
	tree_AtTree[playerid] = INVALID_TREE_ID;
	tree_CuttingTree[playerid] = INVALID_TREE_ID;
}


/*==============================================================================

	Core

==============================================================================*/


DefineTreeCategory(const name[])
{
	if(treeCategory_Total >= MAX_TREE_CATEGORIES)
	{
		err("Tree category index limit reached at name: %i", name);
		return -1;
	}

	strcat(treeCategory_Data[treeCategory_Total], name);
	treeCategory_SpeciesCount[treeCategory_Total] = 0;

	return treeCategory_Total++;
}

DefineTreeSpecies(modelid, Float:diameter, Float:health, Float:chop_damage, pieces, categoryid, E_FALL_TYPE:falltype, ItemType:harvestitem, ItemType:resultitem, Float:zoffset = 0.0)
{
	if(treeSpecies_Total >= MAX_TREE_SPECIES - 1)
	{
		err("Tree species limit reached at modelid: %i", modelid);
		return -1;
	}

	if(!(0 <= categoryid < treeCategory_Total))
		return -1;

	if(!treeCategory_Data[categoryid][0])
	{
		err("DefineTreeSpecies() undefined \"categoryid\" parameter: %i", categoryid);
		return -1;
	}

	treeSpecies_Data[treeSpecies_Total][tree_model] 		= modelid;
	treeSpecies_Data[treeSpecies_Total][tree_diameter] 		= diameter;
	treeSpecies_Data[treeSpecies_Total][tree_max_health] 	= health;
	treeSpecies_Data[treeSpecies_Total][tree_chop_damage] 	= chop_damage;
	treeSpecies_Data[treeSpecies_Total][tree_pieces] 		= pieces;
	treeSpecies_Data[treeSpecies_Total][tree_category] 		= categoryid;
	treeSpecies_Data[treeSpecies_Total][tree_falltype] 		= falltype;
	treeSpecies_Data[treeSpecies_Total][tree_harvest_item]	= harvestitem;
	treeSpecies_Data[treeSpecies_Total][tree_result_item] 	= resultitem;
	treeSpecies_Data[treeSpecies_Total][tree_zoffset]		= zoffset;

	treeCategory_Species[categoryid][treeCategory_SpeciesCount[categoryid]] = treeSpecies_Total;
	treeCategory_SpeciesCount[categoryid]++;

	return treeSpecies_Total++;
}

CreateTree(speciesid, Float:x, Float:y, Float:z)
{
	if(!(0 <= speciesid < MAX_TREE_SPECIES))
	{
		err("Invalid tree species ID: %d", speciesid);
		return -1;
	}

	if(treeSpecies_Data[speciesid][tree_model] == 0)
	{
		err("CreateTree() undefined \"speciesid\" parameter: %i", speciesid);
		return -1;
	}

	new
		Float:treeDiameter = treeSpecies_Data[speciesid][tree_diameter] + 1.0,
		id = Iter_Free(tree_Index),
		data[2];

	if(id == ITER_NONE)
	{
		err("CreateTree() limit reached at [%i, %f, %f, %f]", speciesid, x, y, z);
		return -1;
	}

	tree_Data[id][tree_species]		= speciesid;
	tree_Data[id][tree_objectid]	= CreateDynamicObject(treeSpecies_Data[speciesid][tree_model], x, y, z + treeSpecies_Data[speciesid][tree_zoffset], 0.0, 0.0, frandom(360.0), 0, 0);
	tree_Data[id][tree_areaid]		= CreateDynamicSphere(x, y, z, treeDiameter, 0, 0);
	tree_Data[id][tree_health]		= treeSpecies_Data[speciesid][tree_max_health];
	tree_Data[id][tree_labelid]		= CreateDynamic3DTextLabel("0.0", YELLOW, x, y, z + 1.0, treeDiameter);

	data[0] = TREE_STREAMER_AREA_IDENTIFIER;
	data[1] = id;

	Streamer_SetArrayData(STREAMER_TYPE_AREA, tree_Data[id][tree_areaid], E_STREAMER_EXTRA_ID, data, 2);

	Iter_Add(tree_Index, id);
	SetTreeHealth(id, tree_Data[id][tree_health]);

	return id;
}

LeanTree(index)
{
	if(!Iter_Contains(tree_Index, index))
		return 0;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz;

	GetDynamicObjectPos	(tree_Data[index][tree_objectid], x, y, z);
	GetDynamicObjectRot	(tree_Data[index][tree_objectid], rx, ry, rz);
	MoveDynamicObject	(tree_Data[index][tree_objectid], x, y, z + 0.0001, 0.0001, rx, 35.0, rz);

	defer _UpdateTreePos(index);

	return 1;
}

DestroyTree(index)
{
	if(!Iter_Contains(tree_Index, index))
		return 0;

	new next;

	Iter_SafeRemove(tree_Index, index, next);

	DestroyDynamicObject(tree_Data[index][tree_objectid]);
	DestroyDynamicArea(tree_Data[index][tree_areaid]);
	DestroyDynamic3DTextLabel(tree_Data[index][tree_labelid]);

	tree_Data[index][tree_species] 	= 0;
	tree_Data[index][tree_objectid] = INVALID_OBJECT_ID;
	tree_Data[index][tree_areaid]   = -1;
	tree_Data[index][tree_labelid]  = Text3D:-1;
	tree_Data[index][tree_health] 	= 0.0;

	return next;
}


/*==============================================================================

	Hooks and Internal

==============================================================================*/


timer _UpdateTreePos[1000](treeid) // time = distance / speed | (0.0001 / 0.0001 = 1 seconds)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz
	;
	GetDynamicObjectPos	(tree_Data[treeid][tree_objectid], x, y, z);
	GetDynamicObjectRot	(tree_Data[treeid][tree_objectid], rx, ry, rz);

	if(treeSpecies_Data[tree_Data[treeid][tree_species]][tree_falltype] == FALL_TYPE_ROTATE)
		MoveDynamicObject(tree_Data[treeid][tree_objectid], x, y, z - 0.0001, 0.0001, rx, 90.0, rz);

	else
		MoveDynamicObject(tree_Data[treeid][tree_objectid], x, y, z - 20.0, 4.0, -10.0 + frandom(10.0), -35.0, rz);

	defer _DeleteTree(treeid, x, y, z);
}

timer _DeleteTree[2000](treeid, Float:x, Float:y, Float:z)
{
	new
		Float:woodAngle,
		Float:woodDistance;

	for(new i; i < treeSpecies_Data[tree_Data[treeid][tree_species]][tree_pieces]; i++)
	{
		woodAngle = frandom(360.0);
		woodDistance = frandom(HARVEST_DROP_MAX_SPHERE_SIZE);

		x += woodDistance * floatsin(-woodAngle, degrees);
		y += woodDistance * floatcos(-woodAngle, degrees);

		CreateItem(treeSpecies_Data[tree_Data[treeid][tree_species]][tree_result_item], x, y, z + 0.5, .rz = frandom(360.0));
	}

	DestroyTree(treeid);
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	if(data[0] == TREE_STREAMER_AREA_IDENTIFIER)
	{
		new
			toolname[MAX_ITEM_NAME],
			yieldname[MAX_ITEM_NAME];

		GetItemTypeName(treeSpecies_Data[tree_Data[data[1]][tree_species]][tree_harvest_item], toolname);
		GetItemTypeName(treeSpecies_Data[tree_Data[data[1]][tree_species]][tree_result_item], yieldname);

		ShowActionText(playerid, sprintf(ls(playerid, "TREECUTINFO"), toolname, yieldname), 6000);
		tree_AtTree[playerid] = data[1];
		CallLocalFunction("OnPlayerEnterTreeArea", "dd", playerid, data[1]);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerLeaveDynArea(playerid, areaid)
{
	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	if(data[0] == TREE_STREAMER_AREA_IDENTIFIER)
	{
		CallLocalFunction("OnPlayerLeaveTreeArea", "dd", playerid, data[1]);
		tree_AtTree[playerid] = INVALID_TREE_ID;
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(tree_AtTree[playerid] != INVALID_TREE_ID)
	{
		if(GetItemType(itemid) == treeSpecies_Data[tree_Data[tree_AtTree[playerid]][tree_species]][tree_harvest_item])
		{
			_StartWoodCutting(playerid, tree_AtTree[playerid]);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(tree_CuttingTree[playerid] == INVALID_TREE_ID)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(oldkeys == 16)
		_StopWoodCutting(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_StartWoodCutting(playerid, treeid)
{
	new
		mult = 1000,
		start = floatround(treeSpecies_Data[tree_Data[treeid][tree_species]][tree_max_health]) / floatround(treeSpecies_Data[tree_Data[treeid][tree_species]][tree_chop_damage]),
		end = floatround(tree_Data[treeid][tree_health]) / floatround(treeSpecies_Data[tree_Data[treeid][tree_species]][tree_chop_damage]);

	mult = GetPlayerSkillTimeModifier(playerid, mult, "Forestry");

	StartHoldAction(playerid, floatround(1.1 * (mult * start)), mult * (start - end));

	SetPlayerToFaceTree(playerid, treeid);
	ApplyAnimation(playerid, "CHAINSAW", "CSAW_G", 4.0, 1, 0, 0, 0, 0, 1);
	tree_CuttingTree[playerid] = treeid;
}

_StopWoodCutting(playerid)
{
	ClearAnimations(playerid);
	StopHoldAction(playerid);
	tree_CuttingTree[playerid] = INVALID_TREE_ID;
}

hook OnHoldActionUpdate(playerid, progress)
{
	if(tree_CuttingTree[playerid] == INVALID_TREE_ID)
		return Y_HOOKS_CONTINUE_RETURN_0;
		
	if(!IsValidTree(tree_CuttingTree[playerid]))
	{
		_StopWoodCutting(playerid);
		return 1;
	}

	new
		Item:itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(itemtype != GetTreeSpeciesHarvestItem(GetTreeSpecies(tree_CuttingTree[playerid])))
	{
		_StopWoodCutting(playerid);
		return 1;
	}

	if(GetItemTypeWeaponFlags(itemtype) & WEAPON_FLAG_LIQUID_AMMO)
	{
		new ammo = GetItemWeaponItemMagAmmo(itemid);

		if(ammo <= 0)
		{
			_StopWoodCutting(playerid);
			return 1;
		}

		if(floatround(GetPlayerProgressBarValue(playerid, ActionBar) * 10) % 60 == 0)
			_FireWeapon(playerid, WEAPON_CHAINSAW);
	}

	new mult = 1000;

	mult = GetPlayerSkillTimeModifier(playerid, mult, "Forestry");

	SetTreeHealth(tree_CuttingTree[playerid], GetTreeHealth(tree_CuttingTree[playerid]) - ((treeSpecies_Data[GetTreeSpecies(tree_CuttingTree[playerid])][tree_chop_damage] / 10000) * mult) );

	if(tree_Data[tree_CuttingTree[playerid]][tree_health] <= 0.0)
	{
		LeanTree(tree_CuttingTree[playerid]);
		PlayerGainSkillExperience(playerid, "Forestry");
		_StopWoodCutting(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Interface

==============================================================================*/


// tree_model
stock GetTreeSpeciesModel(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_Total))
		return INVALID_TREE_SPECIES_ID;

	return treeSpecies_Data[speciesid][tree_model];
}

// tree_diameter
stock Float:GetTreeSpeciesDiameter(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_Total))
		return 0.0;

	return treeSpecies_Data[speciesid][tree_diameter];
}

// tree_max_health
stock Float:GetTreeSpeciesMaxHealth(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_Total))
		return 0.0;

	return treeSpecies_Data[speciesid][tree_max_health];
}

// tree_chop_damage
stock Float:GetTreeSpeciesChopDamage(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_Total))
		return 0.0;

	return treeSpecies_Data[speciesid][tree_chop_damage];
}

// tree_pieces
stock GetTreeSpeciesChopPieces(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_Total))
		return 0;

	return treeSpecies_Data[speciesid][tree_pieces];
}

// tree_category
stock GetTreeSpeciesCategory(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_Total))
		return -1;

	return treeSpecies_Data[speciesid][tree_category];
}

// tree_falltype
stock GetTreeSpeciesFalltype(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_Total))
		return -1;

	return treeSpecies_Data[speciesid][tree_falltype];
}

// tree_harvest_item
stock ItemType:GetTreeSpeciesHarvestItem(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_Total))
		return INVALID_ITEM_TYPE;

	return treeSpecies_Data[speciesid][tree_harvest_item];
}

// tree_result_item
stock ItemType:GetTreeSpeciesResultItem(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_Total))
		return INVALID_ITEM_TYPE;

	return treeSpecies_Data[speciesid][tree_result_item];
}


stock IsValidTree(treeid)
{
	if(!Iter_Contains(tree_Index, treeid))
		return 0;

	return 1;
}


// tree_species
stock GetTreeSpecies(treeid)
{
	if(!Iter_Contains(tree_Index, treeid))
		return 0;

	return tree_Data[treeid][tree_species];
}

// tree_objectid
//

// tree_areaid
//

// tree_labelid
//

// tree_health
Float:GetTreeHealth(treeid)
{
	if(!Iter_Contains(tree_Index, treeid))
		return 0.0;

	return tree_Data[treeid][tree_health];
}

stock SetTreeHealth(treeid, Float:health)
{
	if(!Iter_Contains(tree_Index, treeid))
		return 0;

	new
		toolname[MAX_ITEM_NAME],
		yieldname[MAX_ITEM_NAME];

	GetItemTypeName(treeSpecies_Data[tree_Data[treeid][tree_species]][tree_harvest_item], toolname);
	GetItemTypeName(treeSpecies_Data[tree_Data[treeid][tree_species]][tree_result_item], yieldname);

	tree_Data[treeid][tree_health] = health;

	if(tree_Data[treeid][tree_health] < 0.0)
		tree_Data[treeid][tree_health] = 0.0;

	UpdateDynamic3DTextLabelText(tree_Data[treeid][tree_labelid], YELLOW, sprintf("Health: %.2f/%.2f\n"C_TEAL"Tool Required: %s\n"C_GREEN"Yields Resource: %s", tree_Data[treeid][tree_health], treeSpecies_Data[tree_Data[treeid][tree_species]][tree_max_health], toolname, yieldname));

	return 1;
}

// Utility
stock GetRandomTreeSpecies(categoryid = -1)
{
	if(categoryid == -1)
	{
		return random(treeSpecies_Total);
	}
	else
	{
		if(!(0 <= categoryid < treeCategory_Total))
			return 0;

		if(treeCategory_SpeciesCount[categoryid] == 0)
			return -1;

		return treeCategory_Species[categoryid][random(treeCategory_SpeciesCount[categoryid])];
	}
}

stock GetTreeCategoryFromName(const name[])
{
	for(new i; i < treeCategory_Total; i++)
	{
		if(!strcmp(treeCategory_Data[i], name))
			return i;
	}

	return -1;
}

stock SetPlayerToFaceTree(playerid, treeid)
{
	if(!Iter_Contains(tree_Index, treeid))
		return 0;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:tx,
		Float:ty,
		Float:tz;

	GetPlayerPos(playerid, x, y, z);
	GetDynamicObjectPos	(tree_Data[treeid][tree_objectid], tx, ty, tz);

	SetPlayerFacingAngle(playerid, GetAngleToPoint(x, y, tx, ty));
	return 1;
}


/*==============================================================================

	Dev

==============================================================================*/


ACMD:killalltrees[5](playerid, params[])
{
	foreach(new i : tree_Index)
		LeanTree(i);

	return 1;
}

ACMD:reloadtrees[5](playerid, params[])
{
	LoadTreesFromFolder("Maps/");
	return 1;
}

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


#define MAX_TREE_CATEGORIES      		(5)
#define MAX_TREE_SPECIES     			(100)
#define MAX_TREES						(20000)

#define MAX_TREE_CATEGORY_NAME  		(32)

#define TREE_STREAMER_AREA_IDENTIFIER	(600)
#define LOG_DROP_MAX_SPHERE_SIZE        (1.5)


enum E_TREE_SPECIES_DATA
{
			tree_model,
Float:		tree_diameter,
Float:		tree_max_health,
Float:		tree_chop_damage,
			tree_pieces,
			tree_category,
			tree_falltype
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
			treeCategory_IndexTotal,

			treeSpecies_Data[MAX_TREE_SPECIES][E_TREE_SPECIES_DATA],
			treeSpecies_IndexTotal,

			tree_Data[MAX_TREES][E_TREE_DATA],
Iterator:   tree_Index<MAX_TREES>;


forward OnPlayerEnterTreeArea(playerid, tree_index);
forward OnPlayerLeaveTreeArea(playerid, tree_index);


DefineTreeCategory(name[])
{
	if(treeCategory_IndexTotal >= MAX_TREE_CATEGORIES)
	{
		printf("ERROR: Tree category index limit reached at name: %i", name);
		return -1;
	}

	strcat(treeCategory_Data[treeCategory_IndexTotal], name);
	treeCategory_SpeciesCount[treeCategory_IndexTotal] = 0;

	return treeCategory_IndexTotal++;
}

DefineTreeSpecies(modelid, Float:diameter, Float:health, Float:chop_damage, pieces, categoryid, falltype)
{
	if(treeSpecies_IndexTotal > MAX_TREE_SPECIES)
	{
		printf("ERROR: Tree species limit reached at modelid: %i", modelid);
		return -1;
	}

	if(!(0 <= categoryid < treeCategory_IndexTotal))
		return -1;

	if(!treeCategory_Data[categoryid][0])
	{
		printf("ERROR: DefineTreeSpecies() undefined \"categoryid\" parameter: %i", categoryid);
		return -1;
	}

	treeSpecies_Data[treeSpecies_IndexTotal][tree_model] 		= modelid;
	treeSpecies_Data[treeSpecies_IndexTotal][tree_diameter] 	= diameter;
	treeSpecies_Data[treeSpecies_IndexTotal][tree_max_health] 	= health;
	treeSpecies_Data[treeSpecies_IndexTotal][tree_chop_damage] 	= chop_damage;
	treeSpecies_Data[treeSpecies_IndexTotal][tree_pieces] 		= pieces;
	treeSpecies_Data[treeSpecies_IndexTotal][tree_category] 	= categoryid;
	treeSpecies_Data[treeSpecies_IndexTotal][tree_falltype] 	= falltype;

	treeCategory_Species[categoryid][treeCategory_SpeciesCount[categoryid]] = treeSpecies_IndexTotal;
	treeCategory_SpeciesCount[categoryid]++;

	return treeSpecies_IndexTotal++;
}

CreateTree(speciesid, Float:x, Float:y, Float:z)
{
	if(!(0 <= speciesid < MAX_TREE_SPECIES))
	{
		printf("ERROR: Invalid tree species ID: %d", speciesid);
		return -1;
	}

	if(treeSpecies_Data[speciesid][tree_model] == 0)
	{
		printf("ERROR: CreateTree() undefined \"speciesid\" parameter: %i", speciesid);
		return -1;
	}

	new
		Float:treeDiameter = species_GetTreeDiameter(speciesid) + 1.0,
		id = Iter_Free(tree_Index),
		data[2];

	if(id == -1)
	{
		printf("ERROR: CreateTree() limit reached at [%i, %f, %f, %f]", speciesid, x, y, z);
		return -1;
	}

	tree_Data[id][tree_species]		= speciesid;
	tree_Data[id][tree_objectid]	= CreateDynamicObject(species_GetTreeModel(speciesid), x, y, z, 0.0, 0.0, frandom(360.0), 0, 0);
	tree_Data[id][tree_areaid]		= CreateDynamicSphere(x, y, z, treeDiameter, 0, 0);
	tree_Data[id][tree_health]		= species_GetTreeMaxHealth(speciesid);
	tree_Data[id][tree_labelid]		= CreateDynamic3DTextLabel("0.0", YELLOW, x, y, z + 1.0, treeDiameter);
	SetTreeHealth(id, tree_Data[id][tree_health]);

	data[0] = TREE_STREAMER_AREA_IDENTIFIER;
	data[1] = id;

	Streamer_SetArrayData(STREAMER_TYPE_AREA, tree_Data[id][tree_areaid], E_STREAMER_EXTRA_ID, data, 2);

	Iter_Add(tree_Index, id);

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
		Float:rz
	;

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

	new
		next;

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


species_GetTreeModel(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_IndexTotal))
	{
		print("<trees.pwn> ERROR: species_GetTreeModel() invalid tree species parameter");
		return 0;
	}

	return treeSpecies_Data[speciesid][tree_model];
}

forward Float:species_GetTreeDiameter(speciesid);
public Float:species_GetTreeDiameter(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_IndexTotal))
	{
		print("<trees.pwn> ERROR: species_GetTreeDiameter() invalid tree species parameter");
		return 0.0;
	}

	return treeSpecies_Data[speciesid][tree_diameter];
}

forward Float:species_GetTreeMaxHealth(speciesid);
public Float:species_GetTreeMaxHealth(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_IndexTotal))
	{
		print("<trees.pwn> ERROR: species_GetTreeMaxHealth invalid tree species parameter");
		return 0.0;
	}

	return treeSpecies_Data[speciesid][tree_max_health];
}

Float:species_GetTreeChopDamage(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_IndexTotal))
	{
		print("<trees.pwn> ERROR: species_GetTreeChopDamage() invalid tree species parameter");
		return 0.0;
	}

	return treeSpecies_Data[speciesid][tree_chop_damage];
}

species_GetTreePieces(speciesid)
{
	if(!(0 <= speciesid < treeSpecies_IndexTotal))
	{
		print("<trees.pwn> ERROR: species_GetTreePieces() invalid tree species parameter");
		return 0;
	}

	return treeSpecies_Data[speciesid][tree_pieces];
}

IsValidTree(tree_index)
{
	if(!(0 <= tree_index < MAX_TREES))
		return 0;

	if(!Iter_Contains(tree_Index, tree_index))
		return 0;

	return 1;
}

GetRandomTreeSpecies(categoryid = -1)
{
	if(categoryid == -1)
	{
		return random(treeSpecies_IndexTotal);
	}
	else
	{
		if(!(0 <= categoryid < treeCategory_IndexTotal))
			return 0;

		if(treeCategory_SpeciesCount[categoryid] == 0)
			return -1;

		return treeCategory_Species[categoryid][random(treeCategory_SpeciesCount[categoryid])];
	}
}

GetTreeCategoryFromName(name[])
{
	for(new i; i < treeCategory_IndexTotal; i++)
	{
		if(!strcmp(treeCategory_Data[i], name))
			return i;
	}

	return -1;
}

Float:GetTreeHealth(tree_index)
{
	if(!(0 <= tree_index < MAX_TREES))
		return 0.0;

	/*if(!IsValidTree(tree_index))
		return 0.0;*/

	return tree_Data[tree_index][tree_health];
}

GetTreeCategory(tree_index)
{
	if(!(0 <= tree_index < MAX_TREES))
		return 0;

	/*if(!IsValidTree(tree_index))
		return 0;*/

	return tree_Data[tree_index][tree_species];
}

SetTreeHealth(tree_index, Float:health)
{
	if(!(0 <= tree_index < MAX_TREES))
		return 0;

	/*if(!IsValidTree(tree_index))
		return 0;*/

	tree_Data[tree_index][tree_health] = health;
	UpdateDynamic3DTextLabelText(tree_Data[tree_index][tree_labelid], YELLOW, sprintf("%.2f", tree_Data[tree_index][tree_health]));

	return 1;
}

SetPlayerToFaceTree(playerid, tree_index)
{
	if(!(0 <= tree_index < MAX_TREES))
		return 0;

	/*if(!IsValidTree(tree_index))
		return 0;*/

	new
		Float:x,
		Float:y,
		Float:z,
		Float:tx,
		Float:ty,
		Float:tz
	;

	GetPlayerPos(playerid, x, y, z);
	GetDynamicObjectPos	(tree_Data[tree_index][tree_objectid], tx, ty, tz);

	SetPlayerFacingAngle(playerid, GetAngleToPoint(x, y, tx, ty));
	return 1;
}

timer _UpdateTreePos[1000](tree_index) // time = distance / speed | (0.0001 / 0.0001 = 1 seconds)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz
	;
	GetDynamicObjectPos	(tree_Data[tree_index][tree_objectid], x, y, z);
	GetDynamicObjectRot	(tree_Data[tree_index][tree_objectid], rx, ry, rz);

	if(treeSpecies_Data[tree_Data[tree_index][tree_species]][tree_falltype] == 0)
		MoveDynamicObject(tree_Data[tree_index][tree_objectid], x, y, z - 0.0001, 0.0001, rx, 90.0, rz);

	else
		MoveDynamicObject(tree_Data[tree_index][tree_objectid], x, y, z - 20.0, 4.0, -10.0 + frandom(10.0), -35.0, rz);

	defer _DeleteTree(tree_index, x, y, z);
}

timer _DeleteTree[2000](tree_index, Float:x, Float:y, Float:z)
{
	DestroyTree(tree_index);

	new
		Float:woodAngle,
		Float:woodDistance;

	for(new i; i < species_GetTreePieces(tree_Data[tree_index][tree_species]); i++)
	{
		woodAngle = frandom(360.0);
		woodDistance = frandom(LOG_DROP_MAX_SPHERE_SIZE);

		x = woodDistance * floatsin(-woodAngle, degrees) + x;
		y = woodDistance * floatcos(-woodAngle, degrees) + y;

		MapAndreas_FindZ_For2DCoord(x, y, z);
		CreateItem(item_Log, x, y, z + 0.088, .rz = frandom(360.0), .zoffset = FLOOR_OFFSET);
	}
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
	if(!IsValidDynamicArea(areaid))
	{
		d:3:GLOBAL_DEBUG("[_tree_EnterArea] Invalid area ID (%d)", areaid);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	if(data[0] != TREE_STREAMER_AREA_IDENTIFIER)
	{
		d:3:GLOBAL_DEBUG("[_tree_EnterArea] Area not tree area type %i, %i", data[0], data[1]);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	CallLocalFunction("OnPlayerEnterTreeArea", "dd", playerid, data[1]);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerLeaveDynArea(playerid, areaid)
{
	if(!IsValidDynamicArea(areaid))
	{
		d:3:GLOBAL_DEBUG("[_tree_LeaveArea] Invalid area ID (%d)", areaid);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	if(data[0] != TREE_STREAMER_AREA_IDENTIFIER)
	{
		d:3:GLOBAL_DEBUG("[_tree_LeaveArea] Area not tree area type");
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	CallLocalFunction("OnPlayerLeaveTreeArea", "dd", playerid, data[1]);

	return Y_HOOKS_CONTINUE_RETURN_0;
}


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

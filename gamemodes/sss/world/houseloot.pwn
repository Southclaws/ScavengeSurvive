/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_HOUSE_TYPES		(4)
#define MAX_LOOT_POSITIONS	(4)

new
	LootHouseModels[MAX_HOUSE_TYPES] =
	{
		19490,
		19492,
		19494,
		19496
	},
	Float:LootOffsets[MAX_HOUSE_TYPES][MAX_LOOT_POSITIONS][3] =
	{
		// 19490
		{
			{-3.73, -3.33, -0.42},
			{4.25, 3.30, -0.42},
			{3.11, 0.16, -3.29},
			{-1.49, -1.67, -3.29}
		},
		// 19492
		{
			{-2.99, -0.84, -1.93},
			{2.49, -1.77, -4.81},
			{-2.60, -0.16, -4.81},
			{2.66, 1.97, -1.93}
		},
		// 19494
		{
			{-2.52, 1.84, -1.75},
			{3.52, 2.26, -4.70},
			{2.78, 1.91, -1.75},
			{0.0, 0.0, 0.0}
		},
		// 19496
		{
			{-2.29, -0.57, -1.75},
			{3.46, 2.53, -1.75},
			{3.65, 2.23, -4.39},
			{0.0, 0.0, 0.0}
		}
	};
// Todo: Add offsets for the remaining house models from LS and LV to this

Load_HouseLoot()
{
	new
		Float:x,
		Float:y,
		Float:z,

		object_id,

		Float:object_px,
		Float:object_py,
		Float:object_pz,
		Float:object_rx,
		Float:object_ry,
		Float:object_rz;

	for(new i; i < CountDynamicObjects(); i++)
	{
		if(IsValidDynamicObject(i))
		{
			object_id = Streamer_GetIntData(STREAMER_TYPE_OBJECT, i, E_STREAMER_MODEL_ID);

			for(new j; j < MAX_HOUSE_TYPES; j++)
			{
				if(random(100) < 50)
					continue;

				if(object_id == LootHouseModels[j])
				{
					GetDynamicObjectPos(i, object_px, object_py, object_pz);
					GetDynamicObjectRot(i, object_rx, object_ry, object_rz);
					for(new k; k < MAX_LOOT_POSITIONS; k++)
					{
						if(LootOffsets[j][k][0] == 0.0)
							break;

						GetAttachedObjectPos(
							object_px, object_py, object_pz, object_rx, object_ry, object_rz,
							LootOffsets[j][k][0], LootOffsets[j][k][1], LootOffsets[j][k][2],
							x, y, z);

						CreateStaticLootSpawn(x, y, z, GetLootIndexFromName("world_civilian"), 20, 3);
					}
				}
			}
		}
	}
}

stock GetAttachedObjectPos(
	Float:object_px, Float:object_py, Float:object_pz, Float:object_rx, Float:object_ry, Float:object_rz,
	Float:offset_x, Float:offset_y, Float:offset_z,
	&Float:x, &Float:y, &Float:z)
{
	new
		Float:cos_x = floatcos(object_rx, degrees),
		Float:cos_y = floatcos(object_ry, degrees),
		Float:cos_z = floatcos(object_rz, degrees),
		Float:sin_x = floatsin(object_rx, degrees),
		Float:sin_y = floatsin(object_ry, degrees),
		Float:sin_z = floatsin(object_rz, degrees);

	x = object_px + offset_x * cos_y * cos_z - offset_x * sin_x * sin_y * sin_z - offset_y * cos_x * sin_z + offset_z * sin_y * cos_z + offset_z * sin_x * cos_y * sin_z;
	y = object_py + offset_x * cos_y * sin_z + offset_x * sin_x * sin_y * cos_z + offset_y * cos_x * cos_z + offset_z * sin_y * sin_z - offset_z * sin_x * cos_y * cos_z;
	z = object_pz - offset_x * cos_x * sin_y + offset_y * sin_x + offset_z * cos_x * cos_y;
}


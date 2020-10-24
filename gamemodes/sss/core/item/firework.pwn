/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#define MAX_PROJECTILE			(64)
#define INVALID_EXPLOSION_TYPE	(-1)
#define INVALID_SPREAD_COUNT	(-1)
#define MAX_EX_PER_SEQUENCE		(4)


enum E_FIREWORK_PROJECTILE_DATA
{
			fwk_object,
			fwk_sequence,
			fwk_index
}
enum E_EXPLOSION_TYPE_DATA
{
			fwk_model[8],	// A
Float:		fwk_elevation,	// B
Float:		fwk_distance,	// C
			fwk_spread		// D
}


new
			fwk_Data[MAX_PROJECTILE][E_FIREWORK_PROJECTILE_DATA],
   Iterator:fwk_ProjectileIndex<MAX_PROJECTILE>,
			fwk_CooldownTick;

new
	fwk_ExplosionTypes[][E_EXPLOSION_TYPE_DATA]=
	{
//		A
//			B			C		D
		{{345, -1},
			60.0,		20.0,	4},

		{{18724, -1},
			45.0,		50.0,	3},

		{{18688, -1},
			45.0,		6.0,	4},

		{{18670, -1},
			45.0,		6.0,	4}
	},
	fwk_ExplosionSequences[][MAX_EX_PER_SEQUENCE]=
	{
		{3, -1},
		{3, 1, 2, -1},
		{1, 0, -1}
	};

CreateFireworkProjectile(model,
	Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz,
	Float:rotation, Float:elevation, Float:distance,
	sequence, index)
{
	new id = Iter_Free(fwk_ProjectileIndex);
	
	if(id == ITER_NONE)
		return -1;

	fwk_Data[id][fwk_object] = CreateDynamicObject(model, x, y, z, rx, ry, rz);
	MoveDynamicObject(fwk_Data[id][fwk_object],
		x += ( distance * floatsin(rotation, degrees) * floatcos(elevation + (random(20)-10), degrees) ),
		y += ( distance * floatcos(rotation, degrees) * floatcos(elevation + (random(20)-10), degrees) ),
		z += ( distance * floatsin(elevation + (random(20)-10), degrees) ),
		20.0, rx, ry, z);

	fwk_Data[id][fwk_sequence] = sequence;
	fwk_Data[id][fwk_index] = index;

	Iter_Add(fwk_ProjectileIndex, id);
	return id;
}
DestroyFireworkProjectile(id)
{
	if(!Iter_Contains(fwk_ProjectileIndex, id))return 0;
	
	DestroyDynamicObject(fwk_Data[id][fwk_object]);
	fwk_Data[id][fwk_sequence] = 0;
	fwk_Data[id][fwk_index] = 0;

	Iter_SafeRemove(fwk_ProjectileIndex, id, id);
	return id;

}


hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(itemid) == item_FireLighter && GetItemType(withitemid) == item_FireworkBox)
	{
		if(GetTickCountDifference(GetTickCount(), fwk_CooldownTick) > 3000)
		{
			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 0, 0, 0, 0, 450);
			defer FireworkLaunch(_:withitemid);
			fwk_CooldownTick = GetTickCount();
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


timer FireworkLaunch[6000](itemid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(Item:itemid, x, y, z);
	CreateFireworkProjectile(345,
		x, y, z, 90.0, 0.0, 0.0,
		0.0, 90.0, 10.0,
		1, 0);
}


hook OnDynamicObjectMoved(objectid)
{
	foreach(new i : fwk_ProjectileIndex)
	{
		if(objectid == fwk_Data[i][fwk_object])
		{
			new
				Float:x,
				Float:y,
				Float:z,
				sequence,
				index,
				extype,
				maxmodels,
				Float:angoffset;

			GetDynamicObjectPos(fwk_Data[i][fwk_object], x, y, z);

			sequence = fwk_Data[i][fwk_sequence];
			index = fwk_Data[i][fwk_index];
			
			if(index >= MAX_EX_PER_SEQUENCE)
			{
				i = DestroyFireworkProjectile(i);
				return Y_HOOKS_BREAK_RETURN_0;
			}

			extype = fwk_ExplosionSequences[sequence][index];

			if(extype == -1)
			{
				i = DestroyFireworkProjectile(i);
				return Y_HOOKS_BREAK_RETURN_0;
			}

			while(maxmodels < 8 && fwk_ExplosionTypes[extype][fwk_model][maxmodels] != -1)
				maxmodels++;

			i = DestroyFireworkProjectile(i);
			
			angoffset = random((360/fwk_ExplosionTypes[extype][fwk_spread]));

			for(new j; j < fwk_ExplosionTypes[extype][fwk_spread]; j++)
			{
				CreateFireworkProjectile(fwk_ExplosionTypes[extype][fwk_model][random(maxmodels)],
					x, y, z, 90.0, 0.0, 0.0,
					j * (360/fwk_ExplosionTypes[extype][fwk_spread])+angoffset,
					fwk_ExplosionTypes[extype][fwk_elevation],
					fwk_ExplosionTypes[extype][fwk_distance],
					sequence, index+1);
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*

CMD:addfirework(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	CreateItem(fireworkLighterType,
		x + (0.5 * floatsin(-r, degrees)),
		y + (0.5 * floatcos(-r, degrees)), z - ITEM_FLOOR_OFFSET, .rz = r);

	CreateItem(fireworkItemType,
		x + (3.5 * floatsin(-r, degrees)),
		y + (3.5 * floatcos(-r, degrees)), z - ITEM_FLOOR_OFFSET, .rz = r);

	return 1;
}

*/

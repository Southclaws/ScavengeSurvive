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


/*

ROOT_LIQUID_BITMASK

liquid_Water			= DefineLiquidType("Water", ROOT_LIQUID_BITMASK)
liquid_Milk				= DefineLiquidType("Milk", ROOT_LIQUID_BITMASK)
liquid_Orange			= DefineLiquidType("Orange", ROOT_LIQUID_BITMASK)
liquid_Whiskey			= DefineLiquidType("Whiskey", ROOT_LIQUID_BITMASK)
liquid_Ethanol			= DefineLiquidType("Ethanol", ROOT_LIQUID_BITMASK)
liquid_Turpentine		= DefineLiquidType("Turpentine", ROOT_LIQUID_BITMASK)
liquid_HydroAcid		= DefineLiquidType("Hydrochloric Acid", ROOT_LIQUID_BITMASK)

liquid_StrongWhiskey	= DefineLiquidType("Acid Whiskey", liquid_Whiskey | liquid_Ethanol)
liquid_Fun				= DefineLiquidType("Fun", liquid_Ethanol | liquid_Turpentine | liquid_HydroAcid)

*/

#define MAX_LIQUID_TYPES (64)
#define MAX_LIQUID_NAME (32)


enum E_LIQUID_DATA
{
		liq_name[MAX_LIQUID_NAME],
Float:	liq_foodvalue,
		liq_mask,
		liq_recipe
}


new const ROOT_LIQUID_BITMASK = 0xFFFFFFFF;

static
		liq_Data[MAX_LIQUID_TYPES][E_LIQUID_DATA],
		liq_Total,
		liq_NextMask = 1;


stock DefineLiquidType(name[], Float:foodvalue, recipe)
{
	if(liq_Total >= MAX_LIQUID_TYPES - 1)
	{
		print("ERROR: MAX_LIQUID_TYPES limit reached!");
		return -1;
	}

	strcat(liq_Data[liq_Total][liq_name], name, MAX_LIQUID_NAME);
	liq_Data[liq_Total][liq_foodvalue] = foodvalue;
	liq_Data[liq_Total][liq_mask] = liq_NextMask;
	liq_Data[liq_Total][liq_recipe] = recipe;

	liq_Total++;
	liq_NextMask = liq_NextMask << 1;
	return liq_NextMask;
}

stock GetLiquidName(liquidtype, name[])
{
	if(!(0 <= liquidtype < liq_Total))
		return 0;

	strcat(name, liq_Data[liquidtype][liq_name], MAX_LIQUID_NAME);

	return 1;
}

stock IsValidLiquidType(liquidtype)
{
	if(!(0 <= liquidtype < liq_Total))
		return 0;

	return 1;
}

stock GetTotalLiquidTypes()
{
	return liq_Total;
}

stock Float:GetLiquidFoodValue(liquidtype)
{
	if(!(0 <= liquidtype < liq_Total))
		return 0.0;

	return liq_Data[liquidtype][liq_foodvalue];
}

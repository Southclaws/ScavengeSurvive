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


#define MAX_LIQUID_TYPES (64)
#define MAX_LIQUID_NAME (32)


enum E_LIQUID_DATA
{
		liq_name[MAX_LIQUID_NAME],
Float:	liq_foodvalue,
		liq_mask,
		liq_recipe
}


static
		liq_Data[MAX_LIQUID_TYPES][E_LIQUID_DATA],
		liq_Total,
		liq_NextMask = 1;


stock DefineLiquidType(name[], Float:foodvalue, ...)
{
	if(liq_Total >= MAX_LIQUID_TYPES - 1)
	{
		err("MAX_LIQUID_TYPES limit reached!");
		return -1;
	}

	strcat(liq_Data[liq_Total][liq_name], name, MAX_LIQUID_NAME);
	liq_Data[liq_Total][liq_foodvalue] = foodvalue;
	liq_Data[liq_Total][liq_mask] = liq_NextMask;

	if(numargs() == 2)
	{
		liq_Data[liq_Total][liq_recipe] = liq_NextMask;
		liq_NextMask = liq_NextMask << 1;
	}
	else
	{
		for(new i = 2; i < numargs(); i++)
			liq_Data[liq_Total][liq_recipe] |= liq_Data[getarg(i)][liq_mask];
	}

	return liq_Total++;
}


/*==============================================================================

	Interface

==============================================================================*/


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

// liq_name
stock GetLiquidName(liquidtype, name[])
{
	if(!(0 <= liquidtype < liq_Total))
		return 0;

	name[0] = EOS;
	strcat(name, liq_Data[liquidtype][liq_name], MAX_LIQUID_NAME);

	return 1;
}

// liq_foodvalue
stock Float:GetLiquidFoodValue(liquidtype)
{
	if(!(0 <= liquidtype < liq_Total))
		return 0.0;

	return liq_Data[liquidtype][liq_foodvalue];
}

// liq_mask
stock GetLiquidMask(liquidtype)
{
	if(!(0 <= liquidtype < liq_Total))
		return 0;

	return liq_Data[liquidtype][liquid_Fun];
}

// liq_recipe
stock GetLiquidRecipe(liquidtype)
{
	if(!(0 <= liquidtype < liq_Total))
		return 0;

	return liq_Data[liquidtype][liq_recipe];
}

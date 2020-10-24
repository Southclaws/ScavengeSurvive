/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


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


stock DefineLiquidType(const name[], Float:foodvalue, ...)
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

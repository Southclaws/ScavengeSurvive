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


#include <YSI_4\y_hooks>


#define MAX_SEED_TYPES	(16)


enum E_SEED_TYPE_DATA
{
			seed_name[ITM_MAX_NAME],
ItemType:	seed_itemType,
			seed_growthTime,
			seed_plantModel,
Float:		seed_plantOffset
}

enum
{
	E_SEED_BAG_AMOUNT,
	E_SEED_BAG_TYPE
}


static
	seed_Data[MAX_SEED_TYPES][E_SEED_TYPE_DATA],
	seed_Total;


stock DefineSeedType(name[], ItemType:itemtype, growthtime, plantmodel, Float:plantoffset)
{
	if(seed_Total >= MAX_SEED_TYPES)
	{
		print("ERROR: Seed type limit reached.");
		return -1;
	}

	strcat(seed_Data[seed_Total][seed_name], name);
	seed_Data[seed_Total][seed_itemType] = itemtype;
	seed_Data[seed_Total][seed_growthTime] = growthtime;
	seed_Data[seed_Total][seed_plantModel] = plantmodel;
	seed_Data[seed_Total][seed_plantOffset] = plantoffset;

	return seed_Total++;
}


hook OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_SeedBag)
	{
		if(GetItemLootIndex(itemid) != -1)
		{
			SetItemArrayDataAtCell(itemid, random(5), E_SEED_BAG_AMOUNT, 1);
			SetItemArrayDataAtCell(itemid, random(seed_Total), E_SEED_BAG_TYPE, 1);
		}
	}
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{
	if(itemtype == item_SeedBag)
	{
		new seeddata[2];

		GetItemArrayData(itemid, seeddata);

		if(seeddata[E_SEED_BAG_AMOUNT] > 0)
		{
			if(0 <= seeddata[E_SEED_BAG_TYPE] < 2)
			{
				SetItemNameExtra(itemid, seed_Data[seeddata[E_SEED_BAG_TYPE]][seed_name]);
			}
		}
		else
		{
			SetItemNameExtra(itemid, "Empty");
		}
	}
}


stock IsValidSeedType(seedtype)
{
	return (0 <= seedtype < seed_Total);
}

// seed_name
stock GetSeedTypeName(seedtype, name[])
{
	if(!(0 <= seedtype < seed_Total))
		return 0;

	name[0] = EOS;
	strcat(name, seed_Data[seedtype][seed_name], ITM_MAX_NAME);

	return 1;
}

// seed_itemType
stock ItemType:GetSeedTypeItemType(seedtype)
{
	if(!(0 <= seedtype < seed_Total))
		return INVALID_ITEM_TYPE;

	return seed_Data[seedtype][seed_itemType];
}

// seed_growthTime
stock GetSeedTypeGrowthTime(seedtype)
{
	if(!(0 <= seedtype < seed_Total))
		return 0;

	return seed_Data[seedtype][seed_growthTime];
}

// seed_plantModel
stock GetSeedTypePlantModel(seedtype)
{
	if(!(0 <= seedtype < seed_Total))
		return 0;

	return seed_Data[seedtype][seed_plantModel];
}

// seed_plantOffset
stock Float:GetSeedTypePlantOffset(seedtype)
{
	if(!(0 <= seedtype < seed_Total))
		return 0.0;

	return seed_Data[seedtype][seed_plantOffset];
}

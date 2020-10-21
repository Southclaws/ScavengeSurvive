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


#define MAX_ITEM_AMMO_TYPES		(20)
#define MAX_AMMO_CALIBRE		(20)
#define MAX_AMMO_CALIBRE_NAME	(32)
#define NO_CALIBRE				(-1)


enum e_calibre_data
{
			clbr_name[MAX_AMMO_CALIBRE_NAME],
Float:		clbr_bleedRate
}

enum E_ITEM_AMMO_DATA
{
ItemType:	ammo_itemType,
			ammo_name[MAX_AMMO_CALIBRE_NAME],
			ammo_calibre,
Float:		ammo_bleedrateMult,
Float:		ammo_knockoutMult,
Float:		ammo_penetration,
			ammo_size
}


static
			clbr_Data[MAX_AMMO_CALIBRE][e_calibre_data],
			clbr_Total;

static
			ammo_Data[MAX_ITEM_AMMO_TYPES][E_ITEM_AMMO_DATA],
			ammo_Total,
			ammo_ItemTypeAmmoType[MAX_ITEM_TYPE] = {-1, ...},
ItemType:	ammo_ItemTypeLowerBound,
ItemType:	ammo_ItemTypeUpperBound;


/*==============================================================================

	Core

==============================================================================*/


stock DefineAmmoCalibre(const name[], Float:bleedrate)
{
	strcat(clbr_Data[clbr_Total][clbr_name], name, MAX_AMMO_CALIBRE_NAME);
	clbr_Data[clbr_Total][clbr_bleedRate] = bleedrate;

	return clbr_Total++;
}

stock DefineItemTypeAmmo(ItemType:itemtype, const name[], calibre, Float:bleedratemult, Float:knockoutmult, Float:penetration, size)
{
	SetItemTypeMaxArrayData(itemtype, 1);

	ammo_Data[ammo_Total][ammo_itemType] = itemtype;
	strcat(ammo_Data[ammo_Total][ammo_name], name, MAX_AMMO_CALIBRE_NAME);
	ammo_Data[ammo_Total][ammo_calibre] = calibre;
	ammo_Data[ammo_Total][ammo_bleedrateMult] = bleedratemult;
	ammo_Data[ammo_Total][ammo_knockoutMult] = knockoutmult;
	ammo_Data[ammo_Total][ammo_penetration] = penetration;
	ammo_Data[ammo_Total][ammo_size] = size;

	ammo_ItemTypeAmmoType[itemtype] = ammo_Total;

	if(itemtype < ammo_ItemTypeLowerBound)
		ammo_ItemTypeLowerBound = itemtype;

	else if(itemtype > ammo_ItemTypeUpperBound)
		ammo_ItemTypeUpperBound = itemtype;

	return ammo_Total++;
}


/*==============================================================================

	Hook

==============================================================================*/


hook OnItemNameRender(Item:itemid, ItemType:itemtype)
{
	dbg("global", CORE, "[OnItemNameRender] in /gamemodes/sss/core/weapon/ammunition.pwn");

	new ammotype = ammo_ItemTypeAmmoType[itemtype];

	if(ammotype == -1)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new
		amount,
		str[MAX_ITEM_TEXT];

	GetItemExtraData(itemid, amount);

	format(str, sizeof(str), "%d, %s, %s",
		amount,
		clbr_Data[ammo_Data[ammotype][ammo_calibre]][clbr_name],
		ammo_Data[ammotype][ammo_name]);

	SetItemNameExtra(itemid, str);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemCreate(Item:itemid)
{
	dbg("global", CORE, "[OnItemCreate] in /gamemodes/sss/core/weapon/ammunition.pwn");

	if(GetItemLootIndex(itemid) != -1)
	{
		new ammotype = GetItemTypeAmmoType(GetItemType(itemid));

		if(ammotype != -1)
		{
			SetItemExtraData(itemid, ammo_Data[ammotype][ammo_size] == 1 ? random(1) : random(ammo_Data[ammotype][ammo_size] - 1) + 1);
		}
	}
}


/*==============================================================================

	Interface

==============================================================================*/


// clbr_name
stock GetCalibreName(calibre, name[MAX_AMMO_CALIBRE_NAME])
{
	if(!(0 <= calibre < clbr_Total))
		return 0;

	name[0] = EOS;
	strcat(name, clbr_Data[calibre][clbr_name]);

	return 1;
}

// clbr_bleedRate
stock Float:GetCalibreBleedRate(calibre)
{
	if(!(0 <= calibre < clbr_Total))
		return 0.0;

	return clbr_Data[calibre][clbr_bleedRate];
}

// ammo_itemType
stock ItemType:GetAmmoTypeItemType(ammotype)
{
	if(!(0 <= ammotype < ammo_Total))
		return INVALID_ITEM_TYPE;

	return ammo_Data[ammotype][ammo_itemType];
}

// ammo_name
stock GetAmmoTypeName(ammotype, name[])
{
	if(!(0 <= ammotype < ammo_Total))
		return 0;

	name[0] = EOS;
	strcat(name, ammo_Data[ammotype][ammo_name], MAX_AMMO_CALIBRE_NAME);

	return 1;
}

// ammo_calibre
stock GetAmmoTypeCalibre(ammotype)
{
	if(!(0 <= ammotype < ammo_Total))
		return 0;

	return ammo_Data[ammotype][ammo_calibre];
}

// ammo_bleedrateMult
stock Float:GetAmmoTypeBleedrateMultiplier(ammotype)
{
	if(!(0 <= ammotype < ammo_Total))
		return 0.0;

	return ammo_Data[ammotype][ammo_bleedrateMult];
}

// ammo_knockoutMult
stock Float:GetAmmoTypeKnockoutMultiplier(ammotype)
{
	if(!(0 <= ammotype < ammo_Total))
		return 0.0;

	return ammo_Data[ammotype][ammo_knockoutMult];
}

// ammo_penetration
stock Float:GetAmmoTypePenetration(ammotype)
{
	if(!(0 <= ammotype < ammo_Total))
		return 0.0;

	return ammo_Data[ammotype][ammo_penetration];
}

// ammo_size
stock GetAmmoTypeSize(ammotype)
{
	if(!(0 <= ammotype < ammo_Total))
		return 0;

	return ammo_Data[ammotype][ammo_size];
}


stock GetItemTypeAmmoType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return -1;

	return ammo_ItemTypeAmmoType[itemtype];
}

stock GetItemTypeCalibre(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return -1;

	if(ammo_ItemTypeAmmoType[itemtype] == -1)
		return -1;

	return ammo_Data[ammo_ItemTypeAmmoType[itemtype]][ammo_calibre];
}

stock GetItemTypeMagSize(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return -1;

	if(ammo_ItemTypeAmmoType[itemtype] == -1)
		return -1;

	return ammo_Data[ammo_ItemTypeAmmoType[itemtype]][ammo_size];
}

stock GetAmmoItemTypesOfCalibre(calibre, ItemType:output[], max = sizeof(output))
{
	new idx;

	for(new i; i < ammo_Total && idx < max; i++)
	{
		if(ammo_Data[i][ammo_calibre] == calibre)
			output[idx++] = ammo_Data[i][ammo_itemType];
	}

	return idx;
}

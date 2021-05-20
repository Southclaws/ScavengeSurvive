/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


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
			ammo_size,
			ammo_notransfer
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

stock DefineItemTypeAmmo(ItemType:itemtype, const name[], calibre, Float:bleedratemult, Float:knockoutmult, Float:penetration, size, bool:notransfer = false)
{
	SetItemTypeMaxArrayData(itemtype, 1);

	ammo_Data[ammo_Total][ammo_itemType] = itemtype;
	strcat(ammo_Data[ammo_Total][ammo_name], name, MAX_AMMO_CALIBRE_NAME);
	ammo_Data[ammo_Total][ammo_calibre] = calibre;
	ammo_Data[ammo_Total][ammo_bleedrateMult] = bleedratemult;
	ammo_Data[ammo_Total][ammo_knockoutMult] = knockoutmult;
	ammo_Data[ammo_Total][ammo_penetration] = penetration;
	ammo_Data[ammo_Total][ammo_size] = size;
	ammo_Data[ammo_Total][ammo_notransfer] = notransfer;

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
	new ammotype = ammo_ItemTypeAmmoType[itemtype];

	if(ammotype == -1)
		return 0;

	new
		amount,
		str[MAX_ITEM_TEXT];

	GetItemExtraData(itemid, amount);

	format(str, sizeof(str), "%d, %s, %s",
		amount,
		clbr_Data[ammo_Data[ammotype][ammo_calibre]][clbr_name],
		ammo_Data[ammotype][ammo_name]);

	SetItemNameExtra(itemid, str);

	return 1;
}

hook OnItemCreate(Item:itemid)
{
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

// ammo_notransfer
stock IsAmmoTypeNoTransfer(ammotype)
{
	if(!(0 <= ammotype < ammo_Total))
		return 0;

	return ammo_Data[ammotype][ammo_notransfer];
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

stock IsItemTypeAmmoTypeNoTransfer(ammotype)
{
	if(!IsValidItemType(itemtype))
		return -1;

	if(ammo_ItemTypeAmmoType[itemtype] == -1)
		return -1;

	return ammo_Data[ammo_ItemTypeAmmoType[itemtype]][ammo_notransfer];
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

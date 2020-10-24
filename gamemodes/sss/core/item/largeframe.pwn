/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnPlayerInteractDefence(playerid, Item:itemid)
{
	if(GetItemType(itemid) != item_LargeFrame)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new objectid;
	GetItemArrayDataAtCell(itemid, objectid, def_mod);
	if(IsValidDynamicObject(objectid))
	{
		SetItemArrayDataAtCell(itemid, def_mod, 0);
		DestroyDynamicObject(objectid);
	}
	else
	{
		_frame_createCovering(itemid);
	}

	SaveDefenceItem(itemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

Error:_frame_createCovering(Item:itemid)
{
	new
		Float:px,
		Float:py,
		Float:pz,
		Float:rx,
		Float:ry,
		Float:rz,
		objectid;
	GetItemPos(itemid, px, py, pz);
	GetItemRot(itemid, rx, ry, rz);

	objectid = CreateDynamicObject(19908, px, py, pz + 2.6, 0.0, 90.0, rz);
	return SetItemArrayDataAtCell(itemid, objectid, def_mod, true);
}

hook OnItemRemoveFromWorld(Item:itemid)
{
	if(GetItemType(itemid) != item_LargeFrame)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new objectid;
	GetItemArrayDataAtCell(itemid, objectid, def_mod);
	if(!IsValidDynamicObject(objectid))
		return Y_HOOKS_CONTINUE_RETURN_0;

	DestroyDynamicObject(objectid);
	SetItemArrayDataAtCell(itemid, -1, def_mod, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnDefenceLoad(Item:itemid, active, geid[], data[], length)
{
	if(!active)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(GetItemType(itemid) != item_LargeFrame)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new mod;
	GetItemArrayDataAtCell(itemid, mod, def_mod);
	if(mod == 0)
		return Y_HOOKS_CONTINUE_RETURN_0;

	_frame_createCovering(itemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}
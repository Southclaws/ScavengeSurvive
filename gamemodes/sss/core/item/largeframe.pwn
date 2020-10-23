/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 "Southclaws" Keene

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
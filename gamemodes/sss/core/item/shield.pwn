/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_Shield)
	{
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
		defer shield_Down(playerid, _:itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

timer shield_Down[400](playerid, itemid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:angle;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, angle);

	RemoveCurrentItem(playerid);

	CreateItemInWorld(Item:itemid,
		x + (0.5 * floatsin(-angle, degrees)),
		y + (0.5 * floatcos(-angle, degrees)),
		z - 0.2,
		90.0, 0.0, 180.0 + angle,
		GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), 1);
}

hook OnPlayerShootPlayer(playerid, targetid, bodypart, Float:bleedrate, Float:knockmult, Float:bulletvelocity, Float:distance)
{
	if(_HandleShieldHit(playerid, targetid, bodypart))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_HandleShieldHit(playerid, targetid, bodypart)
{
	if(bodypart == 9)
		return 0;

	new ItemType:itemtype = GetItemType(GetPlayerItem(targetid));

	if(itemtype == item_Shield)
	{
		if((7 <= bodypart <= 8) && GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK)
			return 0;

		new
			Float:angleto,
			Float:targetangle;

		GetPlayerFacingAngle(targetid, targetangle);

		angleto = absoluteangle(targetangle - GetPlayerAngleToPlayer(targetid, playerid));

		if(45.0 < angleto < 135.0)
			return 1;
	}

	itemtype = GetItemType(GetPlayerHolsterItem(playerid));

	if(itemtype == item_Shield)
	{
		new
			Float:angleto,
			Float:targetangle;

		GetPlayerFacingAngle(targetid, targetangle);

		angleto = absoluteangle(targetangle - GetPlayerAngleToPlayer(targetid, playerid));

		if(155.0 < angleto < 205.0)
			return 1;
	}

	return 0;
}

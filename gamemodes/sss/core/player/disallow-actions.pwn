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


#define IsBadInteract(%0) GetPlayerSpecialAction(%0) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(%0) || IsPlayerKnockedOut(%0) || GetPlayerAnimationIndex(%0) == 1381

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGiveItem(playerid, targetid, Item:itemid)
{
	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsBadInteract(targetid) || GetPlayerSpectateTarget(playerid) != INVALID_PLAYER_ID)
		return Y_HOOKS_BREAK_RETURN_1;

	if(GetPlayerWeapon(targetid) != 0)
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromCnt(containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(IsBadInteract(playerid))
			return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenInventory(playerid)
{
	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsPlayerAtAnyVehicleBonnet(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemCreate(Item:itemid)
{
	if(GetItemType(itemid) == ItemType:0)
		return Y_HOOKS_BREAK_RETURN_0;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

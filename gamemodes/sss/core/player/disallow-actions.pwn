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

hook OnPlayerPickUpItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerPickUpItem] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGiveItem(playerid, targetid, itemid)
{
	dbg("global", CORE, "[OnPlayerGiveItem] in /gamemodes/sss/core/player/disallow-actions.pwn");

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
	dbg("global", CORE, "[OnItemRemoveFromCnt] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(IsPlayerConnected(playerid))
	{
		if(IsBadInteract(playerid))
			return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenInventory(playerid)
{
	dbg("global", CORE, "[OnPlayerOpenInventory] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	dbg("global", CORE, "[OnPlayerOpenContainer] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerUseItem] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsPlayerAtAnyVehicleBonnet(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemCreate(itemid)
{
	dbg("global", CORE, "[OnItemCreate] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(GetItemType(itemid) == ItemType:0)
		return Y_HOOKS_BREAK_RETURN_0;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

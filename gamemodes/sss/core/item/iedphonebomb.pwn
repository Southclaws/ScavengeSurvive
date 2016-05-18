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


#include <YSI\y_hooks>


new iedp_SyncTick[MAX_PLAYERS];

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItemWithItem] in /gamemodes/sss/core/item/iedphonebomb.pwn");

	if(GetItemType(itemid) == item_MobilePhone && GetItemType(withitemid) == item_IedPhoneBomb)
	{
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
		SetItemExtraData(itemid, withitemid);
		SetItemExtraData(withitemid, 1);
		iedp_SyncTick[playerid] = GetTickCount();
		ChatMsgLang(playerid, YELLOW, "TNTPHBARMED");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItem] in /gamemodes/sss/core/item/iedphonebomb.pwn");

	if(GetItemType(itemid) == item_MobilePhone)
	{
		new bombitem = GetItemExtraData(itemid);

		if(IsValidItem(bombitem) && GetItemType(bombitem) == item_IedPhoneBomb && GetItemExtraData(bombitem) == 1)
		{
			if(GetTickCountDifference(GetTickCount(), iedp_SyncTick[playerid]) > 1000)
			{
				new
					Float:x,
					Float:y,
					Float:z;

				GetItemPos(bombitem, x, y, z);

				logf("[EXPLOSIVE] IED PHONEBOMB detonated by %p at %f, %f, %f", playerid, x, y, z);

				SetItemToExplode(bombitem, 11, 8.0, EXPLOSION_PRESET_STRUCTURAL, 1);
				SetItemExtraData(itemid, INVALID_ITEM_ID);
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

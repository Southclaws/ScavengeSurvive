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


new iedp_SyncTick[MAX_PLAYERS];

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_MobilePhone && GetItemType(withitemid) == item_IedPhoneBomb)
	{
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
		SetItemExtraData(itemid, withitemid);
		SetItemExtraData(withitemid, 1);
		iedp_SyncTick[playerid] = GetTickCount();
		Msg(playerid, YELLOW, " >  Cell phones synced, use phone to detonate.");
	}
	#if defined iedp_OnPlayerUseItemWithItem
		return iedp_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem iedp_OnPlayerUseItemWithItem
#if defined iedp_OnPlayerUseItemWithItem
	forward iedp_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif

public OnPlayerUseItem(playerid, itemid)
{
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
	#if defined iedp_OnPlayerUseItem
		return iedp_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem iedp_OnPlayerUseItem
#if defined iedp_OnPlayerUseItem
	forward iedp_OnPlayerUseItem(playerid, itemid);
#endif

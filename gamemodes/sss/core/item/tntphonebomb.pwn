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


new tntp_SyncTick[MAX_PLAYERS];

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_MobilePhone && GetItemType(withitemid) == item_TntPhoneBomb)
	{
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
		SetItemExtraData(itemid, withitemid);
		SetItemExtraData(withitemid, 1);
		tntp_SyncTick[playerid] = GetTickCount();
		Msg(playerid, YELLOW, " >  Cell phones synced, use phone to detonate.");
	}
	#if defined tntp_OnPlayerUseItemWithItem
		return tntp_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem tntp_OnPlayerUseItemWithItem
#if defined tntp_OnPlayerUseItemWithItem
	forward tntp_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_MobilePhone)
	{
		new bombitem = GetItemExtraData(itemid);

		if(IsValidItem(bombitem) && GetItemType(bombitem) == item_TntPhoneBomb && GetItemExtraData(bombitem) == 1)
		{
			if(GetTickCountDifference(GetTickCount(), tntp_SyncTick[playerid]) > 1000)
			{
				new
					Float:x,
					Float:y,
					Float:z;

				GetItemPos(bombitem, x, y, z);

				logf("[EXPLOSIVE] TNT PHONEBOMB detonated by %p at %f, %f, %f", playerid, x, y, z);

				SetItemToExplode(bombitem, 10, 12.0, EXPLOSION_PRESET_STRUCTURAL, 2);
				SetItemExtraData(itemid, INVALID_ITEM_ID);
			}
		}
	}
	#if defined tntp_OnPlayerUseItem
		return tntp_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem tntp_OnPlayerUseItem
#if defined tntp_OnPlayerUseItem
	forward tntp_OnPlayerUseItem(playerid, itemid);
#endif

public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_MobilePhone)
	{
		SetItemExtraData(itemid, INVALID_ITEM_ID);
	}

	#if defined tntp_OnItemCreate
		return tntp_OnItemCreate(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate tntp_OnItemCreate
#if defined tntp_OnItemCreate
	forward tntp_OnItemCreate(itemid);
#endif

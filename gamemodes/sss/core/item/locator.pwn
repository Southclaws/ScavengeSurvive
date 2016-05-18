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


hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItemWithItem] in /gamemodes/sss/core/item/locator.pwn");

	if(GetItemType(itemid) == item_Locator && GetItemType(withitemid) == item_MobilePhone)
	{
		SetItemExtraData(itemid, withitemid);
		SetItemExtraData(withitemid, 1);

		ChatMsgLang(playerid, YELLOW, "LOCATORSYNC");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItem] in /gamemodes/sss/core/item/locator.pwn");

	if(GetItemType(itemid) == item_Locator)
	{
		new phoneItemID = GetItemExtraData(itemid);
		
		if(IsValidItem(phoneItemID) && GetItemType(phoneItemID) == item_MobilePhone && GetItemExtraData(phoneItemID) == 1)
		{
		
			new
				Float:x,
				Float:y,
				Float:z,
				Float:phone_x,
				Float:phone_y,
				Float:phone_z;

			GetPlayerPos(playerid, x, y, z);
			
			if(IsItemInWorld(phoneItemID))
			{
			
				GetItemPos	(phoneItemID, phone_x, phone_y, phone_z);
				
				new
					Float:distance = Distance(phone_x, phone_y, phone_z, x, y, z);
					
				ShowActionText(playerid, sprintf(ls(playerid, "DISTANCEVAL"), distance), 2000);
				return 1;
			}
			
			new containerid = GetItemContainer(phoneItemID);

			if(IsValidContainer(containerid))
			{
				new buttonid = GetContainerButton(containerid);

				if(IsValidButton(buttonid))
				{
					GetButtonPos(buttonid, phone_x, phone_y, phone_z);

					new
						Float:distance = Distance(phone_x, phone_y, phone_z, x, y, z);

					ShowActionText(playerid, sprintf(ls(playerid, "DISTANCEVAL"), distance), 2000);
					return 1;
				}

				new vehicleid = GetContainerTrunkVehicleID(containerid);

				if(IsValidVehicle(vehicleid))
				{
					GetVehiclePos(vehicleid, phone_x, phone_y, phone_z);

					new
						Float:distance = Distance(phone_x, phone_y, phone_z, x, y, z);

					ShowActionText(playerid, sprintf(ls(playerid, "DISTANCEVAL"), distance), 2000);
					return 1;
				}

				new safeboxitemid = GetContainerSafeboxItem(containerid);

				if(IsValidItem(safeboxitemid))
				{
					
					GetItemPos(safeboxitemid, phone_x, phone_y, phone_z);

					new
						Float:distance = Distance(phone_x, phone_y, phone_z, x, y, z);

					ShowActionText(playerid, sprintf(ls(playerid, "DISTANCEVAL"), distance), 2000);
					return 1;
				}

				new playerid_ = GetContainerPlayerBag(containerid);
				
				if(IsPlayerConnected(playerid_))
				{
					
					GetPlayerPos(playerid_, phone_x, phone_y, phone_z);
				
					new
						Float:distance = Distance(phone_x, phone_y, phone_z, x, y, z);

					ShowActionText(playerid, sprintf(ls(playerid, "DISTANCEVAL"), distance), 2000);
					return 1;
				}
				
				new bagitemid = GetContainerBagItem(containerid);

				if(IsValidItem(bagitemid))
				{

					GetItemPos(bagitemid, phone_x, phone_y, phone_z);

					new
						Float:distance = Distance(phone_x, phone_y, phone_z, x, y, z);

					ShowActionText(playerid, sprintf(ls(playerid, "DISTANCEVAL"), distance), 2000);
					return 1;
				}
			}
			
			new playerid_ = GetItemPlayerInventory(phoneItemID);

			if(IsPlayerConnected(playerid_))
			{
				
				GetPlayerPos(playerid_, phone_x, phone_y, phone_z);
				
				new
					Float:distance = Distance(phone_x, phone_y, phone_z, x, y, z);

				ShowActionText(playerid, sprintf(ls(playerid, "DISTANCEVAL"), distance), 2000);
				return 1;
			}
			
			
			ShowActionText(playerid, "Unable to trace the mobile phone", 2000);
	

		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemCreate(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemCreate] in /gamemodes/sss/core/item/locator.pwn");

	if(GetItemType(itemid) == item_Locator)
	{
		SetItemExtraData(itemid, INVALID_ITEM_ID);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

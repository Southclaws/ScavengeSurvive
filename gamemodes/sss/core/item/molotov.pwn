/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(withitemid) == item_MolotovEmpty)
	{
		new 
			ItemType:itemtype = GetItemType(itemid);

		if(GetItemTypeLiquidContainerType(itemtype) == -1)
			return Y_HOOKS_BREAK_RETURN_1;
			
		if(GetLiquidItemLiquidType(itemid) != liquid_Petrol)
		{
			ShowActionText(playerid, ls(playerid, "FUELNOTPETR", true), 3000);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		new 
			Float:canfuel = GetLiquidItemLiquidAmount(itemid);

		if(canfuel <= 0.0)
		{
			ShowActionText(playerid, ls(playerid, "PETROLEMPTY", true), 3000);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		new
			Float:x,
			Float:y,
			Float:z,
			Float:rz,
			Float:transfer;

		GetItemPos(withitemid, x, y, z);
		GetItemRot(withitemid, rz, rz, rz);

		DestroyItem(withitemid);
		CreateItem(ItemType:18, x, y, z, .rz = rz);

		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
		ShowActionText(playerid, ls(playerid, "MOLOPOURBOT", true), 3000);
		
		transfer = (canfuel - 0.5 < 0.0) ? canfuel : 0.5;
		SetLiquidItemLiquidAmount(itemid, canfuel - transfer);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

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


static HANDLER = -1;


enum e_plant_pot_data
{
	E_PLANT_POT_ACTIVE,
	E_PLANT_POT_SEED_TYPE,
	E_PLANT_POT_WATER,
	E_PLANT_POT_GROWTH,
	E_PLANT_POT_OBJECT_ID
}


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'PlantPot'...");

	HANDLER = debug_register_handler("plantpot");
}

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "PlantPot"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("PlantPot"), 5);
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItemWithItem] in /gamemodes/sss/core/item/plantpot.pwn");

	if(GetItemType(withitemid) == item_PlantPot)
	{
		d:1:HANDLER("[_pot_UseItemWithItem] player %d itemid %d withitemid %d", playerid, itemid, withitemid);
		new
			ItemType:itemtype = GetItemType(itemid),
			potdata[e_plant_pot_data];

		GetItemArrayData(withitemid, potdata);

		if(itemtype == item_SeedBag)
		{
			new amount = GetItemArrayDataAtCell(itemid, E_SEED_BAG_AMOUNT);

			if(amount > 0)
			{
				potdata[E_PLANT_POT_SEED_TYPE] = GetItemArrayDataAtCell(itemid, E_SEED_BAG_TYPE);
				potdata[E_PLANT_POT_ACTIVE] = 1;
				potdata[E_PLANT_POT_GROWTH] = 0;

				SetItemArrayDataAtCell(itemid, amount - 1, E_SEED_BAG_AMOUNT);
				SetItemArrayData(withitemid, potdata, e_plant_pot_data);
				ShowActionText(playerid, ls(playerid, "POTADDSEEDS"), 5000);
				SetButtonText(GetItemButtonID(itemid), "Press F to pick up~n~Press "KEYTEXT_INTERACT" with water bottle to add water");
			}
		}

		if(GetItemTypeLiquidContainerType(itemtype) != -1)
		{
			new
				Float:amount = GetLiquidItemLiquidAmount(itemid),
				type = GetLiquidItemLiquidType(itemid);

			if(amount <= 0.0)
			{
				ShowActionText(playerid, ls(playerid, "POTBOTEMPTY"), 5000);
			}
			else if(type != liquid_Water)
			{
				ShowActionText(playerid, ls(playerid, "POTBOTNOWAT"), 5000);
			}
			else
			{
				new Float:transfer = (amount < 0.1) ? amount : 0.1;
				d:2:HANDLER("[_pot_UseItemWithItem] amount %f transfer %f floatround(transfer * 10) = %d", amount, transfer, floatround(transfer * 10));

				SetItemArrayDataAtCell(withitemid, GetItemArrayDataAtCell(withitemid, E_PLANT_POT_WATER) + floatround(transfer * 10), E_PLANT_POT_WATER, 1);
				SetLiquidItemLiquidAmount(itemid, amount - transfer);
				ShowActionText(playerid, ls(playerid, "POTADDWATER"), 5000);
				SetButtonText(GetItemButtonID(itemid), "Press F to pick up~n~Press "KEYTEXT_INTERACT" with knife to harvest");
			}
		}

		if(itemtype == item_Knife)
		{
			if(!potdata[E_PLANT_POT_ACTIVE])
			{
				ShowActionText(playerid, ls(playerid, "POTNOACPLNT"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			new seedtype = potdata[E_PLANT_POT_SEED_TYPE];

			if(!IsValidSeedType(seedtype))
			{
				ShowActionText(playerid, ls(playerid, "POTINVASEED"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			if(_:(potdata[E_PLANT_POT_GROWTH] < GetSeedTypeGrowthTime(seedtype)))
			{
				ShowActionText(playerid, ls(playerid, "POTNOTGROWN"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			new
				Float:x,
				Float:y,
				Float:z,
				world = GetItemWorld(withitemid),
				interior = GetItemInterior(withitemid);

			GetItemPos(withitemid, x, y, z);

			CreateItem(GetSeedTypeItemType(seedtype), x, y, z + 0.5, _, _, _, FLOOR_OFFSET - 0.3, world, interior);
			DestroyDynamicObject(potdata[E_PLANT_POT_OBJECT_ID]);

			potdata[E_PLANT_POT_ACTIVE] = 0;
			potdata[E_PLANT_POT_SEED_TYPE] = 0;
			potdata[E_PLANT_POT_WATER] = 0;
			potdata[E_PLANT_POT_GROWTH] = 0;
			potdata[E_PLANT_POT_OBJECT_ID] = INVALID_OBJECT_ID;

			SetItemArrayData(withitemid, potdata, e_plant_pot_data);

			ShowActionText(playerid, ls(playerid, "POTHARVESTE"), 3000);
		}

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_pot_Load(itemid)
{
	if(GetItemType(itemid) != item_PlantPot)
	{
		printf("ERROR: Attempted to _pot_Load an item that wasn't a pot (%d type %d).", itemid, _:GetItemType(itemid));
		return;
	}

	d:1:HANDLER("[_pot_Load] itemid %d", itemid);
	new potdata[e_plant_pot_data];

	GetItemArrayData(itemid, potdata);

	if(!potdata[E_PLANT_POT_ACTIVE])
	{
		SetButtonText(GetItemButtonID(itemid), "Press F to pick up~n~Press "KEYTEXT_INTERACT" with seeds to plant");
		return;
	}

	d:1:HANDLER("[_pot_Load] pot active, water: %d", potdata[E_PLANT_POT_WATER]);
	if(potdata[E_PLANT_POT_WATER] > 0)
	{
		// Sufficiently watered? Grow and drink some water.
		potdata[E_PLANT_POT_WATER] -= 1;
		potdata[E_PLANT_POT_GROWTH] += 1;
	}
	else
	{
		// No water? Degrade.
		potdata[E_PLANT_POT_GROWTH] -= 1;
	}

	// If growth is reduced to 0, Die :(
	if(potdata[E_PLANT_POT_GROWTH] <= 0)
	{
		d:1:HANDLER("[_pot_Load] growth: %d dying.", potdata[E_PLANT_POT_GROWTH]);
		potdata[E_PLANT_POT_ACTIVE] = 0;
		potdata[E_PLANT_POT_SEED_TYPE] = -1;
		potdata[E_PLANT_POT_WATER] = 0;
		potdata[E_PLANT_POT_GROWTH] = 0;
		SetButtonText(GetItemButtonID(itemid), "Press F to pick up~n~Press "KEYTEXT_INTERACT" with seeds to plant");
	}

	SetItemArrayData(itemid, potdata, e_plant_pot_data);

	_pot_UpdateModel(itemid);

	return;
}

_pot_UpdateModel(itemid, bool:toggle = true)
{
	d:1:HANDLER("[_pot_UpdateModel] itemid %d toggle %d", itemid, toggle);
	if(!IsItemInWorld(itemid))
		toggle = false;

	if(toggle)
	{
		if(!GetItemArrayDataAtCell(itemid, E_PLANT_POT_ACTIVE))
			return 0;

		new
			Float:x,
			Float:y,
			Float:z,
			Float:rz,
			world,
			interior,
			seedtype;

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rz, rz, rz);
		world = GetItemWorld(itemid);
		interior = GetItemInterior(itemid);
		seedtype = GetItemArrayDataAtCell(itemid, E_PLANT_POT_SEED_TYPE);

		if(!IsValidSeedType(seedtype))
		{
			return 0;
		}

		new growth = GetItemArrayDataAtCell(itemid, E_PLANT_POT_GROWTH);

		if(0 < growth < GetSeedTypeGrowthTime(seedtype))
		{
			// max: 0.2741 min: 0.0775
			// step size: 0.1966 / max growth
			// pos: step size * current growth+1
			new id = GetItemArrayDataAtCell(itemid, E_PLANT_POT_OBJECT_ID);

			if(id != INVALID_OBJECT_ID)
			{
				DestroyDynamicObject(id);
			}

			z += (0.1966 / GetSeedTypeGrowthTime(seedtype)) * growth;

			id = CreateDynamicObject(2194, x, y, z, 0.0, 0.0, rz, world, interior, _, 50.0, 50.0);
			SetItemArrayDataAtCell(itemid, id, E_PLANT_POT_OBJECT_ID, 0, 0);
		}
		else
		{
			new id = GetItemArrayDataAtCell(itemid, E_PLANT_POT_OBJECT_ID);

			if(id != INVALID_OBJECT_ID)
			{
				DestroyDynamicObject(id);
			}

			z += GetSeedTypePlantOffset(seedtype);

			id = CreateDynamicObject(GetSeedTypePlantModel(seedtype), x, y, z, 0.0, 0.0, rz, world, interior, _, 50.0, 50.0);
			SetItemArrayDataAtCell(itemid, id, E_PLANT_POT_OBJECT_ID, 0, 0);
		}
	}
	else
	{
		DestroyDynamicObject(GetItemArrayDataAtCell(itemid, E_PLANT_POT_OBJECT_ID));
		SetItemArrayDataAtCell(itemid, INVALID_OBJECT_ID, E_PLANT_POT_OBJECT_ID, 0, 0);
	}

	return 1;
}

hook OnItemCreateInWorld(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemCreateInWorld] in /gamemodes/sss/core/item/plantpot.pwn");

	if(GetItemType(itemid) == item_PlantPot)
	{
		d:1:HANDLER("[OnItemCreateInWorld] PlantPot itemid %d", itemid);

		SetButtonText(GetItemButtonID(itemid), "Hold "KEYTEXT_INTERACT" to pick up~n~Press "KEYTEXT_INTERACT" for status");

		if(gServerInitialising)
		{
			d:2:HANDLER("[OnItemCreateInWorld] gServerInitialising true");
			if(GetItemLootIndex(itemid) != -1)
			{
				d:2:HANDLER("[OnItemCreateInWorld] ItemLootIndex != -1");
				new potdata[e_plant_pot_data];

				potdata[E_PLANT_POT_ACTIVE] = 0;
				potdata[E_PLANT_POT_SEED_TYPE] = -1;
				potdata[E_PLANT_POT_WATER] = 0;
				potdata[E_PLANT_POT_GROWTH] = 0;
				potdata[E_PLANT_POT_OBJECT_ID] = INVALID_OBJECT_ID;

				SetItemArrayData(itemid, potdata, e_plant_pot_data);
			}
			else
			{
				d:2:HANDLER("[OnItemCreateInWorld] ItemLootIndex == -1");
				_pot_Load(itemid);
			}
		}
	}
}

hook OnPlayerUseItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItem] in /gamemodes/sss/core/item/plantpot.pwn");

	if(GetItemType(itemid) == item_PlantPot && IsItemInWorld(itemid))
	{
		new
			potdata[e_plant_pot_data],
			string[256];

		GetItemArrayData(itemid, potdata);

		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);

		format(string, sizeof(string), "Active:%d\nSeed type:%d\nWater:%d\nGrowth:%d/%d\n",
			potdata[E_PLANT_POT_ACTIVE],
			potdata[E_PLANT_POT_SEED_TYPE],
			potdata[E_PLANT_POT_WATER],
			potdata[E_PLANT_POT_GROWTH],
			GetSeedTypeGrowthTime(potdata[E_PLANT_POT_SEED_TYPE]));

		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, response, listitem, inputtext
			ClearAnimations(playerid, 1);
		}
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Plant Pot", string, "Close");

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerPickUpItem] in /gamemodes/sss/core/item/plantpot.pwn");

	if(GetItemType(itemid) == item_PlantPot)
		_pot_UpdateModel(itemid, false);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerDroppedItem] in /gamemodes/sss/core/item/plantpot.pwn");

	if(GetItemType(itemid) == item_PlantPot)
		_pot_UpdateModel(itemid);
}

hook OnItemDestroy(itemid)
{
	d:3:GLOBAL_DEBUG("[OnItemDestroy] in /gamemodes/sss/core/item/plantpot.pwn");

	if(GetItemType(itemid) == item_PlantPot)
		_pot_UpdateModel(itemid, false);
}

ACMD:potg[4](playerid, params[])
{
	new
		itemid,
		growth;

	itemid = strval(params);
	growth = GetItemArrayDataAtCell(itemid, E_PLANT_POT_GROWTH);

	SetItemArrayDataAtCell(itemid, growth, E_PLANT_POT_GROWTH);
	_pot_Load(itemid);

	return 1;
}

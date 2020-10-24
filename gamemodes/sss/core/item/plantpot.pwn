/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


enum e_plant_pot_data
{
	E_PLANT_POT_ACTIVE,
	E_PLANT_POT_SEED_TYPE,
	E_PLANT_POT_WATER,
	E_PLANT_POT_GROWTH,
	E_PLANT_POT_OBJECT_ID
}


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "PlantPot"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("PlantPot"), 5);
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(withitemid) == item_PlantPot)
	{
		dbg("plantpot", 1, "[_pot_UseItemWithItem] player %d itemid %d withitemid %d", playerid, _:itemid, _:withitemid);
		new
			ItemType:itemtype = GetItemType(itemid),
			potdata[e_plant_pot_data];

		GetItemArrayData(withitemid, potdata);

		if(itemtype == item_SeedBag)
		{
			new amount;
			GetItemArrayDataAtCell(itemid, amount, E_SEED_BAG_AMOUNT);

			if(amount > 0)
			{
				GetItemArrayDataAtCell(itemid, potdata[E_PLANT_POT_SEED_TYPE], E_SEED_BAG_TYPE);
				potdata[E_PLANT_POT_ACTIVE] = 1;
				potdata[E_PLANT_POT_GROWTH] = 0;

				SetItemArrayDataAtCell(itemid, amount - 1, E_SEED_BAG_AMOUNT);
				SetItemArrayData(withitemid, potdata, e_plant_pot_data);
				ShowActionText(playerid, ls(playerid, "POTADDSEEDS", true), 5000);
				new Button:buttonid;
				GetItemButtonID(itemid, buttonid);
				SetButtonText(buttonid, "Press F to pick up~n~Press "KEYTEXT_INTERACT" with water bottle to add water");
			}
		}

		if(GetItemTypeLiquidContainerType(itemtype) != -1)
		{
			new
				Float:amount = GetLiquidItemLiquidAmount(itemid),
				type = GetLiquidItemLiquidType(itemid);

			if(amount <= 0.0)
			{
				ShowActionText(playerid, ls(playerid, "POTBOTEMPTY", true), 5000);
			}
			else if(type != liquid_Water)
			{
				ShowActionText(playerid, ls(playerid, "POTBOTNOWAT", true), 5000);
			}
			else
			{
				new Float:transfer = (amount < 0.1) ? amount : 0.1, water;
				dbg("plantpot", 2, "[_pot_UseItemWithItem] amount %f transfer %f floatround(transfer * 10) = %d", amount, transfer, floatround(transfer * 10));

				GetItemArrayDataAtCell(withitemid, water, E_PLANT_POT_WATER);
				SetItemArrayDataAtCell(withitemid, water + floatround(transfer * 10), E_PLANT_POT_WATER, true);
				SetLiquidItemLiquidAmount(itemid, amount - transfer);
				ShowActionText(playerid, ls(playerid, "POTADDWATER", true), 5000);
				new Button:buttonid;
				GetItemButtonID(itemid, buttonid);
				SetButtonText(buttonid, "Press F to pick up~n~Press "KEYTEXT_INTERACT" with knife to harvest");
			}
		}

		if(itemtype == item_Knife)
		{
			if(!potdata[E_PLANT_POT_ACTIVE])
			{
				ShowActionText(playerid, ls(playerid, "POTNOACPLNT", true), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			new seedtype = potdata[E_PLANT_POT_SEED_TYPE];

			if(!IsValidSeedType(seedtype))
			{
				ShowActionText(playerid, ls(playerid, "POTINVASEED", true), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			if(_:(potdata[E_PLANT_POT_GROWTH] < GetSeedTypeGrowthTime(seedtype)))
			{
				ShowActionText(playerid, ls(playerid, "POTNOTGROWN", true), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			new
				Float:x,
				Float:y,
				Float:z,
				world,
				interior;

			GetItemWorld(withitemid, world);
			GetItemInterior(withitemid, interior);

			GetItemPos(withitemid, x, y, z);

			CreateItem(GetSeedTypeItemType(seedtype), x, y, z + 0.5, .world = world, .interior = interior);
			DestroyDynamicObject(potdata[E_PLANT_POT_OBJECT_ID]);

			potdata[E_PLANT_POT_ACTIVE] = 0;
			potdata[E_PLANT_POT_SEED_TYPE] = 0;
			potdata[E_PLANT_POT_WATER] = 0;
			potdata[E_PLANT_POT_GROWTH] = 0;
			potdata[E_PLANT_POT_OBJECT_ID] = INVALID_OBJECT_ID;

			SetItemArrayData(withitemid, potdata, e_plant_pot_data);

			ShowActionText(playerid, ls(playerid, "POTHARVESTE", true), 3000);
		}

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_pot_Load(Item:itemid)
{
	if(GetItemType(itemid) != item_PlantPot)
	{
		err("Attempted to _pot_Load an item that wasn't a pot (%d type %d).", _:itemid, _:GetItemType(itemid));
		return;
	}

	dbg("plantpot", 1, "[_pot_Load] itemid %d", _:itemid);
	new potdata[e_plant_pot_data];

	GetItemArrayData(itemid, potdata);

	if(!potdata[E_PLANT_POT_ACTIVE])
	{
		new Button:buttonid;
		GetItemButtonID(itemid, buttonid);
		SetButtonText(buttonid, "Press F to pick up~n~Press "KEYTEXT_INTERACT" with seeds to plant");
		return;
	}

	dbg("plantpot", 1, "[_pot_Load] pot active, water: %d", potdata[E_PLANT_POT_WATER]);
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
		dbg("plantpot", 1, "[_pot_Load] growth: %d dying.", potdata[E_PLANT_POT_GROWTH]);
		potdata[E_PLANT_POT_ACTIVE] = 0;
		potdata[E_PLANT_POT_SEED_TYPE] = -1;
		potdata[E_PLANT_POT_WATER] = 0;
		potdata[E_PLANT_POT_GROWTH] = 0;
		new Button:buttonid;
		GetItemButtonID(itemid, buttonid);
		SetButtonText(buttonid, "Press F to pick up~n~Press "KEYTEXT_INTERACT" with seeds to plant");
	}

	SetItemArrayData(itemid, potdata, e_plant_pot_data);

	_pot_UpdateModel(itemid);

	return;
}

_pot_UpdateModel(Item:itemid, bool:toggle = true)
{
	dbg("plantpot", 1, "[_pot_UpdateModel] itemid %d toggle %d", _:itemid, toggle);
	if(!IsItemInWorld(itemid))
		toggle = false;

	if(toggle)
	{
		new active;
		GetItemArrayDataAtCell(itemid, active, E_PLANT_POT_ACTIVE);
		if(!active)
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
		GetItemWorld(itemid, world);
		GetItemInterior(itemid, interior);
		GetItemArrayDataAtCell(itemid, seedtype, E_PLANT_POT_SEED_TYPE);

		if(!IsValidSeedType(seedtype))
		{
			return 0;
		}

		new growth;
		GetItemArrayDataAtCell(itemid, growth, E_PLANT_POT_GROWTH);

		if(0 < growth < GetSeedTypeGrowthTime(seedtype))
		{
			// max: 0.2741 min: 0.0775
			// step size: 0.1966 / max growth
			// pos: step size * current growth+1
			new id;
			GetItemArrayDataAtCell(itemid, id, E_PLANT_POT_OBJECT_ID);

			if(id != INVALID_OBJECT_ID)
			{
				DestroyDynamicObject(id);
			}

			z += (0.1966 / GetSeedTypeGrowthTime(seedtype)) * growth;

			id = CreateDynamicObject(2194, x, y, z, 0.0, 0.0, rz, world, interior, _, 50.0, 50.0);
			SetItemArrayDataAtCell(itemid, id, E_PLANT_POT_OBJECT_ID, false, false);
		}
		else
		{
			new id;
			GetItemArrayDataAtCell(itemid, id, E_PLANT_POT_OBJECT_ID);

			if(id != INVALID_OBJECT_ID)
			{
				DestroyDynamicObject(id);
			}

			z += GetSeedTypePlantOffset(seedtype);

			id = CreateDynamicObject(GetSeedTypePlantModel(seedtype), x, y, z, 0.0, 0.0, rz, world, interior, _, 50.0, 50.0);
			SetItemArrayDataAtCell(itemid, id, E_PLANT_POT_OBJECT_ID, false, false);
		}
	}
	else
	{
		new objectid;
		GetItemArrayDataAtCell(itemid, objectid, E_PLANT_POT_OBJECT_ID);
		DestroyDynamicObject(objectid);
		SetItemArrayDataAtCell(itemid, INVALID_OBJECT_ID, E_PLANT_POT_OBJECT_ID, false, false);
	}

	return 1;
}

hook OnItemCreateInWorld(Item:itemid)
{
	if(GetItemType(itemid) == item_PlantPot)
	{
		dbg("plantpot", 1, "[OnItemCreateInWorld] PlantPot itemid %d", _:itemid);

		new Button:buttonid;
		GetItemButtonID(itemid, buttonid);
		SetButtonText(buttonid, "Hold "KEYTEXT_INTERACT" to pick up~n~Press "KEYTEXT_INTERACT" for status");

		if(gServerInitialising)
		{
			dbg("plantpot", 2, "[OnItemCreateInWorld] gServerInitialising true");
			if(GetItemLootIndex(itemid) != -1)
			{
				dbg("plantpot", 2, "[OnItemCreateInWorld] ItemLootIndex != -1");
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
				dbg("plantpot", 2, "[OnItemCreateInWorld] ItemLootIndex == -1");
				_pot_Load(itemid);
			}
		}
	}
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
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

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_PlantPot)
		_pot_UpdateModel(itemid, false);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_PlantPot)
		_pot_UpdateModel(itemid);
}

hook OnItemDestroy(Item:itemid)
{
	if(GetItemType(itemid) == item_PlantPot)
		_pot_UpdateModel(itemid, false);
}

ACMD:potg[4](playerid, params[])
{
	new
		Item:itemid,
		growth;

	itemid = Item:strval(params);
	GetItemArrayDataAtCell(itemid, growth, E_PLANT_POT_GROWTH);

	SetItemArrayDataAtCell(itemid, growth, E_PLANT_POT_GROWTH);
	_pot_Load(itemid);

	return 1;
}

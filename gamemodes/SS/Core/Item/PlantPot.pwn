enum e_plant_pot_data
{
	E_PLANT_POT_ACTIVE,
	E_PLANT_POT_SEED_TYPE,
	E_PLANT_POT_WATER,
	E_PLANT_POT_GROWTH,
	E_PLANT_POT_OBJECT_ID
}


static
Timer:	pot_PickUpTimer[MAX_PLAYERS],
		pot_PickUpTick[MAX_PLAYERS],
		pot_CurrentItem[MAX_PLAYERS];

_pot_UseItemWithItem(playerid, itemid, withitemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_SeedBag)
	{
		new amount = GetItemArrayDataAtCell(itemid, E_SEED_BAG_AMOUNT);

		if(amount > 0)
		{
			SetItemArrayDataAtCell(withitemid, GetItemArrayDataAtCell(itemid, E_SEED_BAG_TYPE), E_PLANT_POT_SEED_TYPE, 1);
			SetItemArrayDataAtCell(withitemid, 1, E_PLANT_POT_ACTIVE, 1);
			SetItemArrayDataAtCell(itemid, amount - 1, E_SEED_BAG_AMOUNT);
			ShowActionText(playerid, "Added seeds to plant pot", 5000);
			SetButtonText(GetItemButtonID(itemid), "Press F to pick up~n~Press "KEYTEXT_INTERACT" with water bottle to add water");
		}
	}

	if(itemtype == item_Bottle)
	{
		new amount = GetFoodItemSubType(itemid);

		if(amount > 0)
		{
			SetItemArrayDataAtCell(withitemid, GetItemArrayDataAtCell(withitemid, E_PLANT_POT_WATER) + 1, E_PLANT_POT_WATER, 1);
			SetFoodItemAmount(itemid, amount - 1);
			ShowActionText(playerid, "Added 1 water to plant pot", 5000);
			SetButtonText(GetItemButtonID(itemid), "Press F to pick up~n~Press "KEYTEXT_INTERACT" with knife to harvest");
		}
	}

	if(itemtype == item_Knife)
	{
		new potdata[e_plant_pot_data];

		GetItemArrayData(withitemid, potdata);

		if(!potdata[E_PLANT_POT_ACTIVE])
		{
			ShowActionText(playerid, "Pot doesn't contain an active plant.", 3000);
			return 0;
		}

		new seedtype = potdata[E_PLANT_POT_SEED_TYPE];

		if(!IsValidSeedType(seedtype))
		{
			ShowActionText(playerid, "Invalid seed type.", 3000);
			return 0;
		}

		if(_:(potdata[E_PLANT_POT_GROWTH] < GetSeedTypeGrowthTime(seedtype)))
		{
			ShowActionText(playerid, "The plant has not fully grown yet.", 3000);
			return 0;
		}

		new
			Float:x,
			Float:y,
			Float:z,
			world = GetItemWorld(withitemid),
			interior = GetItemInterior(withitemid);

		GetItemPos(withitemid, x, y, z);

		CreateItem(GetSeedTypeItemType(seedtype), x, y, z, _, _, _, FLOOR_OFFSET - 0.3, world, interior);
		DestroyDynamicObject(potdata[E_PLANT_POT_OBJECT_ID]);

		potdata[E_PLANT_POT_ACTIVE] = 0;
		potdata[E_PLANT_POT_SEED_TYPE] = 0;
		potdata[E_PLANT_POT_WATER] = 0;
		potdata[E_PLANT_POT_GROWTH] = 0;
		potdata[E_PLANT_POT_OBJECT_ID] = INVALID_OBJECT_ID;

		SetItemArrayData(withitemid, potdata, e_plant_pot_data);

		ShowActionText(playerid, "Plant harvested", 3000);
	}

	return 1;
}

_pot_Load(itemid)
{
	new potdata[e_plant_pot_data];

	GetItemArrayData(itemid, potdata);

	if(!potdata[E_PLANT_POT_ACTIVE])
	{
		SetButtonText(GetItemButtonID(itemid), "Press F to pick up~n~Press "KEYTEXT_INTERACT" with seeds to plant");
		return;
	}

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
		potdata[E_PLANT_POT_ACTIVE] = 0;
		potdata[E_PLANT_POT_SEED_TYPE] = -1;
		SetButtonText(GetItemButtonID(itemid), "Press F to pick up~n~Press "KEYTEXT_INTERACT" with seeds to plant");
	}

	SetItemArrayData(itemid, potdata, e_plant_pot_data);

	_pot_UpdateModel(itemid);

	return;
}

_pot_UpdateModel(itemid, bool:toggle = true)
{
	if(!IsItemInWorld(itemid))
		toggle = false;

	if(toggle)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:rx,
			Float:ry,
			Float:rz,
			world,
			interior,
			seedtype;

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rx, ry, rz);
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

			id = CreateDynamicObject(2194, x, y, z, rx, ry, rz, world, interior, _, 50.0, 50.0);
			SetItemArrayDataAtCell(itemid, id, E_PLANT_POT_OBJECT_ID);
		}
		else
		{
			new id = GetItemArrayDataAtCell(itemid, E_PLANT_POT_OBJECT_ID);

			if(id != INVALID_OBJECT_ID)
			{
				DestroyDynamicObject(id);
			}

			id = CreateDynamicObject(GetSeedTypePlantModel(seedtype), x, y, z + GetSeedTypePlantOffset(seedtype), rx, ry, rz, world, interior, _, 50.0, 50.0);
			SetItemArrayDataAtCell(itemid, id, E_PLANT_POT_OBJECT_ID);
		}
	}
	else
	{
		DestroyDynamicObject(GetItemArrayDataAtCell(itemid, E_PLANT_POT_OBJECT_ID));
		SetItemArrayDataAtCell(itemid, INVALID_OBJECT_ID, E_PLANT_POT_OBJECT_ID);
	}

	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		if(GetTickCountDifference(GetTickCount(), pot_PickUpTick[playerid]) < 200)
		{
			if(IsValidItem(pot_CurrentItem[playerid]))
			{
				new
					potdata[e_plant_pot_data],
					string[256];

				GetItemArrayData(pot_CurrentItem[playerid], potdata);

				ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);
				stop pot_PickUpTimer[playerid];
				pot_PickUpTick[playerid] = 0;

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
			}
		}
	}
}

_pot_PickUp(playerid, itemid)
{
	if(GetItemType(itemid) == item_PlantPot)
	{
		stop pot_PickUpTimer[playerid];
		pot_PickUpTimer[playerid] = defer _pot_PickUpDelay(playerid, itemid);

		pot_PickUpTick[playerid] = GetTickCount();
		pot_CurrentItem[playerid] = itemid;

		return 1;
	}

	return 0;
}

timer _pot_PickUpDelay[400](playerid, itemid)
{
	if(IsValidItem(GetPlayerItem(playerid)))
		return;

	PlayerPickUpItem(playerid, itemid);
	_pot_UpdateModel(itemid, false);

	return;
}

public OnItemCreateInWorld(itemid)
{
	if(GetItemType(itemid) == item_PlantPot)
	{
		if(gServerInitialising)
		{
			if(GetItemLootIndex(itemid) != -1)
			{
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
				_pot_Load(itemid);
			}
		}
	}

	#if defined pot_OnItemCreateInWorld
		return pot_OnItemCreateInWorld(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreateInWorld
	#undef OnItemCreateInWorld
#else
	#define _ALS_OnItemCreateInWorld
#endif
 
#define OnItemCreateInWorld pot_OnItemCreateInWorld
#if defined pot_OnItemCreateInWorld
	forward pot_OnItemCreateInWorld(itemid);
#endif

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(withitemid) == item_PlantPot)
	{
		if(_pot_UseItemWithItem(playerid, itemid, withitemid))
			return 1;
	}

	#if defined pot_OnPlayerUseItemWithItem
		return pot_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
 
#define OnPlayerUseItemWithItem pot_OnPlayerUseItemWithItem
#if defined pot_OnPlayerUseItemWithItem
	forward pot_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif

public OnPlayerPickUpItem(playerid, itemid)
{
	if(_pot_PickUp(playerid, itemid))
		return 1;

	#if defined pot_OnPlayerPickUpItem
		return pot_OnPlayerPickUpItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
 
#define OnPlayerPickUpItem pot_OnPlayerPickUpItem
#if defined pot_OnPlayerPickUpItem
	forward pot_OnPlayerPickUpItem(playerid, itemid);
#endif
new lastitem;
public OnPlayerDroppedItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_PlantPot)
		_pot_UpdateModel(itemid);
	lastitem = itemid;
	#if defined pot_OnPlayerDroppedItem
		return pot_OnPlayerDroppedItem(playerid, itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDroppedItem
	#undef OnPlayerDroppedItem
#else
	#define _ALS_OnPlayerDroppedItem
#endif
 
#define OnPlayerDroppedItem pot_OnPlayerDroppedItem
#if defined pot_OnPlayerDroppedItem
	forward pot_OnPlayerDroppedItem(playerid, itemid);
#endif

public OnItemDestroy(itemid)
{
	if(GetItemType(itemid) == item_PlantPot)
		_pot_UpdateModel(itemid, false);

	#if defined pot_OnItemDestroy
		return pot_OnItemDestroy(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemDestroy
	#undef OnItemDestroy
#else
	#define _ALS_OnItemDestroy
#endif
 
#define OnItemDestroy pot_OnItemDestroy
#if defined pot_OnItemDestroy
	forward pot_OnItemDestroy(itemid);
#endif

CMD:potg(playerid, params[])
{
	new growth = strval(params);
	SetItemArrayDataAtCell(lastitem, growth, E_PLANT_POT_GROWTH);
	_pot_Load(lastitem);
	return 1;
}

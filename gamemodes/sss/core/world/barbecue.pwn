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


#define MAX_BBQ				(256)

#define COOKER_STATE_NONE	(0)
#define COOKER_STATE_COOK	(1)


// Struct for item data
enum //E_BBQ_DATA
{
			bbq_state,
			bbq_fuel,
			bbq_grillItem1,
			bbq_grillItem2, 
			bbq_grillPart1,
			bbq_grillPart2,
Timer:		bbq_cookTimer
}


static
			bbq_PlaceFoodTick[MAX_PLAYERS],
			bbq_ItemBBQ[ITM_MAX] = {-1, ...};

static
			HANDLER = -1;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Barbecue'...");

	HANDLER = debug_register_handler("BBQ");
}


public OnItemCreate(itemid)
{
	d:1:HANDLER("[OnItemCreate] itemid: %d type: %d", itemid, _:GetItemType(itemid));
	if(GetItemType(itemid) == item_Barbecue)
	{
		d:1:HANDLER("[OnItemCreate] BBQ item %d created", itemid);

		new data[7];

		if(GetItemLootIndex(itemid) != -1)
		{
			data[bbq_fuel] = random(10);
		}

		data[bbq_state] = COOKER_STATE_NONE;
		data[bbq_grillItem1] = INVALID_ITEM_ID;
		data[bbq_grillItem2] = INVALID_ITEM_ID;
		data[bbq_grillPart1] = INVALID_ITEM_ID;
		data[bbq_grillPart2] = INVALID_ITEM_ID;
		data[bbq_cookTimer] = Timer:0;

		d:3:HANDLER("SET %d data[bbq_state]: %d", itemid, data[bbq_state]);
		d:3:HANDLER("SET %d data[bbq_fuel]: %d", itemid, data[bbq_fuel]);
		d:3:HANDLER("SET %d data[bbq_grillItem1]: %d", itemid, data[bbq_grillItem1]);
		d:3:HANDLER("SET %d data[bbq_grillItem2]: %d", itemid, data[bbq_grillItem2]);
		d:3:HANDLER("SET %d data[bbq_grillPart1]: %d", itemid, data[bbq_grillPart1]);
		d:3:HANDLER("SET %d data[bbq_grillPart2]: %d", itemid, data[bbq_grillPart2]);
		d:3:HANDLER("SET %d data[bbq_cookTimer]: %d", itemid, data[bbq_cookTimer]);

		SetItemArrayData(itemid, data, 7);
	}

	#if defined bbq_OnItemCreate
		return bbq_OnItemCreate(itemid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
 
#define OnItemCreate bbq_OnItemCreate
#if defined bbq_OnItemCreate
	forward bbq_OnItemCreate(itemid);
#endif


public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	d:1:HANDLER("[OnPlayerUseItemWithItem HOOK] %d %d %d", playerid, itemid, withitemid);

	if(GetItemType(withitemid) == item_Barbecue)
	{
		if(_UseBbqHandler(playerid, itemid, withitemid))
			return 1;
	}

	d:2:HANDLER("[OnPlayerUseItemWithItem END] %d %d %d", playerid, itemid, withitemid);

	#if defined bbq_OnPlayerUseItemWithItem
		return bbq_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
    #undef OnPlayerUseItemWithItem
#else
    #define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem bbq_OnPlayerUseItemWithItem
#if defined bbq_OnPlayerUseItemWithItem
	forward bbq_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif

_UseBbqHandler(playerid, itemid, withitemid)
{
	d:1:HANDLER("[_UseBbqHandler] %d %d %d", playerid, itemid, withitemid);

	new data[7];

	GetItemArrayData(withitemid, data);

	d:3:HANDLER("GET %d data[bbq_state]: %d", itemid, data[bbq_state]);
	d:3:HANDLER("GET %d data[bbq_fuel]: %d", itemid, data[bbq_fuel]);
	d:3:HANDLER("GET %d data[bbq_grillItem1]: %d", itemid, data[bbq_grillItem1]);
	d:3:HANDLER("GET %d data[bbq_grillItem2]: %d", itemid, data[bbq_grillItem2]);
	d:3:HANDLER("GET %d data[bbq_grillPart1]: %d", itemid, data[bbq_grillPart1]);
	d:3:HANDLER("GET %d data[bbq_grillPart2]: %d", itemid, data[bbq_grillPart2]);
	d:3:HANDLER("GET %d data[bbq_cookTimer]: %d", itemid, data[bbq_cookTimer]);

	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_GasCan)
	{
		d:2:HANDLER("[_UseBbqHandler] Item type is gas can", playerid, itemid, withitemid);
		if(GetItemExtraData(itemid) > 0)
		{
			SetItemArrayDataAtCell(withitemid, data[bbq_fuel] + 10, bbq_fuel);
			SetItemExtraData(itemid, GetItemExtraData(itemid) - 1);
			ShowActionText(playerid, "1L of petrol added~n~10 BBQ uses", 3000);
		}
		else
		{
			ShowActionText(playerid, "Petrol can empty", 3000);
		}

		return 1;
	}

	if(IsItemTypeFood(itemtype))
	{
		d:2:HANDLER("[_UseBbqHandler] Item type %d is food", _:itemtype);

		if(GetItemExtraData(itemid) != 0)
		{
			ShowActionText(playerid, "Food already cooked", 3000);
			return 1;
		}

		new
			Float:x,
			Float:y,
			Float:z,
			Float:r;

		GetItemPos(withitemid, x, y, z);
		GetItemRot(withitemid, r, r, r);

		if(data[bbq_grillItem1] <= 0)// == INVALID_ITEM_ID) temp fix
		{
			d:2:HANDLER("[_UseBbqHandler] Adding food to grill slot 1");

			CreateItemInWorld(itemid,
				x + (0.25 * floatsin(-r + 90.0, degrees)),
				y + (0.25 * floatcos(-r + 90.0, degrees)),
				z + 0.818,
				.rz = r);

			bbq_ItemBBQ[itemid] = withitemid;
			SetItemArrayDataAtCell(withitemid, itemid, bbq_grillItem1);
			bbq_PlaceFoodTick[playerid] = GetTickCount();
			ShowActionText(playerid, "Food added", 3000);

			return 1;
		}
		else if(data[bbq_grillItem2] <= 0)// == INVALID_ITEM_ID) temp fix
		{
			d:2:HANDLER("[_UseBbqHandler] Adding food to grill slot 2");

			CreateItemInWorld(itemid,
				x + (0.25 * floatsin(-r - 90.0, degrees)),
				y + (0.25 * floatcos(-r - 90.0, degrees)),
				z + 0.818,
				.rz = r);

			bbq_ItemBBQ[itemid] = withitemid;
			SetItemArrayDataAtCell(withitemid, itemid, bbq_grillItem2);
			bbq_PlaceFoodTick[playerid] = GetTickCount();
			ShowActionText(playerid, "Food added", 3000);

			return 1;
		}
	}

	if(itemtype == item_FireLighter)
	{
		d:2:HANDLER("[_UseBbqHandler] Item type is lighter");

		if(data[bbq_fuel] <= 0)
		{
			d:2:HANDLER("[_UseBbqHandler] Fuel empty");
			ShowActionText(playerid, "No fuel", 3000);
			return 1;
		}

		new Timer:timerid = defer bbq_FinishCooking(withitemid);

		SetItemArrayDataAtCell(withitemid, _:timerid, bbq_cookTimer);
		SetItemArrayDataAtCell(withitemid, COOKER_STATE_COOK, bbq_state);

		_LightBBQ(withitemid);

		ShowActionText(playerid, "BBQ Lit~n~Cook time: 30 seconds", 3000);

		return 1;
	}

	return 0;
}

_LightBBQ(itemid)
{
	d:1:HANDLER("[_LightBBQ] Lighting BBQ item %d", itemid);

	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, r, r, r);

	SetItemArrayDataAtCell(itemid, CreateDynamicObject(18701,
		x + (0.25 * floatsin(-r + 90.0, degrees)),
		y + (0.25 * floatcos(-r + 90.0, degrees)),
		z - 0.6,
		0.0, 0.0, r), bbq_grillPart1);

	SetItemArrayDataAtCell(itemid, CreateDynamicObject(18701,
		x + (0.25 * floatsin(-r + 270.0, degrees)),
		y + (0.25 * floatcos(-r + 270.0, degrees)),
		z - 0.6,
		0.0, 0.0, r), bbq_grillPart2);

	return 1;
}

timer bbq_FinishCooking[30000](itemid)
{
	d:1:HANDLER("[bbq_FinishCooking] itemid: %d", itemid);

	new data[7];

	GetItemArrayData(itemid, data);

	DestroyDynamicObject(data[bbq_grillPart1]);
	DestroyDynamicObject(data[bbq_grillPart2]);

	SetItemExtraData(data[bbq_grillItem1], 1);
	SetItemExtraData(data[bbq_grillItem2], 1);

	SetItemArrayDataAtCell(itemid, data[bbq_fuel] - 1, bbq_fuel);
	SetItemArrayDataAtCell(itemid, COOKER_STATE_NONE, bbq_state);
}


public OnPlayerPickUpItem(playerid, itemid)
{
	d:1:HANDLER("[OnPlayerPickUpItem] playerid: %d itemid: %d", playerid, itemid);
	if(GetItemType(itemid) == item_Barbecue)
	{
		d:1:HANDLER("[OnPlayerPickUpItem] Item type is BBQ", playerid, itemid);
		if(GetTickCountDifference(GetTickCount(), bbq_PlaceFoodTick[playerid]) < 1000)
			return 1;

		new data[7];

		GetItemArrayData(itemid, data);

		d:3:HANDLER("GET %d data[bbq_state]: %d", itemid, data[bbq_state]);
		d:3:HANDLER("GET %d data[bbq_fuel]: %d", itemid, data[bbq_fuel]);
		d:3:HANDLER("GET %d data[bbq_grillItem1]: %d", itemid, data[bbq_grillItem1]);
		d:3:HANDLER("GET %d data[bbq_grillItem2]: %d", itemid, data[bbq_grillItem2]);
		d:3:HANDLER("GET %d data[bbq_grillPart1]: %d", itemid, data[bbq_grillPart1]);
		d:3:HANDLER("GET %d data[bbq_grillPart2]: %d", itemid, data[bbq_grillPart2]);
		d:3:HANDLER("GET %d data[bbq_cookTimer]: %d", itemid, data[bbq_cookTimer]);

		if(data[bbq_state] != COOKER_STATE_NONE)
			return 1;

		if(IsValidItem(data[bbq_grillItem1]) && data[bbq_grillItem1] > 0) // temp fix
		{
			d:2:HANDLER("[OnPlayerPickUpItem] BBQ has valid item in slot 1 (%d)", data[bbq_grillItem1]);
			GiveWorldItemToPlayer(playerid, data[bbq_grillItem1], 1);
			SetItemArrayDataAtCell(itemid, INVALID_ITEM_ID, bbq_grillItem1);
			return 1;
		}

		if(IsValidItem(data[bbq_grillItem2]) && data[bbq_grillItem2] > 0) // temp fix
		{
			d:2:HANDLER("[OnPlayerPickUpItem] BBQ has valid item in slot 2 (%d)", data[bbq_grillItem2]);
			GiveWorldItemToPlayer(playerid, data[bbq_grillItem2], 1);
			SetItemArrayDataAtCell(itemid, INVALID_ITEM_ID, bbq_grillItem2);
			return 1;
		}
	}

	if(bbq_ItemBBQ[itemid] != -1)
	{
		d:1:HANDLER("[OnPlayerPickUpItem] Item %d is from BBQ item %d", itemid, bbq_ItemBBQ[itemid]);

		if(GetItemArrayDataAtCell(bbq_ItemBBQ[itemid], bbq_grillItem1) == itemid)
		{
			d:2:HANDLER("[OnPlayerPickUpItem] Item removed from bbq slot 1");
			SetItemArrayDataAtCell(bbq_ItemBBQ[itemid], INVALID_ITEM_ID, bbq_grillItem1);
		}

		else if(GetItemArrayDataAtCell(bbq_ItemBBQ[itemid], bbq_grillItem2) == itemid)
		{
			d:2:HANDLER("[OnPlayerPickUpItem] Item removed from bbq slot 2");
			SetItemArrayDataAtCell(bbq_ItemBBQ[itemid], INVALID_ITEM_ID, bbq_grillItem2);
		}
	}

	#if defined bbq_OnPlayerPickUpItem
		return bbq_OnPlayerPickUpItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem bbq_OnPlayerPickUpItem
#if defined bbq_OnPlayerPickUpItem
	forward bbq_OnPlayerPickUpItem(playerid, itemid);
#endif

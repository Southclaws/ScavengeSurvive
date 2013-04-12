#define MAX_BBQ				(256)

#define COOKER_STATE_NONE	(0)
#define COOKER_STATE_COOK	(1)


enum E_BBQ_DATA
{
			bbq_itemId,
			bbq_state,
Float:		bbq_fuel,
			bbq_grillItem[2],
			bbq_grillPart[2],
}


new
			bbq_Data[MAX_BBQ][E_BBQ_DATA],
Iterator:	bbq_Index<MAX_BBQ>,
Timer:		bbq_CookTimer[MAX_BBQ];


public OnItemCreate(itemid)
{
	if(GetItemType(itemid) == item_Barbecue)
	{
		new id = Iter_Free(bbq_Index);
		if(id == -1)
		{
			print("ERROR: BBQ Limit Reached");
			return 1;
		}
		bbq_Data[id][bbq_itemId] = itemid;
		bbq_Data[id][bbq_grillItem][0] = INVALID_ITEM_ID;
		bbq_Data[id][bbq_grillItem][1] = INVALID_ITEM_ID;
		bbq_Data[id][bbq_state] = COOKER_STATE_NONE;
		Iter_Add(bbq_Index, id);
	}

	return CallLocalFunction("bbq_OnItemCreate", "d", itemid);
}
#if defined _ALS_OnItemCreate
	#undef OnItemCreate
#else
	#define _ALS_OnItemCreate
#endif
#define OnItemCreate bbq_OnItemCreate
forward bbq_OnItemCreate(itemid);


public OnItemDestroy(itemid)
{
	if(GetItemType(itemid) == item_Barbecue)
	{
		new i;
		foreach(i : bbq_Index)
		{
			if(itemid == bbq_Data[i][bbq_itemId])
				break;
		}
		Iter_Add(bbq_Index, i);
	}

	return CallLocalFunction("bbq_OnItemDestroy", "d", itemid);
}
#if defined _ALS_OnItemDestroy
	#undef OnItemDestroy
#else
	#define _ALS_OnItemDestroy
#endif
#define OnItemDestroy bbq_OnItemDestroy
forward bbq_OnItemDestroy(itemid);


public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	new ItemType:withitemtype = GetItemType(withitemid);

	if(withitemtype == item_Barbecue || IsItemTypeFood(withitemtype))
	{
		foreach(new i : bbq_Index)
		{
			if(withitemid == bbq_Data[i][bbq_itemId] || withitemid == bbq_Data[i][bbq_grillItem][0] || withitemid == bbq_Data[i][bbq_grillItem][1])
			{
				new ItemType:itemtype = GetItemType(itemid);

				if(itemtype == item_GasCan)
				{
					if(GetItemExtraData(itemid) > 0)
					{
						bbq_Data[i][bbq_fuel] += 10;
						SetItemExtraData(itemid, GetItemExtraData(itemid) - 1);
						ShowMsgBox(playerid, "1 Liter of petrol added", 3000);
					}
					else
					{
						ShowMsgBox(playerid, "Petrol can empty", 3000);
					}
				}

				if(IsItemTypeFood(itemtype))
				{
					new
						Float:x,
						Float:y,
						Float:z,
						Float:r;

					GetItemPos(bbq_Data[i][bbq_itemId], x, y, z);
					GetItemRot(bbq_Data[i][bbq_itemId], r, r, r);

					if(bbq_Data[i][bbq_grillItem][0] == INVALID_ITEM_ID)
					{
						CreateItemInWorld(itemid,
							x + (0.25 * floatsin(-r + 90.0, degrees)),
							y + (0.25 * floatcos(-r + 90.0, degrees)),
							z + 0.818,
							.rz = r);

						bbq_Data[i][bbq_grillItem][0] = itemid;
						ShowMsgBox(playerid, "Food added", 3000);
					}
					else if(bbq_Data[i][bbq_grillItem][1] == INVALID_ITEM_ID)
					{
						CreateItemInWorld(itemid,
							x + (0.25 * floatsin(-r - 90.0, degrees)),
							y + (0.25 * floatcos(-r - 90.0, degrees)),
							z + 0.818,
							.rz = r);

						bbq_Data[i][bbq_grillItem][1] = itemid;
						ShowMsgBox(playerid, "Food added", 3000);
					}
					else
					{
						return 1;
					}
				}

				if(itemtype == item_FireLighter && bbq_Data[i][bbq_fuel] > 0)
				{
					new
						Float:x,
						Float:y,
						Float:z,
						Float:r;

					GetItemPos(bbq_Data[i][bbq_itemId], x, y, z);
					GetItemRot(bbq_Data[i][bbq_itemId], r, r, r);

					bbq_Data[i][bbq_grillPart][0] = CreateDynamicObject(18701,
						x + (0.25 * floatsin(-r + 90.0, degrees)),
						y + (0.25 * floatcos(-r + 90.0, degrees)),
						z - 0.668,
						0.0, 0.0, r);

					bbq_Data[i][bbq_grillPart][1] = CreateDynamicObject(18701,
						x + (0.25 * floatsin(-r + 270.0, degrees)),
						y + (0.25 * floatcos(-r + 270.0, degrees)),
						z - 0.668,
						0.0, 0.0, r);

					ShowMsgBox(playerid, "BBQ Lit", 3000);
					bbq_CookTimer[i] = defer bbq_FinishCooking(i);
					bbq_Data[i][bbq_state] = COOKER_STATE_COOK;
				}
			}
		}
	}

    return CallLocalFunction("bbq_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);

}
#if defined _ALS_OnPlayerUseItemWithItem
    #undef OnPlayerUseItemWithItem
#else
    #define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem bbq_OnPlayerUseItemWithItem
forward bbq_OnPlayerUseItemWithItem(playerid, itemid, withitemid);

timer bbq_FinishCooking[30000](bbqid)
{
	DestroyDynamicObject(bbq_Data[bbqid][bbq_grillPart][0]);
	DestroyDynamicObject(bbq_Data[bbqid][bbq_grillPart][1]);

	SetItemExtraData(bbq_Data[bbqid][bbq_grillItem][0], 1);
	SetItemExtraData(bbq_Data[bbqid][bbq_grillItem][1], 1);

	bbq_Data[bbqid][bbq_fuel] -= 1;

	bbq_Data[bbqid][bbq_state] = COOKER_STATE_NONE;
}


public OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Barbecue)
	{
		foreach(new i : bbq_Index)
		{
			if(itemid == bbq_Data[i][bbq_itemId] || itemid == bbq_Data[i][bbq_grillItem][0] || itemid == bbq_Data[i][bbq_grillItem][1])
			{
				if(bbq_Data[i][bbq_state] != COOKER_STATE_NONE)
					return 1;

				if(IsValidItem(bbq_Data[i][bbq_grillItem][0]))
				{
					GiveWorldItemToPlayer(playerid, bbq_Data[i][bbq_grillItem][0], 1);
					bbq_Data[i][bbq_grillItem][0] = INVALID_ITEM_ID;
					return 1;
				}
				if(IsValidItem(bbq_Data[i][bbq_grillItem][0]))
				{
					GiveWorldItemToPlayer(playerid, bbq_Data[i][bbq_grillItem][0], 1);
					bbq_Data[i][bbq_grillItem][1] = INVALID_ITEM_ID;
					return 1;
				}
			}
		}
	}
	else
	{
		foreach(new i : bbq_Index)
		{
			if(itemid == bbq_Data[i][bbq_grillItem][0])
				bbq_Data[i][bbq_grillItem][0] = INVALID_ITEM_ID;

			if(itemid == bbq_Data[i][bbq_grillItem][1])
				bbq_Data[i][bbq_grillItem][1] = INVALID_ITEM_ID;
		}
	}

	return CallLocalFunction("bbq_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem bbq_OnPlayerPickUpItem
forward bbq_OnPlayerPickUpItem(playerid, itemid);

public OnItemNameRender(itemid)
{
	if(IsItemTypeFood(GetItemType(itemid)))
	{
		if(GetItemExtraData(itemid) == 1)
			SetItemNameExtra(itemid, "Cooked");

		else
			SetItemNameExtra(itemid, "Uncooked");
	}

	return CallLocalFunction("bbq_OnItemNameRender", "d", itemid);
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender bbq_OnItemNameRender
forward bbq_OnItemNameRender(itemid);

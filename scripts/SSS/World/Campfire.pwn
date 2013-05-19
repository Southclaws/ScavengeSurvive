#define MAX_CAMPFIRE	(1024)


#define TEXTURE_1		2068,	"cj_ammo_net",		"CJ_cammonet"
#define TEXTURE_2		693,	"gta_tree_pine",	"sm_redwood_branch"


enum E_CAMPFIRE_DATA
{
			cmp_itemId,
			cmp_objMid1,
			cmp_objMid2,
			cmp_objMid3,
			cmp_objMid4,
			cmp_objStick1,
			cmp_objStick2,
			cmp_objStick3,
			cmp_objStick4,
			cmp_objStick5,
			cmp_objStick6,
			cmp_objStick7,
			cmp_objStick8,
Float:		cmp_posX,
Float:		cmp_posY,
Float:		cmp_posZ,
Float:		cmp_rotZ,
			cmp_objFlame,
			cmp_objSmoke,
			cmp_foodItem,
			cmp_fueled
}


static
			cmp_Data[MAX_CAMPFIRE][E_CAMPFIRE_DATA],
Iterator:	cmp_Index<MAX_CAMPFIRE>,
Timer:		cmp_CookTimer[MAX_CAMPFIRE];


stock CreateCampfire(Float:x, Float:y, Float:z, Float:rz)
{
	new id = Iter_Free(cmp_Index);

	cmp_Data[id][cmp_objMid1] = CreateDynamicObject(19475, x, y, z, 10.0, 90.0, rz + 18.0);
	cmp_Data[id][cmp_objMid2] = CreateDynamicObject(19475, x, y, z, -10.0, 90.0, rz + 36.0);
	cmp_Data[id][cmp_objMid3] = CreateDynamicObject(19475, x, y, z, 0.0, 100.0, rz + 54.0);
	cmp_Data[id][cmp_objMid4] = CreateDynamicObject(19475, x, y, z, 0.0, 80.0, rz + 72.0);


	cmp_Data[id][cmp_objStick1] = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz, degrees)),
		y + (0.1 * floatcos(-rz, degrees)),
		z + 0.01,
		10.0, 80.0, rz + 45.0);

	cmp_Data[id][cmp_objStick2] = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz - 90.0, degrees)),
		y + (0.1 * floatcos(-rz - 90.0, degrees)),
		z + 0.01,
		10.0, 80.0, rz + 45.0 + 90.0);

	cmp_Data[id][cmp_objStick3] = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz - 180.0, degrees)),
		y + (0.1 * floatcos(-rz - 180.0, degrees)),
		z + 0.01,
		10.0, 80.0, rz + 45.0 + 180.0);

	cmp_Data[id][cmp_objStick4] = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz - 270.0, degrees)),
		y + (0.1 * floatcos(-rz - 270.0, degrees)),
		z + 0.01,
		10.0, 80.0, rz + 45.0 + 270.0);

	cmp_Data[id][cmp_objStick5] = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz, degrees)),
		y + (0.1 * floatcos(-rz, degrees)),
		z + 0.01,
		10.0, 80.0, rz + random(90));

	cmp_Data[id][cmp_objStick6] = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz - 90.0, degrees)),
		y + (0.1 * floatcos(-rz - 90.0, degrees)),
		z + 0.01,
		10.0, 80.0, rz + random(90) + 90.0);

	cmp_Data[id][cmp_objStick7] = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz - 180.0, degrees)),
		y + (0.1 * floatcos(-rz - 180.0, degrees)),
		z + 0.01,
		10.0, 80.0, rz + random(90) + 180.0);

	cmp_Data[id][cmp_objStick8] = CreateDynamicObject(19475,
		x + (0.1 * floatsin(-rz - 270.0, degrees)),
		y + (0.1 * floatcos(-rz - 270.0, degrees)),
		z + 0.01,
		10.0, 80.0, rz + random(90) + 270.0);

	SetDynamicObjectMaterial(cmp_Data[id][cmp_objMid1], 0, TEXTURE_1, 0);
	SetDynamicObjectMaterial(cmp_Data[id][cmp_objMid2], 0, TEXTURE_1, 0);
	SetDynamicObjectMaterial(cmp_Data[id][cmp_objMid3], 0, TEXTURE_1, 0);
	SetDynamicObjectMaterial(cmp_Data[id][cmp_objMid4], 0, TEXTURE_1, 0);

	SetDynamicObjectMaterial(cmp_Data[id][cmp_objStick1], 0, TEXTURE_2, 0);
	SetDynamicObjectMaterial(cmp_Data[id][cmp_objStick2], 0, TEXTURE_2, 0);
	SetDynamicObjectMaterial(cmp_Data[id][cmp_objStick3], 0, TEXTURE_2, 0);
	SetDynamicObjectMaterial(cmp_Data[id][cmp_objStick4], 0, TEXTURE_2, 0);

	SetDynamicObjectMaterial(cmp_Data[id][cmp_objStick5], 0, TEXTURE_2, 0);
	SetDynamicObjectMaterial(cmp_Data[id][cmp_objStick6], 0, TEXTURE_2, 0);
	SetDynamicObjectMaterial(cmp_Data[id][cmp_objStick7], 0, TEXTURE_2, 0);
	SetDynamicObjectMaterial(cmp_Data[id][cmp_objStick8], 0, TEXTURE_2, 0);

	cmp_Data[id][cmp_posX] = x;
	cmp_Data[id][cmp_posY] = y;
	cmp_Data[id][cmp_posZ] = z;
	cmp_Data[id][cmp_rotZ] = rz;

	cmp_Data[id][cmp_objFlame] = INVALID_OBJECT_ID;
	cmp_Data[id][cmp_foodItem] = INVALID_ITEM_ID;
	cmp_Data[id][cmp_itemId] = INVALID_ITEM_ID;

	Iter_Add(cmp_Index, id);

	return id;
}

stock DestroyCampfire(fireid)
{
	if(!Iter_Contains(cmp_Index, fireid))
		return 0;

	DestroyDynamicObject(cmp_Data[fireid][cmp_objMid1]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objMid2]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objMid3]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objMid4]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objStick1]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objStick2]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objStick3]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objStick4]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objStick5]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objStick6]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objStick7]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objStick8]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objFlame]);
	DestroyDynamicObject(cmp_Data[fireid][cmp_objSmoke]);

	cmp_Data[fireid][cmp_objMid1] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_objMid2] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_objMid3] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_objMid4] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_objStick1] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_objStick2] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_objStick3] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_objStick4] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_objStick5] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_objStick6] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_objStick7] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_objStick8] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_posX] = 0.0;
	cmp_Data[fireid][cmp_posY] = 0.0;
	cmp_Data[fireid][cmp_posZ] = 0.0;
	cmp_Data[fireid][cmp_rotZ] = 0.0;
	cmp_Data[fireid][cmp_objFlame] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_objSmoke] = INVALID_OBJECT_ID;
	cmp_Data[fireid][cmp_foodItem] = INVALID_ITEM_ID;
	cmp_Data[fireid][cmp_itemId] = INVALID_ITEM_ID;
	stop cmp_CookTimer[fireid];

	Iter_Remove(cmp_Index, fireid);

	return 1;
}

stock IsValidCampfire(fireid)
{
	if(!Iter_Contains(cmp_Index, fireid))
		return 0;

	return 1;
}

stock SetCampfireState(fireid, bool:toggle)
{
	if(!Iter_Contains(cmp_Index, fireid))
		return 0;

	if(toggle)
	{
		if(IsValidDynamicObject(cmp_Data[fireid][cmp_objFlame]))
			return -1;

		cmp_Data[fireid][cmp_objFlame] = CreateDynamicObject(18693,
			cmp_Data[fireid][cmp_posX], cmp_Data[fireid][cmp_posY], cmp_Data[fireid][cmp_posZ] - 1.5, 0.0, 0.0, cmp_Data[fireid][cmp_rotZ]);
	}
	else
	{
		if(!IsValidDynamicObject(cmp_Data[fireid][cmp_objFlame]))
			return -1;

		DestroyDynamicObject(cmp_Data[fireid][cmp_objFlame]);
		DestroyDynamicObject(cmp_Data[fireid][cmp_objSmoke]);
		cmp_Data[fireid][cmp_objFlame] = INVALID_OBJECT_ID;
		cmp_Data[fireid][cmp_objSmoke] = INVALID_OBJECT_ID;
		stop cmp_CookTimer[fireid];
	}

	return 1;
}

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(withitemid) == item_Campfire)
	{
		new fireid = GetItemExtraData(withitemid);

		if(IsValidCampfire(fireid))
		{
			if(!IsValidDynamicObject(cmp_Data[fireid][cmp_objFlame]))
			{
				new ItemType:itemtype = GetItemType(itemid);

				if(itemtype == item_GasCan)
				{
					if(cmp_Data[fireid][cmp_fueled])
					{
						ShowActionText(playerid, "Campfire already fueled");
					}
					else
					{
						ShowActionText(playerid, "1L of petrol added");
						cmp_Data[fireid][cmp_fueled] = 1;
					}
				}
				else if(itemtype == item_FireLighter)
				{
					if(gWeatherID == 8 || gWeatherID == 16)
					{
						if(random(100) < 40)
						{
							if(cmp_Data[fireid][cmp_fueled])
							{
								SetCampfireState(fireid, true);
								cmp_Data[fireid][cmp_fueled] = 0;
								defer CampfireBurnOut(fireid, 120000);
							}
							else
							{
								if(random(1000) < 5)
								{
									SetCampfireState(fireid, true);
									defer CampfireBurnOut(fireid, 120000);
								}
							}
						}
					}
					else
					{
						if(cmp_Data[fireid][cmp_fueled])
						{
							SetCampfireState(fireid, true);
							cmp_Data[fireid][cmp_fueled] = 0;
							defer CampfireBurnOut(fireid, 600000);
						}
						else
						{
							if(random(1000) < 5)
							{
								SetCampfireState(fireid, true);
								defer CampfireBurnOut(fireid, 600000);
							}
						}
					}
				}
			}
			else
			{
				if(IsItemTypeFood(GetItemType(itemid)))
				{
					if(!IsValidItem(cmp_Data[fireid][cmp_foodItem]))
					{
						new
							Float:x,
							Float:y,
							Float:z,
							Float:r;

						GetItemPos(withitemid, x, y, z);
						GetItemRot(withitemid, r, r, r);

						CreateItemInWorld(itemid, x, y, z + 0.3, .rz = r);

						cmp_Data[fireid][cmp_foodItem] = itemid;
						cmp_CookTimer[fireid] = defer cmp_FinishCooking(fireid);
						ShowActionText(playerid, "Food added~n~1 minute cook time", 3000);
					}
				}
			}
		}
	}

	return CallLocalFunction("cmp_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem cmp_OnPlayerUseItemWithItem
forward cmp_OnPlayerUseItemWithItem(playerid, itemid, withitemid);

timer CampfireBurnOut[time](fireid, time)
{
	#pragma unused time
	DestroyCampfire(fireid);
}

timer cmp_FinishCooking[60000](fireid)
{
	cmp_Data[fireid][cmp_objSmoke] = CreateDynamicObject(18726, cmp_Data[fireid][cmp_posX], cmp_Data[fireid][cmp_posY], cmp_Data[fireid][cmp_posZ] - 1.0, 0.0, 0.0, 0.0);
	defer cmp_DestroySmoke(fireid);

	SetItemExtraData(cmp_Data[fireid][cmp_foodItem], 1);
}

timer cmp_DestroySmoke[1000](fireid)
{
	DestroyDynamicObject(cmp_Data[fireid][cmp_objSmoke]);
}

public OnPlayerPickedUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Campfire)
	{
		new fireid = GetItemExtraData(itemid);

		if(IsValidCampfire(fireid))
		{
			if(IsValidItem(cmp_Data[fireid][cmp_foodItem]))
			{
				GiveWorldItemToPlayer(playerid, cmp_Data[fireid][cmp_foodItem]);
				cmp_Data[fireid][cmp_foodItem] = INVALID_ITEM_ID;
				return 1;
			}
		}
	}
	else
	{
		foreach(new i : cmp_Index)
		{
			if(itemid == cmp_Data[i][cmp_foodItem])
			{
				DestroyDynamicObject(cmp_Data[i][cmp_objSmoke]);
				cmp_Data[i][cmp_foodItem] = INVALID_ITEM_ID;
				cmp_Data[i][cmp_objSmoke] = INVALID_OBJECT_ID;
				stop cmp_CookTimer[i];
				break;
			}
		}
	}

	return CallLocalFunction("cmp2_OnPlayerPickedUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickedUpItem
	#undef OnPlayerPickedUpItem
#else
	#define _ALS_OnPlayerPickedUpItem
#endif
#define OnPlayerPickedUpItem cmp2_OnPlayerPickedUpItem
forward cmp2_OnPlayerPickedUpItem(playerid, itemid);


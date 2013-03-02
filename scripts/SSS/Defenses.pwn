#define MAX_DEFENSE_ITEM (10)


enum E_DEFENSE_DATA
{
ItemType:	def_itemtype,
Float:		def_placeRotX,
Float:		def_placeRotY,
Float:		def_placeRotZ,
Float:		def_placeOffsetZ
}


static
			def_Data[MAX_DEFENSE_ITEM][E_DEFENSE_DATA],
Iterator:	def_Index<MAX_DEFENSE_ITEM>,
			def_ItemTypeBounds[2] = {65535, 0};


stock DefineDefenseItem(ItemType:itemtype, Float:rx, Float:ry, Float:rz, Float:zoffset)
{
	new id = Iter_Free(def_Index);

	def_Data[id][def_itemtype] = itemtype;
	def_Data[id][def_placeRotX] = rx;
	def_Data[id][def_placeRotY] = ry;
	def_Data[id][def_placeRotZ] = rz;
	def_Data[id][def_placeOffsetZ] = zoffset;

	if(_:itemtype < def_ItemTypeBounds[0])
		def_ItemTypeBounds[0] = _:itemtype;

	if(_:itemtype > def_ItemTypeBounds[1])
		def_ItemTypeBounds[1] = _:itemtype;

	Iter_Add(def_Index, id);

	return id;
}


public OnPlayerPickedUpItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeBounds[0] <= _:itemtype <= def_ItemTypeBounds[1])
	{
		foreach(new i : def_Index)
		{
			if(itemtype == def_Data[i][def_itemtype])
			{
				ShowHelpTip(playerid, "Use a tool with this while it's on the floor to construct a permanent defense.", 10000);
			}
		}
	}

	return CallLocalFunction("def_OnPlayerPickedUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickedUpItem
	#undef OnPlayerPickedUpItem
#else
	#define _ALS_OnPlayerPickedUpItem
#endif
#define OnPlayerPickedUpItem def_OnPlayerPickedUpItem
forward def_OnPlayerPickedUpItem(playerid, itemid);


public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Hammer)
	{
		new ItemType:withitemtype = GetItemType(withitemid);

		if(def_ItemTypeBounds[0] <= _:withitemtype <= def_ItemTypeBounds[1])
		{
			foreach(new i : def_Index)
			{
				if(withitemtype == def_Data[i][def_itemtype])
				{
					new
						model,
						Float:x,
						Float:y,
						Float:z,
						Float:angle;

					model = GetItemTypeModel(withitemtype);
					GetItemPos(withitemid, x, y, z);
					GetItemRot(withitemid, angle, angle, angle);

					CreateDynamicObject(model, x, y, z + def_Data[i][def_placeOffsetZ],
						def_Data[i][def_placeRotX], def_Data[i][def_placeRotY], def_Data[i][def_placeRotZ] + angle);

					DestroyItem(withitemid);
				}
			}
		}
	}

	return CallLocalFunction("def_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem def_OnPlayerUseItemWithItem
forward def_OnPlayerUseItemWithItem(playerid, itemid, withitemid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
	}
}

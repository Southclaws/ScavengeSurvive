public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_GasCan && GetItemType(withitemid) == item_MolotovEmpty)
	{
		if(GetItemExtraData(itemid) > 0)
		{
			new
				Float:x,
				Float:y,
				Float:z,
				Float:rz;

			GetItemPos(withitemid, x, y, z);
			GetItemRot(withitemid, rz, rz, rz);

			DestroyItem(withitemid);
			SetItemExtraData(CreateItem(ItemType:18, x, y, z, .rz = rz, .zoffset = FLOOR_OFFSET), 1);

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
			ShowMsgBox(playerid, "Fuel poured in bottle", 3000);
			SetItemExtraData(itemid, GetItemExtraData(itemid) - 1);
		}
		else
		{
			ShowMsgBox(playerid, "Petrol Can Empty", 3000);
		}
	}
	return CallLocalFunction("mol_OnPlayerUseItemWithItem", "ddd", playerid, itemid, withitemid);
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem mol_OnPlayerUseItemWithItem
forward mol_OnPlayerUseItemWithItem(playerid, itemid, withitemid);

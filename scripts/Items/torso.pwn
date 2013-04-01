public OnPlayerUseWeaponWithItem(playerid, weapon, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(weapon == 4 && itemtype == item_Torso)
	{
		if(GetItemExtraData(itemid) != -1)
		{
			new
				Float:x,
				Float:y,
				Float:z,
				Float:r;

			GetItemPos(itemid, x, y, z);
			GetItemRot(itemid, r, r, r);

			CreateItem(item_Meat,
				x + (0.5 * floatsin(-r + 90.0, degrees)),
				y + (0.5 * floatcos(-r + 90.0, degrees)),
				z, .rz = r);

			CreateItem(item_Meat,
				x + (0.5 * floatsin(-r + 270.0, degrees)),
				y + (0.5 * floatcos(-r + 270.0, degrees)),
				z, .rz = r);

			SetItemExtraData(itemid, -1);
		}
	}
	return CallLocalFunction("tor_OnPlayerUseWeaponWithItem", "ddd", playerid, weapon, itemid);
}
#if defined _ALS_OnPlayerUseWeaponWithItem
	#undef OnPlayerUseWeaponWithItem
#else
	#define _ALS_OnPlayerUseWeaponWithItem
#endif
#define OnPlayerUseWeaponWithItem tor_OnPlayerUseWeaponWithItem
forward tor_OnPlayerUseWeaponWithItem(playerid, weapon, itemid);

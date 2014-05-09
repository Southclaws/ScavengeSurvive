stock PlayerDamagePlayer_Firearm(playerid, targetid, itemid)
{
	new
		ItemType:itemtype,
		ammoitem,
		Float:bleedrate,
		Float:muzzvelocity,
		Float:distance;

	itemtype = GetItemType(itemid);
	ammoitem = GetItemWeaponItemAmmoItem(itemid);
	bleedrate = GetCalibreBleedRate(GetItemTypeWeaponCalibre(itemtype));
	muzzvelocity = GetItemTypeWeaponMuzzVelocity(itemtype);
	distance = GetDistanceBetweenPlayers(playerid, targetid);

	// do math, bleed rate alters depending on distance and muzzvelocity

	// SetPlayerBleedRate(playerid, bleedrate);

	return 1;
}

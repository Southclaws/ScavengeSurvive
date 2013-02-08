#include <YSI\y_hooks>


#define MAX_ITEM_WEP (32)


enum E_ITEMDAMAGE_DATA
{
bool:		itd_used,
ItemType:	itd_itemtype,
Float:		itd_damage,
			itd_animLib[32],
			itd_animName[32]
}


new
	itd_Data[MAX_ITEM_WEP][E_ITEMDAMAGE_DATA],
	itd_Total;


DefineItemDamage(ItemType:itemtype, Float:damage, animlib[32], animname[32])
{
	new id;
	while(itd_Data[id][itd_used] && id < MAX_ITEM_WEP)id++;

	if(id == MAX_ITEM_WEP)
		return -1;

	itd_Data[id][itd_used] = true;
	itd_Data[id][itd_itemtype] = itemtype;
	itd_Data[id][itd_damage] = damage;
	itd_Data[id][itd_animLib] = animlib;
	itd_Data[id][itd_animName] = animname;

	itd_Total = id;

	return id;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_FIRE)
	{
		new itemid = GetPlayerItem(playerid);

		if(!IsValidItem(itemid))
			return 0;

		for(new i; i < itd_Total; i++)
		{
			if(GetItemType(itemid) == itd_Data[i][itd_itemtype])
				AttackWithItemWeapon(playerid, i);
		}
	}
	return 1;
}

AttackWithItemWeapon(playerid, itemweapon)
{
	ApplyAnimation(playerid, itd_Data[itemweapon][itd_animLib], itd_Data[itemweapon][itd_animName], 4.1, 0, 1, 1, 0, 0, 1);

	new
		Float:px,
		Float:py,
		Float:pz,
		Float:pa,
		Float:ix,
		Float:iy,
		Float:iz,
		Float:angle;

	GetPlayerPos(playerid, px, py, pz);

	foreach(new i : Player)
	{
		if(playerid == i)
			continue;

		GetPlayerPos(i, ix, iy, iz);
		if(Distance(px, py, pz, ix, iy, iz) < 2.0)
		{
			GetPlayerFacingAngle(playerid, pa);
			angle = absoluteangle(pa - GetAngleToPoint(px, py, ix, iy));

			printf("Angle: %f", angle);

			if(angle > 315.0 || angle < 45.0)
			{
				ApplyAnimation(i, "PED", "KO_spin_R", 4.1, 0, 1, 1, 1, 0, 1);
				internal_HitPlayer(playerid, i, itemweapon);
			}
		}
	}
}
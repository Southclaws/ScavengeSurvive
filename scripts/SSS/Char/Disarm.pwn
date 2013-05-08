#include <YSI\y_hooks>


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerWeapon(playerid) != 0 || IsValidItem(GetPlayerItem(playerid)))
		return 1;

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || bPlayerGameSettings[playerid] & AdminDuty || bPlayerGameSettings[playerid] & KnockedOut || GetPlayerAnimationIndex(playerid) == 1381)
		return 1;

	if(newkeys & 16)
	{
		foreach(new i : Player)
		{
			if(IsPlayerInPlayerArea(playerid, i))
			{
				if(bPlayerGameSettings[i] & KnockedOut || GetPlayerAnimationIndex(i) == 1381)
				{
					DisarmPlayer(playerid, i);
				}
			}
		}
	}

	return 1;
}

DisarmPlayer(playerid, i)
{
	if(GetPlayerWeapon(playerid) != 0 || IsValidItem(GetPlayerItem(playerid)))
		return 0;

	new
		weaponid = GetPlayerCurrentWeapon(i),
		itemid;

	if(weaponid> 0)
	{
		new
			ammo = GetPlayerAmmo(i);

		RemovePlayerWeapon(i);
		SetPlayerWeapon(playerid, weaponid, ammo);

		return 1;
	}
	else
	{
		itemid = GetPlayerItem(i);

		if(IsValidItem(itemid))
		{
			RemoveCurrentItem(i);
			GiveWorldItemToPlayer(playerid, itemid);

			return 1;
		}

		itemid = GetPlayerHolsterItem(i);

		if(IsValidItem(itemid))
		{
			RemovePlayerHolsterItem(i);
			CreateItemInWorld(itemid);
			GiveWorldItemToPlayer(playerid, itemid);
			ConvertPlayerItemToWeapon(playerid);

			return 1;
		}
	}

	return 0;
}

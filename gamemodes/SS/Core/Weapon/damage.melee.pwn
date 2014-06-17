#include <YSI\y_hooks>


new
			anm_AttackTick[MAX_PLAYERS],
			anm_CurrentAnim[MAX_PLAYERS];


forward Float:OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, kochance);


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_FIRE)
	{
		_HandleCustomMelee(playerid, GetItemType(GetPlayerItem(playerid)));
	}

	return 1;
}

_HandleCustomMelee(playerid, ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(IsPlayerInAnyVehicle(playerid))
		return 0;

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
		return 0;

	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(IsPlayerKnockedOut(playerid))
		return 0;

	if(GetPlayerAnimationIndex(playerid) == 1381)
		return 0;

	if(GetTickCountDifference(GetTickCount(), anm_AttackTick[playerid]) < 800)
		return 0;

	new
		animset = GetItemTypeWeaponAnimSet(itemtype),
		lib[32],
		anim[32];

	if(animset == -1)
		return 0;

	if(anm_CurrentAnim[playerid] >= GetAnimSetSize(animset) || GetTickCountDifference(GetTickCount(), anm_AttackTick[playerid]) > 1000)
		anm_CurrentAnim[playerid] = 0;

	GetAnimationName(GetAnimSetAnimationIdx(animset, anm_CurrentAnim[playerid]), lib, 32, anim, 32);
	ApplyAnimation(playerid, lib, anim, 4.1, 0, 1, 1, 0, 0, 1);

	anm_CurrentAnim[playerid]++;
	anm_AttackTick[playerid] = GetTickCount();

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

			if(angle > 315.0 || angle < 45.0)
			{
				GetPlayerFacingAngle(i, pa);
				angle = absoluteangle(pa - GetAngleToPoint(ix, iy, px, py));

				if(angle > 135.0 || angle < 225.0)
					ApplyAnimation(i, "PED", "DAM_stomach_frmBK", 4.1, 0, 1, 1, 0, 0, 1); // FROM BACK

				if(angle > 315.0 || angle < 45.0)
					ApplyAnimation(i, "PED", "DAM_stomach_frmFT", 4.1, 0, 1, 1, 0, 0, 1); // FROM FRONT

				if(angle > 45.0 || angle < 135.0)
					ApplyAnimation(i, "PED", "DAM_stomach_frmLT", 4.1, 0, 1, 1, 0, 0, 1); // FROM LEFT

				if(angle > 225.0 || angle < 315.0)
					ApplyAnimation(i, "PED", "DAM_stomach_frmRT", 4.1, 0, 1, 1, 0, 0, 1); // FROM RIGHT

				_DoMeleeDamage(playerid, i, GetItemTypeWeaponMuzzVelocity(itemtype), GetItemTypeWeaponMaxReserveMags(itemtype));
			}
		}
	}

	return 1;
}

hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	if(weaponid == 0)
		return _DoMeleeDamage(playerid, damagedid, 0.01, 10);

	return _HandleStandardMelee(playerid, damagedid);
}

_HandleStandardMelee(playerid, targetid)
{
	new
		itemid,
		ItemType:itemtype,
		weapontype,
		baseweapon;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);
	weapontype = GetItemTypeWeapon(itemtype);
	baseweapon = GetItemWeaponBaseWeapon(weapontype);

	if(!IsBaseWeaponMelee(baseweapon))
		return 0;

	return _DoMeleeDamage(playerid, targetid, GetItemTypeWeaponMuzzVelocity(itemtype), GetItemTypeWeaponMaxReserveMags(itemtype));
}

_DoMeleeDamage(playerid, targetid, Float:bleedrate, kochance)
{
	bleedrate += Float:CallLocalFunction("OnPlayerMeleePlayer", "ddfd", playerid, targetid, Float:bleedrate, kochance);

	PlayerInflictWound(playerid, targetid, E_WOUND_MELEE, bleedrate, NO_CALIBRE);
	ShowHitMarker(playerid, 0);

	if(random(100) < kochance)
	{
		new Float:hp = GetPlayerHP(playerid);

		KnockOutPlayer(targetid, GetPlayerItemWeaponKOTime(playerid) + floatround(500 * (50.0 - hp) + frandom(200 * (50.0 - hp))));
	}

	return 1;
}

#include <YSI\y_hooks>


#define MAX_ANIMSET			(8)
#define MAX_ANIMS_PER_SET	(4)
#define MAX_MELEE_ITEM		(8)


enum E_ANIMSET_DATA
{
bool:		anm_used,
			anm_anims
}

enum E_ANIM_DATA
{
			anm_attackIdx,
			anm_hitIdx,
Float:		anm_damage
}

enum E_MELEE_ITEM_DATA
{
ItemType:	anm_itemType,
			anm_animSet
}

new
			anm_Data[MAX_ANIMSET][E_ANIMSET_DATA],
			anm_Anims[MAX_ANIMSET][MAX_ANIMS_PER_SET][E_ANIM_DATA],
			anm_MeleeItems[MAX_MELEE_ITEM][E_MELEE_ITEM_DATA],
			anm_TotalMeleeItems;
new
			anm_AttackTick[MAX_PLAYERS],
			anm_CurrentAnim[MAX_PLAYERS];


DefineAnimSet()
{
	new id;

	while(anm_Data[id][anm_used] && id < MAX_ANIMSET)
		id++;

	if(id == MAX_ANIMSET)
		return -1;

	anm_Data[id][anm_used] = true;
	anm_Data[id][anm_anims] = 0;

	return id;
}

AddAnimToSet(animset, attackidx, hitidx, Float:damage)
{
	if(!anm_Data[animset][anm_used])
		return -1;

	anm_Anims[animset][anm_Data[animset][anm_anims]][anm_attackIdx] = attackidx;
	anm_Anims[animset][anm_Data[animset][anm_anims]][anm_hitIdx] = hitidx;
	anm_Anims[animset][anm_Data[animset][anm_anims]][anm_damage] = damage;

	return anm_Data[animset][anm_anims]++;
}

SetItemAnimSet(ItemType:itemtype, animset)
{
	if(anm_TotalMeleeItems == MAX_MELEE_ITEM)
		return 0;

	anm_MeleeItems[anm_TotalMeleeItems][anm_itemType] = itemtype;
	anm_MeleeItems[anm_TotalMeleeItems][anm_animSet] = animset;

	anm_TotalMeleeItems++;

	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_FIRE)
	{
		if(tickcount() - anm_AttackTick[playerid] < 800)
			return 1;

		new itemid = GetPlayerItem(playerid);

		if(!IsValidItem(itemid))
			return 0;

		for(new i; i < anm_TotalMeleeItems; i++)
		{
			if(GetItemType(itemid) == anm_MeleeItems[i][anm_itemType])
			{
				new
					lib[32],
					anim[32];

				if(anm_CurrentAnim[playerid] >= anm_Data[anm_MeleeItems[i][anm_animSet]][anm_anims] || tickcount() - anm_AttackTick[playerid] > 1000)
					anm_CurrentAnim[playerid] = 0;

				GetAnimationName(anm_Anims[anm_MeleeItems[i][anm_animSet]][anm_CurrentAnim[playerid]][anm_attackIdx], lib, 32, anim, 32);
				ApplyAnimation(playerid, lib, anim, 4.1, 0, 1, 1, 0, 0, 1);

				anm_CurrentAnim[playerid]++;
				anm_AttackTick[playerid] = tickcount();

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

				foreach(new j : Player)
				{
					if(playerid == j)
						continue;

					GetPlayerPos(j, ix, iy, iz);
					if(Distance(px, py, pz, ix, iy, iz) < 2.0)
					{
						GetPlayerFacingAngle(playerid, pa);
						angle = absoluteangle(pa - GetAngleToPoint(px, py, ix, iy));

						if(angle > 315.0 || angle < 45.0)
						{
							GetAnimationName(anm_Anims[anm_MeleeItems[i][anm_animSet]][anm_CurrentAnim[playerid]][anm_hitIdx], lib, 32, anim, 32);
							ApplyAnimation(j, lib, anim, 4.1, 0, 1, 1, 0, 0, 1);
							DamagePlayer(playerid, j, anm_MeleeItems[i][anm_animSet], 1);
						}
					}
				}
			}
		}
	}
	return 1;
}

forward Float:GetMeleeDamage(weaponid, animation);
Float:GetMeleeDamage(weaponid, animation)
{
	return anm_Anims[weaponid][animation][anm_damage];
}

GetCurrentMeleeAnim(playerid)
{
	return anm_CurrentAnim[playerid];
}

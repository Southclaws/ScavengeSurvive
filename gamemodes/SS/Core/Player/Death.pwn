#include <YSI\y_hooks>


static
Float:	death_PosX[MAX_PLAYERS],
Float:	death_PosY[MAX_PLAYERS],
Float:	death_PosZ[MAX_PLAYERS],
Float:	death_RotZ[MAX_PLAYERS];


public OnPlayerDeath(playerid, killerid, reason)
{
	if(killerid == INVALID_PLAYER_ID)
	{
		if(GetTickCountDifference(GetTickCount(), GetPlayerTookDamageTick(playerid)) < 1000)
		{
			killerid = GetLastHitById(playerid);

			if(!IsPlayerConnected(killerid))
				killerid = INVALID_PLAYER_ID;
		}
	}

	OnDeath(playerid, killerid, reason);

	return 1;
}

OnDeath(playerid, killerid, reason)
{
	if(!IsPlayerAlive(playerid) || IsPlayerOnAdminDuty(playerid))
	{
		return 0;
	}

	new deathreason[256];

	SetPlayerBitFlag(playerid, Dying, true);
	SetPlayerBitFlag(playerid, Spawned, false);
	SetPlayerBitFlag(playerid, Alive, false);

	GetPlayerPos(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid]);
	GetPlayerFacingAngle(playerid, death_RotZ[playerid]);

	if(IsPlayerInAnyVehicle(playerid))
		death_PosZ[playerid] += 0.1;

	HideWatch(playerid);
	DropItems(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid]);
	RemovePlayerWeapon(playerid);
	SpawnPlayer(playerid);
	ToggleArmour(playerid, false);

	if(IsPlayerConnected(killerid))
	{
		logf("[KILL] %p killed %p with %d", killerid, playerid, reason);
		printf("[KILL] %p killed %p with %d", killerid, playerid, reason);

		SetLastKilledBy(playerid, gPlayerName[killerid]);
		SetLastKilledById(playerid, killerid);

		//MsgAdminsF(1, YELLOW, " >  [KILL]: %p killed %p with %d", killerid, playerid, reason);

		switch(reason)
		{
			case 0..3, 5..7, 10..15:
				deathreason = "They were beaten to death.";

			case 4:
				deathreason = "They suffered small lacerations on the torso, possibly from a knife.";

			case 8:
				deathreason = "Large lacerations cover the torso and head, looks like a finely sharpened sword.";

			case 9:
				deathreason = "There's bits everywhere, probably suffered a chainsaw to the torso.";

			case 16, 39, 35, 36, 255:
				deathreason = "They suffered massive concussion due to an explosion.";

			case 18, 37:
				deathreason = "The entire body is charred and burnt.";

			case 22..34, 38:
				deathreason = "They died of blood loss.";

			case 41, 42:
				deathreason = "They were sprayed and suffocated by a high pressure liquid.";

			case 44, 45:
				deathreason = "Somehow, they were killed by goggles.";

			case 43:
				deathreason = "Somehow, they were killed by a camera.";

			default:
				deathreason = "They died for an unknown reason.";

		}
	}
	else
	{
		logf("[DEATH] %p died because of %d", playerid, reason);
		printf("[DEATH] %p died because of %d", playerid, reason);

		SetLastKilledBy(playerid, "");
		SetLastKilledById(playerid, INVALID_PLAYER_ID);

		//MsgAdminsF(1, YELLOW, " >  [DEATH]: %p died by %d", playerid, reason);

		if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_AIR))
		{
			deathreason = "They died of air embolism (injecting oxygen into their bloodstream).";
			RemoveDrug(playerid, DRUG_TYPE_AIR);
		}
		else
		{
			switch(reason)
			{
				case 53:
					deathreason = "They drowned.";

				case 54:
					deathreason = "Most bones are broken, looks like they fell from a great height.";

				case 255:
					deathreason = "They suffered massive concussion due to an explosion.";

				default:
					deathreason = "They died for an unknown reason.";
			}
		}
	}

	CreateGravestone(playerid, deathreason, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid] - FLOOR_OFFSET, death_RotZ[playerid]);

	return 1;
}

DropItems(playerid, Float:x, Float:y, Float:z, Float:r)
{
	new
		interior = GetPlayerInterior(playerid),
		backpackitem = GetPlayerBagItem(playerid),
		itemid,
		clothes = GetPlayerClothes(playerid);

	if(IsValidItem(GetPlayerItem(playerid)))
	{
		itemid = CreateItemInWorld(GetPlayerItem(playerid),
			x + floatsin(345.0, degrees),
			y + floatcos(345.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);

		RemoveCurrentItem(playerid);
	}
	else if(GetPlayerWeapon(playerid) > 0 && GetPlayerTotalAmmo(playerid) > 0)
	{
		itemid = CreateItem(ItemType:GetPlayerWeapon(playerid),
			x + floatsin(345.0, degrees),
			y + floatcos(345.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);

		SetItemExtraData(itemid, GetPlayerTotalAmmo(playerid));
		RemovePlayerWeapon(playerid);
	}

	if(IsValidItem(GetPlayerHolsterItem(playerid)))
	{
		CreateItemInWorld(GetPlayerHolsterItem(playerid),
			x + floatsin(15.0, degrees),
			y + floatcos(15.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);

		RemovePlayerHolsterItem(playerid);
	}

	for(new i; i < INV_MAX_SLOTS; i++)
	{
		itemid = GetInventorySlotItem(playerid, 0);

		if(!IsValidItem(itemid))
			break;

		RemoveItemFromInventory(playerid, 0);
		CreateItemInWorld(itemid,
			x + floatsin(45.0 + (90.0 * float(i)), degrees),
			y + floatcos(45.0 + (90.0 * float(i)), degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);
	}

	if(IsValidItem(backpackitem))
	{
		RemovePlayerBag(playerid);

		CreateItemInWorld(backpackitem,
			x + floatsin(180.0, degrees),
			y + floatcos(180.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);

		SetItemRot(backpackitem, 0.0, 0.0, r, true);
	}

	if(clothes != skin_MainM && clothes != skin_MainF)
	{
		itemid = CreateItem(item_Clothes,
			x + floatsin(90.0, degrees),
			y + floatcos(90.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);

		SetItemExtraData(itemid, clothes);
	}

	if(IsValidItem(GetPlayerHat(playerid)))
	{
		CreateItem(GetItemTypeFromHat(GetPlayerHat(playerid)),
			x + floatsin(270.0, degrees),
			y + floatcos(270.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);

		RemovePlayerHat(playerid);
	}

	if(IsValidItem(GetPlayerMask(playerid)))
	{
		CreateItem(GetItemTypeFromMask(GetPlayerMask(playerid)),
			x + floatsin(280.0, degrees),
			y + floatcos(280.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);

		RemovePlayerMask(playerid);
	}

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
	{
		CreateItem(item_HandCuffs,
			x + floatsin(135.0, degrees),
			y + floatcos(135.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);
	}
}

hook OnPlayerSpawn(playerid)
{
	if(IsPlayerDead(playerid))
	{
		TogglePlayerSpectating(playerid, true);

		defer SetDeathCamera(playerid);

		SetPlayerCameraPos(playerid,
			death_PosX[playerid] - floatsin(-death_RotZ[playerid], degrees),
			death_PosY[playerid] - floatcos(-death_RotZ[playerid], degrees),
			death_PosZ[playerid]);

		SetPlayerCameraLookAt(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid]);

		TextDrawShowForPlayer(playerid, DeathText);
		TextDrawShowForPlayer(playerid, DeathButton);
		SelectTextDraw(playerid, 0xFFFFFF88);
		SetPlayerHP(playerid, 1.0);
	}
}

timer SetDeathCamera[50](playerid)
{
	InterpolateCameraPos(playerid,
		death_PosX[playerid] - floatsin(-death_RotZ[playerid], degrees),
		death_PosY[playerid] - floatcos(-death_RotZ[playerid], degrees),
		death_PosZ[playerid] + 1.0,
		death_PosX[playerid] - floatsin(-death_RotZ[playerid], degrees),
		death_PosY[playerid] - floatcos(-death_RotZ[playerid], degrees),
		death_PosZ[playerid] + 20.0,
		30000, CAMERA_MOVE);

	InterpolateCameraLookAt(playerid,
		death_PosX[playerid],
		death_PosY[playerid],
		death_PosZ[playerid],
		death_PosX[playerid],
		death_PosY[playerid],
		death_PosZ[playerid] + 1.0,
		30000, CAMERA_MOVE);
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == DeathButton)
	{
		SetPlayerBitFlag(playerid, Dying, false);
		TogglePlayerSpectating(playerid, false);
		CancelSelectTextDraw(playerid);
		TextDrawHideForPlayer(playerid, DeathText);
		TextDrawHideForPlayer(playerid, DeathButton);
	}

	return 1;
}


stock GetPlayerDeathPos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	x = death_PosX[playerid];
	y = death_PosY[playerid];
	z = death_PosZ[playerid];

	return 1;
}

stock GetPlayerDeathRot(playerid, &Float:r)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	r = death_RotZ;

	return 1;
}

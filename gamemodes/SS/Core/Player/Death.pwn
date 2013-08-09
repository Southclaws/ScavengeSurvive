public OnPlayerDeath(playerid, killerid, reason)
{
	if(!(gPlayerBitData[playerid] & Alive) || gPlayerBitData[playerid] & AdminDuty)
	{
		return 0;
	}

	new deathreason[256];

	t:gPlayerBitData[playerid]<Dying>;
	f:gPlayerBitData[playerid]<Spawned>;
	f:gPlayerBitData[playerid]<AdminDuty>;
	f:gPlayerBitData[playerid]<Alive>;

	GetPlayerPos(playerid, gPlayerData[playerid][ply_DeathPosX], gPlayerData[playerid][ply_DeathPosY], gPlayerData[playerid][ply_DeathPosZ]);
	GetPlayerFacingAngle(playerid, gPlayerData[playerid][ply_DeathRotZ]);

	if(IsPlayerInAnyVehicle(playerid))
		gPlayerData[playerid][ply_DeathPosZ] += 0.1;

	HideWatch(playerid);
	DropItems(playerid);
	RemovePlayerWeapon(playerid);
	SpawnPlayer(playerid);
	ToggleArmour(playerid, false);

	if(IsPlayerConnected(killerid))
	{
		gPlayerData[playerid][ply_LastKilledBy] = gPlayerName[killerid];

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
		gPlayerData[playerid][ply_LastKilledBy][0] = EOS;

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

	CreateGravestone(playerid, deathreason, gPlayerData[playerid][ply_DeathPosX], gPlayerData[playerid][ply_DeathPosY], gPlayerData[playerid][ply_DeathPosZ] - FLOOR_OFFSET, gPlayerData[playerid][ply_DeathRotZ]);

	return 1;
}

DropItems(playerid)
{
	new
		interior = GetPlayerInterior(playerid),
		backpackitem = GetPlayerBackpackItem(playerid),
		itemid,
		clothes = GetPlayerClothes(playerid);

	if(IsValidItem(GetPlayerItem(playerid)))
	{
		itemid = CreateItemInWorld(GetPlayerItem(playerid),
			gPlayerData[playerid][ply_DeathPosX] + floatsin(345.0, degrees),
			gPlayerData[playerid][ply_DeathPosY] + floatcos(345.0, degrees),
			gPlayerData[playerid][ply_DeathPosZ] - FLOOR_OFFSET,
			.rz = gPlayerData[playerid][ply_DeathRotZ],
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);

		RemoveCurrentItem(playerid);
	}
	else if(GetPlayerWeapon(playerid) > 0 && GetPlayerTotalAmmo(playerid) > 0)
	{
		itemid = CreateItem(ItemType:GetPlayerWeapon(playerid),
			gPlayerData[playerid][ply_DeathPosX] + floatsin(345.0, degrees),
			gPlayerData[playerid][ply_DeathPosY] + floatcos(345.0, degrees),
			gPlayerData[playerid][ply_DeathPosZ] - FLOOR_OFFSET,
			.rz = gPlayerData[playerid][ply_DeathRotZ],
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);

		SetItemExtraData(itemid, GetPlayerTotalAmmo(playerid));
	}

	if(IsValidItem(GetPlayerHolsterItem(playerid)))
	{
		CreateItemInWorld(GetPlayerHolsterItem(playerid),
			gPlayerData[playerid][ply_DeathPosX] + floatsin(15.0, degrees),
			gPlayerData[playerid][ply_DeathPosY] + floatcos(15.0, degrees),
			gPlayerData[playerid][ply_DeathPosZ] - FLOOR_OFFSET,
			.rz = gPlayerData[playerid][ply_DeathRotZ],
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
			gPlayerData[playerid][ply_DeathPosX] + floatsin(45.0 + (90.0 * float(i)), degrees),
			gPlayerData[playerid][ply_DeathPosY] + floatcos(45.0 + (90.0 * float(i)), degrees),
			gPlayerData[playerid][ply_DeathPosZ] - FLOOR_OFFSET,
			.rz = gPlayerData[playerid][ply_DeathRotZ],
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);
	}

	if(IsValidItem(backpackitem))
	{
		RemovePlayerBackpack(playerid);

		CreateItemInWorld(backpackitem,
			gPlayerData[playerid][ply_DeathPosX] + floatsin(180.0, degrees),
			gPlayerData[playerid][ply_DeathPosY] + floatcos(180.0, degrees),
			gPlayerData[playerid][ply_DeathPosZ] - FLOOR_OFFSET,
			.rz = gPlayerData[playerid][ply_DeathRotZ],
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);

		SetItemRot(backpackitem, 0.0, 0.0, gPlayerData[playerid][ply_DeathRotZ], true);
	}

	if(clothes != skin_MainM && clothes != skin_MainF)
	{
		itemid = CreateItem(item_Clothes,
			gPlayerData[playerid][ply_DeathPosX] + floatsin(90.0, degrees),
			gPlayerData[playerid][ply_DeathPosY] + floatcos(90.0, degrees),
			gPlayerData[playerid][ply_DeathPosZ] - FLOOR_OFFSET,
			.rz = gPlayerData[playerid][ply_DeathRotZ],
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);

		SetItemExtraData(itemid, clothes);
	}

	if(IsValidItem(GetPlayerHat(playerid)))
	{
		CreateItem(GetItemTypeFromHat(GetPlayerHat(playerid)),
			gPlayerData[playerid][ply_DeathPosX] + floatsin(270.0, degrees),
			gPlayerData[playerid][ply_DeathPosY] + floatcos(270.0, degrees),
			gPlayerData[playerid][ply_DeathPosZ] - FLOOR_OFFSET,
			.rz = gPlayerData[playerid][ply_DeathRotZ],
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);

		RemovePlayerHat(playerid);
	}

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
	{
		CreateItem(item_HandCuffs,
			gPlayerData[playerid][ply_DeathPosX] + floatsin(135.0, degrees),
			gPlayerData[playerid][ply_DeathPosY] + floatcos(135.0, degrees),
			gPlayerData[playerid][ply_DeathPosZ] - FLOOR_OFFSET,
			.rz = gPlayerData[playerid][ply_DeathRotZ],
			.zoffset = ITEM_BUTTON_OFFSET,
			.interior = interior);
	}
}

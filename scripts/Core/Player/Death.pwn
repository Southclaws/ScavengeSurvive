public OnPlayerDeath(playerid, killerid, reason)
{
	if(!(bPlayerGameSettings[playerid] & Alive) || bPlayerGameSettings[playerid] & AdminDuty)
	{
		return 0;
	}

	new deathreason[256];

	t:bPlayerGameSettings[playerid]<Dying>;
	f:bPlayerGameSettings[playerid]<Spawned>;
	f:bPlayerGameSettings[playerid]<AdminDuty>;
	f:bPlayerGameSettings[playerid]<Alive>;

	GetPlayerPos(playerid, gPlayerDeathPos[playerid][0], gPlayerDeathPos[playerid][1], gPlayerDeathPos[playerid][2]);
	GetPlayerFacingAngle(playerid, gPlayerDeathPos[playerid][3]);

	if(IsPlayerInAnyVehicle(playerid))
		gPlayerDeathPos[playerid][2] += 0.1;

	HideWatch(playerid);
	DropItems(playerid);
	RemovePlayerWeapon(playerid);
	SpawnPlayer(playerid);

	if(IsPlayerConnected(killerid))
	{
		gLastKilledBy[playerid] = gPlayerName[killerid];

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
		gLastKilledBy[playerid][0] = EOS;

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

	CreateGravestone(playerid, deathreason, gPlayerDeathPos[playerid][0], gPlayerDeathPos[playerid][1], gPlayerDeathPos[playerid][2] - FLOOR_OFFSET, gPlayerDeathPos[playerid][3]);

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
			gPlayerDeathPos[playerid][0] + floatsin(345.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(345.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET,
			.rz = gPlayerDeathPos[playerid][3],
			.zoffset = ITEM_BTN_OFFSET_Z,
			.interior = interior);

		RemoveCurrentItem(playerid);
	}
	else if(GetPlayerWeapon(playerid) > 0 && GetPlayerTotalAmmo(playerid) > 0)
	{
		itemid = CreateItem(ItemType:GetPlayerWeapon(playerid),
			gPlayerDeathPos[playerid][0] + floatsin(345.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(345.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET,
			.rz = gPlayerDeathPos[playerid][3],
			.zoffset = ITEM_BTN_OFFSET_Z,
			.interior = interior);

		SetItemExtraData(itemid, GetPlayerTotalAmmo(playerid));
	}

	if(IsValidItem(GetPlayerHolsterItem(playerid)))
	{
		CreateItemInWorld(GetPlayerHolsterItem(playerid),
			gPlayerDeathPos[playerid][0] + floatsin(15.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(15.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET,
			.rz = gPlayerDeathPos[playerid][3],
			.zoffset = ITEM_BTN_OFFSET_Z,
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
			gPlayerDeathPos[playerid][0] + floatsin(45.0 + (90.0 * float(i)), degrees),
			gPlayerDeathPos[playerid][1] + floatcos(45.0 + (90.0 * float(i)), degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET,
			.rz = gPlayerDeathPos[playerid][3],
			.zoffset = ITEM_BTN_OFFSET_Z,
			.interior = interior);
	}

	if(IsValidItem(backpackitem))
	{
		RemovePlayerBackpack(playerid);

		CreateItemInWorld(backpackitem,
			gPlayerDeathPos[playerid][0] + floatsin(180.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(180.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET,
			.rz = gPlayerDeathPos[playerid][3],
			.zoffset = ITEM_BTN_OFFSET_Z,
			.interior = interior);

		SetItemRot(backpackitem, 0.0, 0.0, gPlayerDeathPos[playerid][3], true);
	}

	if(clothes != skin_MainM && clothes != skin_MainF)
	{
		itemid = CreateItem(item_Clothes,
			gPlayerDeathPos[playerid][0] + floatsin(90.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(90.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET,
			.rz = gPlayerDeathPos[playerid][3],
			.zoffset = ITEM_BTN_OFFSET_Z,
			.interior = interior);

		SetItemExtraData(itemid, clothes);
	}

	if(IsValidItem(GetPlayerHat(playerid)))
	{
		CreateItem(GetItemTypeFromHat(GetPlayerHat(playerid)),
			gPlayerDeathPos[playerid][0] + floatsin(270.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(270.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET,
			.rz = gPlayerDeathPos[playerid][3],
			.zoffset = ITEM_BTN_OFFSET_Z,
			.interior = interior);

		RemovePlayerHat(playerid);
	}

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
	{
		CreateItem(item_HandCuffs,
			gPlayerDeathPos[playerid][0] + floatsin(135.0, degrees),
			gPlayerDeathPos[playerid][1] + floatcos(135.0, degrees),
			gPlayerDeathPos[playerid][2] - FLOOR_OFFSET,
			.rz = gPlayerDeathPos[playerid][3],
			.zoffset = ITEM_BTN_OFFSET_Z,
			.interior = interior);
	}
}

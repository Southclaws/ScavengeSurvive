CreateNewUserfile(playerid, password[])
{
	new
		file[MAX_PLAYER_FILE],
		tmpQuery[300];

	GetFile(gPlayerName[playerid], file);

	fclose(fopen(file, io_write));

	format(tmpQuery, 300,
		"INSERT INTO `Player` (`"#ROW_NAME"`, `"#ROW_PASS"`, `"#ROW_IPV4"`, `"#ROW_ALIVE"`, `"#ROW_SPAWN"`, `"#ROW_ISVIP"`) \
		VALUES('%s', '%s', '%d', '0', '0.0, 0.0, 0.0, 0.0', '%d')",
		gPlayerName[playerid], password, gPlayerData[playerid][ply_IP],
		(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0);

	db_free_result(db_query(gAccounts, tmpQuery));

	for(new idx; idx<gTotalAdmins; idx++)
	{
		if(!strcmp(gPlayerName[playerid], gAdminData[idx][admin_Name]) && !isnull(gPlayerName[playerid]))
		{
			gPlayerData[playerid][ply_Admin] = gAdminData[idx][admin_Level];
			break;
		}
	}

	if(gPlayerData[playerid][ply_Admin] > 0)
		MsgF(playerid, BLUE, " >  Your admin level: %d", gPlayerData[playerid][ply_Admin]);

	t:bPlayerGameSettings[playerid]<LoggedIn>;
	t:bPlayerGameSettings[playerid]<HasAccount>;
}

Login(playerid)
{
	new
		tmpQuery[256];

	format(tmpQuery, sizeof(tmpQuery), "UPDATE `Player` SET `"#ROW_IPV4"` = '%d' WHERE `"#ROW_NAME"` = '%s'", gPlayerData[playerid][ply_IP], gPlayerName[playerid]);
	db_free_result(db_query(gAccounts, tmpQuery));

	for(new idx; idx<gTotalAdmins; idx++)
	{

		if(!strcmp(gPlayerName[playerid], gAdminData[idx][admin_Name]))
		{
			gPlayerData[playerid][ply_Admin] = gAdminData[idx][admin_Level];
			break;
		}
	}

	if(gPlayerData[playerid][ply_Admin] > 0)
	{
		new
			reports = GetUnreadReports();

		MsgF(playerid, BLUE, " >  Your admin level: %d", gPlayerData[playerid][ply_Admin]);

		if(reports > 0)
			MsgF(playerid, YELLOW, " >  %d unread reports, type "#C_BLUE"/reports "#C_YELLOW"to view.", reports);
	}

	t:bPlayerGameSettings[playerid]<LoggedIn>;
	IncorrectPass[playerid]=0;

	stop gScreenFadeTimer[playerid];
	gScreenFadeTimer[playerid] = repeat FadeScreen(playerid);

	SetPlayerPos(playerid,
		gPlayerData[playerid][ply_posX],
		gPlayerData[playerid][ply_posY],
		gPlayerData[playerid][ply_posZ]);

	FreezePlayer(playerid, 3000);
}

CheckForExtraAccounts(playerid, name[])
{
	new
		numrows,
		query[128],
		tmpname[32],
		DBResult:dbresult,
		list[128],
		msglevel = 1;

	if(gPlayerData[playerid][ply_Admin] > 1)
		msglevel = gPlayerData[playerid][ply_Admin];

	format(query, 128,
		"SELECT * FROM `Player` WHERE `"#ROW_IPV4"` = '%d' AND `"#ROW_NAME"` != '%s'",
		gPlayerData[playerid][ply_IP], name);

	dbresult = db_query(gAccounts, query);

	numrows = db_num_rows(dbresult);

	if(numrows > 0)
	{
		for(new i; i < numrows && i < 5;i++)
		{
			db_get_field(dbresult, 0, tmpname, 128);

			for(new j; j < gTotalAdmins; j++)
			{
				if(!strcmp(tmpname, gAdminData[j][admin_Name]))
				{
					db_free_result(dbresult);
					return 0;
				}
			}

			if(i > 0)
				strcat(list, ", ");

			strcat(list, tmpname);
			db_next_row(dbresult);
		}
		MsgAdminsF(msglevel, YELLOW, " >  Aliases: "#C_BLUE"(%d)"#C_ORANGE" %s", numrows, list);
	}

	db_free_result(dbresult);

	return 1;
}

SavePlayerData(playerid, prints = false)
{
	if(bPlayerGameSettings[playerid] & AdminDuty)
		return 0;

	new
		tmpQuery[256];

	if(bPlayerGameSettings[playerid] & Alive)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		if(Distance(x, y, z, -907.5452, 272.7235, 1014.1449) < 50.0)
			return 0;

		if(x == 0.0 && y == 0.0 && z == 0.0)
			return 0;

		format(tmpQuery, sizeof(tmpQuery),
			"UPDATE `Player` SET \
			`"#ROW_ALIVE"` = '1', \
			`"#ROW_GEND"` = '%d', \
			`"#ROW_SPAWN"` = '%f %f %f %f', \
			`"#ROW_ISVIP"` = '%d' \
			WHERE `"#ROW_NAME"` = '%s'",
			(bPlayerGameSettings[playerid] & Gender) ? 1 : 0,
			x, y, z, a,
			(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0,
			gPlayerName[playerid]);

		SavePlayerInventory(playerid, prints);

		if(IsPlayerInAnyVehicle(playerid))
		{
			SavePlayerVehicle(gPlayerVehicleID[playerid], gPlayerName[playerid]);
		}
	}
	else
	{
		format(tmpQuery, sizeof(tmpQuery),
			"UPDATE `Player` SET \
			`"#ROW_ALIVE"` = '0', \
			`"#ROW_GEND"` = '0', \
			`"#ROW_SPAWN"` = '0.0 0.0 0.0 0.0', \
			`"#ROW_ISVIP"` = '%d' \
			WHERE `"#ROW_NAME"` = '%s'",
			(bPlayerGameSettings[playerid] & IsVip) ? 1 : 0,
			gPlayerName[playerid]);

		ClearPlayerInventoryFile(playerid);
	}

	db_free_result(db_query(gAccounts, tmpQuery));

	return 1;
}

SavePlayerInventory(playerid, prints = false)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		characterdata[5],
		helditems[2],
		inventoryitems[8];

	GetFile(gPlayerName[playerid], filename);

	file = fopen(filename, io_write);

	characterdata[0] = _:gPlayerHP[playerid];
	characterdata[1] = _:gPlayerAP[playerid];
	characterdata[2] = _:gPlayerFP[playerid];
	characterdata[3] = GetPlayerClothes(playerid);
	characterdata[4] = GetPlayerHat(playerid);

	if(prints)
		printf("[SAVE] Player: %p HP: %.2f", playerid, characterdata[0]);

	fblockwrite(file, characterdata, 5);

	if(GetPlayerHolsteredWeapon(playerid) != 0)
	{
		helditems[0] = GetPlayerHolsteredWeapon(playerid);
		helditems[1] = GetPlayerHolsteredWeaponAmmo(playerid);
		fblockwrite(file, helditems, 2);
	}
	else
	{
		helditems[0] = 0;
		helditems[1] = 0;
		fblockwrite(file, helditems, 2);
	}

	if(GetPlayerWeapon(playerid) > 0)
	{
		helditems[0] = GetPlayerWeapon(playerid);
		helditems[1] = GetPlayerAmmo(playerid);
		fblockwrite(file, helditems, 2);
	}
	else
	{
		if(IsValidItem(GetPlayerItem(playerid)))
		{
			helditems[0] = _:GetItemType(GetPlayerItem(playerid));
			helditems[1] = GetItemExtraData(GetPlayerItem(playerid));
			fblockwrite(file, helditems, 2);
		}
		else
		{
			helditems[0] = -1;
			helditems[1] = -1;
			fblockwrite(file, helditems, 2);
		}
	}

	for(new i, j; j < 4; i += 2, j++)
	{
		inventoryitems[i] = _:GetItemType(GetInventorySlotItem(playerid, j));
		inventoryitems[i + 1] = GetItemExtraData(GetInventorySlotItem(playerid, j));
	}

	fblockwrite(file, inventoryitems, 8);

	if(IsValidItem(GetPlayerBackpackItem(playerid)))
	{
		new
			containerid = GetItemExtraData(GetPlayerBackpackItem(playerid)),
			bagdata[17];

		bagdata[0] = _:GetItemType(GetPlayerBackpackItem(playerid));

		for(new i = 1, j; j < GetContainerSize(containerid); i += 2, j++)
		{
			bagdata[i] = _:GetItemType(GetContainerSlotItem(containerid, j));
			bagdata[i + 1] = GetItemExtraData(GetContainerSlotItem(containerid, j));
		}
		fblockwrite(file, bagdata, 17);
	}

	fclose(file);
}
LoadPlayerInventory(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file,
		filepos,
		characterdata[5],
		helditems[2],
		inventoryitems[8],
		bagdata[17],
		itemid;

	GetFile(gPlayerName[playerid], filename);

	if(!fexist(filename))
	{
		ClearPlayerInventoryFile(playerid);
		return 0;
	}

	file = fopen(filename, io_read);

	fblockread(file, characterdata, 5);

	printf("[LOAD]: %p HP: %f", playerid, characterdata[0]);

	if(Float:characterdata[0] <= 0.0)
		characterdata[0] = _:1.0;

	gPlayerHP[playerid] = Float:characterdata[0];
	gPlayerAP[playerid] = Float:characterdata[1];
	gPlayerFP[playerid] = Float:characterdata[2];
	gPlayerData[playerid][ply_Skin] = characterdata[3];
	SetPlayerHat(playerid, characterdata[4]);

	fblockread(file, helditems, 2);

	printf("[LOAD]: holster: %d %d", helditems[0], helditems[1]);
	if(0 < helditems[0] <= WEAPON_PARACHUTE)
	{
		if(helditems[1] > 0)
		{
			HolsterWeapon(playerid, helditems[0], helditems[1], 800);
		}
	}

	fblockread(file, helditems, 2);
	printf("[LOAD]: holding: %d %d", helditems[0], helditems[1]);
	if(helditems[0] != -1)
	{
		if(0 < helditems[0] <= WEAPON_PARACHUTE)
		{
			GivePlayerWeapon(playerid, helditems[0], helditems[1]);
			gPlayerArmedWeapon[playerid] = helditems[0];
		}
		else
		{
			itemid = CreateItem(ItemType:helditems[0], 0.0, 0.0, 0.0);

			if(!IsItemTypeSafebox(ItemType:helditems[0]) && !IsItemTypeBag(ItemType:helditems[0]))
				SetItemExtraData(itemid, helditems[1]);

			GiveWorldItemToPlayer(playerid, itemid, false);
		}
	}

	filepos = fblockread(file, inventoryitems, 8);

	for(new i; i < 8; i += 2)
	{
		if(!IsValidItemType(ItemType:inventoryitems[i]) || inventoryitems[i] == 0)
			continue;

		itemid = CreateItem(ItemType:inventoryitems[i], 0.0, 0.0, 0.0);
	
		if(!IsItemTypeSafebox(ItemType:inventoryitems[i]) && !IsItemTypeBag(ItemType:inventoryitems[i]))
			SetItemExtraData(itemid, inventoryitems[i + 1]);
	
		AddItemToInventory(playerid, itemid);
	}

	if(filepos != 0)
	{
		new
			containerid;

		fblockread(file, bagdata, 17);

		if(bagdata[0] == _:item_Satchel)
		{
			itemid = CreateItem(item_Satchel, 0.0, 0.0, 0.0);
			containerid = GetItemExtraData(itemid);
			GivePlayerBackpack(playerid, itemid);

			for(new i = 1; i < 8; i += 2)
			{
				if(bagdata[i] == _:INVALID_ITEM_TYPE)
					continue;

				itemid = CreateItem(ItemType:bagdata[i], 0.0, 0.0, 0.0);

				if(!IsItemTypeSafebox(ItemType:bagdata[i]) && !IsItemTypeBag(ItemType:bagdata[i]))
					SetItemExtraData(itemid, bagdata[i+1]);

				AddItemToContainer(containerid, itemid);
			}
		}

		if(bagdata[0] == _:item_Backpack)
		{
			itemid = CreateItem(item_Backpack, 0.0, 0.0, 0.0);
			containerid = GetItemExtraData(itemid);

			GivePlayerBackpack(playerid, itemid);

			for(new i = 1; i < 16; i += 2)
			{
				if(bagdata[i] == _:INVALID_ITEM_TYPE)
					continue;

				itemid = CreateItem(ItemType:bagdata[i], 0.0, 0.0, 0.0);

				if(!IsItemTypeSafebox(ItemType:bagdata[i]) && !IsItemTypeBag(ItemType:bagdata[i]))
					SetItemExtraData(itemid, bagdata[i+1]);

				AddItemToContainer(containerid, itemid);
			}
		}

		if(bagdata[0] == _:item_ParaBag)
		{
			itemid = CreateItem(item_ParaBag, 0.0, 0.0, 0.0);
			containerid = GetItemExtraData(itemid);

			GivePlayerBackpack(playerid, itemid);

			for(new i = 1; i < 12; i += 2)
			{
				if(bagdata[i] == _:INVALID_ITEM_TYPE)
					continue;

				itemid = CreateItem(ItemType:bagdata[i], 0.0, 0.0, 0.0);

				if(!IsItemTypeSafebox(ItemType:bagdata[i]) && !IsItemTypeBag(ItemType:bagdata[i]))
					SetItemExtraData(itemid, bagdata[i+1]);

				AddItemToContainer(containerid, itemid);
			}
		}
	}

	fclose(file);

	return 1;
}
ClearPlayerInventoryFile(playerid)
{
	new
		filename[MAX_PLAYER_FILE],
		File:file;

	GetFile(gPlayerName[playerid], filename);

	file = fopen(filename, io_write);
	fblockwrite(file, {0}, 1);
	fclose(file);
}



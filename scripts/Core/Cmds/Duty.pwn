static tick_AdminDuty[MAX_PLAYERS];

ACMD:duty[1](playerid, params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
	{
		Msg(playerid, YELLOW, " >  You cannot do that while spectating.");
		return 1;
	}

	if(gPlayerBitData[playerid] & AdminDuty)
	{
		f:gPlayerBitData[playerid]<AdminDuty>;

		SetPlayerPos(playerid,
			gPlayerData[playerid][ply_SpawnPosX],
			gPlayerData[playerid][ply_SpawnPosY],
			gPlayerData[playerid][ply_SpawnPosZ]);

		RemovePlayerWeapon(playerid);
		LoadPlayerInventory(playerid);
		LoadPlayerChar(playerid);

		SetPlayerClothes(playerid, gPlayerData[playerid][ply_Clothes]);

		tick_AdminDuty[playerid] = tickcount();
	}
	else
	{
		if(tickcount() - tick_AdminDuty[playerid] < 10000)
		{
			Msg(playerid, YELLOW, " >  Please don't use the duty ability that frequently.");
			return 1;
		}

		new
			itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		GetPlayerPos(playerid,
			gPlayerData[playerid][ply_SpawnPosX],
			gPlayerData[playerid][ply_SpawnPosY],
			gPlayerData[playerid][ply_SpawnPosZ]);

		if(IsItemTypeSafebox(itemtype) || IsItemTypeBag(itemtype))
		{
			if(!IsContainerEmpty(GetItemExtraData(itemid)))
			{
				CreateItemInWorld(itemid,
					gPlayerData[playerid][ply_SpawnPosX],
					gPlayerData[playerid][ply_SpawnPosY],
					gPlayerData[playerid][ply_SpawnPosZ] - FLOOR_OFFSET, .zoffset = ITEM_BUTTON_OFFSET);
			}
		}

		Logout(playerid);

		ToggleArmour(playerid, false);

		t:gPlayerBitData[playerid]<AdminDuty>;

		if(gPlayerData[playerid][ply_Gender] == GENDER_MALE)
			SetPlayerSkin(playerid, 217);

		else
			SetPlayerSkin(playerid, 211);
	}
	return 1;
}

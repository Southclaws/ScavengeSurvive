#include <YSI\y_hooks>


enum e_item_object{ItemType:e_itmobj_type,e_itmobj_exdata}
static
ItemType:	spawn_BagType,
ItemType:	spawn_ReSpawnItems[4][e_item_object],
ItemType:	spawn_NewSpawnItems[4][e_item_object];


forward OnPlayerCreateNewCharacter(playerid);


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Player/Spawn'...");

	new
		bagtype[ITM_MAX_NAME],
		respawnitems[4][ITM_MAX_NAME],
		newspawnitems[4][ITM_MAX_NAME];

	GetSettingString("spawn/bagtype", "Satchel", bagtype);
	spawn_BagType = GetItemTypeFromUniqueName(bagtype, true);

	for(new i; i < 4; i++)
	{
		GetSettingString(sprintf("spawn/respawnitems/%d/itemType", i), "", respawnitems[i]);
		GetSettingInt(sprintf("spawn/respawnitems/%d/exData", i), 0, spawn_ReSpawnItems[i][e_itmobj_exdata]);
		spawn_ReSpawnItems[i][e_itmobj_type] = GetItemTypeFromUniqueName(respawnitems[i]);
	}

	for(new i; i < 4; i++)
	{
		GetSettingString(sprintf("spawn/newspawnitems/%d/itemType", i), "", newspawnitems[i]);
		GetSettingInt(sprintf("spawn/newspawnitems/%d/exData", i), 0, spawn_NewSpawnItems[i][e_itmobj_exdata]);
		spawn_NewSpawnItems[i][e_itmobj_type] = GetItemTypeFromUniqueName(newspawnitems[i]);
	}
}


SpawnLoggedInPlayer(playerid)
{
	if(IsPlayerAlive(playerid))
	{
		if(PlayerSpawnExistingCharacter(playerid))
		{
			SetPlayerScreenFadeLevel(playerid, 255);
			return 1;
		}
	}
	
	PlayerCreateNewCharacter(playerid);
	SetPlayerScreenFadeLevel(playerid, 0);

	return 0;
}

PrepareForSpawn(playerid)
{
	SetPlayerBitFlag(playerid, Spawned, true);

	SetCameraBehindPlayer(playerid);
	SetAllWeaponSkills(playerid, 500);

	GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	ShowWatch(playerid);
	CancelSelectTextDraw(playerid);
}

PlayerSpawnExistingCharacter(playerid)
{
	if(GetPlayerBitFlag(playerid, Spawned))
		return 0;

	if(!LoadPlayerChar(playerid))
		return 0;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerSpawnPos(playerid, x, y, z);
	GetPlayerSpawnRot(playerid, r);

	Streamer_UpdateEx(playerid, x, y, z, 0, 0);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);

	SetPlayerGender(playerid, GetClothesGender(GetPlayerClothes(playerid)));

	if(GetPlayerWarnings(playerid) > 0)
	{
		if(GetPlayerWarnings(playerid) >= 5)	
			SetPlayerWarnings(playerid, 0);

		MsgF(playerid, YELLOW, " >  You have %d/5 warnings.", GetPlayerWarnings(playerid));
	}

	SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
	FreezePlayer(playerid, gLoginFreezeTime * 1000);

	PrepareForSpawn(playerid);

	if(GetPlayerStance(playerid) == 1)
	{
		ApplyAnimation(playerid, "SUNBATHE", "PARKSIT_M_OUT", 4.0, 0, 0, 0, 0, 0);
	}
	else if(GetPlayerStance(playerid) == 2)
	{
		ApplyAnimation(playerid, "SUNBATHE", "PARKSIT_M_OUT", 4.0, 0, 0, 0, 0, 0);
	}
	else if(GetPlayerStance(playerid) == 3)
	{
		ApplyAnimation(playerid, "ROB_BANK", "SHP_HandsUp_Scr", 4.0, 0, 1, 1, 1, 0);
	}

	logf("[SPAWN] %p spawned existing character at %.1f, %.1f, %.1f (%.1f)", playerid, x, y, z, r);

	return 1;
}

PlayerCreateNewCharacter(playerid)
{
	logf("[NEWCHAR] %p creating new character", playerid);

	SetPlayerPos(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);
	SetPlayerFacingAngle(playerid, 0.0);
	SetPlayerCameraLookAt(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);
	SetPlayerCameraPos(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z + 1.0);
	Streamer_UpdateEx(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);

	PlayerTextDrawBoxColor(playerid, ClassBackGround[playerid], 0x000000FF);
	PlayerTextDrawShow(playerid, ClassBackGround[playerid]);
	TogglePlayerControllable(playerid, false);

	if(IsPlayerLoggedIn(playerid))
	{
		PlayerTextDrawShow(playerid, ClassButtonMale[playerid]);
		PlayerTextDrawShow(playerid, ClassButtonFemale[playerid]);
		SelectTextDraw(playerid, 0xFFFFFF88);
	}

	CallLocalFunction("OnPlayerCreateNewCharacter", "d", playerid);
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(CanPlayerLeaveWelcomeMessage(playerid))
	{
		if(playertextid == ClassButtonMale[playerid])
		{
			PlayerSpawnNewCharacter(playerid, GENDER_MALE);
		}
		if(playertextid == ClassButtonFemale[playerid])
		{
			PlayerSpawnNewCharacter(playerid, GENDER_FEMALE);
		}
	}
}

PlayerSpawnNewCharacter(playerid, gender)
{
	if(GetPlayerBitFlag(playerid, Spawned))
		return 0;

	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	SetPlayerTotalSpawns(playerid, GetPlayerTotalSpawns(playerid) + 1);

	GetAccountLastSpawnTimestamp(name, gettime());
	SetAccountTotalSpawns(name, GetPlayerTotalSpawns(playerid));

	new
		backpackitem,
		containerid,
		tmpitem,
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GenerateSpawnPoint(playerid, x, y, z, r);
	Streamer_UpdateEx(playerid, x, y, z, 0, 0);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);

	if(gender == GENDER_MALE)
	{
		switch(random(6))
		{
			case 0: SetPlayerClothesID(playerid, skin_MainM);
			case 1: SetPlayerClothesID(playerid, skin_Civ1M);
			case 2: SetPlayerClothesID(playerid, skin_Civ2M);
			case 3: SetPlayerClothesID(playerid, skin_Civ3M);
			case 4: SetPlayerClothesID(playerid, skin_Civ4M);
			case 5: SetPlayerClothesID(playerid, skin_MechM);
			case 6: SetPlayerClothesID(playerid, skin_BikeM);
		}
	}
	else
	{
		switch(random(6))
		{
			case 0: SetPlayerClothesID(playerid, skin_MainF);
			case 1: SetPlayerClothesID(playerid, skin_Civ1F);
			case 2: SetPlayerClothesID(playerid, skin_Civ2F);
			case 3: SetPlayerClothesID(playerid, skin_Civ3F);
			case 4: SetPlayerClothesID(playerid, skin_Civ4F);
			case 5: SetPlayerClothesID(playerid, skin_ArmyF);
			case 6: SetPlayerClothesID(playerid, skin_IndiF);
		}
	}

	SetPlayerHP(playerid, 100.0);
	SetPlayerAP(playerid, 0.0);
	SetPlayerFP(playerid, 80.0);
	SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
	SetPlayerGender(playerid, gender);
	SetPlayerBleedRate(playerid, 0.0);

	SetPlayerBitFlag(playerid, Alive, true);
	SetPlayerBitFlag(playerid, Infected, false);

	FreezePlayer(playerid, gLoginFreezeTime * 1000);
	PrepareForSpawn(playerid);

	PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
	PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);

	if(IsValidItemType(spawn_BagType))
	{
		backpackitem = CreateItem(spawn_BagType);
		containerid = GetItemArrayDataAtCell(backpackitem, 1);

		GivePlayerBag(playerid, backpackitem);

		for(new i; i < 4; i++)
		{
			if(!IsValidItemType(spawn_ReSpawnItems[i][e_itmobj_type]))
				break;

			tmpitem = CreateItem(spawn_ReSpawnItems[i][e_itmobj_type]);
			SetItemExtraData(tmpitem, spawn_ReSpawnItems[i][e_itmobj_exdata]);
			AddItemToContainer(containerid, tmpitem);
		}

		if(IsNewPlayer(playerid))
		{
			for(new i; i < 4; i++)
			{
				if(!IsValidItemType(spawn_NewSpawnItems[i][e_itmobj_type]))
					break;

				tmpitem = CreateItem(spawn_NewSpawnItems[i][e_itmobj_type]);
				SetItemExtraData(tmpitem, spawn_NewSpawnItems[i][e_itmobj_exdata]);
				AddItemToContainer(containerid, tmpitem);
			}
		}
	}

	SetPlayerScreenFadeLevel(playerid, 255);

	logf("[SPAWN] %p spawned new character at %.1f, %.1f, %.1f (%.1f)", playerid, x, y, z, r);

	return 1;
}


/*==============================================================================

	Interface

==============================================================================*/


IsAtDefaultPos(Float:x, Float:y, Float:z)
{
	if(-5.0 < (x - DEFAULT_POS_X) < 5.0 && -5.0 < (y - DEFAULT_POS_Y) < 5.0 && -5.0 < (z - DEFAULT_POS_Z) < 5.0)
		return 1;

	return 0;
}

IsAtConnectionPos(Float:x, Float:y, Float:z)
{
	if(x == 1133.05 && y == -2038.40 && z == 69.09)
		return 1;

	return 0;
}

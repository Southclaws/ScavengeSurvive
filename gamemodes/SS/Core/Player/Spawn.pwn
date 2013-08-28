#include <YSI\y_hooks>


PlayerSpawnExistingCharacter(playerid)
{
	new Float:z;

	if(gPlayerData[playerid][ply_SpawnPosX] > 3000.0 ||
		gPlayerData[playerid][ply_SpawnPosX] < -3000.0 ||
		gPlayerData[playerid][ply_SpawnPosY] > 3000.0 ||
		gPlayerData[playerid][ply_SpawnPosY] < -3000.0)
		z += 2.0;

	Streamer_UpdateEx(playerid,
		gPlayerData[playerid][ply_SpawnPosX],
		gPlayerData[playerid][ply_SpawnPosY],
		gPlayerData[playerid][ply_SpawnPosZ] + z, 0, 0);

	SetPlayerPos(playerid,
		gPlayerData[playerid][ply_SpawnPosX],
		gPlayerData[playerid][ply_SpawnPosY],
		gPlayerData[playerid][ply_SpawnPosZ] + z);

	SetPlayerFacingAngle(playerid, gPlayerData[playerid][ply_SpawnRotZ]);

	LoadPlayerInventory(playerid);
	LoadPlayerChar(playerid);
	t:gPlayerBitData[playerid]<LoadedData>;

	gPlayerData[playerid][ply_Gender] = GetClothesGender(GetPlayerClothes(playerid));

	if(gPlayerData[playerid][ply_Warnings] > 0)
	{
		if(gPlayerData[playerid][ply_Warnings] >= 5)	
			gPlayerData[playerid][ply_Warnings] = 0;

		MsgF(playerid, YELLOW, " >  You have %d/5 warnings.", gPlayerData[playerid][ply_Warnings]);
	}

	SetPlayerClothes(playerid, gPlayerData[playerid][ply_Clothes]);
	SetCameraBehindPlayer(playerid);
	FreezePlayer(playerid, gLoginFreezeTime * 1000);
	t:gPlayerBitData[playerid]<Spawned>;

	GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	ShowWatch(playerid);

	if(gPlayerData[playerid][ply_stance] == 1)
	{
		ApplyAnimation(playerid, "BEACH", "PARKSIT_M_LOOP", 4.0, 1, 0, 0, 0, 0);
	}
	else if(gPlayerData[playerid][ply_stance] == 2)
	{
		ApplyAnimation(playerid, "BEACH", "PARKSIT_M_LOOP", 4.0, 1, 0, 0, 0, 0);
	}
	else if(gPlayerData[playerid][ply_stance] == 3)
	{
		ApplyAnimation(playerid, "ROB_BANK", "SHP_HandsUp_Scr", 4.0, 0, 1, 1, 1, 0);
	}
}

PlayerCreateNewCharacter(playerid)
{
	SetPlayerPos(playerid, -907.5452, 272.7235, 1014.1449);
	SetPlayerFacingAngle(playerid, 0.0);
	SetPlayerCameraLookAt(playerid, -907.5452, 272.7235, 1014.1449);
	SetPlayerCameraPos(playerid, -907.4642, 277.0962, 1014.1492);
	Streamer_UpdateEx(playerid, -907.5452, 272.7235, 1014.1449);

	PlayerTextDrawBoxColor(playerid, ClassBackGround[playerid], 0x000000FF);
	PlayerTextDrawShow(playerid, ClassBackGround[playerid]);

	if(gPlayerBitData[playerid] & LoggedIn)
	{
		PlayerTextDrawShow(playerid, ClassButtonMale[playerid]);
		PlayerTextDrawShow(playerid, ClassButtonFemale[playerid]);
		SelectTextDraw(playerid, 0xFFFFFF88);
	}

	t:gPlayerBitData[playerid]<LoadedData>;
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
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

PlayerSpawnNewCharacter(playerid, gender)
{
	gPlayerData[playerid][ply_TotalSpawns]++;

	stmt_bind_value(gStmt_AccountSetSpawnTime, 0, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(gStmt_AccountSetSpawnTime, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(gStmt_AccountSetSpawnTime);

	stmt_bind_value(gStmt_AccountSetTotalSpawns, 0, DB::TYPE_INTEGER, gPlayerData[playerid][ply_TotalSpawns]);
	stmt_bind_value(gStmt_AccountSetTotalSpawns, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(gStmt_AccountSetTotalSpawns);

	new
		backpackitem,
		containerid,
		tmpitem,
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	if(gender == GENDER_MALE)
	{
		switch(random(6))
		{
			case 0: gPlayerData[playerid][ply_Clothes] = skin_MainM;
			case 1: gPlayerData[playerid][ply_Clothes] = skin_Civ1M;
			case 2: gPlayerData[playerid][ply_Clothes] = skin_Civ2M;
			case 3: gPlayerData[playerid][ply_Clothes] = skin_Civ3M;
			case 4: gPlayerData[playerid][ply_Clothes] = skin_Civ4M;
			case 5: gPlayerData[playerid][ply_Clothes] = skin_MechM;
			case 6: gPlayerData[playerid][ply_Clothes] = skin_BikeM;

		}
	}
	else
	{
		switch(random(6))
		{
			case 0: gPlayerData[playerid][ply_Clothes] = skin_MainF;
			case 1: gPlayerData[playerid][ply_Clothes] = skin_Civ1F;
			case 2: gPlayerData[playerid][ply_Clothes] = skin_Civ2F;
			case 3: gPlayerData[playerid][ply_Clothes] = skin_Civ3F;
			case 4: gPlayerData[playerid][ply_Clothes] = skin_Civ4F;
			case 5: gPlayerData[playerid][ply_Clothes] = skin_ArmyF;
			case 6: gPlayerData[playerid][ply_Clothes] = skin_IndiF;
		}
	}

	SetPlayerClothes(playerid, gPlayerData[playerid][ply_Clothes]);

	GenerateSpawnPoint(playerid, x, y, z, r);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);

	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
	SetAllWeaponSkills(playerid, 500);
	GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	ShowWatch(playerid);

	CancelSelectTextDraw(playerid);
	PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
	PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);

	t:gPlayerBitData[playerid]<Spawned>;
	t:gPlayerBitData[playerid]<Alive>;
	f:gPlayerBitData[playerid]<Bleeding>;
	f:gPlayerBitData[playerid]<Infected>;
	f:gPlayerBitData[playerid]<KnockedOut>;

	gPlayerData[playerid][ply_ScreenBoxFadeLevel] = 255;

	backpackitem = CreateItem(item_Satchel);
	containerid = GetItemExtraData(backpackitem);

	GivePlayerBag(playerid, backpackitem);

	tmpitem = CreateItem(item_Wrench);
	AddItemToContainer(containerid, tmpitem);

	if(gPlayerBitData[playerid] & IsVip)
	{
		tmpitem = CreateItem(item_ZorroMask);
		AddItemToInventory(playerid, tmpitem);
	}

	if(gPlayerBitData[playerid] & IsNewPlayer)
		Tutorial_Start(playerid);
}

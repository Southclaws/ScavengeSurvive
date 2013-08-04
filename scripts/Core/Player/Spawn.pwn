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
	t:bPlayerGameSettings[playerid]<LoadedData>;

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
	t:bPlayerGameSettings[playerid]<Spawned>;

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

	PlayerTextDrawBoxColor(playerid, ClassBackGround, 0x000000FF);
	PlayerTextDrawShow(playerid, ClassBackGround);

	if(bPlayerGameSettings[playerid] & LoggedIn)
	{
		PlayerTextDrawShow(playerid, ClassButtonMale);
		PlayerTextDrawShow(playerid, ClassButtonFemale);
		SelectTextDraw(playerid, 0xFFFFFF88);
	}

	t:bPlayerGameSettings[playerid]<LoadedData>;
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == ClassButtonMale)
	{
		PlayerSpawnNewCharacter(playerid, 1);
	}
	if(playertextid == ClassButtonFemale)
	{
		PlayerSpawnNewCharacter(playerid, 0);
	}
}

PlayerSpawnNewCharacter(playerid, gender)
{
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
	PlayerTextDrawHide(playerid, ClassButtonMale);
	PlayerTextDrawHide(playerid, ClassButtonFemale);

	t:bPlayerGameSettings[playerid]<Spawned>;
	t:bPlayerGameSettings[playerid]<Alive>;
	f:bPlayerGameSettings[playerid]<Bleeding>;
	f:bPlayerGameSettings[playerid]<Infected>;
	f:bPlayerGameSettings[playerid]<KnockedOut>;

	gPlayerData[playerid][ply_ScreenBoxFadeLevel] = 255;

	backpackitem = CreateItem(item_Satchel);
	containerid = GetItemExtraData(backpackitem);

	GivePlayerBackpack(playerid, backpackitem);

	tmpitem = CreateItem(item_Wrench);
	AddItemToContainer(containerid, tmpitem);

	if(bPlayerGameSettings[playerid] & IsVip)
	{
		tmpitem = CreateItem(item_ZorroMask);
		AddItemToInventory(playerid, tmpitem);
	}

	if(bPlayerGameSettings[playerid] & IsNewPlayer)
		Tutorial_Start(playerid);
}

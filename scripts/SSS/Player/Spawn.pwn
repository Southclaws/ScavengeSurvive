#include <YSI\y_hooks>


#define MAX_SPAWNS (4)


new Float:gSpawns[MAX_SPAWNS][4];


hook OnGameModeInit()
{
	new
		File:file,
		line[128],
		idx;

	file = fopen("SSS/Spawns.dat", io_read);

	while(fread(file, line))
	{
		sscanf(line, "p<,>ffff", gSpawns[idx][0], gSpawns[idx][1], gSpawns[idx][2], gSpawns[idx][3]);
		idx++;
	}
}


PlayerSpawnExistingCharacter(playerid)
{
	new Float:z;

	if(gPlayerData[playerid][ply_posX] > 3000.0 || gPlayerData[playerid][ply_posX] < -3000.0 && gPlayerData[playerid][ply_posY] > 3000.0 || gPlayerData[playerid][ply_posY])
		z += 2.0;

	SetPlayerPos(playerid,
		gPlayerData[playerid][ply_posX],
		gPlayerData[playerid][ply_posY],
		gPlayerData[playerid][ply_posZ] + z);

	LoadPlayerInventory(playerid);
	LoadPlayerChar(playerid);
	t:bPlayerGameSettings[playerid]<LoadedData>;

	if(gPlayerWarnings[playerid] > 0)
	{
		if(gPlayerWarnings[playerid] >= 5)	
			gPlayerWarnings[playerid] = 0;

		MsgF(playerid, YELLOW, " >  You have %d/5 warnings.", gPlayerWarnings[playerid]);
	}

	SetPlayerClothes(playerid, gPlayerData[playerid][ply_Skin]);
	SetPlayerFacingAngle(playerid, gPlayerData[playerid][ply_rotZ]);
	SetCameraBehindPlayer(playerid);
	FreezePlayer(playerid, 3000);
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
	PlayerTextDrawShow(playerid, ClassButtonMale);
	PlayerTextDrawShow(playerid, ClassButtonFemale);
	SelectTextDraw(playerid, 0xFFFFFF88);

	t:bPlayerGameSettings[playerid]<LoadedData>;
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == ClassButtonMale)
	{
		t:bPlayerGameSettings[playerid]<Gender>;
		PlayerSpawnNewCharacter(playerid);
	}
	if(playertextid == ClassButtonFemale)
	{
		f:bPlayerGameSettings[playerid]<Gender>;
		PlayerSpawnNewCharacter(playerid);
	}
}

PlayerSpawnNewCharacter(playerid)
{
	new
		r = random(MAX_SPAWNS),
		backpackitem,
		containerid,
		tmpitem;

	if(bPlayerGameSettings[playerid] & IsVip)
	{
		if(bPlayerGameSettings[playerid] & Gender)
		{
			switch(random(6))
			{
				case 0: gPlayerData[playerid][ply_Skin] = skin_Civ1M;
				case 1: gPlayerData[playerid][ply_Skin] = skin_Civ2M;
				case 2: gPlayerData[playerid][ply_Skin] = skin_Civ3M;
				case 3: gPlayerData[playerid][ply_Skin] = skin_Civ4M;
				case 4: gPlayerData[playerid][ply_Skin] = skin_MechM;
				case 5: gPlayerData[playerid][ply_Skin] = skin_BikeM;

			}
		}

		else
		{
			switch(random(6))
			{
				case 0: gPlayerData[playerid][ply_Skin] = skin_Civ1F;
				case 1: gPlayerData[playerid][ply_Skin] = skin_Civ2F;
				case 2: gPlayerData[playerid][ply_Skin] = skin_Civ3F;
				case 3: gPlayerData[playerid][ply_Skin] = skin_Civ4F;
				case 4: gPlayerData[playerid][ply_Skin] = skin_ArmyF;
				case 5: gPlayerData[playerid][ply_Skin] = skin_IndiF;
			}
		}
	}
	else
	{
		if(bPlayerGameSettings[playerid] & Gender)
			gPlayerData[playerid][ply_Skin] = skin_MainM;

		else
			gPlayerData[playerid][ply_Skin] = skin_MainF;
	}

	SetPlayerClothes(playerid, gPlayerData[playerid][ply_Skin]);

	SetPlayerPos(playerid, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	SetPlayerFacingAngle(playerid, gSpawns[r][3]);
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
	f:bPlayerGameSettings[playerid]<KnockedOut>;

	gScreenBoxFadeLevel[playerid] = 255;

	backpackitem = CreateItem(item_Satchel, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	containerid = GetItemExtraData(backpackitem);

	GivePlayerBackpack(playerid, backpackitem);

	tmpitem = CreateItem(ItemType:WEAPON_KNIFE, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	SetItemExtraData(tmpitem, 1);
	AddItemToContainer(containerid, tmpitem);

	tmpitem = CreateItem(item_Wrench, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
	AddItemToContainer(containerid, tmpitem);

	if(bPlayerGameSettings[playerid] & IsVip)
	{
		tmpitem = CreateItem(item_ZorroMask, gSpawns[r][0], gSpawns[r][1], gSpawns[r][2]);
		AddItemToInventory(playerid, tmpitem);
	}

	if(bPlayerGameSettings[playerid] & IsNewPlayer)
		Tutorial_Start(playerid);
}

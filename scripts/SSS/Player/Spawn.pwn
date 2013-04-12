#include <YSI\y_hooks>


#define MAX_SPAWNS (5)


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
	SetPlayerPos(playerid,
		gPlayerData[playerid][ply_posX],
		gPlayerData[playerid][ply_posY],
		gPlayerData[playerid][ply_posZ]);

	LoadPlayerInventory(playerid);
	LoadPlayerChar(playerid);

	if(gPlayerWarnings[playerid] > 0)
	{
		if(gPlayerWarnings[playerid] >= 5)	
			gPlayerWarnings[playerid] = 0;

		MsgF(playerid, YELLOW, " >  You have %d/5 warnings.", gPlayerWarnings[playerid]);
	}

	SetPlayerClothes(playerid, gPlayerData[playerid][ply_Skin]);
	SetPlayerFacingAngle(playerid, gPlayerData[playerid][ply_rotZ]);
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
	t:bPlayerGameSettings[playerid]<Spawned>;

	GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	ShowWatch(playerid);

	stop gScreenFadeTimer[playerid];
	gScreenFadeTimer[playerid] = repeat FadeScreen(playerid);
}

PlayerCreateNewCharacter(playerid)
{
	SetPlayerPos(playerid, -907.5452, 272.7235, 1014.1449);
	SetPlayerFacingAngle(playerid, 0.0);
	SetPlayerCameraLookAt(playerid, -907.5452, 272.7235, 1014.1449);
	SetPlayerCameraPos(playerid, -907.4642, 277.0962, 1014.1492);
	Streamer_UpdateEx(playerid, -907.5452, 272.7235, 1014.1449);

	PlayerTextDrawShow(playerid, ClassButtonMale);
	PlayerTextDrawShow(playerid, ClassButtonFemale);
	SelectTextDraw(playerid, 0xFFFFFF88);
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
	stop gScreenFadeTimer[playerid];
	gScreenFadeTimer[playerid] = repeat FadeScreen(playerid);

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

timer FadeScreen[100](playerid)
{
	PlayerTextDrawBoxColor(playerid, ClassBackGround, gScreenBoxFadeLevel[playerid]);
	PlayerTextDrawShow(playerid, ClassBackGround);

	gScreenBoxFadeLevel[playerid] -= 4;

	if(gPlayerHP[playerid] <= 40.0)
	{
		if(gScreenBoxFadeLevel[playerid] <= floatround((40.0 - gPlayerHP[playerid]) * 4.4))
			stop gScreenFadeTimer[playerid];
	}
	else
	{
		if(gScreenBoxFadeLevel[playerid] <= 0)
			stop gScreenFadeTimer[playerid];
	}
}

/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


enum e_item_object{ItemType:e_itmobj_type,e_itmobj_exdata}
static
ItemType:	spawn_BagType,
ItemType:	spawn_NewItems[16][e_item_object], // items given to new players
ItemType:	spawn_ResItems[16][e_item_object]; // items given on respawns

new
PlayerText:	ClassButtonMale[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	ClassButtonFemale[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};


forward OnPlayerCreateChar(playerid);
forward OnPlayerSpawnChar(playerid);
forward OnPlayerSpawnNewChar(playerid);


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Player/Spawn'...");

	new
		newitems[16][32],
		newitems_total,

		resitems[16][32],
		resitems_total,

		bagtype[ITM_MAX_NAME];

	GetSettingString("spawn/bagtype", "Satchel", bagtype);
	spawn_BagType = GetItemTypeFromUniqueName(bagtype, true);

	if(!IsValidItemType(spawn_BagType))
		printf("ERROR: spawn/bagtype item name '%s' results in invalid item type %d", bagtype, _:spawn_BagType);

	GetSettingStringArray("spawn/new-spawn-items", "Knife", 16, newitems, newitems_total, 32);
	GetSettingStringArray("spawn/respawn-items", "AntiSepBandage", 16, resitems, resitems_total, 32);

	// todo: handle arraydata

	for(new i; i < 16; i++)
	{
		spawn_NewItems[i][e_itmobj_type] = GetItemTypeFromUniqueName(newitems[i], true);

		if(newitems[i][0] != EOS && !IsValidItemType(spawn_NewItems[i][e_itmobj_type]))
			printf("ERROR: item '%s' from spawn/new-spawn-items/%d is invalid type %d.", newitems[i], i, _:spawn_NewItems[i][e_itmobj_type]);
	}

	for(new i; i < 16; i++)
	{
		spawn_ResItems[i][e_itmobj_type] = GetItemTypeFromUniqueName(resitems[i], true);

		if(resitems[i][0] != EOS && !IsValidItemType(spawn_ResItems[i][e_itmobj_type]))
			printf("ERROR: item '%s' from spawn/new-spawn-items/%d is invalid type %d.", resitems[i], i, _:spawn_ResItems[i][e_itmobj_type]);
	}
}

hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/player/spawn.pwn");

//	defer LoadClassUI(playerid);
//}
//
//timer LoadClassUI[1](playerid)
//{
	ClassButtonMale[playerid]		=CreatePlayerTextDraw(playerid, 250.000000, 200.000000, "~n~Male~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonMale[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonMale[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonMale[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonMale[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonMale[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonMale[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonMale[playerid], 44.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonMale[playerid], true);

	ClassButtonFemale[playerid]		=CreatePlayerTextDraw(playerid, 390.000000, 200.000000, "~n~Female~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonFemale[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonFemale[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonFemale[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonFemale[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonFemale[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonFemale[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonFemale[playerid], 44.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonFemale[playerid], true);
}

SpawnLoggedInPlayer(playerid)
{
	if(IsPlayerAlive(playerid))
	{
		if(PlayerSpawnExistingCharacter(playerid))
		{
			SetPlayerBrightness(playerid, 255);
			return 1;
		}
	}
	
	PlayerCreateNewCharacter(playerid);
	SetPlayerBrightness(playerid, 255);

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

		ChatMsgLang(playerid, YELLOW, "WARNCOUNTER", GetPlayerWarnings(playerid));
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

	CallLocalFunction("OnPlayerSpawnChar", "d", playerid);

	return 1;
}

PlayerCreateNewCharacter(playerid)
{
	logf("[NEWCHAR] %p creating new character", playerid);

	SetPlayerPos(playerid, DEFAULT_POS_X + 5, DEFAULT_POS_Y, DEFAULT_POS_Z);
	SetPlayerFacingAngle(playerid, 0.0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);

	SetPlayerCameraLookAt(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);
	SetPlayerCameraPos(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z - 1.0);
	Streamer_UpdateEx(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);

	SetPlayerBrightness(playerid, 255);
	TogglePlayerControllable(playerid, false);

	if(IsPlayerLoggedIn(playerid))
	{
		PlayerTextDrawShow(playerid, ClassButtonMale[playerid]);
		PlayerTextDrawShow(playerid, ClassButtonFemale[playerid]);
		SelectTextDraw(playerid, 0xFFFFFF88);
	}

	CallLocalFunction("OnPlayerCreateChar", "d", playerid);
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerClickPlayerTD] in /gamemodes/sss/core/player/spawn.pwn");

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

	SetAccountLastSpawnTimestamp(name, gettime());
	SetAccountTotalSpawns(name, GetPlayerTotalSpawns(playerid));

	new
		backpackitem,
		tmpitem,
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GenerateSpawnPoint(playerid, x, y, z, r);
	Streamer_UpdateEx(playerid, x, y, z, 0, 0);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);

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

	FreezePlayer(playerid, gLoginFreezeTime * 1000);
	PrepareForSpawn(playerid);

	PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
	PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);

	if(IsValidItemType(spawn_BagType))
	{
		backpackitem = CreateItem(spawn_BagType);

		GivePlayerBag(playerid, backpackitem);

		for(new i; i < 4; i++)
		{
			if(!IsValidItemType(spawn_ResItems[i][e_itmobj_type]))
				break;

			tmpitem = CreateItem(spawn_ResItems[i][e_itmobj_type]);

			if(spawn_ResItems[i][e_itmobj_exdata] != 0)
				SetItemExtraData(tmpitem, spawn_ResItems[i][e_itmobj_exdata]);

			AddItemToPlayer(playerid, tmpitem, true, false);
		}

		if(IsNewPlayer(playerid))
		{
			for(new i; i < 4; i++)
			{
				if(!IsValidItemType(spawn_NewItems[i][e_itmobj_type]))
					break;

				tmpitem = CreateItem(spawn_NewItems[i][e_itmobj_type]);

				if(spawn_NewItems[i][e_itmobj_exdata] != 0)
					SetItemExtraData(tmpitem, spawn_NewItems[i][e_itmobj_exdata]);

				AddItemToPlayer(playerid, tmpitem, true, false);
			}
		}
	}

	SetPlayerBrightness(playerid, 255);

	CallLocalFunction("OnPlayerSpawnNewChar", "d", playerid);

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
	if(1133.05 < x < 1133.059999 && -2038.40 < y < -2038.409999 && 69.09 < z < 69.099999)
		return 1;

	return 0;
}

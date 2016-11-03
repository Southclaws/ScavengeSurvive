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


static
Text:	DeathText = Text:INVALID_TEXT_DRAW,
Text:	DeathButton = Text:INVALID_TEXT_DRAW,
bool:	death_Dying[MAX_PLAYERS],
		death_LastDeath[MAX_PLAYERS],
Float:	death_PosX[MAX_PLAYERS],
Float:	death_PosY[MAX_PLAYERS],
Float:	death_PosZ[MAX_PLAYERS],
Float:	death_RotZ[MAX_PLAYERS],
		death_LastKilledBy[MAX_PLAYERS][MAX_PLAYER_NAME],
		death_LastKilledById[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/player/death.pwn");

	death_LastKilledBy[playerid][0] = EOS;
	death_LastKilledById[playerid] = INVALID_PLAYER_ID;

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(GetTickCountDifference(GetTickCount(), death_LastDeath[playerid]) < 1000)
		return -1;

	death_LastDeath[playerid] = GetTickCount();

	if(killerid == INVALID_PLAYER_ID)
	{
		killerid = GetLastHitById(playerid);

		if(!IsPlayerConnected(killerid))
			killerid = INVALID_PLAYER_ID;
	}

	_OnDeath(playerid, killerid);

	return 1;
}

_OnDeath(playerid, killerid)
{
	if(!IsPlayerAlive(playerid) || IsPlayerOnAdminDuty(playerid))
	{
		return 0;
	}

	new
		deathreason = GetLastHitByWeapon(playerid),
		deathreasonstring[256];

	death_Dying[playerid] = true;
	SetPlayerSpawnedState(playerid, false);
	SetPlayerAliveState(playerid, false);

	GetPlayerPos(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid]);
	GetPlayerFacingAngle(playerid, death_RotZ[playerid]);

	if(IsPlayerInAnyVehicle(playerid))
	{
		RemovePlayerFromVehicle(playerid);
		TogglePlayerSpectating(playerid, true);
		TogglePlayerSpectating(playerid, false);
		death_PosZ[playerid] += 0.5;
	}

	HideWatch(playerid);
	DropItems(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid], true);
	RemovePlayerWeapon(playerid);
	SpawnPlayer(playerid);

	KillPlayer(playerid, killerid, deathreason);

	if(IsPlayerConnected(killerid))
	{
		logf("[KILL] %p killed %p with %d at %f, %f, %f (%f)", killerid, playerid, deathreason, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid]);

		GetPlayerName(killerid, death_LastKilledBy[playerid], MAX_PLAYER_NAME);
		death_LastKilledById[playerid] = killerid;

		switch(deathreason)
		{
			case 0..3, 5..7, 10..15:
				deathreasonstring = "They were beaten to death.";

			case 4:
				deathreasonstring = "They suffered small lacerations on the torso, possibly from a knife.";

			case 8:
				deathreasonstring = "Large lacerations cover the torso and head, looks like a finely sharpened sword.";

			case 9:
				deathreasonstring = "There's bits everywhere, probably suffered a chainsaw to the torso.";

			case 16, 39, 35, 36, 255:
				deathreasonstring = "They suffered massive concussion due to an explosion.";

			case 18, 37:
				deathreasonstring = "The entire body is charred and burnt.";

			case 22..34, 38:
				deathreasonstring = "They died of blood loss caused by what looks like bullets.";

			case 41, 42:
				deathreasonstring = "They were sprayed and suffocated by a high pressure substance.";

			case 44, 45:
				deathreasonstring = "Somehow, they were killed by goggles.";

			case 43:
				deathreasonstring = "Somehow, they were killed by a camera.";

			default:
				deathreasonstring = "They bled to death.";
		}
	}
	else
	{
		logf("[DEATH] %p died because of %d at %f, %f, %f (%f)", playerid, deathreason, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid]);

		death_LastKilledBy[playerid][0] = EOS;
		death_LastKilledById[playerid] = INVALID_PLAYER_ID;

		switch(deathreason)
		{
			case 53:
				deathreasonstring = "They drowned.";

			case 54:
				deathreasonstring = "Most bones are broken, looks like they fell from a great height.";

			case 255:
				deathreasonstring = "They suffered massive concussion due to an explosion.";

			default:
				deathreasonstring = "They died for an unknown reason.";
		}
	}

	CreateGravestone(playerid, deathreasonstring, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid] - FLOOR_OFFSET, death_RotZ[playerid]);

	return 1;
}

DropItems(playerid, Float:x, Float:y, Float:z, Float:r, bool:death)
{
	new
		itemid,
		interior = GetPlayerInterior(playerid),
		world = GetPlayerVirtualWorld(playerid);

	/*
		Held item
	*/

	itemid = GetPlayerItem(playerid);

	if(IsValidItem(itemid))
	{
		CreateItemInWorld(itemid,
			x + floatsin(345.0, degrees),
			y + floatcos(345.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);
	}

	/*
		Holstered item
	*/

	itemid = GetPlayerHolsterItem(playerid);

	if(IsValidItem(itemid))
	{
		RemovePlayerHolsterItem(playerid);

		CreateItemInWorld(itemid,
			x + floatsin(15.0, degrees),
			y + floatcos(15.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);
	}

	/*
		Inventory
	*/

	for(new i; i < INV_MAX_SLOTS; i++)
	{
		itemid = GetInventorySlotItem(playerid, 0);

		if(!IsValidItem(itemid))
			break;

		RemoveItemFromInventory(playerid, 0);
		CreateItemInWorld(itemid,
			x + floatsin(45.0 + (90.0 * float(i)), degrees),
			y + floatcos(45.0 + (90.0 * float(i)), degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);
	}

	/*
		Bag item
	*/

	itemid = GetPlayerBagItem(playerid);

	if(IsValidItem(itemid))
	{
		RemovePlayerBag(playerid);

		SetItemPos(itemid, x + floatsin(180.0, degrees), y + floatcos(180.0, degrees), z - FLOOR_OFFSET);
		SetItemRot(itemid, 0.0, 0.0, r, true);
		SetItemInterior(itemid, interior);
		SetItemWorld(itemid, world);
	}

	/*
		Head-wear item
	*/

	itemid = RemovePlayerHatItem(playerid);

	if(IsValidItem(itemid))
	{
		CreateItemInWorld(itemid,
			x + floatsin(270.0, degrees),
			y + floatcos(270.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);
	}

	/*
		Face-wear item
	*/

	itemid = RemovePlayerMaskItem(playerid);

	if(IsValidItem(itemid))
	{
		CreateItemInWorld(itemid,
			x + floatsin(280.0, degrees),
			y + floatcos(280.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);
	}

	/*
		Armour item
	*/

	if(GetPlayerAP(playerid) > 0.0)
	{
		itemid = CreateItemInWorld(RemovePlayerArmourItem(playerid),
			x + floatsin(80.0, degrees),
			y + floatcos(80.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);

		SetPlayerAP(playerid, 0.0);
	}

	/*
		These items should only be dropped on death.
	*/

	if(!death)
		return;

	/*
		Handcuffs
	*/

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
	{
		CreateItem(item_HandCuffs,
			x + floatsin(135.0, degrees),
			y + floatcos(135.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);

		SetPlayerCuffs(playerid, false);
	}

	/*
		Clothes item
	*/

	itemid = CreateItem(item_Clothes,
		x + floatsin(90.0, degrees),
		y + floatcos(90.0, degrees),
		z - FLOOR_OFFSET,
		.rz = r,
		.world = world,
		.interior = interior);

	SetItemExtraData(itemid, GetPlayerClothes(playerid));

	return;
}

hook OnPlayerSpawn(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerSpawn] in /gamemodes/sss/core/player/death.pwn");

	if(IsPlayerDead(playerid))
	{
		TogglePlayerSpectating(playerid, true);
		TogglePlayerControllable(playerid, false);

		defer SetDeathCamera(playerid);

		SetPlayerCameraPos(playerid,
			death_PosX[playerid] - floatsin(-death_RotZ[playerid], degrees),
			death_PosY[playerid] - floatcos(-death_RotZ[playerid], degrees),
			death_PosZ[playerid]);

		SetPlayerCameraLookAt(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid]);

		SelectTextDraw(playerid, 0xFFFFFF88);
		SetPlayerHP(playerid, 1.0);
		SetPlayerBrightness(playerid, 200);
		TextDrawShowForPlayer(playerid, DeathText);
		TextDrawShowForPlayer(playerid, DeathButton);
	}
}

timer SetDeathCamera[500](playerid)
{
	if(!IsPlayerDead(playerid))
		return;

	InterpolateCameraPos(playerid,
		death_PosX[playerid] - floatsin(-death_RotZ[playerid], degrees),
		death_PosY[playerid] - floatcos(-death_RotZ[playerid], degrees),
		death_PosZ[playerid] + 1.0,
		death_PosX[playerid] - floatsin(-death_RotZ[playerid], degrees),
		death_PosY[playerid] - floatcos(-death_RotZ[playerid], degrees),
		death_PosZ[playerid] + 20.0,
		30000, CAMERA_MOVE);

	InterpolateCameraLookAt(playerid,
		death_PosX[playerid],
		death_PosY[playerid],
		death_PosZ[playerid],
		death_PosX[playerid],
		death_PosY[playerid],
		death_PosZ[playerid] + 1.0,
		30000, CAMERA_MOVE);

	return;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerClickTextDraw] in /gamemodes/sss/core/player/death.pwn");

	if(clickedid == DeathButton)
	{
		if(!IsPlayerDead(playerid))
			return 1;

		death_Dying[playerid] = false;
		TogglePlayerSpectating(playerid, false);
		CancelSelectTextDraw(playerid);
		TextDrawHideForPlayer(playerid, DeathText);
		TextDrawHideForPlayer(playerid, DeathButton);
		SpawnLoggedInPlayer(playerid);
	}

	return 1;
}

hook OnGameModeInit()
{
	DeathText					=TextDrawCreate(320.000000, 300.000000, "YOU ARE DEAD!");
	TextDrawAlignment			(DeathText, 2);
	TextDrawBackgroundColor		(DeathText, 255);
	TextDrawFont				(DeathText, 1);
	TextDrawLetterSize			(DeathText, 0.500000, 2.000000);
	TextDrawColor				(DeathText, -1);
	TextDrawSetOutline			(DeathText, 0);
	TextDrawSetProportional		(DeathText, 1);
	TextDrawSetShadow			(DeathText, 1);
	TextDrawUseBox				(DeathText, 1);
	TextDrawBoxColor			(DeathText, 85);
	TextDrawTextSize			(DeathText, 20.000000, 150.000000);

	DeathButton					=TextDrawCreate(320.000000, 323.000000, ">Play Again<");
	TextDrawAlignment			(DeathButton, 2);
	TextDrawBackgroundColor		(DeathButton, 255);
	TextDrawFont				(DeathButton, 1);
	TextDrawLetterSize			(DeathButton, 0.370000, 1.599999);
	TextDrawColor				(DeathButton, -1);
	TextDrawSetOutline			(DeathButton, 0);
	TextDrawSetProportional		(DeathButton, 1);
	TextDrawSetShadow			(DeathButton, 1);
	TextDrawUseBox				(DeathButton, 1);
	TextDrawBoxColor			(DeathButton, 85);
	TextDrawTextSize			(DeathButton, 20.000000, 150.000000);
	TextDrawSetSelectable		(DeathButton, true);
}


stock IsPlayerDead(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return death_Dying[playerid];
}

stock GetPlayerDeathPos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	x = death_PosX[playerid];
	y = death_PosY[playerid];
	z = death_PosZ[playerid];

	return 1;
}

stock GetPlayerDeathRot(playerid, &Float:r)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	r = death_RotZ;

	return 1;
}

// death_LastKilledBy
stock GetLastKilledBy(playerid, name[MAX_PLAYER_NAME])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	name = death_LastKilledBy[playerid];

	return 1;
}

// death_LastKilledById
stock GetLastKilledById(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return death_LastKilledById[playerid];
}

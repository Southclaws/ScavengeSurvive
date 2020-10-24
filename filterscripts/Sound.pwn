/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#define FILTERSCRIPT

#include <a_samp>
#include <SIF\SIF>

// In the sound-system class/library

#define MAX_SOUND_LEVEL 100.0

static
Float:	sound_Level[MAX_PLAYERS],
Float:	sound_DropSpeed[MAX_PLAYERS],
bool:	sound_MakingSound[MAX_PLAYERS];

// Core functions

PlayerMakeSound(playerid, Float:amount, Float:dropspeed)
{
	//printf("%.0f\t%.1f", amount, dropspeed);
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!sound_MakingSound[playerid] && sound_Level[playerid] > 0.0)
	{
		sound_Level[playerid] = 0.0;
	}
	else
	{
		if(amount < sound_Level[playerid])
			return -1;
	}

	sound_Level[playerid] = amount;

	if(dropspeed > sound_DropSpeed[playerid])
		sound_DropSpeed[playerid] = dropspeed;

	if(sound_Level[playerid] > MAX_SOUND_LEVEL)
		sound_Level[playerid] = MAX_SOUND_LEVEL;

	sound_MakingSound[playerid] = true;

	return 1;
}

// Internal

/*
This function is either called on your Player Update timer (if you have one)
or on a 100ms ptask.

Don't confuse a player update timer with OnPlayerUpdate. My mode relies a lot on
process frames, so each player has a 100ms repeating timer running in order to
process various things like this.
*/

timer UpdatePlayerSoundLevel[100](playerid)
{
	// If the sound level is 0 or below, set it to 0.0 and return.
	// This will just keep happening until the sound level is raised.

	if(sound_Level[playerid] <= 0.0)
	{
		sound_Level[playerid] = 0.0;
		sound_DropSpeed[playerid] = 0.0;
		sound_MakingSound[playerid] = false;

		return;
	}

	// If the sound level is above 0.0, subtract the drop speed value each tick.

	sound_Level[playerid] -= sound_DropSpeed[playerid];

	// If the drop speed is at 0.0, the sound level is maintained until it is
	// manipulated by other means.

	return;
}


// Interface


Float:GetPlayerSoundLevel(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	if(sound_Level[playerid] < 0.0)
		sound_Level[playerid] = 0.0;

	return sound_Level[playerid];
}


// Outside the sound-system class/library

// Checking for different sound triggers
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_FIRE && newkeys & 128)
	{
		if(22 <= GetPlayerWeapon(playerid) <= 38)
		{
			new weaponstate = GetPlayerWeaponState(playerid);

			if((weaponstate != WEAPONSTATE_RELOADING && weaponstate != WEAPONSTATE_NO_BULLETS))
			{
				// When a player fires any firearm, sound level maxes out
				// And drops by 1.0 every tick (Very loud and quick)
				PlayerMakeSound(playerid, 100.0, 5.0);
			}
		}
	}
}

timer AnimationCheck[100](playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerVelocity(playerid, x, y, z);

	if(x + y + z == 0.0)
		return;

	new
		animidx = GetPlayerAnimationIndex(playerid),
		k,
		ud,
		lr;

	GetPlayerKeys(playerid, k, ud, lr);

	printf("%d", animidx);

	if(animidx == 1159) // Crouching
	{
		PlayerMakeSound(playerid, 1.0, 0.1);
	}
	else if(animidx == 1195) // Jumping
	{
		PlayerMakeSound(playerid, 50.0, 2.0);
	}
	else if(animidx == 1231 || animidx == 1196) // Running
	{
		if(k & KEY_WALK) // Walking
		{
			PlayerMakeSound(playerid, 5.0, 0.1);
		}
		else if(k & KEY_SPRINT) // Sprinting
		{
			PlayerMakeSound(playerid, 40.0, 1.0);
		}
		else if(k & KEY_JUMP) // Jump
		{
			PlayerMakeSound(playerid, 50.0, 2.0);
		}
		else
		{
			PlayerMakeSound(playerid, 20.0, 1.0);
		}
	}

	return;
}

// Quick GUI to visualize the sound level
public OnPlayerUpdate(playerid)
{
	new str[128];
	format(str, 128, "Sound: %f", GetPlayerSoundLevel(playerid));
	ShowActionText(playerid, str, 0);
}

// Other stuff to make this work as a filterscript
public OnFilterScriptInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			repeat UpdatePlayerSoundLevel(i);
			repeat AnimationCheck(i);
		}
	}

	return 1;
}

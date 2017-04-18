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


#define MAX_ADMIN_LEVELS			(7)


enum
{
	STAFF_LEVEL_NONE,
	STAFF_LEVEL_GAME_MASTER,
	STAFF_LEVEL_MODERATOR,
	STAFF_LEVEL_ADMINISTRATOR,
	STAFF_LEVEL_LEAD,
	STAFF_LEVEL_DEVELOPER,
	STAFF_LEVEL_SECRET
}


static
				admin_List[MAX_ADMIN * (MAX_PLAYER_NAME + 12)],
				admin_Total,
				admin_Names[MAX_ADMIN_LEVELS][15] =
				{
					"Player",			// 0 (Unused)
					"Game Master",		// 1
					"Moderator",		// 2
					"Administrator",	// 3
					"Overseer",			// 4
					"Developer",		// 5
					""					// 6
				},
				admin_Colours[MAX_ADMIN_LEVELS] =
				{
					0xFFFFFFFF,			// 0 (Unused)
					0x5DFC0AFF,			// 1
					0x33CCFFFF,			// 2
					0x6600FFFF,			// 3
					0xFF0000FF,			// 4
					0xFF3200FF,			// 5
					0x00000000			// 6
				},
				admin_Commands[4][512];

static
				admin_Level[MAX_PLAYERS],
				admin_OnDuty[MAX_PLAYERS],
				admin_PlayerKicked[MAX_PLAYERS];


hook OnScriptInit()
{
	AccountIO_UpdateAdminList();
}

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/admin/core.pwn");

	admin_Level[playerid] = 0;
	admin_OnDuty[playerid] = 0;
	admin_PlayerKicked[playerid] = 0;

	return 1;
}

hook OnPlayerDisconnected(playerid)
{
	dbg("global", CORE, "[OnPlayerDisconnected] in /gamemodes/sss/core/admin/core.pwn");

	admin_Level[playerid] = 0;
	admin_OnDuty[playerid] = 0;
	admin_PlayerKicked[playerid] = 0;
}


/*==============================================================================

	Core

==============================================================================*/


TimeoutPlayer(playerid, reason[])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(admin_PlayerKicked[playerid])
		return 0;

	new ip[16];

	GetPlayerIp(playerid, ip, sizeof(ip));

	BlockIpAddress(ip, 11500);
	admin_PlayerKicked[playerid] = true;

	log("[PART] %p (timeout: %s)", playerid, reason);

	ChatMsgAdmins(1, GREY, " >  %P"C_GREY" timed out, reason: "C_BLUE"%s", playerid, reason);

	return 1;
}

KickPlayer(playerid, reason[], bool:tellplayer = true)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(admin_PlayerKicked[playerid])
		return 0;

	defer KickPlayerDelay(playerid);
	admin_PlayerKicked[playerid] = true;

	log("[PART] %p (kick: %s)", playerid, reason);

	ChatMsgAdmins(1, GREY, " >  %P"C_GREY" kicked, reason: "C_BLUE"%s", playerid, reason);

	if(tellplayer)
		ChatMsgLang(playerid, GREY, "KICKMESSAGE", reason);

	return 1;
}

timer KickPlayerDelay[1000](playerid)
{
	Kick(playerid);
	admin_PlayerKicked[playerid] = false;
}

ChatMsgAdminsFlat(level, colour, string[])
{
	if(level == 0)
	{
		err("MsgAdmins parameter 'level' cannot be 0");
		return 0;
	}

	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new c = 128; c>0; c--)
		{
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;

		foreach(new i : Player)
		{
			if(admin_Level[i] < level)
				continue;

			SendClientMessage(i, colour, string);
			SendClientMessage(i, colour, string2);
		}
	}
	else
	{
		foreach(new i : Player)
		{
			if(admin_Level[i] < level)
				continue;

			SendClientMessage(i, colour, string);
		}
	}

	return 1;
}

TogglePlayerAdminDuty(playerid, toggle)
{
	if(toggle)
	{
		new
			itemid,
			ItemType:itemtype,
			Float:x,
			Float:y,
			Float:z;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		GetPlayerPos(playerid, x, y, z);
		SetPlayerSpawnPos(playerid, x, y, z);

		if(IsItemTypeSafebox(itemtype) || IsItemTypeBag(itemtype))
		{
			if(!IsContainerEmpty(GetItemExtraData(itemid)))
				CreateItemInWorld(itemid, x, y, z - FLOOR_OFFSET);
		}

		Logout(playerid, 0); // docombatlogcheck = 0

		RemovePlayerArmourItem(playerid);

		RemoveAllDrugs(playerid);

		admin_OnDuty[playerid] = true;

		if(GetPlayerGender(playerid) == GENDER_MALE)
			SetPlayerSkin(playerid, 217);

		else
			SetPlayerSkin(playerid, 211);
	}
	else
	{
		admin_OnDuty[playerid] = false;

		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerSpawnPos(playerid, x, y, z);

		SetPlayerPos(playerid, x, y, z);
		LoadPlayerChar(playerid);

		SetPlayerClothes(playerid, GetPlayerClothesID(playerid));

		ToggleNameTagsForPlayer(playerid, false);
	}
}


/*==============================================================================

	Interface

==============================================================================*/


stock SetPlayerAdminLevel(playerid, level)
{
	if(!(0 <= level < MAX_ADMIN_LEVELS))
		return 0;

	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	admin_Level[playerid] = level;

	SetAccountAdminLevel(name, level);

	return 1;
}

stock GetPlayerAdminLevel(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return admin_Level[playerid];
}

stock GetAdminLevelByName(name[MAX_PLAYER_NAME])
{
	new level;

	return level;
}

stock GetAdminTotal()
{
	return AdminIO_GetAdminTotal();
}

stock GetAdminsOnline(from = 1, to = 5)
{
	new count;

	foreach(new i : Player)
	{
		if(from <= admin_Level[i] <= to)
			count++;
	}

	return count;
}

stock GetAdminRankName(rank)
{
	if(!(0 < rank < MAX_ADMIN_LEVELS))
		return admin_Names[0];

	return admin_Names[rank];
}

stock GetAdminRankColour(rank)
{
	if(!(0 < rank < MAX_ADMIN_LEVELS))
		return admin_Colours[0];

	return admin_Colours[rank];
}

stock IsPlayerOnAdminDuty(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return admin_OnDuty[playerid];
}

stock RegisterAdminCommand(level, string[])
{
	if(!(STAFF_LEVEL_GAME_MASTER <= level <= STAFF_LEVEL_LEAD))
	{
		err("Cannot register admin command for level %d", level);
		return 0;
	}

	strcat(admin_Commands[level - 1], string);

	return 1;
}


/*==============================================================================

	Commands

==============================================================================*/


ACMD:acmds[1](playerid, params[])
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid], "/a [message] - Staff chat channel");

	if(admin_Level[playerid] >= 4)
	{
		strcat(gBigString[playerid], "\n\n"C_YELLOW"Lead (level 4)"C_BLUE"\n");
		strcat(gBigString[playerid], admin_Commands[3]);
	}
	if(admin_Level[playerid] >= 3)
	{
		strcat(gBigString[playerid], "\n\n"C_YELLOW"Administrator (level 3)"C_BLUE"\n");
		strcat(gBigString[playerid], admin_Commands[2]);
	}
	if(admin_Level[playerid] >= 2)
	{
		strcat(gBigString[playerid], "\n\n"C_YELLOW"Moderator (level 2)"C_BLUE"\n");
		strcat(gBigString[playerid], admin_Commands[1]);
	}
	if(admin_Level[playerid] >= 1)
	{
		strcat(gBigString[playerid], "\n\n"C_YELLOW"Game Master (level 1)"C_BLUE"\n");
		strcat(gBigString[playerid], admin_Commands[0]);
	}
	
	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "Admin Commands List", gBigString[playerid], "Close", "");

	return 1;
}

ACMD:adminlist[3](playerid, params[])
{
	new
		title[20],
		line[52],
		ret;

	gBigString[playerid][0] = EOS;

	format(title, 20, "Staff (%d)", AdminIO_GetAdminTotal());

	ret = AccountIO_GetAdminList(gBigString[playerid], sizeof(gBigString[]));
	if(ret)
		err("AccountIO_GetAdminList failed, return: %d", ret);

	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_LIST, title, gBigString[playerid], "Close", "");

	return 1;
}

/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_ADMIN_LEVELS			(7)
#define ACCOUNTS_TABLE_ADMINS		"Admins"
#define FIELD_ADMINS_NAME			"name"		// 00
#define FIELD_ADMINS_LEVEL			"level"		// 01


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

enum e_admin_data
{
	admin_Name[MAX_PLAYER_NAME],
	admin_Rank
}


static
				admin_Data[MAX_ADMIN][e_admin_data],
				admin_Total,
				admin_Names[MAX_ADMIN_LEVELS][15] =
				{
					"Player",			// 0 (Unused)
					"Game Master",		// 1
					"Moderator",		// 2
					"Administrator",	// 3
					"Lord of Admins",	// 4
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
				admin_Commands[4][512],
DBStatement:	stmt_AdminLoadAll,
DBStatement:	stmt_AdminExists,
DBStatement:	stmt_AdminInsert,
DBStatement:	stmt_AdminUpdate,
DBStatement:	stmt_AdminDelete,
DBStatement:	stmt_AdminGetLevel;

static
				admin_Level[MAX_PLAYERS],
				admin_OnDuty[MAX_PLAYERS],
				admin_PlayerKicked[MAX_PLAYERS];


hook OnScriptInit()
{
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_ADMINS" (\
		"FIELD_ADMINS_NAME" TEXT,\
		"FIELD_ADMINS_LEVEL" INTEGER)"));

	DatabaseTableCheck(gAccounts, ACCOUNTS_TABLE_ADMINS, 2);

	stmt_AdminLoadAll	= db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_ADMINS" ORDER BY "FIELD_ADMINS_LEVEL" DESC");
	stmt_AdminExists	= db_prepare(gAccounts, "SELECT COUNT(*) FROM "ACCOUNTS_TABLE_ADMINS" WHERE "FIELD_ADMINS_NAME" = ?");
	stmt_AdminInsert	= db_prepare(gAccounts, "INSERT INTO "ACCOUNTS_TABLE_ADMINS" VALUES(?, ?)");
	stmt_AdminUpdate	= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_ADMINS" SET "FIELD_ADMINS_LEVEL" = ? WHERE "FIELD_ADMINS_NAME" = ?");
	stmt_AdminDelete	= db_prepare(gAccounts, "DELETE FROM "ACCOUNTS_TABLE_ADMINS" WHERE "FIELD_ADMINS_NAME" = ?");
	stmt_AdminGetLevel	= db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_ADMINS" WHERE "FIELD_ADMINS_NAME" = ?");

	LoadAdminData();
}

hook OnPlayerConnect(playerid)
{
	admin_Level[playerid] = 0;
	admin_OnDuty[playerid] = 0;
	admin_PlayerKicked[playerid] = 0;

	return 1;
}

hook OnPlayerDisconnected(playerid)
{
	admin_Level[playerid] = 0;
	admin_OnDuty[playerid] = 0;
	admin_PlayerKicked[playerid] = 0;
}


/*==============================================================================

	Core

==============================================================================*/


LoadAdminData()
{
	new
		name[MAX_PLAYER_NAME],
		level;

	stmt_bind_result_field(stmt_AdminLoadAll, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AdminLoadAll, 1, DB::TYPE_INTEGER, level);

	if(stmt_execute(stmt_AdminLoadAll))
	{
		while(stmt_fetch_row(stmt_AdminLoadAll))
		{
			if(level > 0 && !isnull(name))
			{
				admin_Data[admin_Total][admin_Name] = name;
				admin_Data[admin_Total][admin_Rank] = level;

				admin_Total++;
			}
			else
			{
				RemoveAdminFromDatabase(name);
			}
		}
	}

	SortDeepArray(admin_Data, admin_Rank, .order = SORT_DESC);
}

UpdateAdmin(const name[MAX_PLAYER_NAME], level)
{
	if(level == 0)
		return RemoveAdminFromDatabase(name);

	new count;

	stmt_bind_value(stmt_AdminExists, 0, DB::TYPE_STRING, name);
	stmt_bind_result_field(stmt_AdminExists, 0, DB::TYPE_INTEGER, count);
	stmt_execute(stmt_AdminExists);
	stmt_fetch_row(stmt_AdminExists);

	if(count == 0)
	{
		stmt_bind_value(stmt_AdminInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_value(stmt_AdminInsert, 1, DB::TYPE_INTEGER, level);

		if(stmt_execute(stmt_AdminInsert))
		{
			admin_Data[admin_Total][admin_Name] = name;
			admin_Data[admin_Total][admin_Rank] = level;
			admin_Total++;

			SortDeepArray(admin_Data, admin_Rank, .order = SORT_DESC);

			return 1;
		}
	}
	else
	{
		stmt_bind_value(stmt_AdminUpdate, 0, DB::TYPE_INTEGER, level);
		stmt_bind_value(stmt_AdminUpdate, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

		if(stmt_execute(stmt_AdminUpdate))
		{
			for(new i; i < admin_Total; i++)
			{
				if(!strcmp(name, admin_Data[i][admin_Name]))
				{
					admin_Data[i][admin_Rank] = level;

					break;
				}
			}

			SortDeepArray(admin_Data, admin_Rank, .order = SORT_DESC);

			return 1;
		}
	}

	return 1;
}

RemoveAdminFromDatabase(const name[])
{
	stmt_bind_value(stmt_AdminDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_AdminDelete))
	{
		new bool:found = false;

		for(new i; i < admin_Total; i++)
		{
			if(!strcmp(name, admin_Data[i][admin_Name]))
				found = true;

			if(found && i < MAX_ADMIN-1)
			{
				format(admin_Data[i][admin_Name], 24, admin_Data[i+1][admin_Name]);
				admin_Data[i][admin_Rank] = admin_Data[i+1][admin_Rank];
			}
		}

		admin_Total--;

		return 1;
	}

	return 0;
}

CheckAdminLevel(playerid)
{
	new name[MAX_PLAYER_NAME];

	for(new i; i < admin_Total; i++)
	{
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);

		if(!strcmp(name, admin_Data[i][admin_Name]))
		{
			admin_Level[playerid] = admin_Data[i][admin_Rank];
			break;
		}
	}
}

TimeoutPlayer(playerid, const reason[])
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

KickPlayer(playerid, const reason[], bool:tellplayer = true)
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

ChatMsgAdminsFlat(level, colour, const message[])
{
	if(level == 0)
	{
		err("MsgAdmins parameter 'level' cannot be 0");
		return 0;
	}

	if(strlen(message) > 127)
	{
		new
			string1[128],
			string2[128],
			splitpos;

		for(new c = 128; c>0; c--)
		{
			if(message[c] == ' ' || message[c] ==  ',' || message[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(string1, message, splitpos);
		strcat(string2, message[splitpos]);

		foreach(new i : Player)
		{
			if(admin_Level[i] < level)
				continue;

			SendClientMessage(i, colour, string1);
			SendClientMessage(i, colour, string2);
		}
	}
	else
	{
		foreach(new i : Player)
		{
			if(admin_Level[i] < level)
				continue;

			SendClientMessage(i, colour, message);
		}
	}

	return 1;
}

TogglePlayerAdminDuty(playerid, toggle)
{
	if(toggle)
	{
		new
			Item:itemid,
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
			new Container:containerid;
			GetItemExtraData(itemid, _:containerid);

			if(!IsContainerEmpty(containerid))
				CreateItemInWorld(itemid, x, y, z - ITEM_FLOOR_OFFSET);
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

	UpdateAdmin(name, level);

	return 1;
}

stock GetPlayerAdminLevel(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return admin_Level[playerid];
}

stock GetAdminLevelByName(const name[MAX_PLAYER_NAME])
{
	new level;

	stmt_bind_value(stmt_AdminGetLevel, 0, DB::TYPE_STRING, name);
	stmt_bind_result_field(stmt_AdminGetLevel, 1, DB::TYPE_INTEGER, level);
	stmt_execute(stmt_AdminGetLevel);
	stmt_fetch_row(stmt_AdminGetLevel);

	return level;
}

stock GetAdminTotal()
{
	return admin_Total;
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

stock RegisterAdminCommand(level, const string[])
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
	
	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Admin Commands List", gBigString[playerid], "Close", "");

	return 1;
}

ACMD:adminlist[3](playerid, params[])
{
	new
		title[20],
		line[52];

	gBigString[playerid][0] = EOS;

	format(title, 20, "Staff (%d)", admin_Total);

	for(new i; i < admin_Total; i++)
	{
		if(admin_Data[i][admin_Rank] == STAFF_LEVEL_SECRET)
			continue;

		format(line, sizeof(line), "%s %C(%d-%s)\n",
			admin_Data[i][admin_Name],
			admin_Colours[admin_Data[i][admin_Rank]],
			admin_Data[i][admin_Rank],
			admin_Names[admin_Data[i][admin_Rank]]);

		if(GetPlayerIDFromName(admin_Data[i][admin_Name]) != INVALID_PLAYER_ID)
			strcat(gBigString[playerid], " >  ");

		strcat(gBigString[playerid], line);
	}

	Dialog_Show(playerid, DIALOG_STYLE_LIST, title, gBigString[playerid], "Close", "");

	return 1;
}

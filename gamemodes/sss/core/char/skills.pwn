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

		Rough usage:
		Every time a player *starts* a skill oriented action, call
		GetPlayerSkillTimeModifier and subtract the return value from the time.
		Every time a player *finishes* a skill oriented action, call
		PlayerGainSkillExperience with the skill name to level them up a bit.


==============================================================================*/


#include <YSI\y_hooks>


#define MAX_PLAYER_SKILLS	(50)
#define MAX_SKILL_NAME		(32)


enum E_SKILL_DATA
{
			skl_name[MAX_SKILL_NAME],
Float:		skl_amount
}

enum E_SKILL_LEVEL_DATA
{
			skl_level[13],
			skl_colour[9],
Float:		skl_bound
}

static
			skl_PlayerSkills[MAX_PLAYERS][MAX_PLAYER_SKILLS][E_SKILL_DATA],
			skl_PlayerSkillCount[MAX_PLAYERS],
PlayerText:	skl_PlayerNotification,
			skl_InventoryItem[MAX_PLAYERS];

static
				skl_Levels[5][E_SKILL_LEVEL_DATA] = {
					{"Novice",			C_YELLOW,	0.1},
					{"Adequate",		C_GREEN,	0.2},
					{"Intermediate",	C_ORANGE,	0.33},
					{"Experienced",		C_BLUE,		0.66},
					{"Master",			C_PINK,		0.9}
				};


hook OnPlayerConnect(playerid)
{
	skl_PlayerNotification			=CreatePlayerTextDraw(playerid, 320.000000, 430.000000, "+Fishing");
	PlayerTextDrawAlignment			(playerid, skl_PlayerNotification, 2);
	PlayerTextDrawBackgroundColor	(playerid, skl_PlayerNotification, 255);
	PlayerTextDrawFont				(playerid, skl_PlayerNotification, 1);
	PlayerTextDrawLetterSize		(playerid, skl_PlayerNotification, 0.400000, 1.399999);
	PlayerTextDrawColor				(playerid, skl_PlayerNotification, 16711935);
	PlayerTextDrawSetOutline		(playerid, skl_PlayerNotification, 1);
	PlayerTextDrawSetProportional	(playerid, skl_PlayerNotification, 1);
}

stock PlayerGainSkillExperience(playerid, skillname[], Float:mult = 0.0)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	new cell = _skl_SkillNameToID(playerid, skillname);

	if(cell == -1)
	{
		cell = skl_PlayerSkillCount[playerid]++;
		strcat(skl_PlayerSkills[playerid][cell][skl_name], skillname, MAX_SKILL_NAME);
	}

	// s-curve(ish) formula
	skl_PlayerSkills[playerid][cell][skl_amount] += 0.001 + mult * (
			(3 * floatpower(skl_PlayerSkills[playerid][cell][skl_amount], 2) -
				2 * floatpower(skl_PlayerSkills[playerid][cell][skl_amount], 3)));

	PlayerTextDrawSetString(playerid, skl_PlayerNotification, sprintf("+%s", skillname));
	PlayerTextDrawShow(playerid, skl_PlayerNotification);
	defer skl_HideUI(playerid);

	return 1;
}

timer skl_HideUI[5000](playerid)
{
	PlayerTextDrawHide(playerid, skl_PlayerNotification);
}

stock GetPlayerSkillTimeModifier(playerid, time, skillname[])
{
	if(!IsPlayerConnected(playerid))
		return time;

	new cell = _skl_SkillNameToID(playerid, skillname);

	if(cell != -1)
		return floatround(time - time * (0.5 * skl_PlayerSkills[playerid][cell][skl_amount]));

	return time;
}

stock Float:GetPlayerSkillValue(playerid, skillname[])
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	new cell = _skl_SkillNameToID(playerid, skillname);

	if(cell != -1)
		return skl_PlayerSkills[playerid][cell][skl_amount];

	return 0.0;
}

_skl_SkillNameToID(playerid, skillname[])
{
	for(new i; i < skl_PlayerSkillCount[playerid]; i++)
	{
		if(!strcmp(skillname, skl_PlayerSkills[playerid][i][skl_name]))
			return i;
	}

	return -1;
}

hook OnPlayerSave(playerid, filename[])
{
	if(skl_PlayerSkillCount[playerid] == 0)
		return Y_HOOKS_CONTINUE_RETURN_1;

	new
		data[MAX_PLAYER_SKILLS * (MAX_SKILL_NAME + 2)],
		ptr,
		tmp;

	for(new i; i < skl_PlayerSkillCount[playerid]; i++)
	{
		tmp = 0;
		do {
			data[ptr++] = skl_PlayerSkills[playerid][i][skl_name][tmp];
		}
		while(skl_PlayerSkills[playerid][i][skl_name][tmp++] != EOS);

		data[ptr++] = _:skl_PlayerSkills[playerid][i][skl_amount];
		log("skill value for '%s': %f", skl_PlayerSkills[playerid][i][skl_name], skl_PlayerSkills[playerid][i][skl_amount]);
	}

	modio_push(filename, _T<S,K,I,L>, ptr, data);

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerLoad(playerid, filename[])
{
	new
		data[MAX_PLAYER_SKILLS * (MAX_SKILL_NAME + 2)],
		length,
		ptr;

	length = modio_read(filename, _T<S,K,I,L>, sizeof(data), data);

	skl_PlayerSkillCount[playerid] = 0;

	for(new i; i < length; i++)
	{
		if(32 < data[i] < 256)
		{
			skl_PlayerSkills[playerid][skl_PlayerSkillCount[playerid]][skl_name][ptr++] = data[i];
		}
		else if(data[i] == EOS)
		{
			// pass the EOS onto the skill amount cell, add an EOS to skill name
			i++;
			skl_PlayerSkills[playerid][skl_PlayerSkillCount[playerid]][skl_name][ptr++] = EOS;
			ptr = 0;

			if(_skl_SkillNameToID(playerid, skl_PlayerSkills[playerid][skl_PlayerSkillCount[playerid]][skl_name]) != -1)
			{
				err("Skill '%s' duplicated in player data", skl_PlayerSkills[playerid][skl_PlayerSkillCount[playerid]][skl_name]);
				continue;
			}

			skl_PlayerSkills[playerid][skl_PlayerSkillCount[playerid]][skl_amount] = Float:data[i];
			skl_PlayerSkillCount[playerid]++;
		}
	}

	for(new i; i < skl_PlayerSkillCount[playerid]; i++)
	{
		log("skill '%s' value: %f", skl_PlayerSkills[playerid][i][skl_name], skl_PlayerSkills[playerid][i][skl_amount]);
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerOpenInventory(playerid)
{
	skl_InventoryItem[playerid] = AddInventoryListItem(playerid, "Skills");
}

hook OnPlayerSelectExtraItem(playerid, item)
{
	if(item == skl_InventoryItem[playerid])
	{
		skl_ShowSkillList(playerid);
	}
}

skl_ShowSkillList(playerid)
{
	gBigString[playerid][0] = EOS;

	new
		skillname[64],
		level,
		levelname[13];

	for(new i; i < skl_PlayerSkillCount[playerid]; i++)
	{
		skillname[0] = EOS;
		strcat(skillname, skl_PlayerSkills[playerid][i][skl_name]);

		for(level = 0; level < 5; level++)
		{
			if(skl_PlayerSkills[playerid][i][skl_amount] < skl_Levels[level][skl_bound])
				break;
		}

		levelname[0] = EOS;
		strcat(levelname, skl_Levels[level][skl_level], 13);

		format(gBigString[playerid], sizeof(gBigString[]), "%s%s%s (%s)\n",
			gBigString[playerid],
			skl_Levels[level][skl_colour],
			skillname,
			skl_Levels[level][skl_level]);
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext, listitem, response
		DisplayPlayerInventory(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Skills", gBigString[playerid], "Back", "");

	return 1;
}

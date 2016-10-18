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
#define MAX_SKILL_NAME		(16)


enum E_SKILL_DATA
{
		skl_name[MAX_SKILL_NAME],
Float:	skl_amount
}

static
		skl_PlayerSkills[MAX_PLAYERS][MAX_PLAYER_SKILLS][E_SKILL_DATA],
		skl_PlayerSkillCount[MAX_PLAYERS];


stock PlayerGainSkillExperience(playerid, skillname[])
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
	skl_PlayerSkills[playerid][cell][skl_amount] += 0.001 + 0.001 * (
			(3 * floatpower(skl_PlayerSkills[playerid][cell][skl_amount], 2) -
				2 * floatpower(skl_PlayerSkills[playerid][cell][skl_amount], 3)));

	return 1;
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
		printf("skill value for '%s': %f", skl_PlayerSkills[playerid][i][skl_name], skl_PlayerSkills[playerid][i][skl_amount]);
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

	for(new i; i < length; i++)
	{
		if(32 < data[i] < 256)
		{
			skl_PlayerSkills[playerid][skl_PlayerSkillCount[playerid]][skl_name][ptr++] = data[i];
		}
		else if(data[i] == EOS)
		{
			i++; // pass the EOS onto the skill amount cell
			skl_PlayerSkills[playerid][skl_PlayerSkillCount[playerid]][skl_name][ptr++] = EOS;
			skl_PlayerSkills[playerid][skl_PlayerSkillCount[playerid]][skl_amount] = Float:data[i];
			skl_PlayerSkillCount[playerid]++;
			ptr = 0;
		}
	}

	for(new i; i < skl_PlayerSkillCount[playerid]; i++)
	{
		printf("skill '%s' value: %f", skl_PlayerSkills[playerid][i][skl_name], skl_PlayerSkills[playerid][i][skl_amount]);
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

CMD:skills(playerid, params[])
{
	gBigString[playerid][0] = EOS;

	for(new i; i < skl_PlayerSkillCount[playerid]; i++)
	{
		format(gBigString[playerid], sizeof(gBigString[]), "%s'%s': %.2f%% Complete",
			gBigString[playerid],
			skl_PlayerSkills[playerid][i][skl_name],
			skl_PlayerSkills[playerid][i][skl_amount] * 100);
	}

	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Skill Values (For debugging!)", gBigString[playerid], "Close", "");

	return 1;
}
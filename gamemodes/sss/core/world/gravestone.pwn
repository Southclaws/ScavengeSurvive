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


#define MAX_DEATH_REASON (128)


enum
{
	torso_canHarvest,				// 0
	torso_spawnTime,				// 1
	torso_nameLen,					// 2
	torso_name[MAX_PLAYER_NAME],
	torso_reasonLen,
	torso_reason[MAX_DEATH_REASON],
	torso_end
}


stock CreateGravestone(playerid, reason[], Float:x, Float:y, Float:z, Float:rz, Float:zoffset = ITEM_BUTTON_OFFSET)
{
	new
		name[MAX_PLAYER_NAME],
		itemid;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	itemid = CreateItem(item_Torso, x, y, z, 0.0, 0.0, rz, .zoffset = zoffset);

	SetItemArrayDataLength(itemid, 0);

	AppendItemArrayCell(itemid, 1); // canHarvest
	AppendItemArrayCell(itemid, gettime()); // spawnTime

	AppendItemArrayCell(itemid, strlen(name)); // nameLen
	AppendItemArray(itemid, name, strlen(name)); // name

	AppendItemArrayCell(itemid, strlen(reason)); // reasonLen
	AppendItemArray(itemid, reason, strlen(reason)); // reason

	return itemid;
}

ShowTorsoDetails(playerid, itemid)
{
	if(GetItemArrayDataSize(itemid) < 3)
		return 0;

	new
		arraydata[torso_end],
		name[MAX_PLAYER_NAME],
		reason[MAX_DEATH_REASON];

	GetItemArrayData(itemid, arraydata);

	memcpy(name, arraydata[3], 0, arraydata[2] * 4);
	memcpy(reason, arraydata[3 + arraydata[2] + 1], 0, arraydata[3 + arraydata[2]] * 4);

	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, name, reason, "Close", "");

	return 1;
}

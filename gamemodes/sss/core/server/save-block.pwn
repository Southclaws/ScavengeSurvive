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


#define MAX_SAVEBLOCK	(64)


enum E_SAVEBLOCK_AREA
{
		saveblock_areaId,
Float:	saveblock_resetX,
Float:	saveblock_resetY,
Float:	saveblock_resetZ
}

new
		saveblock_Data[MAX_SAVEBLOCK][E_SAVEBLOCK_AREA],
		saveblock_Total;


stock CreateSaveBlockArea(areaid, Float:resetX, Float:resetY, Float:resetZ)
{
	saveblock_Data[saveblock_Total][saveblock_areaId] = areaid;
	saveblock_Data[saveblock_Total][saveblock_resetX] = resetX;
	saveblock_Data[saveblock_Total][saveblock_resetY] = resetY;
	saveblock_Data[saveblock_Total][saveblock_resetZ] = resetZ;

	return saveblock_Total++;
}

SaveBlockAreaCheck(&Float:x, &Float:y, &Float:z)
{
	for(new i; i < saveblock_Total; i++)
	{
		if(IsPointInDynamicArea(saveblock_Data[i][saveblock_areaId], x, y, z))
		{
			x = saveblock_Data[i][saveblock_resetX];
			y = saveblock_Data[i][saveblock_resetY];
			z = saveblock_Data[i][saveblock_resetZ];
			return 1;
		}
	}

	return 0;
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerEnterDynArea] in /gamemodes/sss/core/server/save-block.pwn");

	for(new i; i < saveblock_Total; i++)
	{
		if(areaid == saveblock_Data[i][saveblock_areaId])
		{
			ChatMsg(playerid, YELLOW, " >  You have entered a save-block area. If you quit while in this area, your character will be moved to a nearby location.");
		}
	}
}

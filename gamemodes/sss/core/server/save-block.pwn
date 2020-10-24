/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


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
	for(new i; i < saveblock_Total; i++)
	{
		if(areaid == saveblock_Data[i][saveblock_areaId])
		{
			ChatMsg(playerid, YELLOW, " >  You have entered a save-block area. If you quit while in this area, your character will be moved to a nearby location.");
		}
	}
}

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


#include <YSI_Coding\y_hooks>


#define DIRECTORY_DEFENCE	DIRECTORY_MAIN"defence/"


forward OnDefenceLoad(Item:itemid, active, geid[], data[], length);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_DEFENCE);
}

hook OnGameModeInit()
{
	LoadItems(DIRECTORY_DEFENCE, "OnDefenceLoad");
}

hook OnDefenceCreate(Item:itemid)
{
	SaveDefenceItem(itemid);
}

hook OnItemDestroy(Item:itemid)
{
	if(IsItemTypeDefence(GetItemType(itemid)))
		RemoveDefenceItem(itemid);
}

hook OnItemHitPointsUpdate(Item:itemid, oldvalue, newvalue)
{
	if(IsItemTypeDefence(GetItemType(itemid)))
		SaveDefenceItem(itemid);
}

hook OnDefenceDestroy(Item:itemid)
{
	RemoveDefenceItem(itemid);
}

hook OnDefenceModified(Item:itemid)
{
	SaveDefenceItem(itemid);
}

hook OnDefenceMove(Item:itemid)
{
	SaveDefenceItem(itemid);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveDefenceItem(Item:itemid, bool:active = true)
{
	if(!IsValidItem(itemid))
		return 1;

	SaveWorldItem(itemid, DIRECTORY_DEFENCE, active, true);

	return 0;
}

public OnDefenceLoad(Item:itemid, active, geid[], data[], length)
{
	ActivateDefenceItem(itemid);

	return 1;
}

stock RemoveDefenceItem(Item:itemid)
{
	RemoveSavedItem(itemid, DIRECTORY_DEFENCE);
}

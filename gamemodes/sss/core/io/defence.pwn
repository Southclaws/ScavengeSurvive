/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


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

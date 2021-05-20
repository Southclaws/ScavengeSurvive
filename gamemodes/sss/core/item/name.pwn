/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>

hook OnItemCreateInWorld(Item:itemid)
{
	new tmp[5 + MAX_ITEM_NAME + MAX_ITEM_TEXT + 1];
	GetItemName(Item:itemid, tmp);
	SetItemLabel(Item:itemid, tmp);
}

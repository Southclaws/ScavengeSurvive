/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
#include <zcmd>
#include <streamer>

public OnFilterScriptInit()
{
	DropSupplyCrate(0.0, 0.0, 2.0, 50.0);
}


static
	sup_ObjCrate1 = INVALID_OBJECT_ID,
	sup_ObjCrate2 = INVALID_OBJECT_ID,
	sup_ObjPara = INVALID_OBJECT_ID;


DropSupplyCrate(Float:x, Float:y, Float:z, Float:height)
{
	sup_ObjCrate1 = CreateDynamicObject(3799, x, y, z + height, 0.0, 0.0, 0.0, .streamdistance = 10000),
	sup_ObjCrate2 = CreateDynamicObject(3799, x + 0.01, y + 0.01, z + height + 2.4650, 0.0, 180.0, 0.0),
	sup_ObjPara = CreateDynamicObject(18849, x, y, z + height + 8.0, 0.0, 0.0, 0.0),

	MoveDynamicObject(sup_ObjCrate1, x, y, z, 5.0, 0.0, 0.0, 720.0);
	MoveDynamicObject(sup_ObjCrate2, x + 0.01, y + 0.01, z + 2.4650, 5.0, 0.0, 180.0, 720.0);
	MoveDynamicObject(sup_ObjPara, x, y, z - 10.0, 5.0, 0.0, 0.0, 720.0);
}

public OnDynamicObjectMoved(objectid)
{
	if(objectid == sup_ObjPara)
	{
		DestroyDynamicObject(sup_ObjPara);
		sup_ObjPara = INVALID_OBJECT_ID;
	}

	return CallLocalFunction("fwk_OnDynamicObjectMoved", "d", objectid);
}
#if defined _ALS_OnDynamicObjectMoved
	#undef OnDynamicObjectMoved
#else
	#define _ALS_OnDynamicObjectMoved
#endif
#define OnDynamicObjectMoved fwk_OnDynamicObjectMoved
forward fwk_OnDynamicObjectMoved(objectid);

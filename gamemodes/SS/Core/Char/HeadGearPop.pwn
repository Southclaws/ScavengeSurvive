#include <YSI\y_hooks>


hook OnPlayerGiveDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(bodypart == BODY_PART_HEAD)
	{
		if(GetPlayerHat(playerid) != -1)
			PopHat(playerid);

		if(GetPlayerMask(playerid) != -1)
			PopMask(playerid);
	}

	return 1;
}

PopHat(playerid)
{
	new
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		objectid;

	itemtype = GetItemTypeFromHat(GetPlayerHat(playerid));
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	objectid = CreateDynamicObject(GetItemTypeModel(itemtype), x, y, z + 0.8, 0.0, 0.0, r);
	MoveDynamicObject(objectid, x, y, z - FLOOR_OFFSET, 5.0, 0.0, 0.0, r + 360.0);
	defer pop_DropHat(objectid, itemtype, _:x, _:y, _:z, _:r);
}

PopMask(playerid)
{
	new
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		objectid;

	itemtype = GetItemTypeFromMask(GetPlayerMask(playerid));
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	objectid = CreateDynamicObject(GetItemTypeModel(itemtype), x, y, z + 0.8, 0.0, 0.0, r);
	MoveDynamicObject(objectid, x, y, z - FLOOR_OFFSET, 5.0, 0.0, 0.0, r + 360.0);
	defer pop_DropMask(objectid, itemtype, _:x, _:y, _:z, _:r);
}


timer pop_DropHat[500](o, ItemType:it, Float:x, Float:y, Float:z, Float:r)
{
	DestroyDynamicObject(o);
	CreateItem(it, x, y, z - FLOOR_OFFSET, 0.0, 0.0, r, .zoffset = FLOOR_OFFSET);
}

timer pop_DropMask[500](o, ItemType:it, Float:x, Float:y, Float:z, Float:r)
{
	DestroyDynamicObject(o);
	CreateItem(it, x, y, z - FLOOR_OFFSET, 0.0, 0.0, r, .zoffset = FLOOR_OFFSET);
}

CMD:pophat(playerid, params[])
{
	PopHat(playerid);
	return 1;
}

CMD:popmask(playerid, params[])
{
	PopMask(playerid);
	return 1;
}

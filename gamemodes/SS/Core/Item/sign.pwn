public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Sign)
	{
		new
			tmpsign,
			Float:x,
			Float:y,
			Float:z,
			Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		DestroyItem(itemid);
		tmpsign = CreateSign("I am a sign.", x + floatsin(-a, degrees), y + floatcos(-a, degrees), z - 1.0, a - 90.0);
		EditSign(playerid, tmpsign);

		return 1;
	}
	return CallLocalFunction("sgn_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem sgn_OnPlayerUseItem
forward sgn_OnPlayerUseItem(playerid, itemid);

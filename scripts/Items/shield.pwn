new ItemType:item_Shield = INVALID_ITEM_TYPE;


public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Shield)
	{
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
		defer shield_Down(playerid, itemid);
		return 1;
	}
    return CallLocalFunction("shd_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem shd_OnPlayerUseItem
forward shd_OnPlayerUseItem(playerid, itemid);

timer shield_Down[400](playerid, itemid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:angle;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, angle);

	RemoveCurrentItem(playerid);
	SetItemPos(itemid, x + (0.5 * floatsin(-angle, degrees)), y + (0.5 * floatcos(-angle, degrees)), z - 0.2);
	SetItemRot(itemid, 90.0, 0.0, 180.0 + angle);
}
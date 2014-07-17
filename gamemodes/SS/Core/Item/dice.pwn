new
	Float:DiceRotationSets[6][2]=
	{
		{0.0, 0.0},		// 1
		{0.0, 90.0},	// 2
		{270.0, 0.0},	// 3
		{90.0, 0.0},	// 4
		{0.0, 270.0},	// 5
		{180.0, 0.0}	// 6
	};


public OnPlayerDroppedItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Dice)
	{
		new Float:angle;

		GetPlayerFacingAngle(playerid, angle);

		defer RollDice(itemid, angle);
	}

	#if defined die_OnPlayerDroppedItem
		return die_OnPlayerDroppedItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerDroppedItem
	#undef OnPlayerDroppedItem
#else
	#define _ALS_OnPlayerDroppedItem
#endif
#define OnPlayerDroppedItem die_OnPlayerDroppedItem
#if defined die_OnPlayerDroppedItem
	forward die_OnPlayerDroppedItem(playerid, itemid);
#endif


timer RollDice[50](itemid, Float:direction)
{
	new
		Float:x,
		Float:y,
		Float:z,
		objectid = GetItemObjectID(itemid),
		side = random(6);

	GetItemPos(itemid, x, y, z);

	x += (0.4 * floatsin(-direction, degrees));
	y += (0.4 * floatcos(-direction, degrees));
	z += 0.136;

	SetItemRot(itemid, DiceRotationSets[5 - side][0], DiceRotationSets[5 - side][1], random(360) * 1.0);

	MoveDynamicObject(objectid, x, y, z, 2.0, DiceRotationSets[side][0], DiceRotationSets[side][1], random(360) * 1.0);

	defer UpdateDiceItemPos(itemid, x, y, z);
}

timer UpdateDiceItemPos[500](itemid, Float:x, Float:y, Float:z)
{
	SetItemPos(itemid, x, y, z, .zoffset = ITEM_BUTTON_OFFSET);
}

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


hook OnPlayerDroppedItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerDroppedItem] in /gamemodes/sss/core/item/dice.pwn");

	if(GetItemType(itemid) == item_Dice)
	{
		new Float:angle;

		GetPlayerFacingAngle(playerid, angle);

		defer RollDice(itemid, angle);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

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
	SetItemPos(itemid, x, y, z);
}

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


stock CreateTimedDynamicObject(model, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, lifetime)
{
	defer DestroyDynamicObject_Delay(CreateDynamicObject(model, x, y, z, rx, ry, rz), lifetime);
}

timer DestroyDynamicObject_Delay[lifetime](objectid, lifetime)
{
	#pragma unused lifetime
	DestroyDynamicObject(objectid);
}

/*
	Credits to Emmet_

	http://forum.sa-mp.com/showpost.php?p=2884743&postcount=4256
*/
stock MoveObjectEx(objectid, time, Float:x, Float:y, Float:z, Float:rx = -1000.0, Float:ry = -1000.0, Float:rz = -1000.0)
{
	if (!IsValidObject(objectid))
		return 0;

	static
		Float:fX,
		Float:fY,
		Float:fZ,
		Float:fDist;
		
	GetObjectPos(objectid, fX, fY, fZ);
	fDist = floatsqroot(((fX - x) * (fX - x)) + ((fY - y) * (fY - y)) + ((fZ - z) * (fZ - z))); 

	MoveObject(objectid, x, y, z, floatdiv(floatsqroot(x + y + z), time / floatmul(fDist, 15)), rx, ry, rz);
	return 1;
}

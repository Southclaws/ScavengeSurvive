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


static det_LineIds[MAX_DETFIELD][8];


hook OnFilterScriptInit()
{
	dbg("global", CORE, "[OnFilterScriptInit] in /gamemodes/sss/core/admin/detfield-draw.pwn");

	for(new i; i < MAX_DETFIELD; i++)
	{
		det_LineIds[i] = {
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID};
	}
}

//RedrawAllDetfieldPolys()
CMD:rdp(playerid, params[])
{
	foreach(new i : det_Index)
	{
		DestroyDetfieldPoly(i);
		CreateDetfieldPoly(i);
	}

	return 1;
}

stock CreateDetfieldPoly(detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	new
		Float:points[10],
		Float:minz,
		Float:maxz;

	GetDetectionFieldPoints(detfieldid, points);
	GetDetectionFieldMinZ(detfieldid, minz);
	GetDetectionFieldMaxZ(detfieldid, maxz);

	for(new i; i < 8; i += 2)
	{
		det_LineIds[detfieldid][i + 0] = CreateLineSegment(19087, 2.46,
			points[i + 0], points[i + 1], minz,
			points[i + 2], points[i + 3], minz,
			.RotX = 90.0, .objlengthoffset = -(2.46/2));

		det_LineIds[detfieldid][i + 1] = CreateLineSegment(19087, 2.46,
			points[i + 0], points[i + 1], maxz,
			points[i + 2], points[i + 3], maxz,
			.RotX = 90.0, .objlengthoffset = -(2.46/2));
	}

	return 1;
}

stock DestroyDetfieldPoly(detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	for(new i; i < 8; i++)
	{
		DestroyLineSegment(det_LineIds[detfieldid][i]);
		det_LineIds[detfieldid][i] = INVALID_LINE_SEGMENT_ID;
	}

	return 1;
}

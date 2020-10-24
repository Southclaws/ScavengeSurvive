/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static det_LineIds[MAX_DETFIELD][8];


hook OnFilterScriptInit()
{
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

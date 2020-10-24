/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#define FILTERSCIPT


#include <a_samp>
#include <sscanf2>
#include <streamer>
#include <YSI\y_iterate>
#include <YSI\y_hooks>

#include <SIF\Button.pwn>

#include <Balloon>
#include <Line>
#include <Zipline>
#include <Ladder>

#include <zcmd>


#define LINE_MODEL		18647	// 19087 < values for rope line
#define LINE_LENGTH		2.0		// 2.46
#define LINE_ROT		0.0		// 90.0
#define LINE_OFFSET		0.0		// -(2.46/2)


//


new
	gBalloonID,
	gLineSegmentID,
	gZiplineID,
	gLadderID;


//


public OnFilterScriptInit()
{
	/*
		Lets start off with a fun balloon!
	*/
	gBalloonID = CreateBalloon(-19.7329, 27.1608, 2.0983, 0.0, -84.8372, -223.6261, 79.1079, 0.0);

	/*
		Now, a long neon leash for the player
	*/
	gLineSegmentID = CreateLineSegment(LINE_MODEL, LINE_LENGTH, -16.0481, 16.9945, 3.6839, -8.4105, 35.9623, 3.5245, LINE_ROT, .objlengthoffset = LINE_OFFSET, .maxlength = 1000.0);

	/*
		Everyone loves ziplines!
	*/
	gZiplineID = CreateZipline(-83.7162, -221.5881, 78.9914, 8.9665, 15.2893, 6.6984);

	/*
		And a ladder to get down if you are too scared to zipline!
	*/
	gLadderID = CreateLadder(-84.9103, -227.5974, 40.2242, 79.1079, 0.0);

	return 1;
}

public OnPlayerUpdate(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	SetLineSegmentDest(0, x, y, z);

	return 1;
}


/*==============================================================================

	Balloon manipulation

==============================================================================*/


CMD:isvalidballoon(playerid, params[])
{
	new str[128];

	format(str, 128, "Is valid balloon: %d", IsValidBalloon(gBalloonID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:getballoonobjectid(playerid, params[])
{
	new str[128];

	format(str, 128, "objectid: %d", GetBalloonObjectID(gBalloonID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:getballoonstartbuttonid(playerid, params[])
{
	new str[128];

	format(str, 128, "start button ID: %d", GetBalloonStartButtonID(gBalloonID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:getballoonendbuttonid(playerid, params[])
{
	new str[128];

	format(str, 128, "end button ID: %d", GetBalloonEndButtonID(gBalloonID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:getballoonstartpos(playerid, params[])
{
	new
		str[128],
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetBalloonStartPos(gBalloonID, x, y, z, r);

	format(str, 128, "Position: %f, %f, %f, %f", x, y, z, r);
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:getballoonendpos(playerid, params[])
{
	new
		str[128],
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetBalloonEndPos(gBalloonID, x, y, z, r);

	format(str, 128, "Position: %f, %f, %f, %f", x, y, z, r);
	SendClientMessage(playerid, -1, str);

	return 1;
}


/*==============================================================================

	Line manipulation

==============================================================================*/


CMD:isvalidlinesegment(playerid, params[])
{
	new
		str[128];

	format(str, 128, "Valid: %d", IsValidLineSegment(gLineSegmentID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:linesegmentmodel(playerid, params[])
{
	new str[128];

	format(str, 128, "Data: %d", GetLineSegmentModel(gLineSegmentID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setlinesegmentmodel(playerid, params[])
{
	new
		modelid,
		Float:objlength,
		Float:objlengthoffset;

	if(sscanf(params, "dff", modelid, objlength, objlengthoffset))
	{
		SendClientMessage(playerid, -1, "Parameters: modelid, objlength, objlengthoffset");
		return 1;
	}

	SetLineSegmentModel(gLineSegmentID, modelid, objlength, objlengthoffset);

	return 1;
}

CMD:linesegmentobjectcount(playerid, params[])
{
	new str[128];

	format(str, 128, "Data: %d", GetLineSegmentObjectCount(gLineSegmentID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:linesegmentobjectlength(playerid, params[])
{
	new str[128];

	format(str, 128, "Data: %d", GetLineSegmentObjectLength(gLineSegmentID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setlinesegmentobjectlength(playerid, params[])
{
	new
		Float:objlength;

	if(sscanf(params, "f", objlength))
	{
		SendClientMessage(playerid, -1, "Parameters: objlength");
		return 1;
	}

	SetLineSegmentObjectLength(gLineSegmentID, objlength);

	return 1;
}

CMD:linesegmentobjectoffset(playerid, params[])
{
	new str[128];

	format(str, 128, "Data: %d", GetLineSegmentObjectOffset(gLineSegmentID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setlinesegmentobjectoffset(playerid, params[])
{
	new Float:objlengthoffset;

	if(sscanf(params, "f", objlengthoffset))
	{
		SendClientMessage(playerid, -1, "Parameters: objlengthoffset");
		return 1;
	}

	SetLineSegmentObjectOffset(gLineSegmentID, objlengthoffset);

	return 1;
}

CMD:linesegmentmaxlength(playerid, params[])
{
	new str[128];

	format(str, 128, "Data: %d", GetLineSegmentMaxLength(gLineSegmentID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setlinesegmentmaxlength(playerid, params[])
{
	new
		Float:maxlength;

	if(sscanf(params, "f", maxlength))
	{
		SendClientMessage(playerid, -1, "Parameters: maxlength");
		return 1;
	}

	SetLineSegmentMaxLength(gLineSegmentID, maxlength);

	return 1;
}

CMD:linesegmentpoint(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetLineSegmentPoint(gLineSegmentID, x, y, z);

	new str[128];

	format(str, 128, "Data: %d", x, y, z);
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setlinesegmentpoint(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	SetLineSegmentPoint(gLineSegmentID, x, y, z);

	return 1;
}

CMD:linesegmentdest(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetLineSegmentDest(gLineSegmentID, x, y, z);

	new str[128];

	format(str, 128, "Data: %d", x, y, z);
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setlinesegmentdest(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	SetLineSegmentDest(gLineSegmentID, x, y, z);

	return 1;
}

CMD:linesegmentmodelangles(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetLineSegmentModelAngles(gLineSegmentID, x, y, z);

	new str[128];

	format(str, 128, "Data: %f, %f, %f", x, y, z);
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setlinesegmentmodelangles(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	if(sscanf(params, "fff", x, y, z))
	{
		SendClientMessage(playerid, -1, "Parameters: x, y, z");
		return 1;
	}

	SetLineSegmentModelAngles(gLineSegmentID, x, y, z);

	return 1;
}

CMD:linesegmentworld(playerid, params[])
{
	new str[128];

	format(str, 128, "Data: %d", GetLineSegmentWorld(gLineSegmentID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setlinesegmentworld(playerid, params[])
{
	new
		world;

	if(sscanf(params, "d", world))
	{
		SendClientMessage(playerid, -1, "Parameters: world");
		return 1;
	}

	SetLineSegmentWorld(gLineSegmentID, world);

	return 1;
}

CMD:linesegmentinterior(playerid, params[])
{
	new str[128];

	format(str, 128, "Data: %d", GetLineSegmentInterior(gLineSegmentID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setlinesegmentinterior(playerid, params[])
{
	new
		interior;

	if(sscanf(params, "d", interior))
	{
		SendClientMessage(playerid, -1, "Parameters: interior");
		return 1;
	}

	SetLineSegmentInterior(gLineSegmentID, interior);

	return 1;
}

CMD:linesegmentvector(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetLineSegmentVector(gLineSegmentID, x, y, z);

	new str[128];

	format(str, 128, "Data: %f, %f, %f", x, y, z);
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:distancetolinesegmentpoint(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z,
		str[128];

	GetPlayerPos(playerid, x, y, z);

	format(str, 128, "Distance: %.2fm", GetDistanceToLineSegmentPoint(gLineSegmentID, x, y, z));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:distancetolinesegmentdest(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z,
		str[128];

	GetPlayerPos(playerid, x, y, z);

	format(str, 128, "Distance: %.2fm", GetDistanceToLineSegmentDest(gLineSegmentID, x, y, z));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:linesegmentlength(playerid, params[])
{
	new str[128];

	format(str, 128, "Data: %f", GetLineSegmentLength(gLineSegmentID));
	SendClientMessage(playerid, -1, str);

	return 1;
}



/*==============================================================================

	Zipline manipulation

==============================================================================*/


CMD:isvalidzipline(playerid, params[])
{
	new
		str[128];

	format(str, 128, "Valid: %d", IsValidZipline(gZiplineID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:getziplinestartareaid(playerid, params[])
{
	new areaid;

	if(sscanf(params, "d", areaid))
	{
		SendClientMessage(playerid, -1, "Parameters: areaid");
		return 1;
	}

	new str[128];
	format(str, 128, "areaid: %d", GetZiplineStartAreaID(gZiplineID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:getziplineendareaid(playerid, params[])
{
	new areaid;

	if(sscanf(params, "d", areaid))
	{
		SendClientMessage(playerid, -1, "Parameters: areaid");
		return 1;
	}

	new str[128];
	format(str, 128, "areaid: %d", GetZiplineEndAreaID(gZiplineID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:getziplinelineid(playerid, params[])
{
	new lineid;

	if(sscanf(params, "d", lineid))
	{
		SendClientMessage(playerid, -1, "Parameters: lineid");
		return 1;
	}

	new str[128];
	format(str, 128, "lineid: %d", GetZiplineLineID(gZiplineID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:getziplinestartpos(playerid, params[])
{
	new
		str[128],
		Float:x,
		Float:y,
		Float:z;

	GetZiplineStartPos(gZiplineID, x, y, z);

	format(str, 128, "coords: %f, %f, %f", x, y, z);
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setziplinestartpos(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	SetZiplineStartPos(gZiplineID, x, y, z);
	SendClientMessage(playerid, -1, "Zipline pos updated.");

	return 1;
}

CMD:getziplineendpos(playerid, params[])
{
	new
		str[128],
		Float:x,
		Float:y,
		Float:z;

	GetZiplineEndPos(gZiplineID, x, y, z);

	format(str, 128, "coords: %f, %f, %f", x, y, z);
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setziplineendpos(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	SetZiplineEndPos(gZiplineID, x, y, z);
	SendClientMessage(playerid, -1, "Zipline pos updated.");

	return 1;
}

CMD:getziplinevector(playerid, params[])
{
	new
		str[128],
		Float:x,
		Float:y,
		Float:z;

	GetZiplineVector(gZiplineID, x, y, z);

	format(str, 128, "vector: %f, %f, %f", x, y, z);
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:getziplineworld(playerid, params[])
{
	new str[128];

	format(str, 128, "World: %d", GetZiplineWorld(gZiplineID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setziplineworld(playerid, params[])
{
	new worldid;

	if(sscanf(params, "d", worldid))
	{
		SendClientMessage(playerid, -1, "Parameters: worldid");
		return 1;
	}

	SetZiplineWorld(gZiplineID, worldid);

	return 1;
}

CMD:getziplineinterior(playerid, params[])
{
	new str[128];

	format(str, 128, "Interior: %d", GetZiplineInterior(gZiplineID));
	SendClientMessage(playerid, -1, str);

	return 1;
}

CMD:setziplineinterior(playerid, params[])
{
	new interiorid;

	if(sscanf(params, "d", interiorid))
	{
		SendClientMessage(playerid, -1, "Parameters: interiorid");
		return 1;
	}

	SetZiplineInterior(gZiplineID, interiorid);

	return 1;
}

CMD:isplayeronzipline(playerid, params[])
{
	new str[128];

	format(str, 128, "On zipline: %d", IsPlayerOnZipline(playerid));
	SendClientMessage(playerid, -1, str);

	return 1;
}



/*==============================================================================

	Ladder manipulation

==============================================================================*/



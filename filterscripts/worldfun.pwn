#define FILTERSCIPT


#include <a_samp>
#include <streamer>
#include <YSI\y_iterate>
#include <YSI\y_hooks>

#include <SIF\Button.pwn>

#include <Balloon>
#include <Line>
#include <Zipline>
#include <Ladder>


#define LINE_MODEL		18647	// 19087 < values for rope line
#define LINE_LENGTH		2.0		// 2.46
#define LINE_ROT		0.0		// 90.0
#define LINE_OFFSET		0.0		// -(2.46/2)


//


public OnFilterScriptInit()
{
	/*
		Lets start off with a fun balloon!
	*/
	CreateBalloon(-19.7329, 27.1608, 2.0983, 0.0, -84.8372, -223.6261, 79.1079, 0.0);

	/*
		Now, a long neon strip
	*/
	CreateLineSegment(LINE_MODEL, LINE_LENGTH, -16.0481, 16.9945, 3.6839, -8.4105, 35.9623, 3.5245, LINE_ROT, .objlengthoffset = LINE_OFFSET, .maxlength = 1000.0);

	/*
		Everyone loves ziplines!
	*/
	CreateZipline(-83.7162, -221.5881, 78.9914, 8.9665, 15.2893, 6.6984);

	/*
		And a ladder to get down if you are too scared to zipline!
	*/
	CreateLadder(-84.9103, -227.5974, 40.2242, 79.1079, 0.0);

	return 1;
}


//


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

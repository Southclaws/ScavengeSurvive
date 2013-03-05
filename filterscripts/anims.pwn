/*
 *	Simple Animation List
 *
 *	Added In Version 1
 *
 *		Simple list of animation libraries.
 *		Each library contains all it's animations.
 *		Save animations with current settings.
 *
 *	Added In Version 2
 *
 *		Added 'anim' prefix to all commands
 *		Search function /animsearch
 *		Added a browsing feature that allows clicking through animation indexes
 *
 *
 *	~Southclaw
 *		Do what you want with it, but keep my name on it :)
 */


#include <a_samp>	// If you don't have this file, give up... just, give up.
	#undef MAX_PLAYERS
	#define MAX_PLAYERS			(16)

#include <zcmd>		// If you don't have ZCMD, get it, don't go asking me to make a strcmp version!


#define DIALOG_INDEX			(10000)		// Default dialog index to start dialog IDs from
#define ANIM_SAVE_FILE			"SavedAnimations.txt"
#define MOUSE_HOVER_COLOUR      0xFFFF00FF	// Yellow

#define MAX_ANIMS				1812		// Total amount of animations (No brackets, because it's embedded in strings)
#define MAX_LIBRARY				(132)		// Total amount of libraries
#define MAX_LIBANIMS    		(294)		// Largest library
#define MAX_LIB_NAME     		(32)
#define MAX_ANIM_NAME    		(32)		// Same as LIBNAME but just for completion!
#define MAX_SEARCH_RESULTS		(20)		// The max amount of search results that can be shown
#define MAX_SEARCH_RESULT_LEN	(MAX_SEARCH_RESULTS * (MAX_LIB_NAME + 1 + MAX_ANIM_NAME))

#define BROWSE_MODE_NONE		(0)			// Player isn't browsing
#define BROWSE_MODE_BROWSING	(2)			// Player is browsing
#define BROWSE_MODE_CAMERA		(3)			// Player is moving the camera in browse mode

#define PreloadAnimLib(%1,%2)	ApplyAnimation(%1,%2,"null",0.0,0,0,0,0,0)
#define Msg                     SendClientMessage


enum
{
	D_ANIM_LIBRARIES = DIALOG_INDEX,		// The list of animation libraries
	D_ANIM_LIST,							// The list of animations in a library
	D_ANIM_SEARCH,							// Search query dialog
	D_ANIM_SEARCH_RESULTS,					// Search results list
	D_ANIM_SETTINGS,						// Animation parameter setup
	D_ANIM_SPEED,							// Animation speed parameter input
	D_ANIM_TIME,							// Animation time parameter input
	D_ANIM_IDX								// Animation index input
}
// anm = 3 letter prefix for animation related vars.
enum E_ANIM_SETTINGS
{
	Float:anm_Speed,
	anm_Loop,
	anm_LockX,
	anm_LockY,
	anm_Freeze,
	anm_Time
}


new
	gAnimTotal[MAX_LIBRARY],
	
	gLibIndex[MAX_LIBRARY][MAX_LIB_NAME],

	gLibList[MAX_LIBRARY * (MAX_LIB_NAME+1)],
	gAnimList[MAX_LIBRARY][MAX_LIBANIMS * (MAX_ANIM_NAME+1)],

	gCurrentIdx[MAX_PLAYERS],
	gCurrentLib[MAX_PLAYERS][MAX_LIB_NAME],
	gCurrentAnim[MAX_PLAYERS][MAX_ANIM_NAME],
	gBrowseMode[MAX_PLAYERS],

	gAnimSettings[MAX_PLAYERS][E_ANIM_SETTINGS];

new
	PlayerText:guiBackground,
	PlayerText:guiArrowL,
	PlayerText:guiArrowR,
	PlayerText:guiAnimIdx,
	PlayerText:guiAnimLib,
	PlayerText:guiAnimName,
	PlayerText:guiCamera,
	PlayerText:guiExitBrowser;


public OnFilterScriptInit()
{
	new
	    lib[32],				// The library name.
	    anim[32],				// The animation name.
		tmplib[32]	= "NULL",	// The current library name to be compared.
		curlib		= -1;		// Current library the code writes to.

	for(new i = 1;i<MAX_ANIMS;i++) // Loop through all animation IDs.
	{
	    GetAnimationName(i, lib, 32, anim, 32);
	    
	    // If the animation library just retrieved does not match the current
	    // library, the following animations are in a new library so advance
	    // the current library variable.
	    if(strcmp(lib, tmplib))
	    {
			curlib++;
			strcat(gLibList, lib);
			strcat(gLibList, "\n");
			tmplib = lib;
			strcat(gLibIndex[curlib], lib);
	    }
	    
	    strcat(gAnimList[curlib], anim);
	    strcat(gAnimList[curlib], "\n");

		gAnimTotal[ curlib ]++; // Increase the total amount of animations in the current library.
	}
	
	for(new i;i<MAX_PLAYERS;i++)
	{
	    // Default animations to avoid crashes if a user uses
	    // /animparams before /animations.
	    gCurrentLib[i] = "RUNNINGMAN";
	    gCurrentAnim[i] = "DANCE_LOOP";
	    gCurrentIdx[i] = 1811;

		// Default speed so the user can use /animations
		// before needing to edit the speed in /animsettings
		gAnimSettings[i][anm_Speed] = 4.0;
		gAnimSettings[i][anm_Loop] = 1;
	}
}

public OnFilterScriptExit()
{
	for(new i;i<MAX_PLAYERS;i++)
	{
	    UnloadPlayerTextDraws(i);
	}
}


CMD:animhelp(playerid, params[])
{
	Msg(playerid, 0x00AAFFFF, " - Southclaws Animation Browser Help");
	Msg(playerid, -1, " | - /animlibs {FFFF00}Open the library list.");
	Msg(playerid, -1, " | - /animsearch {FFFF00}Open the search dialog to find animations.");
	Msg(playerid, -1, " | - /animparams {FFFF00}Set parameters for the current animation.");
	Msg(playerid, -1, " | - /animsave <comment> {FFFF00}Save the animation to '"#ANIM_SAVE_FILE"' with a comment.");
	Msg(playerid, -1, " | - /animplay {FFFF00}Play the current animation if stopped.");
	Msg(playerid, -1, " | - /animstop {FFFF00}Stop the current animation.");
	return 1;
}
CMD:animbrowse(playerid, params[])
{
	if(gBrowseMode[playerid] == BROWSE_MODE_NONE)
	{
		EnterAnimationBrowser(playerid);
    	Msg(playerid, -1, "If you accidentally exit mouse mode with ESC, use ~k~~VEHICLE_ENTER_EXIT~ to show the mouse again.");
    }
    else ExitAnimationBrowser(playerid);
	return 1;
}
CMD:animplay(playerid, params[])
{
    PlayCurrentAnimation(playerid);
	return 1;
}
CMD:animstop(playerid, params[])
{
	ClearAnimations(playerid);
	return 1;
}
CMD:animlibs(playerid, params[])
{
    PreloadPlayerAnims(playerid);
	ShowPlayerDialog(playerid, D_ANIM_LIBRARIES, DIALOG_STYLE_LIST, "Choose an animation library", gLibList, "Open...", "Cancel");
	return 1;
}
CMD:animsearch(playerid, params[])
{
	ShowPlayerDialog(playerid, D_ANIM_SEARCH, DIALOG_STYLE_INPUT, "Animation search", "Type a keyword", "Open...", "Cancel");
	return 1;
}
CMD:animparams(playerid, params[])
{
	FormatAnimSettingsMenu(playerid);
	return 1;
}
CMD:animsave(playerid, params[])
{
	if(0 < strlen(params) < 32)
	{
		SaveCurrentAnimation(playerid, params);
		Msg(playerid, -1, "Animation data saved!");
	}
	else SendClientMessage(playerid, -1, "Usage: /saveanimation [comment between 1 and 32 chars]");
	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == D_ANIM_LIBRARIES && response)
	{
	    // Blank the string because strcat is used.
	    gCurrentLib[playerid][0] = EOS;
	    // Fortunately, inputtext will return the text of the line,
	    // So this can just be saved as the player's current library.
	    strcat(gCurrentLib[playerid], inputtext);
	    // Show the right list of animations from the chosen library.
		ShowPlayerDialog(playerid, D_ANIM_LIST, DIALOG_STYLE_LIST, "Choose an animation", gAnimList[listitem], "Play", "Back");
		// Preload the animations for that library
		PreloadAnimLib(playerid, inputtext);
	}
	if(dialogid == D_ANIM_LIST)
	{
	    if(response)
	    {
			// Blank the string because strcat is used
			gCurrentAnim[playerid][0] = EOS;
		    // Save the animation name to the variable (For saving)
			strcat(gCurrentAnim[playerid], inputtext);

			PlayCurrentAnimation(playerid);
		}
		else ShowPlayerDialog(playerid, D_ANIM_LIBRARIES, DIALOG_STYLE_LIST, "Choose an animation library", gLibList, "Open...", "Cancel");
	}
	if(dialogid == D_ANIM_SEARCH && response)
    {
        new
			result,
			output[MAX_SEARCH_RESULTS * MAX_ANIM_NAME],
			title[48];

		result = AnimSearch(inputtext, output);
		
		if(result)
		{
			format(title, 48, "Results for: \"%s\"", inputtext);
			ShowPlayerDialog(playerid, D_ANIM_SEARCH_RESULTS, DIALOG_STYLE_LIST, title, output, "Play", "Back");
		}
		else ShowPlayerDialog(playerid, D_ANIM_SEARCH, DIALOG_STYLE_INPUT, "Animation search", "Type a keyword\n\n{FF0000}Query not found, please try again.", "Open...", "Cancel");
	}
	if(dialogid == D_ANIM_SEARCH_RESULTS)
	{
	    if(!response)return ShowPlayerDialog(playerid, D_ANIM_SEARCH, DIALOG_STYLE_INPUT, "Animation search", "Type a keyword", "Open...", "Cancel");

	    new delim = strfind(inputtext, "~");

		strmid(gCurrentLib[playerid], inputtext, 0, delim);
		strmid(gCurrentAnim[playerid], inputtext, delim+1, strlen(inputtext));

		PlayCurrentAnimation(playerid);
	}
	if(dialogid == D_ANIM_SETTINGS && response)
	{
		if(listitem == 0)ShowPlayerDialog(playerid, D_ANIM_SPEED, DIALOG_STYLE_INPUT, "Animation Speed", "Change the speed of the animation below:", "Accept", "Back");
		else if(listitem == 5)ShowPlayerDialog(playerid, D_ANIM_TIME, DIALOG_STYLE_INPUT, "Animation Time", "Change the time of the animation below:", "Accept", "Back");
		else
		{
		    gAnimSettings[playerid][E_ANIM_SETTINGS:listitem] = !gAnimSettings[playerid][E_ANIM_SETTINGS:listitem];
		    PlayCurrentAnimation(playerid);
			FormatAnimSettingsMenu(playerid);
		}
	}
	if(dialogid == D_ANIM_SPEED && response)
	{
		gAnimSettings[playerid][anm_Speed] = floatstr(inputtext);
    	PlayCurrentAnimation(playerid);
		FormatAnimSettingsMenu(playerid);
	}
	if(dialogid == D_ANIM_TIME && response)
	{
		gAnimSettings[playerid][anm_Time] = strval(inputtext);
    	PlayCurrentAnimation(playerid);
		FormatAnimSettingsMenu(playerid);
	}
	if(dialogid == D_ANIM_IDX && response)
	{
		new idx = strval(inputtext);
		if(0 < idx < MAX_ANIMS)
		{
		    GetAnimationName(idx,
				gCurrentLib[playerid], MAX_LIB_NAME,
				gCurrentAnim[playerid], MAX_ANIM_NAME);

		    gCurrentIdx[playerid] = idx;
		    UpdateBrowserControls(playerid);
			PlayCurrentAnimation(playerid);
		}
		else ShowPlayerDialog(playerid, D_ANIM_IDX, DIALOG_STYLE_INPUT, "Anim Index", "Enter an animation index number (idx)\nbetween 0 and "#MAX_ANIMS":", "Enter", "Cancel");
	}
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == guiArrowL)
	{
		gCurrentIdx[playerid]--;
		if(gCurrentIdx[playerid] <= 0)gCurrentIdx[playerid] = MAX_ANIMS-1;

		GetAnimationName(gCurrentIdx[playerid],
			gCurrentLib[playerid], MAX_LIB_NAME,
			gCurrentAnim[playerid], MAX_ANIM_NAME);

		PlayCurrentAnimation(playerid);
		UpdateBrowserControls(playerid);
	}
	if(playertextid == guiArrowR)
	{
		gCurrentIdx[playerid]++;
		if(gCurrentIdx[playerid] == MAX_ANIMS)gCurrentIdx[playerid] = 1;

		GetAnimationName(gCurrentIdx[playerid],
			gCurrentLib[playerid], MAX_LIB_NAME,
			gCurrentAnim[playerid], MAX_ANIM_NAME);

		PlayCurrentAnimation(playerid);
		UpdateBrowserControls(playerid);
	}
	if(playertextid == guiAnimIdx)
	{
	    ShowPlayerDialog(playerid, D_ANIM_IDX, DIALOG_STYLE_INPUT, "Anim Index", "Enter an animation index number (idx)\nbetween 0 and "#MAX_ANIMS":", "Enter", "Cancel");
	}
	if(playertextid == guiCamera)
	{
	    gBrowseMode[playerid] = BROWSE_MODE_CAMERA;
	    PlayerTextDrawSetString(playerid, guiCamera, "~k~~VEHICLE_ENTER_EXIT~ for mouse mode");
	    CancelSelectTextDraw(playerid);
		UpdateBrowserControls(playerid);
		SetCameraBehindPlayer(playerid);
	}
	if(playertextid == guiExitBrowser)
	{
	    ExitAnimationBrowser(playerid);
	}
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & 16 && gBrowseMode[playerid] != BROWSE_MODE_NONE)
	{
		SelectTextDraw(playerid, MOUSE_HOVER_COLOUR);
		gBrowseMode[playerid] = BROWSE_MODE_BROWSING;
	    PlayerTextDrawSetString(playerid, guiCamera, "Click for camera mode");
	}
}

EnterAnimationBrowser(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	SetPlayerCameraPos(playerid,
		x + (5*floatsin(-r, degrees)),
		y + (5*floatcos(-r, degrees)), z);

	SetPlayerCameraLookAt(playerid, x, y, z, CAMERA_MOVE);
	
	if(!(0 < gCurrentIdx[playerid] < MAX_ANIMS))
		gCurrentIdx[playerid] = 1811;

	LoadPlayerTextDraws(playerid);
	ShowBrowserControls(playerid);
	UpdateBrowserControls(playerid);
	SelectTextDraw(playerid, MOUSE_HOVER_COLOUR);
	PlayCurrentAnimation(playerid);

	gBrowseMode[playerid] = BROWSE_MODE_BROWSING;
}
ExitAnimationBrowser(playerid)
{
	SetCameraBehindPlayer(playerid);
	HideBrowserControls(playerid);
	UnloadPlayerTextDraws(playerid);
	CancelSelectTextDraw(playerid);
	ClearAnimations(playerid);
	
	gBrowseMode[playerid] = BROWSE_MODE_NONE;
}

UpdateBrowserControls(playerid)
{
	new tmp[32];

	valstr(tmp, gCurrentIdx[playerid]);
	PlayerTextDrawSetString(playerid, guiAnimIdx, tmp);
	
	PlayerTextDrawSetString(playerid, guiAnimLib, gCurrentLib[playerid]);
	PlayerTextDrawSetString(playerid, guiAnimName, gCurrentAnim[playerid]);

	ShowBrowserControls(playerid);
}


PlayCurrentAnimation(playerid)
{
	ClearAnimations(playerid);
    ApplyAnimation(playerid,
		gCurrentLib[playerid],
		gCurrentAnim[playerid],
		gAnimSettings[playerid][anm_Speed],
		gAnimSettings[playerid][anm_Loop],
		gAnimSettings[playerid][anm_LockX],
		gAnimSettings[playerid][anm_LockY],
		gAnimSettings[playerid][anm_Freeze],
		gAnimSettings[playerid][anm_Time],
		1);
}

FormatAnimSettingsMenu(playerid)
{
	new
	    list[128];

	format(list, 128,
	    "Speed:\t\t%f\n\
		Loop:\t\t%d\n\
		Lock X:\t\t%d\n\
		Lock Y:\t\t%d\n\
		Freeze:\t\t%d\n\
		Time:\t\t%d",
		gAnimSettings[playerid][anm_Speed],
		gAnimSettings[playerid][anm_Loop],
		gAnimSettings[playerid][anm_LockX],
		gAnimSettings[playerid][anm_LockY],
		gAnimSettings[playerid][anm_Freeze],
		gAnimSettings[playerid][anm_Time]);

	ShowPlayerDialog(playerid, D_ANIM_SETTINGS, DIALOG_STYLE_LIST, "Animation Settings", list, "Change", "Exit");
}

SaveCurrentAnimation(playerid, comment[])
{
	new
		File:file,
		line[156]; // Based on comment max len = 32

	if(!fexist(ANIM_SAVE_FILE))file = fopen(ANIM_SAVE_FILE, io_write);
	else file = fopen(ANIM_SAVE_FILE, io_append);

	format(line, 156, "ApplyAnimation(playerid, \"%s\", \"%s\", %.1f, %d, %d, %d, %d, %d); // %s\r\n",
		gCurrentLib[playerid],
		gCurrentAnim[playerid],
		gAnimSettings[playerid][anm_Speed],
		gAnimSettings[playerid][anm_Loop],
		gAnimSettings[playerid][anm_LockX],
		gAnimSettings[playerid][anm_LockY],
		gAnimSettings[playerid][anm_Freeze],
		gAnimSettings[playerid][anm_Time],
		comment);

	fwrite(file, line);
	fclose(file);
}

AnimSearch(query[], output[])
{
	new
		j,
		animlen,
		findpos,
		tmp[MAX_ANIM_NAME],
		items;

	for(new i; i < MAX_LIBRARY && items < MAX_SEARCH_RESULTS; i++)
	{
		while(j < strlen(gAnimList[i]))
		{
			if(gAnimList[i][j] == '\n')
			{
				animlen = strfind(gAnimList[i], "\n", false, j+1) - j;
				findpos = strfind(gAnimList[i], query, true, j+1);

				if(findpos != -1 && findpos - j < animlen)
				{
					if(animlen == -1)strmid(tmp, gAnimList[i], j+1, strlen(gAnimList[i]), MAX_ANIM_NAME);
					else strmid(tmp, gAnimList[i], j+1, j+animlen, MAX_ANIM_NAME);

					strcat(output, gLibIndex[i], MAX_SEARCH_RESULTS * MAX_ANIM_NAME);
					strcat(output, "~", MAX_SEARCH_RESULTS * MAX_ANIM_NAME);
					strcat(output, tmp, MAX_SEARCH_RESULTS * MAX_ANIM_NAME);
					strcat(output, "\n", MAX_SEARCH_RESULTS * MAX_ANIM_NAME);

					items++;
				}
			}
			j++;
		}
	}
	return items;
}


PreloadPlayerAnims(playerid)
{
   	PreloadAnimLib(playerid,"BOMBER");
   	PreloadAnimLib(playerid,"RAPPING");
   	PreloadAnimLib(playerid,"SHOP");
	PreloadAnimLib(playerid,"BEACH");
	PreloadAnimLib(playerid,"SMOKING");
   	PreloadAnimLib(playerid,"FOOD");
   	PreloadAnimLib(playerid,"ON_LOOKERS");
   	PreloadAnimLib(playerid,"DEALER");
	PreloadAnimLib(playerid,"CRACK");
	PreloadAnimLib(playerid,"CARRY");
	PreloadAnimLib(playerid,"COP_AMBIENT");
	PreloadAnimLib(playerid,"PARK");
	PreloadAnimLib(playerid,"INT_HOUSE");
	PreloadAnimLib(playerid,"FOOD");
	PreloadAnimLib(playerid,"PED");
}

ShowBrowserControls(playerid)
{
	PlayerTextDrawShow(playerid, guiBackground);
	PlayerTextDrawShow(playerid, guiArrowL);
	PlayerTextDrawShow(playerid, guiArrowR);
	PlayerTextDrawShow(playerid, guiAnimIdx);
	PlayerTextDrawShow(playerid, guiAnimLib);
	PlayerTextDrawShow(playerid, guiAnimName);
	PlayerTextDrawShow(playerid, guiCamera);
	PlayerTextDrawShow(playerid, guiExitBrowser);
}
HideBrowserControls(playerid)
{
	PlayerTextDrawHide(playerid, guiBackground);
	PlayerTextDrawHide(playerid, guiArrowL);
	PlayerTextDrawHide(playerid, guiArrowR);
	PlayerTextDrawHide(playerid, guiAnimIdx);
	PlayerTextDrawHide(playerid, guiAnimLib);
	PlayerTextDrawHide(playerid, guiAnimName);
	PlayerTextDrawHide(playerid, guiCamera);
	PlayerTextDrawHide(playerid, guiExitBrowser);
}

LoadPlayerTextDraws(playerid)
{
	guiBackground					=CreatePlayerTextDraw(playerid, 320.0, 336.0, "~n~");
	PlayerTextDrawAlignment			(playerid, guiBackground, 2);
	PlayerTextDrawBackgroundColor	(playerid, guiBackground, 255);
	PlayerTextDrawFont				(playerid, guiBackground, 2);
	PlayerTextDrawLetterSize		(playerid, guiBackground, 0.25, 9.8);
	PlayerTextDrawColor				(playerid, guiBackground, -1);
	PlayerTextDrawSetOutline		(playerid, guiBackground, 0);
	PlayerTextDrawSetProportional	(playerid, guiBackground, 1);
	PlayerTextDrawSetShadow			(playerid, guiBackground, 1);
	PlayerTextDrawUseBox			(playerid, guiBackground, 1);
	PlayerTextDrawBoxColor			(playerid, guiBackground, 80);
	PlayerTextDrawTextSize			(playerid, guiBackground, 0.0, 220.0);

	guiArrowL						=CreatePlayerTextDraw(playerid, 280.0, 350.0, "<");
	PlayerTextDrawTextSize			(playerid, guiArrowL, 20.0, 20.0);
	PlayerTextDrawAlignment			(playerid, guiArrowL, 2);
	PlayerTextDrawBackgroundColor	(playerid, guiArrowL, 255);
	PlayerTextDrawFont				(playerid, guiArrowL, 1);
	PlayerTextDrawLetterSize		(playerid, guiArrowL, 0.5, 3.0);
	PlayerTextDrawColor				(playerid, guiArrowL, -1);
	PlayerTextDrawSetOutline		(playerid, guiArrowL, 1);
	PlayerTextDrawSetProportional	(playerid, guiArrowL, 1);
	PlayerTextDrawSetShadow			(playerid, guiArrowL, 0);
	PlayerTextDrawSetSelectable		(playerid, guiArrowL, 1);

	guiArrowR						=CreatePlayerTextDraw(playerid, 360.0, 350.0, ">");
	PlayerTextDrawTextSize			(playerid, guiArrowR, 20.0, 20.0);
	PlayerTextDrawAlignment			(playerid, guiArrowR, 2);
	PlayerTextDrawBackgroundColor	(playerid, guiArrowR, 255);
	PlayerTextDrawFont				(playerid, guiArrowR, 1);
	PlayerTextDrawLetterSize		(playerid, guiArrowR, 0.5, 3.0);
	PlayerTextDrawColor				(playerid, guiArrowR, -1);
	PlayerTextDrawSetOutline		(playerid, guiArrowR, 1);
	PlayerTextDrawSetProportional	(playerid, guiArrowR, 1);
	PlayerTextDrawSetShadow			(playerid, guiArrowR, 0);
	PlayerTextDrawSetSelectable		(playerid, guiArrowR, 1);

	guiAnimIdx						=CreatePlayerTextDraw(playerid, 320.0, 355.0, "1800");
	PlayerTextDrawTextSize			(playerid, guiAnimIdx, 10.0, 20.0);
	PlayerTextDrawAlignment			(playerid, guiAnimIdx, 2);
	PlayerTextDrawBackgroundColor	(playerid, guiAnimIdx, 255);
	PlayerTextDrawFont				(playerid, guiAnimIdx, 2);
	PlayerTextDrawLetterSize		(playerid, guiAnimIdx, 0.3, 1.8);
	PlayerTextDrawColor				(playerid, guiAnimIdx, -1);
	PlayerTextDrawSetOutline		(playerid, guiAnimIdx, 0);
	PlayerTextDrawSetProportional	(playerid, guiAnimIdx, 1);
	PlayerTextDrawSetShadow			(playerid, guiAnimIdx, 1);
	PlayerTextDrawSetSelectable		(playerid, guiAnimIdx, 1);

	guiAnimLib						=CreatePlayerTextDraw(playerid, 320.0, 375.0, "ANIMATION LIBRARY");
	PlayerTextDrawAlignment			(playerid, guiAnimLib, 2);
	PlayerTextDrawBackgroundColor	(playerid, guiAnimLib, 255);
	PlayerTextDrawFont				(playerid, guiAnimLib, 2);
	PlayerTextDrawLetterSize		(playerid, guiAnimLib, 0.3, 1.8);
	PlayerTextDrawColor				(playerid, guiAnimLib, -1);
	PlayerTextDrawSetOutline		(playerid, guiAnimLib, 0);
	PlayerTextDrawSetProportional	(playerid, guiAnimLib, 1);
	PlayerTextDrawSetShadow			(playerid, guiAnimLib, 1);

	guiAnimName						=CreatePlayerTextDraw(playerid, 320.0, 390.0, "ANIMATION NAME");
	PlayerTextDrawAlignment			(playerid, guiAnimName, 2);
	PlayerTextDrawBackgroundColor	(playerid, guiAnimName, 255);
	PlayerTextDrawFont				(playerid, guiAnimName, 2);
	PlayerTextDrawLetterSize		(playerid, guiAnimName, 0.3, 1.8);
	PlayerTextDrawColor				(playerid, guiAnimName, -1);
	PlayerTextDrawSetOutline		(playerid, guiAnimName, 0);
	PlayerTextDrawSetProportional	(playerid, guiAnimName, 1);
	PlayerTextDrawSetShadow			(playerid, guiAnimName, 1);

	guiCamera						=CreatePlayerTextDraw(playerid, 320.0, 336.0, "Click for camera mode");
	PlayerTextDrawTextSize			(playerid, guiCamera, 10.0, 130.0);
	PlayerTextDrawAlignment			(playerid, guiCamera, 2);
	PlayerTextDrawBackgroundColor	(playerid, guiCamera, 255);
	PlayerTextDrawFont				(playerid, guiCamera, 2);
	PlayerTextDrawLetterSize		(playerid, guiCamera, 0.25, 1.5);
	PlayerTextDrawColor				(playerid, guiCamera, -1);
	PlayerTextDrawSetOutline		(playerid, guiCamera, 0);
	PlayerTextDrawSetProportional	(playerid, guiCamera, 1);
	PlayerTextDrawSetShadow			(playerid, guiCamera, 1);
	PlayerTextDrawSetSelectable		(playerid, guiCamera, 1);

	guiExitBrowser					=CreatePlayerTextDraw(playerid, 320.000000, 410.000000, "Exit");
	PlayerTextDrawTextSize			(playerid, guiExitBrowser, 10.0, 25.0);
	PlayerTextDrawAlignment			(playerid, guiExitBrowser, 2);
	PlayerTextDrawBackgroundColor	(playerid, guiExitBrowser, 255);
	PlayerTextDrawFont				(playerid, guiExitBrowser, 2);
	PlayerTextDrawLetterSize		(playerid, guiExitBrowser, 0.250000, 1.500000);
	PlayerTextDrawColor				(playerid, guiExitBrowser, -1);
	PlayerTextDrawSetOutline		(playerid, guiExitBrowser, 0);
	PlayerTextDrawSetProportional	(playerid, guiExitBrowser, 1);
	PlayerTextDrawSetShadow			(playerid, guiExitBrowser, 1);
	PlayerTextDrawSetSelectable		(playerid, guiExitBrowser, 1);
}

UnloadPlayerTextDraws(playerid)
{
	PlayerTextDrawDestroy(playerid, guiBackground);
	PlayerTextDrawDestroy(playerid, guiArrowL);
	PlayerTextDrawDestroy(playerid, guiArrowR);
	PlayerTextDrawDestroy(playerid, guiAnimIdx);
	PlayerTextDrawDestroy(playerid, guiAnimLib);
	PlayerTextDrawDestroy(playerid, guiAnimName);
	PlayerTextDrawDestroy(playerid, guiCamera);
	PlayerTextDrawDestroy(playerid, guiExitBrowser);
}


CMD:deltd(playerid, params[])
{
	for(new i;i<2048;i++)PlayerTextDrawHide(playerid, PlayerText:i);
	return 1;
}



#endinput

// The code I used to get the max values

public OnFilterScriptInit()
{
	new
	    lib[32],
	    anim[32],
		tmplib[32] = "NULL",
		libtotal,
		animtotal,
		largest;

	for(new i;i<MAX_ANIMS;i++)
	{
	    GetAnimationName(i, lib, 32, anim, 32);
	    animtotal++;
	    if(strcmp(lib, tmplib))
	    {
	        printf("Found library: '%s' anims: %d", lib, animtotal);
	        libtotal++;

	        if(animtotal > largest) largest = animtotal;
	        animtotal = 0;

	        tmplib = lib;
	    }
	}
	printf("Total Libraries: %d Largest Libaray: %d", libtotal, largest);
}

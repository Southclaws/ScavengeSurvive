/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
#include <zcmd>
#include <YSI\y_hooks>


new
	PlayerText:kp_Background,
	PlayerText:kp_EdgeL,
	PlayerText:kp_EdgeT,
	PlayerText:kp_EdgeB,
	PlayerText:kp_EdgeR,
	PlayerText:kp_KeyEnter,
	PlayerText:kp_KeyCancel,
	PlayerText:kp_Key0,
	PlayerText:kp_Key1,
	PlayerText:kp_Key2,
	PlayerText:kp_Key3,
	PlayerText:kp_Key4,
	PlayerText:kp_Key5,
	PlayerText:kp_Key6,
	PlayerText:kp_Key7,
	PlayerText:kp_Key8,
	PlayerText:kp_Key9,
	PlayerText:kp_Display;

new
	kp_Value[MAX_PLAYERS],
	kp_Match[MAX_PLAYERS];


forward OnPlayerKeypadEnter(playerid, success);


ShowKeypad(playerid, match)
{
	PlayerTextDrawShow(playerid, kp_Background);
	PlayerTextDrawShow(playerid, kp_EdgeL);
	PlayerTextDrawShow(playerid, kp_EdgeT);
	PlayerTextDrawShow(playerid, kp_EdgeB);
	PlayerTextDrawShow(playerid, kp_EdgeR);
	PlayerTextDrawShow(playerid, kp_KeyEnter);
	PlayerTextDrawShow(playerid, kp_KeyCancel);
	PlayerTextDrawShow(playerid, kp_Key0);
	PlayerTextDrawShow(playerid, kp_Key1);
	PlayerTextDrawShow(playerid, kp_Key2);
	PlayerTextDrawShow(playerid, kp_Key3);
	PlayerTextDrawShow(playerid, kp_Key4);
	PlayerTextDrawShow(playerid, kp_Key5);
	PlayerTextDrawShow(playerid, kp_Key6);
	PlayerTextDrawShow(playerid, kp_Key7);
	PlayerTextDrawShow(playerid, kp_Key8);
	PlayerTextDrawShow(playerid, kp_Key9);
	PlayerTextDrawShow(playerid, kp_Display);
	SelectTextDraw(playerid, 0xFF0000FF);

	kp_Match[playerid] = match;
	KeypadUpdateDisplay(playerid);
}

HideKeypad(playerid)
{
	PlayerTextDrawHide(playerid, kp_Background);
	PlayerTextDrawHide(playerid, kp_EdgeL);
	PlayerTextDrawHide(playerid, kp_EdgeT);
	PlayerTextDrawHide(playerid, kp_EdgeB);
	PlayerTextDrawHide(playerid, kp_EdgeR);
	PlayerTextDrawHide(playerid, kp_KeyEnter);
	PlayerTextDrawHide(playerid, kp_KeyCancel);
	PlayerTextDrawHide(playerid, kp_Key0);
	PlayerTextDrawHide(playerid, kp_Key1);
	PlayerTextDrawHide(playerid, kp_Key2);
	PlayerTextDrawHide(playerid, kp_Key3);
	PlayerTextDrawHide(playerid, kp_Key4);
	PlayerTextDrawHide(playerid, kp_Key5);
	PlayerTextDrawHide(playerid, kp_Key6);
	PlayerTextDrawHide(playerid, kp_Key7);
	PlayerTextDrawHide(playerid, kp_Key8);
	PlayerTextDrawHide(playerid, kp_Key9);
	PlayerTextDrawHide(playerid, kp_Display);
	CancelSelectTextDraw(playerid);

	kp_Match[playerid] = 0;
}


//hook OnPlayerConnect(playerid)
public OnFilterScriptInit()
{
	LoadTD(0);
}

public OnFilterScriptExit()
{
	UnLoadTD(0);
}

LoadTD(playerid)
{
	kp_Background					=CreatePlayerTextDraw(playerid, 320.000000, 204.000000, "_");
	PlayerTextDrawAlignment			(playerid, kp_Background, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Background, -1);
	PlayerTextDrawFont				(playerid, kp_Background, 1);
	PlayerTextDrawLetterSize		(playerid, kp_Background, 0.500000, 16.199998);
	PlayerTextDrawColor				(playerid, kp_Background, 255);
	PlayerTextDrawSetOutline		(playerid, kp_Background, 1);
	PlayerTextDrawSetProportional	(playerid, kp_Background, 1);
	PlayerTextDrawUseBox			(playerid, kp_Background, 1);
	PlayerTextDrawBoxColor			(playerid, kp_Background, 80);
	PlayerTextDrawTextSize			(playerid, kp_Background, 20.000000, 82.000000);

	kp_EdgeL						=CreatePlayerTextDraw(playerid, 275.000000, 204.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, kp_EdgeL, -1);
	PlayerTextDrawFont				(playerid, kp_EdgeL, 1);
	PlayerTextDrawLetterSize		(playerid, kp_EdgeL, 0.500000, -1.100000);
	PlayerTextDrawColor				(playerid, kp_EdgeL, 255);
	PlayerTextDrawSetOutline		(playerid, kp_EdgeL, 1);
	PlayerTextDrawSetProportional	(playerid, kp_EdgeL, 1);
	PlayerTextDrawUseBox			(playerid, kp_EdgeL, 1);
	PlayerTextDrawBoxColor			(playerid, kp_EdgeL, -2021161081);
	PlayerTextDrawTextSize			(playerid, kp_EdgeL, 361.000000, 82.000000);

	kp_EdgeT						=CreatePlayerTextDraw(playerid, 275.000000, 204.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, kp_EdgeT, -1);
	PlayerTextDrawFont				(playerid, kp_EdgeT, 1);
	PlayerTextDrawLetterSize		(playerid, kp_EdgeT, 0.500000, 16.199998);
	PlayerTextDrawColor				(playerid, kp_EdgeT, 255);
	PlayerTextDrawSetOutline		(playerid, kp_EdgeT, 1);
	PlayerTextDrawSetProportional	(playerid, kp_EdgeT, 1);
	PlayerTextDrawUseBox			(playerid, kp_EdgeT, 1);
	PlayerTextDrawBoxColor			(playerid, kp_EdgeT, -2021161081);
	PlayerTextDrawTextSize			(playerid, kp_EdgeT, 275.000000, 82.000000);

	kp_EdgeB						=CreatePlayerTextDraw(playerid, 275.000000, 359.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, kp_EdgeB, -1);
	PlayerTextDrawFont				(playerid, kp_EdgeB, 1);
	PlayerTextDrawLetterSize		(playerid, kp_EdgeB, 0.500000, -1.100000);
	PlayerTextDrawColor				(playerid, kp_EdgeB, 255);
	PlayerTextDrawSetOutline		(playerid, kp_EdgeB, 1);
	PlayerTextDrawSetProportional	(playerid, kp_EdgeB, 1);
	PlayerTextDrawUseBox			(playerid, kp_EdgeB, 1);
	PlayerTextDrawBoxColor			(playerid, kp_EdgeB, -2021161081);
	PlayerTextDrawTextSize			(playerid, kp_EdgeB, 365.000000, 82.000000);

	kp_EdgeR						=CreatePlayerTextDraw(playerid, 365.000000, 199.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, kp_EdgeR, -1);
	PlayerTextDrawFont				(playerid, kp_EdgeR, 1);
	PlayerTextDrawLetterSize		(playerid, kp_EdgeR, 0.500000, 16.800001);
	PlayerTextDrawColor				(playerid, kp_EdgeR, 255);
	PlayerTextDrawSetOutline		(playerid, kp_EdgeR, 1);
	PlayerTextDrawSetProportional	(playerid, kp_EdgeR, 1);
	PlayerTextDrawUseBox			(playerid, kp_EdgeR, 1);
	PlayerTextDrawBoxColor			(playerid, kp_EdgeR, -2021161081);
	PlayerTextDrawTextSize			(playerid, kp_EdgeR, 365.000000, 82.000000);

	kp_KeyEnter						=CreatePlayerTextDraw(playerid, 350.000000, 330.000000, ">");
	PlayerTextDrawAlignment			(playerid, kp_KeyEnter, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_KeyEnter, -1);
	PlayerTextDrawFont				(playerid, kp_KeyEnter, 1);
	PlayerTextDrawLetterSize		(playerid, kp_KeyEnter, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_KeyEnter, 255);
	PlayerTextDrawSetOutline		(playerid, kp_KeyEnter, 1);
	PlayerTextDrawSetProportional	(playerid, kp_KeyEnter, 1);
	PlayerTextDrawUseBox			(playerid, kp_KeyEnter, 1);
	PlayerTextDrawBoxColor			(playerid, kp_KeyEnter, 538976384);
	PlayerTextDrawTextSize			(playerid, kp_KeyEnter, 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_KeyEnter, true);

	kp_KeyCancel					=CreatePlayerTextDraw(playerid, 290.000000, 330.000000, "X");
	PlayerTextDrawAlignment			(playerid, kp_KeyCancel, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_KeyCancel, -1);
	PlayerTextDrawFont				(playerid, kp_KeyCancel, 1);
	PlayerTextDrawLetterSize		(playerid, kp_KeyCancel, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_KeyCancel, 255);
	PlayerTextDrawSetOutline		(playerid, kp_KeyCancel, 1);
	PlayerTextDrawSetProportional	(playerid, kp_KeyCancel, 1);
	PlayerTextDrawUseBox			(playerid, kp_KeyCancel, 1);
	PlayerTextDrawBoxColor			(playerid, kp_KeyCancel, 538976384);
	PlayerTextDrawTextSize			(playerid, kp_KeyCancel, 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_KeyCancel, true);

	kp_Key0							=CreatePlayerTextDraw(playerid, 320.000000, 330.000000, "0");
	PlayerTextDrawAlignment			(playerid, kp_Key0, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key0, -1);
	PlayerTextDrawFont				(playerid, kp_Key0, 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key0, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key0, 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key0, 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key0, 1);
	PlayerTextDrawUseBox			(playerid, kp_Key0, 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key0, 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key0, 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key0, true);

	kp_Key1							=CreatePlayerTextDraw(playerid, 290.000000, 300.000000, "1");
	PlayerTextDrawAlignment			(playerid, kp_Key1, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key1, -1);
	PlayerTextDrawFont				(playerid, kp_Key1, 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key1, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key1, 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key1, 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key1, 1);
	PlayerTextDrawUseBox			(playerid, kp_Key1, 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key1, 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key1, 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key1, true);

	kp_Key2							=CreatePlayerTextDraw(playerid, 320.000000, 300.000000, "2");
	PlayerTextDrawAlignment			(playerid, kp_Key2, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key2, -1);
	PlayerTextDrawFont				(playerid, kp_Key2, 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key2, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key2, 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key2, 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key2, 1);
	PlayerTextDrawUseBox			(playerid, kp_Key2, 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key2, 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key2, 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key2, true);

	kp_Key3							=CreatePlayerTextDraw(playerid, 350.000000, 300.000000, "3");
	PlayerTextDrawAlignment			(playerid, kp_Key3, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key3, -1);
	PlayerTextDrawFont				(playerid, kp_Key3, 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key3, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key3, 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key3, 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key3, 1);
	PlayerTextDrawUseBox			(playerid, kp_Key3, 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key3, 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key3, 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key3, true);

	kp_Key4							=CreatePlayerTextDraw(playerid, 290.000000, 270.000000, "4");
	PlayerTextDrawAlignment			(playerid, kp_Key4, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key4, -1);
	PlayerTextDrawFont				(playerid, kp_Key4, 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key4, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key4, 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key4, 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key4, 1);
	PlayerTextDrawUseBox			(playerid, kp_Key4, 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key4, 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key4, 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key4, true);

	kp_Key5							=CreatePlayerTextDraw(playerid, 320.000000, 270.000000, "5");
	PlayerTextDrawAlignment			(playerid, kp_Key5, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key5, -1);
	PlayerTextDrawFont				(playerid, kp_Key5, 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key5, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key5, 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key5, 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key5, 1);
	PlayerTextDrawUseBox			(playerid, kp_Key5, 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key5, 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key5, 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key5, true);

	kp_Key6							=CreatePlayerTextDraw(playerid, 350.000000, 270.000000, "6");
	PlayerTextDrawAlignment			(playerid, kp_Key6, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key6, -1);
	PlayerTextDrawFont				(playerid, kp_Key6, 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key6, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key6, 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key6, 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key6, 1);
	PlayerTextDrawUseBox			(playerid, kp_Key6, 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key6, 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key6, 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key6, true);

	kp_Key7							=CreatePlayerTextDraw(playerid, 290.000000, 240.000000, "7");
	PlayerTextDrawAlignment			(playerid, kp_Key7, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key7, -1);
	PlayerTextDrawFont				(playerid, kp_Key7, 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key7, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key7, 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key7, 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key7, 1);
	PlayerTextDrawUseBox			(playerid, kp_Key7, 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key7, 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key7, 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key7, true);

	kp_Key8						=CreatePlayerTextDraw(playerid, 320.000000, 240.000000, "8");
	PlayerTextDrawAlignment			(playerid, kp_Key8, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key8, -1);
	PlayerTextDrawFont				(playerid, kp_Key8, 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key8, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key8, 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key8, 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key8, 1);
	PlayerTextDrawUseBox			(playerid, kp_Key8, 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key8, 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key8, 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key8, true);

	kp_Key9							=CreatePlayerTextDraw(playerid, 350.000000, 240.000000, "9");
	PlayerTextDrawAlignment			(playerid, kp_Key9, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key9, -1);
	PlayerTextDrawFont				(playerid, kp_Key9, 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key9, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key9, 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key9, 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key9, 1);
	PlayerTextDrawUseBox			(playerid, kp_Key9, 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key9, 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key9, 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key9, true);

	kp_Display						=CreatePlayerTextDraw(playerid, 320.000000, 210.000000, "0000");
	PlayerTextDrawAlignment			(playerid, kp_Display, 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Display, -1);
	PlayerTextDrawFont				(playerid, kp_Display, 2);
	PlayerTextDrawLetterSize		(playerid, kp_Display, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Display, -65281);
	PlayerTextDrawSetOutline		(playerid, kp_Display, 0);
	PlayerTextDrawSetProportional	(playerid, kp_Display, 1);
	PlayerTextDrawSetShadow			(playerid, kp_Display, 0);
	PlayerTextDrawUseBox			(playerid, kp_Display, 1);
	PlayerTextDrawBoxColor			(playerid, kp_Display, 255);
	PlayerTextDrawTextSize			(playerid, kp_Display, 20.000000, 80.000000);

	return 1;
}

//hook OnPlayerDisconnect(playerid)
UnLoadTD(playerid)
{
	PlayerTextDrawDestroy(playerid, kp_Background);
	PlayerTextDrawDestroy(playerid, kp_EdgeL);
	PlayerTextDrawDestroy(playerid, kp_EdgeT);
	PlayerTextDrawDestroy(playerid, kp_EdgeB);
	PlayerTextDrawDestroy(playerid, kp_EdgeR);
	PlayerTextDrawDestroy(playerid, kp_KeyEnter);
	PlayerTextDrawDestroy(playerid, kp_KeyCancel);
	PlayerTextDrawDestroy(playerid, kp_Key0);
	PlayerTextDrawDestroy(playerid, kp_Key1);
	PlayerTextDrawDestroy(playerid, kp_Key2);
	PlayerTextDrawDestroy(playerid, kp_Key3);
	PlayerTextDrawDestroy(playerid, kp_Key4);
	PlayerTextDrawDestroy(playerid, kp_Key5);
	PlayerTextDrawDestroy(playerid, kp_Key6);
	PlayerTextDrawDestroy(playerid, kp_Key7);
	PlayerTextDrawDestroy(playerid, kp_Key8);
	PlayerTextDrawDestroy(playerid, kp_Key9);
	PlayerTextDrawDestroy(playerid, kp_Display);

	return 1;
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:clickedid)
{
	if(clickedid == kp_KeyEnter)
		KeypadEnter(playerid);

	if(clickedid == kp_KeyCancel)
		HideKeypad(playerid);

	if(clickedid == kp_Key0)
		KeypadAddNumber(playerid, 0);

	if(clickedid == kp_Key1)
		KeypadAddNumber(playerid, 1);

	if(clickedid == kp_Key2)
		KeypadAddNumber(playerid, 2);

	if(clickedid == kp_Key3)
		KeypadAddNumber(playerid, 3);

	if(clickedid == kp_Key4)
		KeypadAddNumber(playerid, 4);

	if(clickedid == kp_Key5)
		KeypadAddNumber(playerid, 5);

	if(clickedid == kp_Key6)
		KeypadAddNumber(playerid, 6);

	if(clickedid == kp_Key7)
		KeypadAddNumber(playerid, 7);

	if(clickedid == kp_Key8)
		KeypadAddNumber(playerid, 8);

	if(clickedid == kp_Key9)
		KeypadAddNumber(playerid, 9);
}

KeypadEnter(playerid)
{
	if(kp_Value[playerid] == kp_Match[playerid])
	{
		HideKeypad(playerid);
		CallLocalFunction("OnPlayerKeypadEnter", "dd", playerid, 1);
	}
	else
	{
		CallLocalFunction("OnPlayerKeypadEnter", "dd", playerid, 0);
		kp_Value[playerid] = 0000;
		ShowKeypad(playerid, kp_Match[playerid]);
	}
}

KeypadAddNumber(playerid, number)
{
	if(kp_Value[playerid] >= 9999)
		return 0;

	kp_Value[playerid] = (kp_Value[playerid] * 10) + number;
	KeypadUpdateDisplay(playerid);

	return 1;
}

KeypadUpdateDisplay(playerid)
{
	new str[5];
	format(str, 5, "%04d", kp_Value[playerid]);
	PlayerTextDrawSetString(playerid, kp_Display, str);
	PlayerTextDrawShow(playerid, kp_Display);
}

public OnPlayerKeypadEnter(playerid, success)
{
}

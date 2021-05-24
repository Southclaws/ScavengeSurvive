/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


new
		PlayerText:kp_Background[MAX_PLAYERS],
		PlayerText:kp_EdgeL[MAX_PLAYERS],
		PlayerText:kp_EdgeT[MAX_PLAYERS],
		PlayerText:kp_EdgeB[MAX_PLAYERS],
		PlayerText:kp_EdgeR[MAX_PLAYERS],
		PlayerText:kp_KeyEnter[MAX_PLAYERS],
		PlayerText:kp_KeyCancel[MAX_PLAYERS],
		PlayerText:kp_Key0[MAX_PLAYERS],
		PlayerText:kp_Key1[MAX_PLAYERS],
		PlayerText:kp_Key2[MAX_PLAYERS],
		PlayerText:kp_Key3[MAX_PLAYERS],
		PlayerText:kp_Key4[MAX_PLAYERS],
		PlayerText:kp_Key5[MAX_PLAYERS],
		PlayerText:kp_Key6[MAX_PLAYERS],
		PlayerText:kp_Key7[MAX_PLAYERS],
		PlayerText:kp_Key8[MAX_PLAYERS],
		PlayerText:kp_Key9[MAX_PLAYERS],
		PlayerText:kp_Display[MAX_PLAYERS];

new
		kp_Value[MAX_PLAYERS],
		kp_Match[MAX_PLAYERS],
		kp_CurrentID[MAX_PLAYERS],
		kp_Hacking[MAX_PLAYERS],
Timer:	kp_HackTimer[MAX_PLAYERS],
		kp_HackTries[MAX_PLAYERS],
		kp_HackFailParticle[MAX_PLAYERS];

static Func:kp_CallbackResponse[MAX_PLAYERS]<dddd>;
static Func:kp_CallbackCancel[MAX_PLAYERS]<dddd>;


#if defined FILTERSCRIPT
	hook OnFilterScriptInit()
	{
		for(new i; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i))
				kp_LoadUI(i);
		}
		return 1;
	}
#endif


forward OnPlayerKeypadEnter(playerid, keypadid, code, match);
forward OnPlayerKeypadCancel(playerid, keypadid);


stock ShowKeypad(playerid, keypadid, match = -1)
{
	PlayerTextDrawShow(playerid, kp_Background[playerid]);
	PlayerTextDrawShow(playerid, kp_EdgeL[playerid]);
	PlayerTextDrawShow(playerid, kp_EdgeT[playerid]);
	PlayerTextDrawShow(playerid, kp_EdgeB[playerid]);
	PlayerTextDrawShow(playerid, kp_EdgeR[playerid]);
	PlayerTextDrawShow(playerid, kp_KeyEnter[playerid]);
	PlayerTextDrawShow(playerid, kp_KeyCancel[playerid]);
	PlayerTextDrawShow(playerid, kp_Key0[playerid]);
	PlayerTextDrawShow(playerid, kp_Key1[playerid]);
	PlayerTextDrawShow(playerid, kp_Key2[playerid]);
	PlayerTextDrawShow(playerid, kp_Key3[playerid]);
	PlayerTextDrawShow(playerid, kp_Key4[playerid]);
	PlayerTextDrawShow(playerid, kp_Key5[playerid]);
	PlayerTextDrawShow(playerid, kp_Key6[playerid]);
	PlayerTextDrawShow(playerid, kp_Key7[playerid]);
	PlayerTextDrawShow(playerid, kp_Key8[playerid]);
	PlayerTextDrawShow(playerid, kp_Key9[playerid]);
	PlayerTextDrawShow(playerid, kp_Display[playerid]);
	SelectTextDraw(playerid, 0xFF0000FF);

	kp_Value[playerid] = 0;
	kp_Match[playerid] = match;
	kp_CurrentID[playerid] = keypadid;
	KeypadUpdateDisplay(playerid);
	
	HideActionText(playerid);
	PlayerPlaySound(playerid, 21002, 0.0, 0.0, 0.0); // Keyboard sound

	return 1;
}

stock ShowKeypad_Callback(playerid, Func:response<dddd>, Func:cancel<dddd>, match = 0)
{
	if(kp_CurrentID[playerid] != -1)
		return 0;

	Callback_Get(response, kp_CallbackResponse[playerid]);
	Callback_Get(cancel, kp_CallbackCancel[playerid]);

	ShowKeypad(playerid, 0xFFFFFFFF, match);

	return 1;
}

stock HideKeypad(playerid)
{
	if(kp_CurrentID[playerid] == -1)
		return 0;

	if(kp_Hacking[playerid])
	{
		kp_Hacking[playerid] = 0;
		kp_HackTries[playerid] = 0;
		stop kp_HackTimer[playerid];
		ClearAnimations(playerid);
	}

	PlayerTextDrawHide(playerid, kp_Background[playerid]);
	PlayerTextDrawHide(playerid, kp_EdgeL[playerid]);
	PlayerTextDrawHide(playerid, kp_EdgeT[playerid]);
	PlayerTextDrawHide(playerid, kp_EdgeB[playerid]);
	PlayerTextDrawHide(playerid, kp_EdgeR[playerid]);
	PlayerTextDrawHide(playerid, kp_KeyEnter[playerid]);
	PlayerTextDrawHide(playerid, kp_KeyCancel[playerid]);
	PlayerTextDrawHide(playerid, kp_Key0[playerid]);
	PlayerTextDrawHide(playerid, kp_Key1[playerid]);
	PlayerTextDrawHide(playerid, kp_Key2[playerid]);
	PlayerTextDrawHide(playerid, kp_Key3[playerid]);
	PlayerTextDrawHide(playerid, kp_Key4[playerid]);
	PlayerTextDrawHide(playerid, kp_Key5[playerid]);
	PlayerTextDrawHide(playerid, kp_Key6[playerid]);
	PlayerTextDrawHide(playerid, kp_Key7[playerid]);
	PlayerTextDrawHide(playerid, kp_Key8[playerid]);
	PlayerTextDrawHide(playerid, kp_Key9[playerid]);
	PlayerTextDrawHide(playerid, kp_Display[playerid]);
	CancelSelectTextDraw(playerid);

	kp_CurrentID[playerid] = -1;
	kp_Value[playerid] = 0;
	kp_Match[playerid] = 0;
	
	PlayerPlaySound(playerid, 21002, 0.0, 0.0, 0.0); // Keyboard sound

	return 1;
}

stock CancelKeypad(playerid)
{
	if(kp_CurrentID[playerid] == -1)
		return 0;

	// if(kp_CurrentID[playerid] == 0xFFFFFFFF)
	// 	@.kp_CallbackCancel[playerid](playerid, 0xFFFFFFFF);

	// else
	// 	CallLocalFunction("OnPlayerKeypadCancel", "dd", playerid, kp_CurrentID[playerid]);

	HideKeypad(playerid);

	return 1;
}

stock HackKeypad(playerid, keypadid, match)
{
	if(kp_Hacking[playerid] != 1)
	{
		kp_Hacking[playerid] = 1;
		kp_HackTimer[playerid] = repeat HackKeypadUpdate(playerid, keypadid, match);
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
	}
}

timer HackKeypadUpdate[100](playerid, keypadid, match)
{
	if(kp_HackTries[playerid] >= 100)
	{
		kp_Hacking[playerid] = 0;
		kp_HackTries[playerid] = 0;
		stop kp_HackTimer[playerid];

		if(random(100) < 40)
		{
			kp_Value[playerid] = match;
			ClearAnimations(playerid);
			KeypadUpdateDisplay(playerid);
			defer HackKeypadFinish(playerid, keypadid, match, match);
		}
		else
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetPlayerPos(playerid, x, y, z);

			kp_HackFailParticle[playerid] = CreateDynamicObject(18724, x, y, z - 1.5, 0.0, 0.0, 0.0);
			defer kp_PrtDestroy(playerid);
			GivePlayerHP(playerid, -5);
			KnockOutPlayer(playerid, 3000);
			defer HackKeypadFinish(playerid, keypadid, kp_Value[playerid], match);
		}

		return;
	}

	kp_Value[playerid] = 1000 + random(8999);
	KeypadUpdateDisplay(playerid);

	kp_HackTries[playerid]++;

	return;
}

timer HackKeypadFinish[1000](playerid, keypadid, code, match)
{
	CallLocalFunction("OnPlayerKeypadEnter", "dddd", playerid, keypadid, code, match);
}

timer kp_PrtDestroy[2000](playerid)
{
	DestroyDynamicObject(kp_HackFailParticle[playerid]);
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	if(playertextid == kp_KeyEnter[playerid])
		KeypadEnter(playerid);

	if(playertextid == kp_KeyCancel[playerid])
		CancelKeypad(playerid);

	if(playertextid == kp_Key0[playerid])
		KeypadAddNumber(playerid, 0);

	if(playertextid == kp_Key1[playerid])
		KeypadAddNumber(playerid, 1);

	if(playertextid == kp_Key2[playerid])
		KeypadAddNumber(playerid, 2);

	if(playertextid == kp_Key3[playerid])
		KeypadAddNumber(playerid, 3);

	if(playertextid == kp_Key4[playerid])
		KeypadAddNumber(playerid, 4);

	if(playertextid == kp_Key5[playerid])
		KeypadAddNumber(playerid, 5);

	if(playertextid == kp_Key6[playerid])
		KeypadAddNumber(playerid, 6);

	if(playertextid == kp_Key7[playerid])
		KeypadAddNumber(playerid, 7);

	if(playertextid == kp_Key8[playerid])
		KeypadAddNumber(playerid, 8);

	if(playertextid == kp_Key9[playerid])
		KeypadAddNumber(playerid, 9);

	return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(kp_CurrentID[playerid] != -1)
	{
		if(clickedid == Text:65535)
			SelectTextDraw(playerid, 0xFF0000FF);
	}

	return 1;
}

KeypadEnter(playerid)
{
	new ret;

	// if(kp_CurrentID[playerid] == 0xFFFFFFFF)
	// 	@.cb(kp_CallbackResponse[playerid], playerid, 0xFFFFFFFF, kp_Value[playerid], kp_Match[playerid]);

	// else
	ret = CallLocalFunction("OnPlayerKeypadEnter", "dddd", playerid, kp_CurrentID[playerid], kp_Value[playerid], kp_Match[playerid]);

	if(ret || kp_Value[playerid] == kp_Match[playerid])
		HideKeypad(playerid);
}

KeypadAddNumber(playerid, number)
{
	new result = (kp_Value[playerid] * 10) + number;

	if(result > 9999)
		return 0;

	kp_Value[playerid] = result;
	KeypadUpdateDisplay(playerid);
	
	PlayerPlaySound(playerid, 17006, 0.0, 0.0, 0.0); // Number sound

	return 1;
}

KeypadUpdateDisplay(playerid)
{
	new str[5];
	format(str, 5, "%04d", kp_Value[playerid]);
	PlayerTextDrawSetString(playerid, kp_Display[playerid], str);
	PlayerTextDrawShow(playerid, kp_Display[playerid]);
}

hook OnPlayerConnect(playerid)
{
	kp_LoadUI(playerid);
}

kp_LoadUI(playerid)
{
	kp_CurrentID[playerid] = -1;

	kp_Background[playerid]			=CreatePlayerTextDraw(playerid, 320.000000, 204.000000, "_");
	PlayerTextDrawAlignment			(playerid, kp_Background[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Background[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_Background[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_Background[playerid], 0.500000, 16.199998);
	PlayerTextDrawColor				(playerid, kp_Background[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_Background[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_Background[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_Background[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_Background[playerid], 80);
	PlayerTextDrawTextSize			(playerid, kp_Background[playerid], 20.000000, 82.000000);

	kp_EdgeL[playerid]				=CreatePlayerTextDraw(playerid, 275.000000, 204.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, kp_EdgeL[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_EdgeL[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_EdgeL[playerid], 0.500000, -1.100000);
	PlayerTextDrawColor				(playerid, kp_EdgeL[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_EdgeL[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_EdgeL[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_EdgeL[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_EdgeL[playerid], -2021161081);
	PlayerTextDrawTextSize			(playerid, kp_EdgeL[playerid], 361.000000, 82.000000);

	kp_EdgeT[playerid]				=CreatePlayerTextDraw(playerid, 275.000000, 204.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, kp_EdgeT[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_EdgeT[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_EdgeT[playerid], 0.500000, 16.199998);
	PlayerTextDrawColor				(playerid, kp_EdgeT[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_EdgeT[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_EdgeT[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_EdgeT[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_EdgeT[playerid], -2021161081);
	PlayerTextDrawTextSize			(playerid, kp_EdgeT[playerid], 275.000000, 82.000000);

	kp_EdgeB[playerid]				=CreatePlayerTextDraw(playerid, 275.000000, 359.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, kp_EdgeB[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_EdgeB[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_EdgeB[playerid], 0.500000, -1.100000);
	PlayerTextDrawColor				(playerid, kp_EdgeB[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_EdgeB[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_EdgeB[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_EdgeB[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_EdgeB[playerid], -2021161081);
	PlayerTextDrawTextSize			(playerid, kp_EdgeB[playerid], 365.000000, 82.000000);

	kp_EdgeR[playerid]				=CreatePlayerTextDraw(playerid, 365.000000, 199.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, kp_EdgeR[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_EdgeR[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_EdgeR[playerid], 0.500000, 16.800001);
	PlayerTextDrawColor				(playerid, kp_EdgeR[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_EdgeR[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_EdgeR[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_EdgeR[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_EdgeR[playerid], -2021161081);
	PlayerTextDrawTextSize			(playerid, kp_EdgeR[playerid], 365.000000, 82.000000);

	kp_KeyEnter[playerid]			=CreatePlayerTextDraw(playerid, 350.000000, 330.000000, ">");
	PlayerTextDrawAlignment			(playerid, kp_KeyEnter[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_KeyEnter[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_KeyEnter[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_KeyEnter[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_KeyEnter[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_KeyEnter[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_KeyEnter[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_KeyEnter[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_KeyEnter[playerid], 538976384);
	PlayerTextDrawTextSize			(playerid, kp_KeyEnter[playerid], 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_KeyEnter[playerid], true);

	kp_KeyCancel[playerid]			=CreatePlayerTextDraw(playerid, 290.000000, 330.000000, "X");
	PlayerTextDrawAlignment			(playerid, kp_KeyCancel[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_KeyCancel[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_KeyCancel[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_KeyCancel[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_KeyCancel[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_KeyCancel[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_KeyCancel[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_KeyCancel[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_KeyCancel[playerid], 538976384);
	PlayerTextDrawTextSize			(playerid, kp_KeyCancel[playerid], 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_KeyCancel[playerid], true);

	kp_Key0[playerid]				=CreatePlayerTextDraw(playerid, 320.000000, 330.000000, "0");
	PlayerTextDrawAlignment			(playerid, kp_Key0[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key0[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_Key0[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key0[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key0[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key0[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key0[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_Key0[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key0[playerid], 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key0[playerid], 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key0[playerid], true);

	kp_Key1[playerid]				=CreatePlayerTextDraw(playerid, 290.000000, 300.000000, "1");
	PlayerTextDrawAlignment			(playerid, kp_Key1[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key1[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_Key1[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key1[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key1[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key1[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key1[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_Key1[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key1[playerid], 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key1[playerid], 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key1[playerid], true);

	kp_Key2[playerid]				=CreatePlayerTextDraw(playerid, 320.000000, 300.000000, "2");
	PlayerTextDrawAlignment			(playerid, kp_Key2[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key2[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_Key2[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key2[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key2[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key2[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key2[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_Key2[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key2[playerid], 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key2[playerid], 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key2[playerid], true);

	kp_Key3[playerid]				=CreatePlayerTextDraw(playerid, 350.000000, 300.000000, "3");
	PlayerTextDrawAlignment			(playerid, kp_Key3[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key3[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_Key3[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key3[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key3[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key3[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key3[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_Key3[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key3[playerid], 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key3[playerid], 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key3[playerid], true);

	kp_Key4[playerid]				=CreatePlayerTextDraw(playerid, 290.000000, 270.000000, "4");
	PlayerTextDrawAlignment			(playerid, kp_Key4[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key4[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_Key4[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key4[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key4[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key4[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key4[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_Key4[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key4[playerid], 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key4[playerid], 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key4[playerid], true);

	kp_Key5[playerid]				=CreatePlayerTextDraw(playerid, 320.000000, 270.000000, "5");
	PlayerTextDrawAlignment			(playerid, kp_Key5[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key5[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_Key5[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key5[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key5[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key5[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key5[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_Key5[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key5[playerid], 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key5[playerid], 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key5[playerid], true);

	kp_Key6[playerid]				=CreatePlayerTextDraw(playerid, 350.000000, 270.000000, "6");
	PlayerTextDrawAlignment			(playerid, kp_Key6[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key6[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_Key6[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key6[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key6[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key6[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key6[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_Key6[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key6[playerid], 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key6[playerid], 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key6[playerid], true);

	kp_Key7[playerid]				=CreatePlayerTextDraw(playerid, 290.000000, 240.000000, "7");
	PlayerTextDrawAlignment			(playerid, kp_Key7[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key7[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_Key7[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key7[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key7[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key7[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key7[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_Key7[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key7[playerid], 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key7[playerid], 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key7[playerid], true);

	kp_Key8[playerid]				=CreatePlayerTextDraw(playerid, 320.000000, 240.000000, "8");
	PlayerTextDrawAlignment			(playerid, kp_Key8[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key8[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_Key8[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key8[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key8[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key8[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key8[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_Key8[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key8[playerid], 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key8[playerid], 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key8[playerid], true);

	kp_Key9[playerid]				=CreatePlayerTextDraw(playerid, 350.000000, 240.000000, "9");
	PlayerTextDrawAlignment			(playerid, kp_Key9[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Key9[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_Key9[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, kp_Key9[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Key9[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, kp_Key9[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, kp_Key9[playerid], 1);
	PlayerTextDrawUseBox			(playerid, kp_Key9[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_Key9[playerid], 538976384);
	PlayerTextDrawTextSize			(playerid, kp_Key9[playerid], 20.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, kp_Key9[playerid], true);

	kp_Display[playerid]			=CreatePlayerTextDraw(playerid, 320.000000, 210.000000, "0000");
	PlayerTextDrawAlignment			(playerid, kp_Display[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, kp_Display[playerid], -1);
	PlayerTextDrawFont				(playerid, kp_Display[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, kp_Display[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, kp_Display[playerid], -65281);
	PlayerTextDrawSetOutline		(playerid, kp_Display[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, kp_Display[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, kp_Display[playerid], 0);
	PlayerTextDrawUseBox			(playerid, kp_Display[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, kp_Display[playerid], 255);
	PlayerTextDrawTextSize			(playerid, kp_Display[playerid], 20.000000, 80.000000);

	return 1;
}

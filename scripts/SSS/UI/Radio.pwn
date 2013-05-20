#include <YSI\y_hooks>


#define MAX_RADIO_FREQ (108.0)
#define MIN_RADIO_FREQ (87.5)


static
	rad_InventoryItem[MAX_PLAYERS],
	rad_ViewingRadio[MAX_PLAYERS],
	rad_OldMode[MAX_PLAYERS],
	PlayerText:RadioUI_Main,
	PlayerText:RadioUI_Strip,
	PlayerText:RadioUI_KnobL,
	PlayerText:RadioUI_KnobR,
	PlayerText:RadioUI_Mode,
	PlayerText:RadioUI_Freq,
	PlayerText:RadioUI_Power,
	PlayerText:RadioUI_Back;


ShowRadioUI(playerid)
{
	PlayerTextDrawShow(playerid, RadioUI_Main);
	PlayerTextDrawShow(playerid, RadioUI_Strip);
	PlayerTextDrawShow(playerid, RadioUI_KnobL);
	PlayerTextDrawShow(playerid, RadioUI_KnobR);
	PlayerTextDrawShow(playerid, RadioUI_Mode);
	PlayerTextDrawShow(playerid, RadioUI_Freq);
	PlayerTextDrawShow(playerid, RadioUI_Power);
	PlayerTextDrawShow(playerid, RadioUI_Back);

	SelectTextDraw(playerid, 0xFFFFFF88);
	UpdateRadioUI(playerid);

	rad_ViewingRadio[playerid] = true;
}

HideRadioUI(playerid)
{
	PlayerTextDrawHide(playerid, RadioUI_Main);
	PlayerTextDrawHide(playerid, RadioUI_Strip);
	PlayerTextDrawHide(playerid, RadioUI_KnobL);
	PlayerTextDrawHide(playerid, RadioUI_KnobR);
	PlayerTextDrawHide(playerid, RadioUI_Mode);
	PlayerTextDrawHide(playerid, RadioUI_Freq);
	PlayerTextDrawHide(playerid, RadioUI_Power);
	PlayerTextDrawHide(playerid, RadioUI_Back);

	if(!IsPlayerInAnyVehicle(playerid))
		DisplayPlayerInventory(playerid);

	else
		CancelSelectTextDraw(playerid);

	rad_ViewingRadio[playerid] = false;
}

UpdateRadioUI(playerid)
{
	new str[18];

	format(str, 18, "Frequency: %.2f", gPlayerFrequency[playerid]);
	PlayerTextDrawSetString(playerid, RadioUI_Freq, str);

	if(Bit2_Get(gPlayerChatMode, playerid) == CHAT_MODE_LOCAL)
	{
		PlayerTextDrawSetString(playerid, RadioUI_Power, "off");

		if(rad_OldMode[playerid] == CHAT_MODE_GLOBAL)
			PlayerTextDrawSetString(playerid, RadioUI_Mode, "global");

		else
			PlayerTextDrawSetString(playerid, RadioUI_Mode, "freq");
	}

	if(Bit2_Get(gPlayerChatMode, playerid) == CHAT_MODE_GLOBAL)
	{
		PlayerTextDrawSetString(playerid, RadioUI_Mode, "global");
		PlayerTextDrawSetString(playerid, RadioUI_Power, "on");
	}

	if(Bit2_Get(gPlayerChatMode, playerid) == CHAT_MODE_RADIO)
	{
		PlayerTextDrawSetString(playerid, RadioUI_Mode, "freq");
		PlayerTextDrawSetString(playerid, RadioUI_Power, "on");
	}
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:clickedid)
{
	if(clickedid == RadioUI_KnobL)
	{
		gPlayerFrequency[playerid] -= 0.5;

		if(gPlayerFrequency[playerid] > MAX_RADIO_FREQ)
			gPlayerFrequency[playerid] = MIN_RADIO_FREQ;

		UpdateRadioUI(playerid);
	}
	if(clickedid == RadioUI_KnobR)
	{
		gPlayerFrequency[playerid] += 0.5;

		if(gPlayerFrequency[playerid] < MIN_RADIO_FREQ)
			gPlayerFrequency[playerid] = MAX_RADIO_FREQ;

		UpdateRadioUI(playerid);
	}
	if(clickedid == RadioUI_Mode)
	{
		if(Bit2_Get(gPlayerChatMode, playerid) == CHAT_MODE_GLOBAL)
			Bit2_Set(gPlayerChatMode, playerid, CHAT_MODE_RADIO);

		else if(Bit2_Get(gPlayerChatMode, playerid) == CHAT_MODE_RADIO)
			Bit2_Set(gPlayerChatMode, playerid, CHAT_MODE_GLOBAL);

		UpdateRadioUI(playerid);
	}
	if(clickedid == RadioUI_Freq)
	{
		ShowPlayerDialog(playerid, d_Radio, DIALOG_STYLE_INPUT, "Frequency", "Enter a frequency between 87.5 and 108.0", "Accept", "Cancel");
	}
	if(clickedid == RadioUI_Power)
	{
		if(Bit2_Get(gPlayerChatMode, playerid) == CHAT_MODE_LOCAL)
		{
			if(rad_OldMode[playerid] == CHAT_MODE_GLOBAL)
				Bit2_Set(gPlayerChatMode, playerid, CHAT_MODE_GLOBAL);

			else
				Bit2_Set(gPlayerChatMode, playerid, CHAT_MODE_RADIO);
		}
		else
		{
			rad_OldMode[playerid] = Bit2_Get(gPlayerChatMode, playerid);
			Bit2_Set(gPlayerChatMode, playerid, CHAT_MODE_LOCAL);
		}

		UpdateRadioUI(playerid);
	}
	if(clickedid == RadioUI_Back)
	{
		HideRadioUI(playerid);
	}
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_Radio)
	{
		if(response)
		{
			new Float:frequency;
			if(!sscanf(inputtext, "f", frequency))
			{
				if(MIN_RADIO_FREQ < frequency < MAX_RADIO_FREQ)
				{
					gPlayerFrequency[playerid] = frequency;
					UpdateRadioUI(playerid);
				}
				else
				{
					ShowPlayerDialog(playerid, d_Radio, DIALOG_STYLE_INPUT, "Frequency", "Enter a frequency between 87.5 and 108.0", "Accept", "Cancel");
				}
			}
			else
			{
				ShowPlayerDialog(playerid, d_Radio, DIALOG_STYLE_INPUT, "Frequency", "Enter a frequency between 87.5 and 108.0", "Accept", "Cancel");
			}
		}
	}

	return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(rad_ViewingRadio[playerid])
		{
			SelectTextDraw(playerid, 0xFFFFFF88);
		}
	}
}


public OnPlayerOpenInventory(playerid)
{
	rad_InventoryItem[playerid] = AddInventoryListItem(playerid, "Radio");

	return CallLocalFunction("rad_OnPlayerOpenInventory", "d", playerid);
}
#if defined _ALS_OnPlayerOpenInventory
	#undef OnPlayerOpenInventory
#else
	#define _ALS_OnPlayerOpenInventory
#endif
#define OnPlayerOpenInventory rad_OnPlayerOpenInventory
forward OnPlayerOpenInventory(playerid);

public OnPlayerSelectExtraItem(playerid, item)
{
	if(item == rad_InventoryItem[playerid])
	{
		ShowRadioUI(playerid);
	}

	return CallLocalFunction("rad_OnPlayerSelectExtraItem", "dd", playerid, item);
}
#if defined _ALS_OnPlayerSelectExtraItem
	#undef OnPlayerSelectExtraItem
#else
	#define _ALS_OnPlayerSelectExtraItem
#endif
#define OnPlayerSelectExtraItem rad_OnPlayerSelectExtraItem
forward OnPlayerSelectExtraItem(playerid, item);


hook OnPlayerConnect(playerid)
{
	RadioUI_Main					= CreatePlayerTextDraw(playerid, 320.000000, 200.000000, "RADIO~n~ ~n~ ~n~ ~n~ ~n~ ");
	PlayerTextDrawAlignment			(playerid, RadioUI_Main, 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Main, 255);
	PlayerTextDrawFont				(playerid, RadioUI_Main, 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Main, 0.500000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Main, -1);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Main, 1);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Main, 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Main, 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Main, 100);
	PlayerTextDrawTextSize			(playerid, RadioUI_Main, 0.000000, 200.000000);

	RadioUI_Strip					= CreatePlayerTextDraw(playerid, 320.000000, 220.000000, "-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-");
	PlayerTextDrawAlignment			(playerid, RadioUI_Strip, 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Strip, 255);
	PlayerTextDrawFont				(playerid, RadioUI_Strip, 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Strip, 0.300000, 1.000000);
	PlayerTextDrawColor				(playerid, RadioUI_Strip, -1);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Strip, 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Strip, 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Strip, 0);

	RadioUI_KnobL					= CreatePlayerTextDraw(playerid, 220.000000, 203.000000, "LD_DRV:nawtxt");
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_KnobL, 255);
	PlayerTextDrawFont				(playerid, RadioUI_KnobL, 4);
	PlayerTextDrawLetterSize		(playerid, RadioUI_KnobL, 0.500000, 1.000000);
	PlayerTextDrawColor				(playerid, RadioUI_KnobL, 0x780000FA);
	PlayerTextDrawSetOutline		(playerid, RadioUI_KnobL, 1);
	PlayerTextDrawSetProportional	(playerid, RadioUI_KnobL, 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_KnobL, 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_KnobL, 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_KnobL, 30.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_KnobL, true);

	RadioUI_KnobR					= CreatePlayerTextDraw(playerid, 390.000000, 203.000000, "LD_DRV:nawtxt");
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_KnobR, 255);
	PlayerTextDrawFont				(playerid, RadioUI_KnobR, 4);
	PlayerTextDrawLetterSize		(playerid, RadioUI_KnobR, 0.500000, 1.000000);
	PlayerTextDrawColor				(playerid, RadioUI_KnobR, 0x780000FA);
	PlayerTextDrawSetOutline		(playerid, RadioUI_KnobR, 1);
	PlayerTextDrawSetProportional	(playerid, RadioUI_KnobR, 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_KnobR, 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_KnobR, 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_KnobR, 30.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_KnobR, true);

	RadioUI_Mode					= CreatePlayerTextDraw(playerid, 238.000000, 251.000000, "global");
	PlayerTextDrawAlignment			(playerid, RadioUI_Mode, 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Mode, 255);
	PlayerTextDrawFont				(playerid, RadioUI_Mode, 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Mode, 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Mode, 16777215);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Mode, 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Mode, 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Mode, 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Mode, 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Mode, 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_Mode, 20.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_Mode, true);

	RadioUI_Freq					= CreatePlayerTextDraw(playerid, 320.000000, 251.000000, "Frequency: 00.00");
	PlayerTextDrawAlignment			(playerid, RadioUI_Freq, 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Freq, 255);
	PlayerTextDrawFont				(playerid, RadioUI_Freq, 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Freq, 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Freq, 16777215);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Freq, 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Freq, 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Freq, 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Freq, 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Freq, 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_Freq, 20.000000, 120.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_Freq, true);

	RadioUI_Power					= CreatePlayerTextDraw(playerid, 402.000000, 251.000000, "off");
	PlayerTextDrawAlignment			(playerid, RadioUI_Power, 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Power, 255);
	PlayerTextDrawFont				(playerid, RadioUI_Power, 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Power, 0.400000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Power, -16776961);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Power, 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Power, 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Power, 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Power, 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Power, 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_Power, 20.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_Power, true);

	RadioUI_Back					= CreatePlayerTextDraw(playerid, 320.000000, 274.000000, "Close");
	PlayerTextDrawAlignment			(playerid, RadioUI_Back, 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Back, 255);
	PlayerTextDrawFont				(playerid, RadioUI_Back, 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Back, 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Back, -1);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Back, 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Back, 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Back, 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Back, 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Back, 100);
	PlayerTextDrawTextSize			(playerid, RadioUI_Back, 20.000000, 200.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_Back, true);

	rad_ViewingRadio[playerid] = 0;
}

hook OnPlayerDisconnect(playerid)
{
	PlayerTextDrawDestroy(playerid, RadioUI_Main);
	PlayerTextDrawDestroy(playerid, RadioUI_Strip);
	PlayerTextDrawDestroy(playerid, RadioUI_KnobL);
	PlayerTextDrawDestroy(playerid, RadioUI_KnobR);
	PlayerTextDrawDestroy(playerid, RadioUI_Mode);
	PlayerTextDrawDestroy(playerid, RadioUI_Freq);
	PlayerTextDrawDestroy(playerid, RadioUI_Power);
	PlayerTextDrawDestroy(playerid, RadioUI_Back);
}

#include <YSI\y_hooks>


static
Text:	page_Left,
Text:	page_Right;


forward OnPlayerDialogPage(playerid, direction);


ShowPlayerPageButtons(playerid)
{
	TextDrawShowForPlayer(playerid, page_Left);
	TextDrawShowForPlayer(playerid, page_Right);
	SelectTextDraw(playerid, YELLOW);
}

HidePlayerPageButtons(playerid)
{
	TextDrawHideForPlayer(playerid, page_Left);
	TextDrawHideForPlayer(playerid, page_Right);
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == page_Left)
	{
		#if defined OnPlayerDialogPage
			OnPlayerDialogPage(playerid, 0);
		#endif
	}
	if(clickedid == page_Right)
	{
		#if defined OnPlayerDialogPage
			OnPlayerDialogPage(playerid, 1);
		#endif
	}
}

hook OnGameModeInit()
{
	page_Left					=TextDrawCreate(280.0, 360.0, "<");
	TextDrawAlignment			(page_Left, 2);
	TextDrawBackgroundColor		(page_Left, 255);
	TextDrawFont				(page_Left, 1);
	TextDrawLetterSize			(page_Left, 0.5, 2.0);
	TextDrawColor				(page_Left, -1);
	TextDrawSetOutline			(page_Left, 0);
	TextDrawSetProportional		(page_Left, 1);
	TextDrawSetShadow			(page_Left, 1);
	TextDrawUseBox				(page_Left, 1);
	TextDrawBoxColor			(page_Left, 128);
	TextDrawTextSize			(page_Left, 25.0, 75.0);
	TextDrawSetSelectable		(page_Left, true);

	page_Right					=TextDrawCreate(360.0, 360.0, ">");
	TextDrawAlignment			(page_Right, 2);
	TextDrawBackgroundColor		(page_Right, 255);
	TextDrawFont				(page_Right, 1);
	TextDrawLetterSize			(page_Right, 0.5, 2.0);
	TextDrawColor				(page_Right, -1);
	TextDrawSetOutline			(page_Right, 0);
	TextDrawSetProportional		(page_Right, 1);
	TextDrawSetShadow			(page_Right, 1);
	TextDrawUseBox				(page_Right, 1);
	TextDrawBoxColor			(page_Right, 128);
	TextDrawTextSize			(page_Right, 25.0, 75.0);
	TextDrawSetSelectable		(page_Right, true);
}

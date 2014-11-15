#include <YSI\y_hooks>


LoadPlayerTextDraws(playerid)
{
//==============================================================Character Create

	ClassBackGround[playerid]		=CreatePlayerTextDraw(playerid, 0.000000, 0.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, ClassBackGround[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassBackGround[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassBackGround[playerid], 0.500000, 50.000000);
	PlayerTextDrawColor				(playerid, ClassBackGround[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassBackGround[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassBackGround[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassBackGround[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassBackGround[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassBackGround[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassBackGround[playerid], 640.000000, 0.000000);

	ClassButtonMale[playerid]		=CreatePlayerTextDraw(playerid, 250.000000, 200.000000, "~n~Male~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonMale[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonMale[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonMale[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonMale[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonMale[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonMale[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonMale[playerid], 44.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonMale[playerid], true);

	ClassButtonFemale[playerid]		=CreatePlayerTextDraw(playerid, 390.000000, 200.000000, "~n~Female~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonFemale[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonFemale[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonFemale[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonFemale[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonFemale[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonFemale[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonFemale[playerid], 44.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonFemale[playerid], true);


//===================================================================Weapon Ammo

	WeaponAmmo[playerid]			=CreatePlayerTextDraw(playerid, 520.000000, 64.000000, "500/500");
	PlayerTextDrawAlignment			(playerid, WeaponAmmo[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, WeaponAmmo[playerid], 255);
	PlayerTextDrawFont				(playerid, WeaponAmmo[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, WeaponAmmo[playerid], 0.210000, 1.000000);
	PlayerTextDrawColor				(playerid, WeaponAmmo[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, WeaponAmmo[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, WeaponAmmo[playerid], 1);
	PlayerTextDrawUseBox			(playerid, WeaponAmmo[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, WeaponAmmo[playerid], 255);
	PlayerTextDrawTextSize			(playerid, WeaponAmmo[playerid], 548.000000, 40.000000);


//======================================================================Tooltips

	ToolTip[playerid]				=CreatePlayerTextDraw(playerid, 618.000000, 120.000000, "fixed it");
	PlayerTextDrawAlignment			(playerid, ToolTip[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, ToolTip[playerid], 255);
	PlayerTextDrawFont				(playerid, ToolTip[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ToolTip[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, ToolTip[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ToolTip[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, ToolTip[playerid], 1);


//======================================================================Food Bar

	HungerBarBackground[playerid]	=CreatePlayerTextDraw(playerid, 612.000000, 101.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, HungerBarBackground[playerid], 255);
	PlayerTextDrawFont				(playerid, HungerBarBackground[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, HungerBarBackground[playerid], 0.500000, -10.200000);
	PlayerTextDrawColor				(playerid, HungerBarBackground[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, HungerBarBackground[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, HungerBarBackground[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, HungerBarBackground[playerid], 1);
	PlayerTextDrawUseBox			(playerid, HungerBarBackground[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, HungerBarBackground[playerid], 255);
	PlayerTextDrawTextSize			(playerid, HungerBarBackground[playerid], 618.000000, 10.000000);

	HungerBarForeground[playerid]	=CreatePlayerTextDraw(playerid, 613.000000, 100.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, HungerBarForeground[playerid], 255);
	PlayerTextDrawFont				(playerid, HungerBarForeground[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, HungerBarForeground[playerid], 0.500000, -10.000000);
	PlayerTextDrawColor				(playerid, HungerBarForeground[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, HungerBarForeground[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, HungerBarForeground[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, HungerBarForeground[playerid], 1);
	PlayerTextDrawUseBox			(playerid, HungerBarForeground[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, HungerBarForeground[playerid], -2130771840);
	PlayerTextDrawTextSize			(playerid, HungerBarForeground[playerid], 617.000000, 10.000000);


//=========================================================================Watch

	WatchBackground[playerid]		=CreatePlayerTextDraw(playerid, 33.000000, 338.000000, "LD_POOL:ball");
	PlayerTextDrawBackgroundColor	(playerid, WatchBackground[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchBackground[playerid], 4);
	PlayerTextDrawLetterSize		(playerid, WatchBackground[playerid], 0.500000, 0.000000);
	PlayerTextDrawColor				(playerid, WatchBackground[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, WatchBackground[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, WatchBackground[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, WatchBackground[playerid], 1);
	PlayerTextDrawUseBox			(playerid, WatchBackground[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, WatchBackground[playerid], 255);
	PlayerTextDrawTextSize			(playerid, WatchBackground[playerid], 108.000000, 89.000000);

	WatchTime[playerid]				=CreatePlayerTextDraw(playerid, 87.000000, 372.000000, "69:69");
	PlayerTextDrawAlignment			(playerid, WatchTime[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchTime[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchTime[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, WatchTime[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, WatchTime[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, WatchTime[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, WatchTime[playerid], 1);

	WatchBear[playerid]				=CreatePlayerTextDraw(playerid, 87.000000, 358.000000, "45 Deg");
	PlayerTextDrawAlignment			(playerid, WatchBear[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchBear[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchBear[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, WatchBear[playerid], 0.300000, 1.500000);
	PlayerTextDrawColor				(playerid, WatchBear[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, WatchBear[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, WatchBear[playerid], 1);

	WatchFreq[playerid]				=CreatePlayerTextDraw(playerid, 87.000000, 391.000000, "88.8");
	PlayerTextDrawAlignment			(playerid, WatchFreq[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchFreq[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchFreq[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, WatchFreq[playerid], 0.300000, 1.500000);
	PlayerTextDrawColor				(playerid, WatchFreq[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, WatchFreq[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, WatchFreq[playerid], 1);


//======================================================================HelpTips

	HelpTipText[playerid]			=CreatePlayerTextDraw(playerid, 150.000000, 350.000000, "Tip: You can access the trunks of cars by pressing F at the back");
	PlayerTextDrawBackgroundColor	(playerid, HelpTipText[playerid], 255);
	PlayerTextDrawFont				(playerid, HelpTipText[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, HelpTipText[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, HelpTipText[playerid], 16711935);
	PlayerTextDrawSetOutline		(playerid, HelpTipText[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, HelpTipText[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, HelpTipText[playerid], 0);
	PlayerTextDrawUseBox			(playerid, HelpTipText[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, HelpTipText[playerid], 0);
	PlayerTextDrawTextSize			(playerid, HelpTipText[playerid], 520.000000, 0.000000);


//========================================================================Speedo

	VehicleNameText[playerid]		=CreatePlayerTextDraw(playerid, 621.000000, 415.000000, "Infernus");
	PlayerTextDrawAlignment			(playerid, VehicleNameText[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleNameText[playerid], 255);
	PlayerTextDrawFont				(playerid, VehicleNameText[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, VehicleNameText[playerid], 0.349999, 1.799998);
	PlayerTextDrawColor				(playerid, VehicleNameText[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, VehicleNameText[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, VehicleNameText[playerid], 1);

	VehicleSpeedText[playerid]		=CreatePlayerTextDraw(playerid, 620.000000, 401.000000, "220km/h");
	PlayerTextDrawAlignment			(playerid, VehicleSpeedText[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleSpeedText[playerid], 255);
	PlayerTextDrawFont				(playerid, VehicleSpeedText[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, VehicleSpeedText[playerid], 0.250000, 1.599998);
	PlayerTextDrawColor				(playerid, VehicleSpeedText[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, VehicleSpeedText[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, VehicleSpeedText[playerid], 1);

	VehicleFuelText[playerid]		=CreatePlayerTextDraw(playerid, 620.000000, 386.000000, "0.0/0.0L");
	PlayerTextDrawAlignment			(playerid, VehicleFuelText[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleFuelText[playerid], 255);
	PlayerTextDrawFont				(playerid, VehicleFuelText[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, VehicleFuelText[playerid], 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, VehicleFuelText[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, VehicleFuelText[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, VehicleFuelText[playerid], 1);

	VehicleDamageText[playerid]		=CreatePlayerTextDraw(playerid, 620.000000, 371.000000, "DMG");
	PlayerTextDrawAlignment			(playerid, VehicleDamageText[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleDamageText[playerid], 255);
	PlayerTextDrawFont				(playerid, VehicleDamageText[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, VehicleDamageText[playerid], 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, VehicleDamageText[playerid], RED);
	PlayerTextDrawSetOutline		(playerid, VehicleDamageText[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, VehicleDamageText[playerid], 1);

	VehicleEngineText[playerid]		=CreatePlayerTextDraw(playerid, 620.000000, 356.000000, "ENG");
	PlayerTextDrawAlignment			(playerid, VehicleEngineText[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleEngineText[playerid], 255);
	PlayerTextDrawFont				(playerid, VehicleEngineText[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, VehicleEngineText[playerid], 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, VehicleEngineText[playerid], RED);
	PlayerTextDrawSetOutline		(playerid, VehicleEngineText[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, VehicleEngineText[playerid], 1);

	VehicleDoorsText[playerid]		=CreatePlayerTextDraw(playerid, 620.000000, 341.000000, "DOR");
	PlayerTextDrawAlignment			(playerid, VehicleDoorsText[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleDoorsText[playerid], 255);
	PlayerTextDrawFont				(playerid, VehicleDoorsText[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, VehicleDoorsText[playerid], 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, VehicleDoorsText[playerid], RED);
	PlayerTextDrawSetOutline		(playerid, VehicleDoorsText[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, VehicleDoorsText[playerid], 1);


//=================================================================Progress Bars

	ActionBar						= CreatePlayerProgressBar(playerid, 291.0, 345.0, 57.50, 5.19, GREY, 100.0);
	OverheatBar						= CreatePlayerProgressBar(playerid, 220.0, 380.0, 200.0, 20.0, RED, 30.0);
	KnockoutBar						= CreatePlayerProgressBar(playerid, 291.0, 315.0, 57.50, 5.19, RED, 100.0);
}

hook OnPlayerDisconnect(playerid)
{
	DestroyPlayerProgressBar(playerid, ActionBar);
	DestroyPlayerProgressBar(playerid, OverheatBar);
	DestroyPlayerProgressBar(playerid, KnockoutBar);
}

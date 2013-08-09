LoadPlayerTextDraws(playerid)
{
//==============================================================Character Create

	ClassBackGround					=CreatePlayerTextDraw(playerid, 0.000000, 0.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, ClassBackGround, 255);
	PlayerTextDrawFont				(playerid, ClassBackGround, 1);
	PlayerTextDrawLetterSize		(playerid, ClassBackGround, 0.500000, 50.000000);
	PlayerTextDrawColor				(playerid, ClassBackGround, -1);
	PlayerTextDrawSetOutline		(playerid, ClassBackGround, 0);
	PlayerTextDrawSetProportional	(playerid, ClassBackGround, 1);
	PlayerTextDrawSetShadow			(playerid, ClassBackGround, 1);
	PlayerTextDrawUseBox			(playerid, ClassBackGround, 1);
	PlayerTextDrawBoxColor			(playerid, ClassBackGround, 255);
	PlayerTextDrawTextSize			(playerid, ClassBackGround, 640.000000, 0.000000);

	ClassButtonMale					=CreatePlayerTextDraw(playerid, 250.000000, 200.000000, "~n~Male~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonMale, 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonMale, 255);
	PlayerTextDrawFont				(playerid, ClassButtonMale, 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonMale, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonMale, -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonMale, 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonMale, 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonMale, 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonMale, 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonMale, 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonMale, 300.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonMale, true);

	ClassButtonFemale				=CreatePlayerTextDraw(playerid, 390.000000, 200.000000, "~n~Female~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonFemale, 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonFemale, 255);
	PlayerTextDrawFont				(playerid, ClassButtonFemale, 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonFemale, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonFemale, -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonFemale, 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonFemale, 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonFemale, 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonFemale, 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonFemale, 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonFemale, 300.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonFemale, true);


//===================================================================Weapon Ammo

	WeaponAmmo						=CreatePlayerTextDraw(playerid, 520.000000, 64.000000, "500/500");
	PlayerTextDrawAlignment			(playerid, WeaponAmmo, 2);
	PlayerTextDrawBackgroundColor	(playerid, WeaponAmmo, 255);
	PlayerTextDrawFont				(playerid, WeaponAmmo, 1);
	PlayerTextDrawLetterSize		(playerid, WeaponAmmo, 0.210000, 1.000000);
	PlayerTextDrawColor				(playerid, WeaponAmmo, -1);
	PlayerTextDrawSetOutline		(playerid, WeaponAmmo, 1);
	PlayerTextDrawSetProportional	(playerid, WeaponAmmo, 1);
	PlayerTextDrawUseBox			(playerid, WeaponAmmo, 1);
	PlayerTextDrawBoxColor			(playerid, WeaponAmmo, 255);
	PlayerTextDrawTextSize			(playerid, WeaponAmmo, 548.000000, 40.000000);


//======================================================================Tooltips

	ToolTip							=CreatePlayerTextDraw(playerid, 618.000000, 120.000000, "fixed it");
	PlayerTextDrawAlignment			(playerid, ToolTip, 3);
	PlayerTextDrawBackgroundColor	(playerid, ToolTip, 255);
	PlayerTextDrawFont				(playerid, ToolTip, 1);
	PlayerTextDrawLetterSize		(playerid, ToolTip, 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, ToolTip, -1);
	PlayerTextDrawSetOutline		(playerid, ToolTip, 1);
	PlayerTextDrawSetProportional	(playerid, ToolTip, 1);


//======================================================================Food Bar

	HungerBarBackground				=CreatePlayerTextDraw(playerid, 612.000000, 101.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, HungerBarBackground, 255);
	PlayerTextDrawFont				(playerid, HungerBarBackground, 1);
	PlayerTextDrawLetterSize		(playerid, HungerBarBackground, 0.500000, -10.200000);
	PlayerTextDrawColor				(playerid, HungerBarBackground, -1);
	PlayerTextDrawSetOutline		(playerid, HungerBarBackground, 0);
	PlayerTextDrawSetProportional	(playerid, HungerBarBackground, 1);
	PlayerTextDrawSetShadow			(playerid, HungerBarBackground, 1);
	PlayerTextDrawUseBox			(playerid, HungerBarBackground, 1);
	PlayerTextDrawBoxColor			(playerid, HungerBarBackground, 255);
	PlayerTextDrawTextSize			(playerid, HungerBarBackground, 618.000000, 10.000000);

	HungerBarForeground				=CreatePlayerTextDraw(playerid, 613.000000, 100.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, HungerBarForeground, 255);
	PlayerTextDrawFont				(playerid, HungerBarForeground, 1);
	PlayerTextDrawLetterSize		(playerid, HungerBarForeground, 0.500000, -10.000000);
	PlayerTextDrawColor				(playerid, HungerBarForeground, -1);
	PlayerTextDrawSetOutline		(playerid, HungerBarForeground, 0);
	PlayerTextDrawSetProportional	(playerid, HungerBarForeground, 1);
	PlayerTextDrawSetShadow			(playerid, HungerBarForeground, 1);
	PlayerTextDrawUseBox			(playerid, HungerBarForeground, 1);
	PlayerTextDrawBoxColor			(playerid, HungerBarForeground, -2130771840);
	PlayerTextDrawTextSize			(playerid, HungerBarForeground, 617.000000, 10.000000);


//=========================================================================Watch

	WatchBackground					=CreatePlayerTextDraw(playerid, 33.000000, 338.000000, "LD_POOL:ball");
	PlayerTextDrawBackgroundColor	(playerid, WatchBackground, 255);
	PlayerTextDrawFont				(playerid, WatchBackground, 4);
	PlayerTextDrawLetterSize		(playerid, WatchBackground, 0.500000, 0.000000);
	PlayerTextDrawColor				(playerid, WatchBackground, 255);
	PlayerTextDrawSetOutline		(playerid, WatchBackground, 0);
	PlayerTextDrawSetProportional	(playerid, WatchBackground, 1);
	PlayerTextDrawSetShadow			(playerid, WatchBackground, 1);
	PlayerTextDrawUseBox			(playerid, WatchBackground, 1);
	PlayerTextDrawBoxColor			(playerid, WatchBackground, 255);
	PlayerTextDrawTextSize			(playerid, WatchBackground, 108.000000, 89.000000);

	WatchTime						=CreatePlayerTextDraw(playerid, 87.000000, 372.000000, "69:69");
	PlayerTextDrawAlignment			(playerid, WatchTime, 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchTime, 255);
	PlayerTextDrawFont				(playerid, WatchTime, 2);
	PlayerTextDrawLetterSize		(playerid, WatchTime, 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, WatchTime, -1);
	PlayerTextDrawSetOutline		(playerid, WatchTime, 1);
	PlayerTextDrawSetProportional	(playerid, WatchTime, 1);

	WatchBear						=CreatePlayerTextDraw(playerid, 87.000000, 358.000000, "45 Deg");
	PlayerTextDrawAlignment			(playerid, WatchBear, 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchBear, 255);
	PlayerTextDrawFont				(playerid, WatchBear, 2);
	PlayerTextDrawLetterSize		(playerid, WatchBear, 0.300000, 1.500000);
	PlayerTextDrawColor				(playerid, WatchBear, -1);
	PlayerTextDrawSetOutline		(playerid, WatchBear, 1);
	PlayerTextDrawSetProportional	(playerid, WatchBear, 1);

	WatchFreq						=CreatePlayerTextDraw(playerid, 87.000000, 391.000000, "88.8");
	PlayerTextDrawAlignment			(playerid, WatchFreq, 2);
	PlayerTextDrawBackgroundColor	(playerid, WatchFreq, 255);
	PlayerTextDrawFont				(playerid, WatchFreq, 2);
	PlayerTextDrawLetterSize		(playerid, WatchFreq, 0.300000, 1.500000);
	PlayerTextDrawColor				(playerid, WatchFreq, -1);
	PlayerTextDrawSetOutline		(playerid, WatchFreq, 1);
	PlayerTextDrawSetProportional	(playerid, WatchFreq, 1);


//======================================================================HelpTips

	HelpTipText						=CreatePlayerTextDraw(playerid, 150.000000, 350.000000, "Tip: You can access the trunks of cars by pressing F at the back");
	PlayerTextDrawBackgroundColor	(playerid, HelpTipText, 255);
	PlayerTextDrawFont				(playerid, HelpTipText, 1);
	PlayerTextDrawLetterSize		(playerid, HelpTipText, 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, HelpTipText, 16711935);
	PlayerTextDrawSetOutline		(playerid, HelpTipText, 1);
	PlayerTextDrawSetProportional	(playerid, HelpTipText, 1);
	PlayerTextDrawSetShadow			(playerid, HelpTipText, 0);
	PlayerTextDrawUseBox			(playerid, HelpTipText, 1);
	PlayerTextDrawBoxColor			(playerid, HelpTipText, 0);
	PlayerTextDrawTextSize			(playerid, HelpTipText, 520.000000, 0.000000);


//========================================================================Speedo

	VehicleNameText					=CreatePlayerTextDraw(playerid, 621.000000, 415.000000, "Infernus");
	PlayerTextDrawAlignment			(playerid, VehicleNameText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleNameText, 255);
	PlayerTextDrawFont				(playerid, VehicleNameText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleNameText, 0.349999, 1.799998);
	PlayerTextDrawColor				(playerid, VehicleNameText, -1);
	PlayerTextDrawSetOutline		(playerid, VehicleNameText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleNameText, 1);

	VehicleSpeedText				=CreatePlayerTextDraw(playerid, 620.000000, 401.000000, "220km/h");
	PlayerTextDrawAlignment			(playerid, VehicleSpeedText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleSpeedText, 255);
	PlayerTextDrawFont				(playerid, VehicleSpeedText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleSpeedText, 0.250000, 1.599998);
	PlayerTextDrawColor				(playerid, VehicleSpeedText, -1);
	PlayerTextDrawSetOutline		(playerid, VehicleSpeedText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleSpeedText, 1);

	VehicleFuelText					=CreatePlayerTextDraw(playerid, 620.000000, 386.000000, "0.0/0.0L");
	PlayerTextDrawAlignment			(playerid, VehicleFuelText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleFuelText, 255);
	PlayerTextDrawFont				(playerid, VehicleFuelText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleFuelText, 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, VehicleFuelText, -1);
	PlayerTextDrawSetOutline		(playerid, VehicleFuelText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleFuelText, 1);

	VehicleDamageText				=CreatePlayerTextDraw(playerid, 620.000000, 371.000000, "DMG");
	PlayerTextDrawAlignment			(playerid, VehicleDamageText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleDamageText, 255);
	PlayerTextDrawFont				(playerid, VehicleDamageText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleDamageText, 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, VehicleDamageText, RED);
	PlayerTextDrawSetOutline		(playerid, VehicleDamageText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleDamageText, 1);

	VehicleEngineText				=CreatePlayerTextDraw(playerid, 620.000000, 356.000000, "ENG");
	PlayerTextDrawAlignment			(playerid, VehicleEngineText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleEngineText, 255);
	PlayerTextDrawFont				(playerid, VehicleEngineText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleEngineText, 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, VehicleEngineText, RED);
	PlayerTextDrawSetOutline		(playerid, VehicleEngineText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleEngineText, 1);

	VehicleDoorsText				=CreatePlayerTextDraw(playerid, 620.000000, 341.000000, "DOR");
	PlayerTextDrawAlignment			(playerid, VehicleDoorsText, 3);
	PlayerTextDrawBackgroundColor	(playerid, VehicleDoorsText, 255);
	PlayerTextDrawFont				(playerid, VehicleDoorsText, 2);
	PlayerTextDrawLetterSize		(playerid, VehicleDoorsText, 0.250000, 1.599999);
	PlayerTextDrawColor				(playerid, VehicleDoorsText, RED);
	PlayerTextDrawSetOutline		(playerid, VehicleDoorsText, 1);
	PlayerTextDrawSetProportional	(playerid, VehicleDoorsText, 1);


//======================================================================Stat GUI

	ActionBar						= CreatePlayerProgressBar(playerid, 291.0, 345.0, 57.50, 5.19, GREY, 100.0);
	OverheatBar						= CreatePlayerProgressBar(playerid, 220.0, 380.0, 200.0, 20.0, RED, 30.0);
	KnockoutBar						= CreatePlayerProgressBar(playerid, 291.0, 315.0, 57.50, 5.19, RED, 100.0);
}

UnloadPlayerTextDraws(playerid)
{
	PlayerTextDrawDestroy(playerid, ClassBackGround);
	PlayerTextDrawDestroy(playerid, ClassButtonMale);
	PlayerTextDrawDestroy(playerid, ClassButtonFemale);
	PlayerTextDrawDestroy(playerid, WeaponAmmo);
	PlayerTextDrawDestroy(playerid, HungerBarBackground);
	PlayerTextDrawDestroy(playerid, HungerBarForeground);
	PlayerTextDrawDestroy(playerid, WatchBackground);
	PlayerTextDrawDestroy(playerid, WatchTime);
	PlayerTextDrawDestroy(playerid, WatchBear);
	PlayerTextDrawDestroy(playerid, WatchFreq);
	PlayerTextDrawDestroy(playerid, ToolTip);
	PlayerTextDrawDestroy(playerid, HelpTipText);
	PlayerTextDrawDestroy(playerid, VehicleFuelText);
	PlayerTextDrawDestroy(playerid, VehicleDamageText);
	PlayerTextDrawDestroy(playerid, VehicleEngineText);
	PlayerTextDrawDestroy(playerid, VehicleDoorsText);
	PlayerTextDrawDestroy(playerid, VehicleNameText);
	PlayerTextDrawDestroy(playerid, VehicleSpeedText);

	DestroyPlayerProgressBar(playerid, OverheatBar);
	DestroyPlayerProgressBar(playerid, ActionBar);
	DestroyPlayerProgressBar(playerid, KnockoutBar);
}

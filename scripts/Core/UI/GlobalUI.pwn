LoadTextDraws()
{
//=========================================================================Death
	DeathText					=TextDrawCreate(320.000000, 300.000000, "YOU ARE DEAD!");
	TextDrawAlignment			(DeathText, 2);
	TextDrawBackgroundColor		(DeathText, 255);
	TextDrawFont				(DeathText, 1);
	TextDrawLetterSize			(DeathText, 0.500000, 2.000000);
	TextDrawColor				(DeathText, -1);
	TextDrawSetOutline			(DeathText, 0);
	TextDrawSetProportional		(DeathText, 1);
	TextDrawSetShadow			(DeathText, 1);
	TextDrawUseBox				(DeathText, 1);
	TextDrawBoxColor			(DeathText, 85);
	TextDrawTextSize			(DeathText, 20.000000, 150.000000);

	DeathButton					=TextDrawCreate(320.000000, 323.000000, ">Play Again<");
	TextDrawAlignment			(DeathButton, 2);
	TextDrawBackgroundColor		(DeathButton, 255);
	TextDrawFont				(DeathButton, 1);
	TextDrawLetterSize			(DeathButton, 0.370000, 1.599999);
	TextDrawColor				(DeathButton, -1);
	TextDrawSetOutline			(DeathButton, 0);
	TextDrawSetProportional		(DeathButton, 1);
	TextDrawSetShadow			(DeathButton, 1);
	TextDrawUseBox				(DeathButton, 1);
	TextDrawBoxColor			(DeathButton, 85);
	TextDrawTextSize			(DeathButton, 20.000000, 150.000000);
	TextDrawSetSelectable		(DeathButton, true);

//=========================================================================Clock
	RestartCount				=TextDrawCreate(430.000000, 10.000000, "Server Restart In:~n~00:00");
	TextDrawAlignment			(RestartCount, 2);
	TextDrawBackgroundColor		(RestartCount, 255);
	TextDrawFont				(RestartCount, 1);
	TextDrawLetterSize			(RestartCount, 0.400000, 2.000000);
	TextDrawColor				(RestartCount, -1);
	TextDrawSetOutline			(RestartCount, 1);
	TextDrawSetProportional		(RestartCount, 1);


//=====================================================================HitMarker
	new hm[14];
	hm[0] =92,	hm[1] =' ',hm[2] ='/',hm[3] ='~',hm[4] ='n',hm[5] ='~',	hm[6] =' ',
	hm[7] ='~',	hm[8] ='n',hm[9] ='~',hm[10]='/',hm[11]=' ',hm[12]=92,  hm[13]=EOS;
	//"\ /~n~ ~n~/ \"

	HitMark_centre			=TextDrawCreate(305.500000, 208.500000, hm);
	TextDrawBackgroundColor	(HitMark_centre, -1);
	TextDrawFont			(HitMark_centre, 1);
	TextDrawLetterSize		(HitMark_centre, 0.500000, 1.000000);
	TextDrawColor			(HitMark_centre, -1);
	TextDrawSetProportional	(HitMark_centre, 1);
	TextDrawSetOutline		(HitMark_centre, 0);
	TextDrawSetShadow		(HitMark_centre, 0);

	HitMark_offset			=TextDrawCreate(325.500000, 165.500000, hm);
	TextDrawBackgroundColor	(HitMark_offset, -1);
	TextDrawFont			(HitMark_offset, 1);
	TextDrawLetterSize		(HitMark_offset, 0.520000, 1.000000);
	TextDrawColor			(HitMark_offset, -1);
	TextDrawSetProportional	(HitMark_offset, 1);
	TextDrawSetOutline		(HitMark_offset, 0);
	TextDrawSetShadow		(HitMark_offset, 0);

}

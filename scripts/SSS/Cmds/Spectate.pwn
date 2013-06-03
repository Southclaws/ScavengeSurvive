new
	PlayerText:spec_Name,
	PlayerText:spec_Info,
	PlayerText:spec_Left,
	PlayerText:spec_Right,
	PlayerText:spec_Mouse;


EnterSpectateMode(playerid, targetid)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	TogglePlayerSpectating(playerid, true);

	if(IsPlayerInAnyVehicle(targetid))
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(targetid));

	else
		PlayerSpectatePlayer(playerid, targetid);

	PlayerTextDrawShow(playerid, spec_Name);
	PlayerTextDrawShow(playerid, spec_Info);
	PlayerTextDrawShow(playerid, spec_Left);
	PlayerTextDrawShow(playerid, spec_Right);
	PlayerTextDrawShow(playerid, spec_Mouse);

	gPlayerSpecTarget[playerid] = targetid;
	SelectTextDraw(playerid, 0xFFFF00FF);
	UpdateSpectateMode(playerid);

	return 1;
}

ExitSpectateMode(playerid)
{
	if(gPlayerSpecTarget[playerid] == INVALID_PLAYER_ID)
		return 0;

	TogglePlayerSpectating(playerid, false);
	PlayerTextDrawHide(playerid, spec_Name);
	PlayerTextDrawHide(playerid, spec_Info);
	PlayerTextDrawHide(playerid, spec_Left);
	PlayerTextDrawHide(playerid, spec_Right);
	PlayerTextDrawHide(playerid, spec_Mouse);

	gPlayerSpecTarget[playerid] = INVALID_PLAYER_ID;

	if(bPlayerGameSettings[playerid] & Gender)
		SetPlayerSkin(playerid, 217);

	else
		SetPlayerSkin(playerid, 211);

	return 1;
}

UpdateSpectateMode(playerid)
{
	new str[128];

	if(IsPlayerInAnyVehicle(gPlayerSpecTarget[playerid]))
	{
		new
			invehicleas[24],
			wepname[32],
			cameramodename[37];

		if(GetPlayerState(gPlayerSpecTarget[playerid]) == PLAYER_STATE_DRIVER)
			invehicleas = "Driver";

		else
			invehicleas = "Passenger";

		GetWeaponName(GetPlayerWeapon(gPlayerSpecTarget[playerid]), wepname);
		GetCameraModeName(GetPlayerCameraMode(playerid), cameramodename);

		format(str, 128, "Health: %.2f Armour: %.2f Food: %.2f~n~\
			Knockedout: %d Bleeding: %d Weapon: %s Ammo: %d/%d~n~\
			Camera: %s Vehicle %d As %s",
			gPlayerHP[gPlayerSpecTarget[playerid]],
			gPlayerAP[gPlayerSpecTarget[playerid]],
			gPlayerFP[gPlayerSpecTarget[playerid]],
			bPlayerGameSettings[gPlayerSpecTarget[playerid]] & KnockedOut ? 1 : 0,
			bPlayerGameSettings[gPlayerSpecTarget[playerid]] & Bleeding ? 1 : 0,
			wepname,
			GetPlayerAmmo(gPlayerSpecTarget[playerid]),
			GetPlayerReserveAmmo(gPlayerSpecTarget[playerid]),
			cameramodename,
			gPlayerVehicleID[gPlayerSpecTarget[playerid]],
			invehicleas);
	}
	else
	{
		new
			wepname[32],
			cameramodename[37];

		GetWeaponName(GetPlayerWeapon(gPlayerSpecTarget[playerid]), wepname);
		GetCameraModeName(GetPlayerCameraMode(playerid), cameramodename);

		format(str, 128, "Health: %.2f Armour: %.2f Food: %.2f~n~\
			Knockedout: %d Bleeding: %d Weapon: %s Ammo: %d/%d~n~\
			Camera: %s",
			gPlayerHP[gPlayerSpecTarget[playerid]],
			gPlayerAP[gPlayerSpecTarget[playerid]],
			gPlayerFP[gPlayerSpecTarget[playerid]],
			bPlayerGameSettings[gPlayerSpecTarget[playerid]] & KnockedOut ? 1 : 0,
			bPlayerGameSettings[gPlayerSpecTarget[playerid]] & Bleeding ? 1 : 0,
			wepname,
			GetPlayerAmmo(gPlayerSpecTarget[playerid]),
			GetPlayerReserveAmmo(gPlayerSpecTarget[playerid]),
			cameramodename);
	}

	PlayerTextDrawSetString(playerid, spec_Name, gPlayerName[gPlayerSpecTarget[playerid]]);
	PlayerTextDrawSetString(playerid, spec_Info, str);
	PlayerTextDrawShow(playerid, spec_Info);
}

hook OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(gPlayerSpecTarget[playerid] != INVALID_PLAYER_ID)
	{
		if(playertextid == spec_Left)
		{
			new
				id = gPlayerSpecTarget[playerid] - 1,
				iters;

			if(id < 0)
				id = MAX_PLAYERS-1;

			while(id >= 0 && iters <= MAX_PLAYERS)
			{
				iters++;
				if(id == playerid || !IsPlayerConnected(id) || !(bPlayerGameSettings[id] & Spawned))
				{
					id--;

					if(id <= 0)
						id = MAX_PLAYERS - 1;

					continue;
				}
				break;
			}
			EnterSpectateMode(playerid, id);
		}

		if(playertextid == spec_Right)
		{
			new
				id = gPlayerSpecTarget[playerid] + 1,
				iters;

			if(id == MAX_PLAYERS)
				id = 0;

			while(id < MAX_PLAYERS && iters <= MAX_PLAYERS)
			{
				iters++;
				if(id == playerid || !IsPlayerConnected(id) || !(bPlayerGameSettings[id] & Spawned))
				{
					id++;

					if(id >= MAX_PLAYERS - 1)
						id=0;

					continue;
				}
				break;
			}
			EnterSpectateMode(playerid, id);
		}

		if(playertextid == spec_Mouse)
		{
			PlayerTextDrawSetString(playerid, spec_Mouse, ""KEYTEXT_INTERACT" Show Mouse");
			CancelSelectTextDraw(playerid);
		}
	}

	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(gPlayerSpecTarget[playerid] != INVALID_PLAYER_ID)
	{
		PlayerTextDrawSetString(playerid, spec_Mouse, "Hide Mouse");
		SelectTextDraw(playerid, 0xFFFF00FF);
	}
	return 1;
}

hook OnPlayerConnect(playerid)
{
	gPlayerSpecTarget[playerid] = INVALID_PLAYER_ID;

	spec_Name						=CreatePlayerTextDraw(playerid, 320.000000, 325.000000, "[HLF]Southclaw");
	PlayerTextDrawAlignment			(playerid, spec_Name, 2);
	PlayerTextDrawBackgroundColor	(playerid, spec_Name, 255);
	PlayerTextDrawFont				(playerid, spec_Name, 1);
	PlayerTextDrawLetterSize		(playerid, spec_Name, 0.200000, 1.000000);
	PlayerTextDrawColor				(playerid, spec_Name, -1);
	PlayerTextDrawSetOutline		(playerid, spec_Name, 0);
	PlayerTextDrawSetProportional	(playerid, spec_Name, 1);
	PlayerTextDrawSetShadow			(playerid, spec_Name, 1);
	PlayerTextDrawUseBox			(playerid, spec_Name, 1);
	PlayerTextDrawBoxColor			(playerid, spec_Name, 255);
	PlayerTextDrawTextSize			(playerid, spec_Name, 100.000000, 240.000000);

	spec_Info						=CreatePlayerTextDraw(playerid, 320.000000, 340.000000, "_");
	PlayerTextDrawAlignment			(playerid, spec_Info, 2);
	PlayerTextDrawBackgroundColor	(playerid, spec_Info, 255);
	PlayerTextDrawFont				(playerid, spec_Info, 1);
	PlayerTextDrawLetterSize		(playerid, spec_Info, 0.200000, 1.000000);
	PlayerTextDrawColor				(playerid, spec_Info, -1);
	PlayerTextDrawSetOutline		(playerid, spec_Info, 0);
	PlayerTextDrawSetProportional	(playerid, spec_Info, 1);
	PlayerTextDrawSetShadow			(playerid, spec_Info, 1);
	PlayerTextDrawUseBox			(playerid, spec_Info, 1);
	PlayerTextDrawBoxColor			(playerid, spec_Info, 255);
	PlayerTextDrawTextSize			(playerid, spec_Info, 100.000000, 240.000000);

	spec_Left						=CreatePlayerTextDraw(playerid, 170.000000, 325.000000, "~<~");
	PlayerTextDrawAlignment			(playerid, spec_Left, 2);
	PlayerTextDrawBackgroundColor	(playerid, spec_Left, 255);
	PlayerTextDrawFont				(playerid, spec_Left, 1);
	PlayerTextDrawLetterSize		(playerid, spec_Left, 0.200000, 3.000000);
	PlayerTextDrawColor				(playerid, spec_Left, -1);
	PlayerTextDrawSetOutline		(playerid, spec_Left, 0);
	PlayerTextDrawSetProportional	(playerid, spec_Left, 1);
	PlayerTextDrawSetShadow			(playerid, spec_Left, 1);
	PlayerTextDrawTextSize			(playerid, spec_Left, 30.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, spec_Left, true);

	spec_Right						=CreatePlayerTextDraw(playerid, 450.000000, 325.000000, "~>~");
	PlayerTextDrawAlignment			(playerid, spec_Right, 2);
	PlayerTextDrawBackgroundColor	(playerid, spec_Right, 255);
	PlayerTextDrawFont				(playerid, spec_Right, 1);
	PlayerTextDrawLetterSize		(playerid, spec_Right, 0.200000, 3.000000);
	PlayerTextDrawColor				(playerid, spec_Right, -1);
	PlayerTextDrawSetOutline		(playerid, spec_Right, 0);
	PlayerTextDrawSetProportional	(playerid, spec_Right, 1);
	PlayerTextDrawSetShadow			(playerid, spec_Right, 1);
	PlayerTextDrawTextSize			(playerid, spec_Right, 30.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, spec_Right, true);

	spec_Mouse						=CreatePlayerTextDraw(playerid, 320.000000, 420.000000, "Hide Mouse");
	PlayerTextDrawAlignment			(playerid, spec_Mouse, 2);
	PlayerTextDrawBackgroundColor	(playerid, spec_Mouse, 255);
	PlayerTextDrawFont				(playerid, spec_Mouse, 1);
	PlayerTextDrawLetterSize		(playerid, spec_Mouse, 0.200000, 1.000000);
	PlayerTextDrawColor				(playerid, spec_Mouse, -1);
	PlayerTextDrawSetOutline		(playerid, spec_Mouse, 0);
	PlayerTextDrawSetProportional	(playerid, spec_Mouse, 1);
	PlayerTextDrawSetShadow			(playerid, spec_Mouse, 1);
	PlayerTextDrawUseBox			(playerid, spec_Mouse, 1);
	PlayerTextDrawBoxColor			(playerid, spec_Mouse, 255);
	PlayerTextDrawTextSize			(playerid, spec_Mouse, 30.000000, 50.000000);
	PlayerTextDrawSetSelectable		(playerid, spec_Mouse, true);
}

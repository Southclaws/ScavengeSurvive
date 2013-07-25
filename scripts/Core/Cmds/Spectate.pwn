new
	PlayerText:spec_Name,
	PlayerText:spec_Info;


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

	gPlayerSpecTarget[playerid] = targetid;
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

	gPlayerSpecTarget[playerid] = INVALID_PLAYER_ID;

	if(bPlayerGameSettings[playerid] & Gender)
		SetPlayerSkin(playerid, 217);

	else
		SetPlayerSkin(playerid, 211);

	return 1;
}

UpdateSpectateMode(playerid)
{
	new
		name[24 + 6],
		str[256];

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
		GetCameraModeName(GetPlayerCameraMode(gPlayerSpecTarget[playerid]), cameramodename);

		format(str, sizeof(str), "Health: %.2f Armour: %.2f Food: %.2f~n~\
			Knockedout: %d Bleeding: %d Weapon: %s Ammo: %d/%d~n~\
			Camera: %s Velocity: %.2f~n~\
			Vehicle %d As %s Fuel: %.2f",
			gPlayerHP[gPlayerSpecTarget[playerid]],
			gPlayerAP[gPlayerSpecTarget[playerid]],
			gPlayerFP[gPlayerSpecTarget[playerid]],
			bPlayerGameSettings[gPlayerSpecTarget[playerid]] & KnockedOut ? 1 : 0,
			bPlayerGameSettings[gPlayerSpecTarget[playerid]] & Bleeding ? 1 : 0,
			wepname,
			GetPlayerAmmo(gPlayerSpecTarget[playerid]),
			GetPlayerReserveAmmo(gPlayerSpecTarget[playerid]),
			cameramodename,
			gPlayerVelocity[gPlayerSpecTarget[playerid]],
			gPlayerVehicleID[gPlayerSpecTarget[playerid]],
			invehicleas,
			GetVehicleFuel(gPlayerVehicleID[gPlayerSpecTarget[playerid]]));
	}
	else
	{
		new
			wepname[32],
			cameramodename[37],
			Float:vx,
			Float:vy,
			Float:vz,
			Float:velocity;

		GetWeaponName(GetPlayerWeapon(gPlayerSpecTarget[playerid]), wepname);
		GetCameraModeName(GetPlayerCameraMode(gPlayerSpecTarget[playerid]), cameramodename);
		GetPlayerVelocity(gPlayerSpecTarget[playerid], vx, vy, vz);

		velocity = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;

		format(str, sizeof(str), "Health: %.2f Armour: %.2f Food: %.2f~n~\
			Knockedout: %d Bleeding: %d Weapon: %s Ammo: %d/%d~n~\
			Camera: %s Velocity: %.2f",
			gPlayerHP[gPlayerSpecTarget[playerid]],
			gPlayerAP[gPlayerSpecTarget[playerid]],
			gPlayerFP[gPlayerSpecTarget[playerid]],
			bPlayerGameSettings[gPlayerSpecTarget[playerid]] & KnockedOut ? 1 : 0,
			bPlayerGameSettings[gPlayerSpecTarget[playerid]] & Bleeding ? 1 : 0,
			wepname,
			GetPlayerAmmo(gPlayerSpecTarget[playerid]),
			GetPlayerReserveAmmo(gPlayerSpecTarget[playerid]),
			cameramodename,
			velocity);
	}

	format(name, sizeof(name), "%s (%d)", gPlayerName[gPlayerSpecTarget[playerid]], gPlayerSpecTarget[playerid]);

	PlayerTextDrawSetString(playerid, spec_Name, name);
	PlayerTextDrawSetString(playerid, spec_Info, str);
	PlayerTextDrawShow(playerid, spec_Info);
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(gPlayerSpecTarget[playerid] != INVALID_PLAYER_ID)
	{
		if(newkeys == 4)
		{
			new
				id = gPlayerSpecTarget[playerid] - 1,
				iters;

			if(id < 0)
				id = MAX_PLAYERS-1;

			while(id >= 0 && iters <= MAX_PLAYERS)
			{
				iters++;

				if(!CanPlayerSpectate(playerid, id))
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

		if(newkeys == 128)
		{
			new
				id = gPlayerSpecTarget[playerid] + 1,
				iters;

			if(id == MAX_PLAYERS)
				id = 0;

			while(id < MAX_PLAYERS && iters <= MAX_PLAYERS)
			{
				iters++;

				if(!CanPlayerSpectate(playerid, id))
				{
					id++;

					if(id >= MAX_PLAYERS - 1)
						id = 0;

					continue;
				}

				break;
			}
			EnterSpectateMode(playerid, id);
		}
	}
	return 1;
}

CanPlayerSpectate(playerid, targetid)
{
	if(targetid == playerid || !IsPlayerConnected(targetid) || !(bPlayerGameSettings[targetid] & Spawned) || GetPlayerState(targetid) == PLAYER_STATE_SPECTATING)
		return 0;

	if(gPlayerData[playerid][ply_Admin] == 1)
	{
		if(!IsPlayerReported(gPlayerName[targetid]))
			return 0;
	}

	return 1;
}

hook OnPlayerConnect(playerid)
{
	gPlayerSpecTarget[playerid] = INVALID_PLAYER_ID;

	spec_Name						=CreatePlayerTextDraw(playerid, 320.000000, 365.000000, "[HLF]Southclaw");
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

	spec_Info						=CreatePlayerTextDraw(playerid, 320.000000, 380.000000, "Is awesome");
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
}

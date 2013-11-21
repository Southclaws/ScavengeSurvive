#include <YSI\y_hooks>


new
	PlayerText:spec_Name,
	PlayerText:spec_Info;

static
	spectate_ClickTick[MAX_PLAYERS];


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

	gPlayerData[playerid][ply_SpectateTarget] = targetid;
	UpdateSpectateMode(playerid);

	logf("[SPECTATE] %p watches %p", playerid, targetid);

	return 1;
}

ExitSpectateMode(playerid)
{
	if(gPlayerData[playerid][ply_SpectateTarget] == INVALID_PLAYER_ID)
		return 0;

	TogglePlayerSpectating(playerid, false);
	PlayerTextDrawHide(playerid, spec_Name);
	PlayerTextDrawHide(playerid, spec_Info);

	gPlayerData[playerid][ply_SpectateTarget] = INVALID_PLAYER_ID;

	if(gPlayerData[playerid][ply_Gender] == GENDER_MALE)
		SetPlayerSkin(playerid, 217);

	else
		SetPlayerSkin(playerid, 211);

	return 1;
}

UpdateSpectateMode(playerid)
{
	new
		targetid = gPlayerData[playerid][ply_SpectateTarget],
		name[24 + 6],
		str[256];

	if(IsPlayerInAnyVehicle(targetid))
	{
		new
			invehicleas[24],
			wepname[32],
			cameramodename[37];

		if(GetPlayerState(targetid) == PLAYER_STATE_DRIVER)
			invehicleas = "Driver";

		else
			invehicleas = "Passenger";

		GetWeaponName(GetPlayerWeapon(targetid), wepname);
		GetCameraModeName(GetPlayerCameraMode(targetid), cameramodename);

		format(str, sizeof(str), "Health: %.2f Armour: %.2f Food: %.2f~n~\
			Knockedout: %d Bleeding: %d Weapon: %s Ammo: %d/%d~n~\
			Camera: %s Velocity: %.2f~n~\
			Vehicle %d As %s Fuel: %.2f Locked: %d",
			gPlayerData[targetid][ply_HitPoints],
			gPlayerData[targetid][ply_ArmourPoints],
			gPlayerData[targetid][ply_FoodPoints],
			IsPlayerKnockedOut(targetid) ? 1 : 0,
			gPlayerBitData[targetid] & Bleeding ? 1 : 0,
			wepname,
			GetPlayerAmmo(targetid),
			GetPlayerReserveAmmo(targetid),
			cameramodename,
			gPlayerData[targetid][ply_Velocity],
			gPlayerData[targetid][ply_CurrentVehicle],
			invehicleas,
			GetVehicleFuel(gPlayerData[targetid][ply_CurrentVehicle]),
			IsVehicleLocked(gPlayerData[targetid][ply_CurrentVehicle]));
	}
	else
	{
		new
			wepname[32],
			ammo[16],
			holsteritemname[32],
			cameramodename[37],
			Float:vx,
			Float:vy,
			Float:vz,
			Float:velocity;

		if(GetPlayerWeapon(targetid))
		{
			GetWeaponName(GetPlayerWeapon(targetid), wepname);
			format(ammo, sizeof(ammo), "%d/%d", GetPlayerAmmo(targetid), GetPlayerReserveAmmo(targetid));
		}
		else
		{
			new itemid = GetPlayerItem(targetid);

			GetItemName(itemid, wepname);
			valstr(ammo, GetItemExtraData(itemid));
		}

		GetItemName(GetPlayerHolsterItem(targetid), holsteritemname);

		GetCameraModeName(GetPlayerCameraMode(targetid), cameramodename);
		GetPlayerVelocity(targetid, vx, vy, vz);

		velocity = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;

		format(str, sizeof(str), "Health: %.2f Armour: %.2f Food: %.2f~n~\
			Knockedout: %d Bleeding: %d Camera: %s Velocity: %.2f~n~\
			Item/Weapon: %s Ammo/Ex: %s Holster: %s Ammo/Ex: %d",
			gPlayerData[targetid][ply_HitPoints],
			gPlayerData[targetid][ply_ArmourPoints],
			gPlayerData[targetid][ply_FoodPoints],
			IsPlayerKnockedOut(targetid) ? 1 : 0,
			gPlayerBitData[targetid] & Bleeding ? 1 : 0,
			cameramodename,
			velocity,
			wepname,
			ammo,
			holsteritemname,
			GetItemExtraData(GetPlayerHolsterItem(targetid)));
	}

	format(name, sizeof(name), "%s (%d)", gPlayerName[targetid], targetid);

	PlayerTextDrawSetString(playerid, spec_Name, name);
	PlayerTextDrawSetString(playerid, spec_Info, str);
	PlayerTextDrawShow(playerid, spec_Info);
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(gPlayerData[playerid][ply_SpectateTarget] != INVALID_PLAYER_ID)
	{
		if(GetTickCountDifference(GetTickCount(), spectate_ClickTick[playerid]) < 1000)
			return 1;

		spectate_ClickTick[playerid] = GetTickCount();

		if(newkeys == 4)
		{
			new
				id = gPlayerData[playerid][ply_SpectateTarget] - 1,
				iters;

			if(id < 0)
				id = MAX_PLAYERS-1;

			while(id >= 0 && iters <= MAX_PLAYERS)
			{
				iters++;

				if(!CanPlayerSpectate(playerid, id))
				{
					id--;

					if(id < 0)
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
				id = gPlayerData[playerid][ply_SpectateTarget] + 1,
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

		if(newkeys == 512)
		{
			EnterSpectateMode(playerid, gPlayerData[playerid][ply_SpectateTarget]);
		}
	}
	return 1;
}

CanPlayerSpectate(playerid, targetid)
{
	if(targetid == playerid || !IsPlayerConnected(targetid) || !(gPlayerBitData[targetid] & Spawned) || GetPlayerState(targetid) == PLAYER_STATE_SPECTATING)
		return 0;

	if(gPlayerData[playerid][ply_Admin] == 1)
	{
		if(!IsPlayerReported(gPlayerName[targetid]))
			return 0;
	}

	return 1;
}

hook OnPlayerDisconnect(playerid)
{
	foreach(new i : Player)
	{
		if(gPlayerData[i][ply_SpectateTarget] == playerid)
		{
			ExitSpectateMode(i);
		}
	}
}

hook OnPlayerConnect(playerid)
{
	gPlayerData[playerid][ply_SpectateTarget] = INVALID_PLAYER_ID;

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

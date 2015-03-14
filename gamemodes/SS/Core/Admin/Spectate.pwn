#include <YSI\y_hooks>


new
		PlayerText:spec_Name,
		PlayerText:spec_Info;

static
		spectate_ClickTick[MAX_PLAYERS],
		spectate_Target[MAX_PLAYERS],
Timer:	spectate_Timer[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	spectate_Target[playerid] = INVALID_PLAYER_ID;

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
	PlayerTextDrawTextSize			(playerid, spec_Name, 100.000000, 340.000000);

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
	PlayerTextDrawTextSize			(playerid, spec_Info, 100.000000, 340.000000);
}

hook OnPlayerDisconnect(playerid)
{
	if(spectate_Target[playerid] != INVALID_PLAYER_ID)
		ExitSpectateMode(playerid);

	foreach(new i : Player)
	{
		if(spectate_Target[i] == playerid)
		{
			ExitSpectateMode(i);
		}
	}

	return 1;
}

EnterSpectateMode(playerid, targetid)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	TogglePlayerSpectating(playerid, true);
	ToggleNameTagsForPlayer(playerid, true);

	spectate_Target[playerid] = targetid;

	_RefreshSpectate(playerid);

	PlayerTextDrawShow(playerid, spec_Name);
	PlayerTextDrawShow(playerid, spec_Info);

	stop spectate_Timer[playerid];
	spectate_Timer[playerid] = repeat UpdateSpectateMode(playerid);

	logf("[SPECTATE] %p watches %p", playerid, targetid);

	return 1;
}

ExitSpectateMode(playerid)
{
	if(spectate_Target[playerid] == INVALID_PLAYER_ID)
		return 0;

	TogglePlayerSpectating(playerid, false);
	PlayerTextDrawHide(playerid, spec_Name);
	PlayerTextDrawHide(playerid, spec_Info);

	spectate_Target[playerid] = INVALID_PLAYER_ID;
	stop spectate_Timer[playerid];

	if(GetPlayerGender(playerid) == GENDER_MALE)
		SetPlayerSkin(playerid, 217);

	else
		SetPlayerSkin(playerid, 211);

	return 1;
}

SpectateNextTarget(playerid)
{
	new
		id = spectate_Target[playerid] + 1,
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

	spectate_Target[playerid] = id;
	_RefreshSpectate(playerid);
}

SpectatePrevTarget(playerid)
{
	new
		id = spectate_Target[playerid] - 1,
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

	spectate_Target[playerid] = id;
	_RefreshSpectate(playerid);
}

_RefreshSpectate(playerid)
{
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(spectate_Target[playerid]));
	SetPlayerInterior(playerid, GetPlayerInterior(spectate_Target[playerid]));

	if(IsPlayerInAnyVehicle(spectate_Target[playerid]))
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(spectate_Target[playerid]));

	else
		PlayerSpectatePlayer(playerid, spectate_Target[playerid]);
}

timer UpdateSpectateMode[100](playerid)
{
	new
		targetid = spectate_Target[playerid],
		name[24 + 6],
		str[256];

	if(!IsPlayerConnected(targetid))
	{
		stop spectate_Timer[playerid];
		return;
	}

	if(!GetPlayerBitFlag(playerid, ShowHUD))
	{
		PlayerTextDrawHide(playerid, spec_Info);
		return;
	}

	if(IsPlayerInAnyVehicle(targetid))
	{
		new
			invehicleas[24],
			itemid,
			itemname[ITM_MAX_NAME + ITM_MAX_TEXT],
			cameramodename[37];

		if(GetPlayerState(targetid) == PLAYER_STATE_DRIVER)
			invehicleas = "Driver";

		else
			invehicleas = "Passenger";

		itemid = GetPlayerItem(targetid);
		if(!GetItemName(itemid, itemname))
			itemname = "None";

		GetCameraModeName(GetPlayerCameraMode(targetid), cameramodename);

		format(str, sizeof(str), "Health: %.2f Armour: %.2f Food: %.2f Int: %d VW: %d~n~\
			Knockout: %s Bleed rate: %02f Item: %s Exdata: %d~n~\
			Camera: %s Velocity: %.2f~n~\
			Vehicle %d As %s Fuel: %.2f Locked: %d",
			GetPlayerHP(targetid),
			GetPlayerAP(targetid),
			GetPlayerFP(targetid),
			GetPlayerInterior(targetid),
			GetPlayerVirtualWorld(targetid),
			IsPlayerKnockedOut(targetid) ? MsToString(GetPlayerKnockOutTick(targetid), "%1m:%1s") : ("No"),
			GetPlayerBleedRate(targetid),
			itemname,
			GetItemExtraData(itemid),
			cameramodename,
			GetPlayerTotalVelocity(targetid),
			GetPlayerLastVehicle(targetid),
			invehicleas,
			GetVehicleFuel(GetPlayerLastVehicle(targetid)),
			IsVehicleLocked(GetPlayerLastVehicle(targetid)));
	}
	else
	{
		new
			itemid,
			itemname[ITM_MAX_NAME + ITM_MAX_TEXT],
			holsteritemid,
			holsteritemname[32],
			cameramodename[37],
			Float:vx,
			Float:vy,
			Float:vz,
			Float:velocity;

		itemid = GetPlayerItem(targetid);
		if(!GetItemName(itemid, itemname))
			itemname = "None";

		holsteritemid = GetPlayerHolsterItem(targetid);
		if(!GetItemName(holsteritemid, holsteritemname))
			holsteritemname = "None";

		GetCameraModeName(GetPlayerCameraMode(targetid), cameramodename);
		GetPlayerVelocity(targetid, vx, vy, vz);

		velocity = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;

		format(str, sizeof(str), "Health: %.2f Armour: %.2f Food: %.2f Int: %d VW: %d~n~\
			Knockout: %s Bleed rate: %02f Camera: %s Velocity: %.2f~n~\
			Item: %s Exdata: %d Holster: %s Exdata: %d",
			GetPlayerHP(targetid),
			GetPlayerAP(targetid),
			GetPlayerFP(targetid),
			GetPlayerInterior(targetid),
			GetPlayerVirtualWorld(targetid),
			IsPlayerKnockedOut(targetid) ? MsToString(GetPlayerKnockOutTick(targetid), "%1m:%1s") : ("No"),
			GetPlayerBleedRate(targetid),
			cameramodename,
			velocity,
			itemname,
			GetItemExtraData(itemid),
			holsteritemname,
			GetItemExtraData(holsteritemid));
	}

	format(name, sizeof(name), "%s (%d)", gPlayerName[targetid], targetid);

	PlayerTextDrawSetString(playerid, spec_Name, name);
	PlayerTextDrawSetString(playerid, spec_Info, str);
	PlayerTextDrawShow(playerid, spec_Info);
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(spectate_Target[playerid] != INVALID_PLAYER_ID)
	{
		if(GetTickCountDifference(GetTickCount(), spectate_ClickTick[playerid]) < 1000)
			return 1;

		spectate_ClickTick[playerid] = GetTickCount();

		if(newkeys == 128)
			SpectateNextTarget(playerid);

		if(newkeys == 4)
			SpectatePrevTarget(playerid);

		if(newkeys == 512)
			EnterSpectateMode(playerid, spectate_Target[playerid]);
	}
	return 1;
}

CanPlayerSpectate(playerid, targetid)
{
	if(targetid == playerid || !IsPlayerConnected(targetid) || !(IsPlayerSpawned(targetid)) || GetPlayerState(targetid) == PLAYER_STATE_SPECTATING)
		return 0;

	if(GetPlayerAdminLevel(playerid) == 1)
	{
		if(!IsPlayerReported(gPlayerName[targetid]))
			return 0;
	}

	return 1;
}

GetPlayerSpectateTarget(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_PLAYER_ID;

	return spectate_Target[playerid];
}

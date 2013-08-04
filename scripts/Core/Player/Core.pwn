#include <YSI\y_hooks>


enum (<<= 1) // 23
{
		HasAccount = 1,
		IsVip,
		LoggedIn,
		LoadedData,
		IsNewPlayer,
		CanExitWelcome,

		AdminDuty,
		Alive,
		Dying,
		Spawned,
		FirstSpawn,

		ToolTips,
		ShowHUD,
		KnockedOut,
		Bleeding,
		Infected,
		GlobalQuiet,

		IsAfk,
		AfkCheck,

		Frozen,
		Muted,

		DebugMode
}

enum E_PLAYER_DATA
{
		// Account Data
		ply_Password[MAX_PASSWORD_LEN],
		ply_IP,
		ply_Admin,
		ply_Warnings,
		ply_Karma,

		// Character Data
Float:	ply_HitPoints,
Float:	ply_ArmourPoints,
Float:	ply_FoodPoints,
		ply_Clothes,
		ply_Gender,
Float:	ply_Velocity,
Float:	ply_SpawnPosX,
Float:	ply_SpawnPosY,
Float:	ply_SpawnPosZ,
Float:	ply_SpawnRotZ,
Float:	ply_DeathPosX,
Float:	ply_DeathPosY,
Float:	ply_DeathPosZ,
Float:	ply_DeathRotZ,
Float:	ply_RadioFrequency,

		// Internal Data
		ply_ChatMode,
		ply_CurrentVehicle,
		ply_LastHitBy[MAX_PLAYER_NAME],
		ply_LastKilledBy[MAX_PLAYER_NAME],
		ply_PingLimitStrikes,
		ply_SpectateTarget,
		ply_ScreenBoxFadeLevel,
		ply_stance,
		ply_JoinTick,
		ply_SpawnTick,
		ply_TookDamageTick,
		ply_DeltDamageTick,
		ply_ExitVehicleTick,
		ply_LastChatMessageTick
}

enum
{
		CHAT_MODE_LOCAL,
		CHAT_MODE_GLOBAL,
		CHAT_MODE_RADIO,
		CHAT_MODE_ADMIN
}


new
		gPlayerData				[MAX_PLAYERS][E_PLAYER_DATA],
		bPlayerGameSettings		[MAX_PLAYERS],
		gPlayerName				[MAX_PLAYERS][MAX_PLAYER_NAME];


public OnPlayerConnect(playerid)
{
	SetPlayerColor(playerid, 0xB8B8B800);
	SetPlayerWeather(playerid, gWeatherID);
	GetPlayerName(playerid, gPlayerName[playerid], MAX_PLAYER_NAME);

	if(IsPlayerNPC(playerid))
		return 1;

	gPlayerData[playerid][ply_JoinTick] = tickcount();

	new
		ipstring[16],
		ipbyte[4],
		loadresult;

	GetPlayerIp(playerid, ipstring, 16);

	sscanf(ipstring, "p<.>a<d>[4]", ipbyte);
	gPlayerData[playerid][ply_IP] = ((ipbyte[0] << 24) | (ipbyte[1] << 16) | (ipbyte[2] << 8) | ipbyte[3]);

	if(BanCheck(playerid))
		return 0;

	ResetVariables(playerid);

	loadresult = LoadAccount(playerid);

	if(loadresult == 0) // Account does not exist
	{
		new str[150];
		format(str, 150, ""#C_WHITE"Hello %P"#C_WHITE", You must be new here!\nPlease create an account by entering a "#C_BLUE"password"#C_WHITE" below:", playerid);
		ShowPlayerDialog(playerid, d_Register, DIALOG_STYLE_PASSWORD, "Register For A New Account", str, "Accept", "Leave");

		t:bPlayerGameSettings[playerid]<IsNewPlayer>;
	}

	if(loadresult == 1) // Account does exist, prompt login
	{
		DisplayLoginPrompt(playerid);
	}

	if(loadresult == 2) // Account does exist, auto login
	{
		Login(playerid);
	}

	if(loadresult == 3) // Account does exist, but not in whitelist
	{
		ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Whitelist",
			""#C_YELLOW"You are not on the whitelist for this server.\n\
			This is in force to provide the best gameplay experience for all players.\n\n\
			"#C_WHITE"Please apply on "#C_BLUE"Empire-Bay.com"#C_WHITE".\n\
			Applications are always accepted as soon as possible\n\
			There are no requirements, just follow the rules.\n\
			Failure to do so will result in permanent removal from the whitelist.", "Close", "");

		defer KickPlayerDelay(playerid);
	}

	CheckForExtraAccounts(playerid);

	SetAllWeaponSkills(playerid, 500);
	LoadPlayerTextDraws(playerid);
	SetPlayerScore(playerid, 0);
	Streamer_ToggleIdleUpdate(playerid, true);
	TextDrawShowForPlayer(playerid, Branding);
	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);
	SpawnPlayer(playerid);

	MsgAllF(WHITE, " >  %P (%d)"#C_WHITE" has joined", playerid, playerid);
	MsgF(playerid, YELLOW, " >  MoTD: "#C_BLUE"%s", gMessageOfTheDay);

	t:bPlayerGameSettings[playerid]<ShowHUD>;

	if(gPingLimit == 600)
	{
		if(Iter_Count(Player) >= 10)
			gPingLimit = 400;
	}
	else if(gPingLimit == 400)
	{
		if(Iter_Count(Player) < 10)
			gPingLimit = 600;
	}

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(gServerRestarting)
		return 0;

	Logout(playerid);

	ResetVariables(playerid);
	UnloadPlayerTextDraws(playerid);

	switch(reason)
	{
		case 0:
			MsgAllF(GREY, " >  %p lost connection.", playerid);

		case 1:
			MsgAllF(GREY, " >  %p left the server.", playerid);
	}

	return 1;
}

ResetVariables(playerid)
{
	bPlayerGameSettings[playerid]				= 0;

	gPlayerData[playerid][ply_Admin]			= 0,
	gPlayerData[playerid][ply_Clothes]				= 0,
	gPlayerData[playerid][ply_HitPoints]		= 100.0;
	gPlayerData[playerid][ply_ArmourPoints]		= 0.0;
	gPlayerData[playerid][ply_FoodPoints]		= 80.0;
	gPlayerData[playerid][ply_CurrentVehicle]	= INVALID_VEHICLE_ID,

	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);

	for(new i; i < 10; i++)
		RemovePlayerAttachedObject(playerid, i);
}

ptask PlayerUpdate[100](playerid)
{
	if(gPlayerData[playerid][ply_SpectateTarget] != INVALID_PLAYER_ID)
	{
		UpdateSpectateMode(playerid);
		return;
	}

	if(GetPlayerPing(playerid) > gPingLimit)
	{
		if(tickcount() - gPlayerData[playerid][ply_JoinTick] > 10000)
		{
			gPlayerData[playerid][ply_PingLimitStrikes]++;

			if(gPlayerData[playerid][ply_PingLimitStrikes] == 3)
			{
				new str[128];
				format(str, 128, "Having a ping of: %d limit: %d.", GetPlayerPing(playerid), gPingLimit);
				KickPlayer(playerid, str);

				gPlayerData[playerid][ply_PingLimitStrikes] = 0;

				return;
			}
		}
	}
	else
	{
		gPlayerData[playerid][ply_PingLimitStrikes] = 0;
	}

	new
		hour,
		minute,
		weather;

	if(IsPlayerInAnyVehicle(playerid))
		PlayerVehicleUpdate(playerid);

	else
		VehicleSurfingCheck(playerid);

	if(gPlayerData[playerid][ply_ScreenBoxFadeLevel] > 0)
	{
		PlayerTextDrawBoxColor(playerid, ClassBackGround, gPlayerData[playerid][ply_ScreenBoxFadeLevel]);
		PlayerTextDrawShow(playerid, ClassBackGround);

		gPlayerData[playerid][ply_ScreenBoxFadeLevel] -= 4;

		if(gPlayerData[playerid][ply_HitPoints] <= 40.0)
		{
			if(gPlayerData[playerid][ply_ScreenBoxFadeLevel] <= floatround((40.0 - gPlayerData[playerid][ply_HitPoints]) * 4.4))
				gPlayerData[playerid][ply_ScreenBoxFadeLevel] = 0;
		}
	}
	else
	{
		if(gPlayerData[playerid][ply_HitPoints] < 40.0)
		{
			if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_PAINKILL))
			{
				PlayerTextDrawHide(playerid, ClassBackGround);

				if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_PAINKILL) > 60000)
					RemoveDrug(playerid, DRUG_TYPE_PAINKILL);
			}
			else if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
			{
				PlayerTextDrawHide(playerid, ClassBackGround);
			}
			else
			{
				PlayerTextDrawBoxColor(playerid, ClassBackGround, floatround((40.0 - gPlayerData[playerid][ply_HitPoints]) * 4.4));
				PlayerTextDrawShow(playerid, ClassBackGround);
			}
		}
		else
		{
			if(bPlayerGameSettings[playerid] & Spawned)
				PlayerTextDrawHide(playerid, ClassBackGround);
		}
	}

	KnockOutUpdate(playerid);

	gettime(hour, minute);

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_LSD))
	{
		hour = 22;
		minute = 3;
		weather = 33;

		if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_LSD) > 300000)
			RemoveDrug(playerid, DRUG_TYPE_LSD);
	}
	else if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_HEROINE))
	{
		hour = 22;
		minute = 30;
		weather = 33;

		if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_HEROINE) > 300000)
			RemoveDrug(playerid, DRUG_TYPE_HEROINE);
	}
	else
	{
		weather = gWeatherID;
	}

	SetPlayerTime(playerid, hour, minute);
	SetPlayerWeather(playerid, weather);

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_AIR))
	{
		SetPlayerDrunkLevel(playerid, 100000);

		if(random(100) < 50)
			GivePlayerHP(playerid, -0.5);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_MORPHINE))
	{
		if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_MORPHINE) > 300000 || gPlayerData[playerid][ply_HitPoints] >= 100.0)
			RemoveDrug(playerid, DRUG_TYPE_MORPHINE);

		SetPlayerDrunkLevel(playerid, 2200);

		if(random(100) < 80)
			GivePlayerHP(playerid, 0.05);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
	{
		if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_ADRENALINE) > 300000 || gPlayerData[playerid][ply_HitPoints] >= 100.0)
			RemoveDrug(playerid, DRUG_TYPE_ADRENALINE);

		GivePlayerHP(playerid, 0.01);
	}

	if(bPlayerGameSettings[playerid] & Bleeding)
	{
		if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_MORPHINE))
		{
			if(random(100) < 30)
				GivePlayerHP(playerid, -0.01);
		}
		else
		{
			if(random(100) < 60)
				GivePlayerHP(playerid, -0.01);
		}

		if(IsPlayerAttachedObjectSlotUsed(playerid, ATTACHSLOT_BLOOD))
		{
			if(frandom(100.0) < gPlayerData[playerid][ply_HitPoints])
			{
				RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
			}
		}
		else
		{
			if(frandom(100.0) < 100 - gPlayerData[playerid][ply_HitPoints])
			{
				SetPlayerAttachedObject(playerid, ATTACHSLOT_BLOOD, 18706, 1,  0.088999, 0.020000, 0.044999,  0.088999, 0.020000, 0.044999,  1.179000, 1.510999, 0.005000);
			}
		}
	}
	else
	{
		if(IsPlayerAttachedObjectSlotUsed(playerid, ATTACHSLOT_BLOOD))
			RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
	}

	if(bPlayerGameSettings[playerid] & Infected)
	{
		PlayerInfectionUpdate(playerid);
	}

	if(GetPlayerCurrentWeapon(playerid) == 0 && GetPlayerWeapon(playerid))
	{
		RemovePlayerWeapon(playerid);
	}

	PlayerBagUpdate(playerid);

	return;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid))return 1;

	t:bPlayerGameSettings[playerid]<FirstSpawn>;

	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);

	return 0;
}

public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid))return 1;

	t:bPlayerGameSettings[playerid]<FirstSpawn>;

	SetSpawn(playerid, -907.5452, 272.7235, 1014.1449, 0.0);

	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(bPlayerGameSettings[playerid] & Dying)
		{
			SelectTextDraw(playerid, 0xFFFFFF88);
		}
		else
		{
			ShowWatch(playerid);
		}
	}
	if(clickedid == DeathButton)
	{
		f:bPlayerGameSettings[playerid]<Dying>;
		TogglePlayerSpectating(playerid, false);
		CancelSelectTextDraw(playerid);
		TextDrawHideForPlayer(playerid, DeathText);
		TextDrawHideForPlayer(playerid, DeathButton);
	}
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
		return 1;

	gPlayerData[playerid][ply_SpawnTick] = tickcount();

	SetPlayerWeather(playerid, gWeatherID);
	SetPlayerTeam(playerid, 0);
	ResetPlayerMoney(playerid);

	if(bPlayerGameSettings[playerid] & AdminDuty)
	{
		SetPlayerPos(playerid, 0.0, 0.0, 3.0);
		gPlayerData[playerid][ply_HitPoints] = 100.0;
		return 1;
	}

	if(bPlayerGameSettings[playerid] & Dying)
	{
		TogglePlayerSpectating(playerid, true);

		defer SetDeathCamera(playerid);

		SetPlayerCameraPos(playerid,
			gPlayerData[playerid][ply_DeathPosX] - floatsin(-gPlayerData[playerid][ply_DeathRotZ], degrees),
			gPlayerData[playerid][ply_DeathPosY] - floatcos(-gPlayerData[playerid][ply_DeathRotZ], degrees),
			gPlayerData[playerid][ply_DeathPosZ]);

		SetPlayerCameraLookAt(playerid, gPlayerData[playerid][ply_DeathPosX], gPlayerData[playerid][ply_DeathPosY], gPlayerData[playerid][ply_DeathPosZ]);

		TextDrawShowForPlayer(playerid, DeathText);
		TextDrawShowForPlayer(playerid, DeathButton);
		SelectTextDraw(playerid, 0xFFFFFF88);
		gPlayerData[playerid][ply_HitPoints] = 1.0;
	}
	else
	{
		gPlayerData[playerid][ply_ScreenBoxFadeLevel] = 0;
		PlayerTextDrawBoxColor(playerid, ClassBackGround, 0x000000FF);
		PlayerTextDrawShow(playerid, ClassBackGround);

		if(bPlayerGameSettings[playerid] & Alive)
		{
			if(bPlayerGameSettings[playerid] & LoggedIn)
			{
				PlayerSpawnExistingCharacter(playerid);
				gPlayerData[playerid][ply_ScreenBoxFadeLevel] = 255;
			}
			else
			{
				DisplayLoginPrompt(playerid);
			}
		}
		else
		{
			gPlayerData[playerid][ply_HitPoints] = 100.0;
			gPlayerData[playerid][ply_ArmourPoints] = 0.0;
			gPlayerData[playerid][ply_FoodPoints] = 80.0;
			gPlayerData[playerid][ply_RadioFrequency] = 108.0;
			PlayerCreateNewCharacter(playerid);
		}
	}

	PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
	PreloadPlayerAnims(playerid);
	SetAllWeaponSkills(playerid, 500);
	Streamer_Update(playerid);

	RemoveAllDrugs(playerid);

	return 1;
}

timer SetDeathCamera[50](playerid)
{
	InterpolateCameraPos(playerid,
		gPlayerData[playerid][ply_DeathPosX] - floatsin(-gPlayerData[playerid][ply_DeathRotZ], degrees),
		gPlayerData[playerid][ply_DeathPosY] - floatcos(-gPlayerData[playerid][ply_DeathRotZ], degrees),
		gPlayerData[playerid][ply_DeathPosZ] + 1.0,
		gPlayerData[playerid][ply_DeathPosX] - floatsin(-gPlayerData[playerid][ply_DeathRotZ], degrees),
		gPlayerData[playerid][ply_DeathPosY] - floatcos(-gPlayerData[playerid][ply_DeathRotZ], degrees),
		gPlayerData[playerid][ply_DeathPosZ] + 20.0,
		30000, CAMERA_MOVE);

	InterpolateCameraLookAt(playerid,
		gPlayerData[playerid][ply_DeathPosX],
		gPlayerData[playerid][ply_DeathPosY],
		gPlayerData[playerid][ply_DeathPosZ],
		gPlayerData[playerid][ply_DeathPosX],
		gPlayerData[playerid][ply_DeathPosY],
		gPlayerData[playerid][ply_DeathPosZ] + 1.0,
		30000, CAMERA_MOVE);
}

public OnPlayerUpdate(playerid)
{
	if(bPlayerGameSettings[playerid] & Frozen)
		return 0;

	if(IsPlayerInAnyVehicle(playerid))
	{
		static
			str[8],
			Float:vx,
			Float:vy,
			Float:vz;

		GetVehicleVelocity(gPlayerData[playerid][ply_CurrentVehicle], vx, vy, vz);
		gPlayerData[playerid][ply_Velocity] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
		format(str, 32, "%.0fkm/h", gPlayerData[playerid][ply_Velocity]);
		PlayerTextDrawSetString(playerid, VehicleSpeedText, str);
	}

	if(bPlayerGameSettings[playerid] & Alive)
	{
		if(bPlayerGameSettings[playerid] & AdminDuty)
			gPlayerData[playerid][ply_HitPoints] = 250.0;

		SetPlayerHealth(playerid, gPlayerData[playerid][ply_HitPoints]);
		SetPlayerArmour(playerid, gPlayerData[playerid][ply_ArmourPoints]);
	}
	else
	{
		SetPlayerHealth(playerid, 100.0);		
	}

	return 1;
}

GetPlayerSpawnPos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	x = gPlayerData[playerid][ply_SpawnPosX];
	z = gPlayerData[playerid][ply_SpawnPosY];
	x = gPlayerData[playerid][ply_SpawnPosZ];

	return 1;
}



public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new vehicleid = GetPlayerVehicleID(playerid);

	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		new model = GetVehicleModel(vehicleid);

		gPlayerData[playerid][ply_CurrentVehicle] = vehicleid;

		SetVehicleUsed(vehicleid, true);
		SetVehicleOccupied(vehicleid, true);

		PlayerTextDrawSetString(playerid, VehicleNameText, VehicleNames[model-400]);
		PlayerTextDrawShow(playerid, VehicleNameText);
		PlayerTextDrawShow(playerid, VehicleSpeedText);

		if(GetVehicleType(model) != VTYPE_BICYCLE)
		{
			PlayerTextDrawShow(playerid, VehicleFuelText);
			PlayerTextDrawShow(playerid, VehicleDamageText);
			PlayerTextDrawShow(playerid, VehicleEngineText);
			PlayerTextDrawShow(playerid, VehicleDoorsText);
		}
	}
	if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
	{
		VehicleDoorsState(gPlayerData[playerid][ply_CurrentVehicle], 0);

		SetVehicleOccupied(vehicleid, false);

		PlayerTextDrawHide(playerid, VehicleNameText);
		PlayerTextDrawHide(playerid, VehicleSpeedText);
		PlayerTextDrawHide(playerid, VehicleFuelText);
		PlayerTextDrawHide(playerid, VehicleDamageText);
		PlayerTextDrawHide(playerid, VehicleEngineText);
		PlayerTextDrawHide(playerid, VehicleDoorsText);
	}
	return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(bPlayerGameSettings[playerid] & KnockedOut)
	{
		return 0;
	}

	if(ispassenger)
	{
		new driverid = -1;

		foreach(new i : Player)
		{
			if(IsPlayerInVehicle(i, vehicleid))
			{
				if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
				{
					driverid = i;
				}
			}
		}

		if(driverid == -1)
			CancelPlayerMovement(playerid);
	}

	return 1;
}
public OnPlayerExitVehicle(playerid, vehicleid)
{
	gPlayerData[playerid][ply_ExitVehicleTick] = tickcount();

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(bPlayerGameSettings[playerid] & KnockedOut)
		return 0;

	if(!IsPlayerInAnyVehicle(playerid))
	{
		new weaponid = GetPlayerCurrentWeapon(playerid);

		if(weaponid == 34 || weaponid == 35 || weaponid == 43)
		{
			if(newkeys & 128)
			{
				TogglePlayerHeadwear(playerid, false);
			}
			if(oldkeys & 128)
			{
				TogglePlayerHeadwear(playerid, true);
			}
	}
/*
		if(newkeys & KEY_FIRE)
		{
			new iWepState = GetPlayerWeaponState(playerid);

			if((iWepState != WEAPONSTATE_RELOADING && iWepState != WEAPONSTATE_NO_BULLETS))
				OnPlayerShoot(playerid);
		}
*/
	}

	return 1;
}



IsPlayerDead(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return bPlayerGameSettings[playerid] & Dying;
}

IsPlayerKnockedOut(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return bPlayerGameSettings[playerid] & KnockedOut;
}

IsPlayerOnAdminDuty(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return bPlayerGameSettings[playerid] & AdminDuty;
}

GetPlayerServerJoinTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_JoinTick];
}

GetPlayerSpawnTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_SpawnTick];
}

GetPlayerVehicleExitTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_ExitVehicleTick];
}

GetPlayerDataBitmask(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return bPlayerGameSettings[playerid];
}

GetPlayerLastVehicle(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_CurrentVehicle];
}

forward Float:GetPlayerTotalVelocity(playerid);
Float:GetPlayerTotalVelocity(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return gPlayerData[playerid][ply_Velocity];
}

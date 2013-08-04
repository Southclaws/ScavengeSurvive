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
		Gender,
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
		ply_Password[MAX_PASSWORD_LEN],
		ply_Admin,
		ply_Skin,
		ply_IP,
Float:	ply_posX,
Float:	ply_posY,
Float:	ply_posZ,
Float:	ply_rotZ,
		ply_stance,
		ply_karma
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

		gPlayerPassAttempts		[MAX_PLAYERS],
		gPlayerWarnings			[MAX_PLAYERS],

		gPlayerName				[MAX_PLAYERS][MAX_PLAYER_NAME],
Float:	gPlayerHP				[MAX_PLAYERS],
Float:	gPlayerAP				[MAX_PLAYERS],
Float:	gPlayerFP				[MAX_PLAYERS],
Float:	gPlayerFrequency		[MAX_PLAYERS],
		gPlayerChatMode			[MAX_PLAYERS],
		gPlayerVehicleID		[MAX_PLAYERS],
Float:	gPlayerVelocity			[MAX_PLAYERS],
		gPingLimitStrikes		[MAX_PLAYERS],
		gPlayerSpecTarget		[MAX_PLAYERS],
		gScreenBoxFadeLevel		[MAX_PLAYERS],
Float:	gPlayerDeathPos			[MAX_PLAYERS][4],

		tick_ServerJoin			[MAX_PLAYERS],
		tick_Spawn				[MAX_PLAYERS],
		tick_LastDamaged		[MAX_PLAYERS],
		tick_WeaponHit			[MAX_PLAYERS],
		tick_ExitVehicle		[MAX_PLAYERS],
		tick_LastChatMessage	[MAX_PLAYERS],
		tick_LastInfectionFX	[MAX_PLAYERS],
		gLastHitBy				[MAX_PLAYERS][MAX_PLAYER_NAME],
		gLastKilledBy			[MAX_PLAYERS][MAX_PLAYER_NAME],
		ChatMessageStreak		[MAX_PLAYERS],
		ChatMuteTick			[MAX_PLAYERS];


public OnPlayerConnect(playerid)
{
	SetPlayerColor(playerid, 0xB8B8B800);
	SetPlayerWeather(playerid, gWeatherID);
	GetPlayerName(playerid, gPlayerName[playerid], MAX_PLAYER_NAME);

	if(IsPlayerNPC(playerid))
		return 1;

	tick_ServerJoin[playerid] = tickcount();

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
	bPlayerGameSettings[playerid]		= 0;

	gPlayerData[playerid][ply_Admin]	= 0,
	gPlayerData[playerid][ply_Skin]		= 0,
	gPlayerHP[playerid]					= 100.0;
	gPlayerAP[playerid]					= 0.0;
	gPlayerFP[playerid]					= 80.0;
	gPlayerVehicleID[playerid]			= INVALID_VEHICLE_ID,
	gPlayerWarnings[playerid]			= 0;
	gPlayerPassAttempts[playerid]		= 0;

	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);

	for(new i; i < 10; i++)
		RemovePlayerAttachedObject(playerid, i);
}

ptask PlayerUpdate[100](playerid)
{
	if(gPlayerSpecTarget[playerid] != INVALID_PLAYER_ID)
	{
		UpdateSpectateMode(playerid);
		return;
	}

	if(GetPlayerPing(playerid) > gPingLimit && tickcount() - tick_ServerJoin[playerid] > 10000)
	{
		gPingLimitStrikes[playerid]++;

		if(gPingLimitStrikes[playerid] == 3)
		{
			new str[128];
			format(str, 128, "Having a ping of: %d limit: %d.", GetPlayerPing(playerid), gPingLimit);
			KickPlayer(playerid, str);

			gPingLimitStrikes[playerid] = 0;

			return;
		}
	}

	new
		hour,
		minute,
		weather;

	if(IsPlayerInAnyVehicle(playerid))
		PlayerVehicleUpdate(playerid);

	else
		VehicleSurfingCheck(playerid);

	if(gScreenBoxFadeLevel[playerid] > 0)
	{
		PlayerTextDrawBoxColor(playerid, ClassBackGround, gScreenBoxFadeLevel[playerid]);
		PlayerTextDrawShow(playerid, ClassBackGround);

		gScreenBoxFadeLevel[playerid] -= 4;

		if(gPlayerHP[playerid] <= 40.0)
		{
			if(gScreenBoxFadeLevel[playerid] <= floatround((40.0 - gPlayerHP[playerid]) * 4.4))
				gScreenBoxFadeLevel[playerid] = 0;
		}
	}
	else
	{
		if(gPlayerHP[playerid] < 40.0)
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
				PlayerTextDrawBoxColor(playerid, ClassBackGround, floatround((40.0 - gPlayerHP[playerid]) * 4.4));
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
		if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_MORPHINE) > 300000 || gPlayerHP[playerid] >= 100.0)
			RemoveDrug(playerid, DRUG_TYPE_MORPHINE);

		SetPlayerDrunkLevel(playerid, 2200);

		if(random(100) < 80)
			GivePlayerHP(playerid, 0.05);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
	{
		if(tickcount() - GetPlayerDrugUseTick(playerid, DRUG_TYPE_ADRENALINE) > 300000 || gPlayerHP[playerid] >= 100.0)
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
			if(frandom(100.0) < gPlayerHP[playerid])
			{
				RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
			}
		}
		else
		{
			if(frandom(100.0) < 100 - gPlayerHP[playerid])
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
		if(!IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_MORPHINE) && !IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE) && !IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_AIR))
		{
			if(GetPlayerDrunkLevel(playerid) == 0)
			{
				if(tickcount() - tick_LastInfectionFX[playerid] > 500 * gPlayerHP[playerid])
				{
					tick_LastInfectionFX[playerid] = tickcount();
					SetPlayerDrunkLevel(playerid, 5000);
				}
			}
			else
			{
				if(tickcount() - tick_LastInfectionFX[playerid] > 100 * (120 - gPlayerHP[playerid]) || 1 < GetPlayerDrunkLevel(playerid) < 2000)
				{
					tick_LastInfectionFX[playerid] = tickcount();
					SetPlayerDrunkLevel(playerid, 0);
				}
			}
		}
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

	tick_Spawn[playerid] = tickcount();

	SetPlayerWeather(playerid, gWeatherID);
	SetPlayerTeam(playerid, 0);
	ResetPlayerMoney(playerid);

	if(bPlayerGameSettings[playerid] & AdminDuty)
	{
		SetPlayerPos(playerid, 0.0, 0.0, 3.0);
		gPlayerHP[playerid] = 100.0;
		return 1;
	}

	if(bPlayerGameSettings[playerid] & Dying)
	{
		TogglePlayerSpectating(playerid, true);

		defer SetDeathCamera(playerid);

		SetPlayerCameraPos(playerid,
			gPlayerDeathPos[playerid][0] - floatsin(-gPlayerDeathPos[playerid][3], degrees),
			gPlayerDeathPos[playerid][1] - floatcos(-gPlayerDeathPos[playerid][3], degrees),
			gPlayerDeathPos[playerid][2]);

		SetPlayerCameraLookAt(playerid, gPlayerDeathPos[playerid][0], gPlayerDeathPos[playerid][1], gPlayerDeathPos[playerid][2]);

		TextDrawShowForPlayer(playerid, DeathText);
		TextDrawShowForPlayer(playerid, DeathButton);
		SelectTextDraw(playerid, 0xFFFFFF88);
		gPlayerHP[playerid] = 1.0;
	}
	else
	{
		gScreenBoxFadeLevel[playerid] = 0;
		PlayerTextDrawBoxColor(playerid, ClassBackGround, 0x000000FF);
		PlayerTextDrawShow(playerid, ClassBackGround);

		if(bPlayerGameSettings[playerid] & Alive)
		{
			if(bPlayerGameSettings[playerid] & LoggedIn)
			{
				PlayerSpawnExistingCharacter(playerid);
				gScreenBoxFadeLevel[playerid] = 255;
			}
			else
			{
				DisplayLoginPrompt(playerid);
			}
		}
		else
		{
			gPlayerHP[playerid] = 100.0;
			gPlayerAP[playerid] = 0.0;
			gPlayerFP[playerid] = 80.0;
			gPlayerFrequency[playerid] = 108.0;
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
		gPlayerDeathPos[playerid][0] - floatsin(-gPlayerDeathPos[playerid][3], degrees),
		gPlayerDeathPos[playerid][1] - floatcos(-gPlayerDeathPos[playerid][3], degrees),
		gPlayerDeathPos[playerid][2] + 1.0,
		gPlayerDeathPos[playerid][0] - floatsin(-gPlayerDeathPos[playerid][3], degrees),
		gPlayerDeathPos[playerid][1] - floatcos(-gPlayerDeathPos[playerid][3], degrees),
		gPlayerDeathPos[playerid][2] + 20.0,
		30000, CAMERA_MOVE);

	InterpolateCameraLookAt(playerid,
		gPlayerDeathPos[playerid][0],
		gPlayerDeathPos[playerid][1],
		gPlayerDeathPos[playerid][2],
		gPlayerDeathPos[playerid][0],
		gPlayerDeathPos[playerid][1],
		gPlayerDeathPos[playerid][2] + 1.0,
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

		GetVehicleVelocity(gPlayerVehicleID[playerid], vx, vy, vz);
		gPlayerVelocity[playerid] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
		format(str, 32, "%.0fkm/h", gPlayerVelocity[playerid]);
		PlayerTextDrawSetString(playerid, VehicleSpeedText, str);
	}

	if(bPlayerGameSettings[playerid] & Alive)
	{
		if(bPlayerGameSettings[playerid] & AdminDuty)
			gPlayerHP[playerid] = 250.0;

		SetPlayerHealth(playerid, gPlayerHP[playerid]);
		SetPlayerArmour(playerid, gPlayerAP[playerid]);
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

	x = gPlayerData[playerid][ply_posX];
	z = gPlayerData[playerid][ply_posY];
	x = gPlayerData[playerid][ply_posZ];

	return 1;
}



public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new vehicleid = GetPlayerVehicleID(playerid);

	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		new model = GetVehicleModel(vehicleid);

		gPlayerVehicleID[playerid] = vehicleid;

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
		VehicleDoorsState(gPlayerVehicleID[playerid], 0);

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
	tick_ExitVehicle[playerid] = tickcount();

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

	return tick_ServerJoin[playerid];
}

GetPlayerSpawnTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return tick_Spawn[playerid];
}

GetPlayerVehicleExitTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return tick_ExitVehicle[playerid];
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

	return gPlayerVehicleID[playerid];
}

forward Float:GetPlayerTotalVelocity(playerid);
Float:GetPlayerTotalVelocity(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return gPlayerVelocity[playerid];
}

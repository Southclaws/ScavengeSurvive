#include <YSI\y_hooks>


enum E_PLAYER_BIT_DATA:(<<= 1) // 23
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
		Bleeding,
		Infected,
		GlobalQuiet,

		Frozen,

		DebugMode
}

enum E_PLAYER_DATA
{
		// Database Account Data
		ply_Password[MAX_PASSWORD_LEN],
		ply_IP,
		ply_Karma,
		ply_RegisterTimestamp,
		ply_LastLogin,
		ply_TotalSpawns,
		ply_Warnings,

		// Other Account Data
		ply_Admin,

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
		ply_CreationTimestamp,
		ply_AimShoutText[128],

		// Internal Data
		ply_ChatMode,
		ply_CurrentVehicle,
		ply_LastHitBy[MAX_PLAYER_NAME],
		ply_LastHitById,
		ply_LastKilledBy[MAX_PLAYER_NAME],
		ply_LastKilledById,
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


new
E_PLAYER_BIT_DATA:
		gPlayerBitData	[MAX_PLAYERS],
		gPlayerData		[MAX_PLAYERS][E_PLAYER_DATA],
		gPlayerName		[MAX_PLAYERS][MAX_PLAYER_NAME];


public OnPlayerConnect(playerid)
{
	SetPlayerColor(playerid, 0xB8B8B800);
	SetPlayerWeather(playerid, gWeatherID);
	GetPlayerName(playerid, gPlayerName[playerid], MAX_PLAYER_NAME);

	if(IsPlayerNPC(playerid))
		return 1;

	ResetVariables(playerid);

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

	loadresult = LoadAccount(playerid);

	if(loadresult == 0) // Account does not exist
	{
		new str[150];
		format(str, 150, ""C_WHITE"Hello %P"C_WHITE", You must be new here!\nPlease create an account by entering a "C_BLUE"password"C_WHITE" below:", playerid);
		ShowPlayerDialog(playerid, d_Register, DIALOG_STYLE_PASSWORD, "Register For A New Account", str, "Accept", "Leave");

		t:gPlayerBitData[playerid]<IsNewPlayer>;

		logf("[JOIN] %p (account does not exist)", playerid);
	}

	if(loadresult == 1) // Account does exist, prompt login
	{
		DisplayLoginPrompt(playerid);

		logf("[JOIN] %p (account exists, prompting login)", playerid);
	}

	if(loadresult == 2) // Account does exist, auto login
	{
		Login(playerid);

		logf("[JOIN] %p (account exists, auto login)", playerid);
	}

	if(loadresult == 3) // Account does exist, but not in whitelist
	{
		WhitelistKick(playerid);

		logf("[JOIN] %p (account not whitelisted)", playerid);
	}

	TogglePlayerControllable(playerid, false);
	Streamer_ToggleIdleUpdate(playerid, true);
	TextDrawShowForPlayer(playerid, Branding);
	SetSpawn(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0);
	SpawnPlayer(playerid);

	LoadPlayerTextDraws(playerid);

	MsgAllF(WHITE, " >  %P (%d)"C_WHITE" has joined", playerid, playerid);
	MsgF(playerid, YELLOW, " >  MoTD: "C_BLUE"%s", gMessageOfTheDay);

	CheckForExtraAccounts(playerid);

	t:gPlayerBitData[playerid]<ShowHUD>;

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(gServerRestarting)
		return 0;

	if(IsValidVehicle(gPlayerData[playerid][ply_CurrentVehicle]))
		VehicleDoorsState(gPlayerData[playerid][ply_CurrentVehicle], 0);

	Logout(playerid);

	ResetVariables(playerid);

	switch(reason)
	{
		case 0:
		{
			MsgAllF(GREY, " >  %p lost connection.", playerid);
			logf("[PART] %p (lost connection)", playerid);
		}
		case 1:
		{
			MsgAllF(GREY, " >  %p left the server.", playerid);
			logf("[PART] %p (quit)", playerid);
		}
	}

	return 1;
}

ResetVariables(playerid)
{
	gPlayerBitData[playerid]						= E_PLAYER_BIT_DATA:0;

	gPlayerData[playerid][ply_Password][0]			= EOS;
	gPlayerData[playerid][ply_IP]					= 0;
	gPlayerData[playerid][ply_Admin]				= 0;
	gPlayerData[playerid][ply_Warnings]				= 0;
	gPlayerData[playerid][ply_Karma]				= 0;

	gPlayerData[playerid][ply_HitPoints]			= 100.0;
	gPlayerData[playerid][ply_ArmourPoints]			= 0.0;
	gPlayerData[playerid][ply_FoodPoints]			= 80.0;
	gPlayerData[playerid][ply_Clothes]				= 0;
	gPlayerData[playerid][ply_Gender]				= 0;
	gPlayerData[playerid][ply_Velocity]				= 0.0;
	gPlayerData[playerid][ply_SpawnPosX]			= 0.0;
	gPlayerData[playerid][ply_SpawnPosY]			= 0.0;
	gPlayerData[playerid][ply_SpawnPosZ]			= 0.0;
	gPlayerData[playerid][ply_SpawnRotZ]			= 0.0;
	gPlayerData[playerid][ply_DeathPosX]			= 0.0;
	gPlayerData[playerid][ply_DeathPosY]			= 0.0;
	gPlayerData[playerid][ply_DeathPosZ]			= 0.0;
	gPlayerData[playerid][ply_DeathRotZ]			= 0.0;
	gPlayerData[playerid][ply_RadioFrequency]		= 0.0;
	gPlayerData[playerid][ply_AimShoutText][0]		= EOS;

	gPlayerData[playerid][ply_ChatMode]				= CHAT_MODE_GLOBAL;
	gPlayerData[playerid][ply_CurrentVehicle]		= 0;
	gPlayerData[playerid][ply_LastHitBy][0]			= EOS;
	gPlayerData[playerid][ply_LastKilledBy][0]		= EOS;
	gPlayerData[playerid][ply_PingLimitStrikes]		= 0;
	gPlayerData[playerid][ply_SpectateTarget]		= INVALID_PLAYER_ID;
	gPlayerData[playerid][ply_ScreenBoxFadeLevel]	= 0;
	gPlayerData[playerid][ply_stance]				= 0;
	gPlayerData[playerid][ply_JoinTick]				= 0;
	gPlayerData[playerid][ply_SpawnTick]			= 0;
	gPlayerData[playerid][ply_TookDamageTick]		= 0;
	gPlayerData[playerid][ply_DeltDamageTick]		= 0;
	gPlayerData[playerid][ply_ExitVehicleTick]		= 0;
	gPlayerData[playerid][ply_LastChatMessageTick]	= 0;

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

	new pinglimit = (Iter_Count(Player) > 10) ? (gPingLimit) : (gPingLimit + 100);

	if(GetPlayerPing(playerid) > pinglimit)
	{
		if(GetTickCountDifference(tickcount(), gPlayerData[playerid][ply_JoinTick]) > 10000)
		{
			gPlayerData[playerid][ply_PingLimitStrikes]++;

			if(gPlayerData[playerid][ply_PingLimitStrikes] == 3)
			{
				KickPlayer(playerid, sprintf("Having a ping of: %d limit: %d.", GetPlayerPing(playerid), pinglimit));

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
	{
		PlayerVehicleUpdate(playerid);
	}
	else
	{
		VehicleSurfingCheck(playerid);

		if(IsValidVehicle(gPlayerData[playerid][ply_CurrentVehicle]))
		{
			new Float:health;

			GetVehicleHealth(gPlayerData[playerid][ply_CurrentVehicle], health);

			if(health < 299.0)
				SetVehicleHealth(gPlayerData[playerid][ply_CurrentVehicle], 299.0);
		}
	}

	if(gPlayerData[playerid][ply_ScreenBoxFadeLevel] > 0)
	{
		PlayerTextDrawBoxColor(playerid, ClassBackGround[playerid], gPlayerData[playerid][ply_ScreenBoxFadeLevel]);
		PlayerTextDrawShow(playerid, ClassBackGround[playerid]);

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
				PlayerTextDrawHide(playerid, ClassBackGround[playerid]);
			}
			else if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
			{
				PlayerTextDrawHide(playerid, ClassBackGround[playerid]);
			}
			else
			{
				PlayerTextDrawBoxColor(playerid, ClassBackGround[playerid], floatround((40.0 - gPlayerData[playerid][ply_HitPoints]) * 4.4));
				PlayerTextDrawShow(playerid, ClassBackGround[playerid]);
			}
		}
		else
		{
			if(gPlayerBitData[playerid] & Spawned)
				PlayerTextDrawHide(playerid, ClassBackGround[playerid]);
		}
	}

	KnockOutUpdate(playerid);
	DrugsUpdate(playerid);

	gettime(hour, minute);

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_LSD))
	{
		hour = 22;
		minute = 3;
		weather = 33;
	}
	else if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_HEROINE))
	{
		hour = 22;
		minute = 30;
		weather = 33;
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
			GivePlayerHP(playerid, -0.1);
	}

	if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_ADRENALINE))
	{
		GivePlayerHP(playerid, 0.01);
	}

	if(gPlayerBitData[playerid] & Bleeding)
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

		GivePlayerHP(playerid, 0.000925925); // One third of the health bar regenerates each real-time hour

		if(IsPlayerUnderDrugEffect(playerid, DRUG_TYPE_MORPHINE))
		{
			SetPlayerDrunkLevel(playerid, 2200);

			if(random(100) < 80)
				GivePlayerHP(playerid, 0.05);
		}

	}

	if(gPlayerBitData[playerid] & Infected)
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

	t:gPlayerBitData[playerid]<FirstSpawn>;

	SetSpawn(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0);

	return 0;
}

public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid))return 1;

	t:gPlayerBitData[playerid]<FirstSpawn>;

	SetSpawn(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0);

	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(gPlayerBitData[playerid] & Dying)
		{
			SelectTextDraw(playerid, 0xFFFFFF88);
		}
		else
		{
			ShowWatch(playerid);
		}
	}

	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
		return 1;

	gPlayerData[playerid][ply_SpawnTick] = tickcount();

	SetAllWeaponSkills(playerid, 500);
	SetPlayerWeather(playerid, gWeatherID);
	SetPlayerTeam(playerid, 0);
	ResetPlayerMoney(playerid);

	if(gPlayerBitData[playerid] & AdminDuty)
	{
		SetPlayerPos(playerid, 0.0, 0.0, 3.0);
		return 1;
	}

	if(!(gPlayerBitData[playerid] & Dying))
	{
		gPlayerData[playerid][ply_ScreenBoxFadeLevel] = 0;
		PlayerTextDrawBoxColor(playerid, ClassBackGround[playerid], 0x000000FF);
		PlayerTextDrawShow(playerid, ClassBackGround[playerid]);

		if(gPlayerBitData[playerid] & Alive)
		{
			if(gPlayerBitData[playerid] & LoggedIn)
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

public OnPlayerUpdate(playerid)
{
	if(gPlayerBitData[playerid] & Frozen)
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
		PlayerTextDrawSetString(playerid, VehicleSpeedText[playerid], str);
	}
	else
	{
		static
			Float:vx,
			Float:vy,
			Float:vz;

		GetPlayerVelocity(playerid, vx, vy, vz);
		gPlayerData[playerid][ply_Velocity] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
	}

	if(gPlayerBitData[playerid] & Alive)
	{
		if(gPlayerBitData[playerid] & AdminDuty)
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

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
		gPlayerData[playerid][ply_CurrentVehicle] = GetPlayerVehicleID(playerid);

	if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)
		gPlayerData[playerid][ply_ExitVehicleTick] = tickcount();

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(IsPlayerKnockedOut(playerid))
		return 0;

	if(GetPlayerSurfingVehicleID(playerid) == vehicleid)
		CancelPlayerMovement(playerid);

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

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerKnockedOut(playerid))
		return 0;

	if(!IsPlayerInAnyVehicle(playerid))
	{
		new weaponid = GetPlayerCurrentWeapon(playerid);

		if(weaponid == 34 || weaponid == 35 || weaponid == 43)
		{
			if(newkeys & 128)
			{
				TogglePlayerHeadwear(playerid, false);
				TogglePlayerMask(playerid, false);
			}
			if(oldkeys & 128)
			{
				TogglePlayerHeadwear(playerid, true);
				TogglePlayerMask(playerid, true);
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


forward E_PLAYER_BIT_DATA:GetPlayerDataBitmask(playerid);
stock E_PLAYER_BIT_DATA:GetPlayerDataBitmask(playerid)
{
	if(!IsPlayerConnected(playerid))
		return E_PLAYER_BIT_DATA:0;

	return gPlayerBitData[playerid];
}

// HasAccount
// IsVip
// LoggedIn
// LoadedData
// IsNewPlayer
// CanExitWelcome

// AdminDuty
stock IsPlayerOnAdminDuty(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return _:(gPlayerBitData[playerid] & AdminDuty);
}

// Alive
stock IsPlayerAlive(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return _:(gPlayerBitData[playerid] & Alive);
}

// Dying
stock IsPlayerDead(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return _:(gPlayerBitData[playerid] & Dying);
}

// Spawned
stock IsPlayerSpawned(playerid)
{
	return _:(gPlayerBitData[playerid] & Spawned);
}

// FirstSpawn

// ToolTips
stock IsPlayerToolTipsOn(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return _:(gPlayerBitData[playerid] & ToolTips);
}

// ShowHUD
stock IsPlayerHudOn(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return _:(gPlayerBitData[playerid] & ShowHUD);
}

// Bleeding
stock IsPlayerBleeding(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return _:(gPlayerBitData[playerid] & Bleeding);
}

// Infected
// GlobalQuiet

// Frozen

// DebugMode




// ply_Password
// ply_IP
// ply_Karma
// ply_RegisterTimestamp
// ply_LastLogin
// ply_TotalSpawns
// ply_Warnings

// ply_Admin
GetPlayerAdminLevel(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_Admin];
}

// ply_HitPoints
// ply_ArmourPoints
forward Float:GetPlayerAP(playerid);
stock Float:GetPlayerAP(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return gPlayerData[playerid][ply_ArmourPoints];
}

stock SetPlayerAP(playerid, Float:amount)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(amount <= 0.0)
	{
		amount = 0.0;

		ToggleArmour(playerid, false);
	}
	else
	{
		if(amount > 100.0)
			amount = 100.0;

		ToggleArmour(playerid, false);
	}

	gPlayerData[playerid][ply_ArmourPoints] = amount;

	return 1;
}

// ply_FoodPoints
// ply_Clothes
// ply_Gender
// ply_Velocity
forward Float:GetPlayerTotalVelocity(playerid);
Float:GetPlayerTotalVelocity(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return gPlayerData[playerid][ply_Velocity];
}

// ply_SpawnPosX
// ply_SpawnPosY
// ply_SpawnPosZ
GetPlayerSpawnPos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	x = gPlayerData[playerid][ply_SpawnPosX];
	z = gPlayerData[playerid][ply_SpawnPosY];
	x = gPlayerData[playerid][ply_SpawnPosZ];

	return 1;
}

// ply_SpawnRotZ
// ply_DeathPosX
// ply_DeathPosY
// ply_DeathPosZ
// ply_DeathRotZ
// ply_RadioFrequency
forward Float:GetPlayerRadioFrequency(playerid);
stock Float:GetPlayerRadioFrequency(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return gPlayerData[playerid][ply_RadioFrequency];
}
stock SetPlayerRadioFrequency(playerid, Float:frequency)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	gPlayerData[playerid][ply_RadioFrequency] = frequency;

	return 1;
}

// ply_CreationTimestamp

// ply_AimShoutText
stock GetPlayerAimShoutText(playerid, string[])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	string[0] = EOS;
	strcat(string, gPlayerData[playerid][ply_AimShoutText], 128);

	return 1;
}
stock SetPlayerAimShoutText(playerid, string[128])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	gPlayerData[playerid][ply_AimShoutText] = string;

	return 1;
}


// ply_ChatMode
stock GetPlayerChatMode(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_ChatMode];
}
stock SetPlayerChatMode(playerid, chatmode)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	gPlayerData[playerid][ply_ChatMode] = chatmode;

	return 1;
}

// ply_CurrentVehicle
stock GetPlayerLastVehicle(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_CurrentVehicle];
}

// ply_LastHitBy
stock GetLastHitBy(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_LastHitBy];
}

// ply_LastHitById
stock GetLastHitById(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_LastHitById];
}

// ply_LastKilledBy
stock GetLastKilledBy(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_LastKilledBy];
}

// ply_LastKilledById
stock GetLastKilledById(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_LastKilledById];
}

// ply_PingLimitStrikes
// ply_SpectateTarget
// ply_ScreenBoxFadeLevel
// ply_stance
// ply_JoinTick
stock GetPlayerServerJoinTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_JoinTick];
}

// ply_SpawnTick
stock GetPlayerSpawnTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_SpawnTick];
}

// ply_TookDamageTick
stock GetPlayerTookDamageTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_TookDamageTick];
}

// ply_DeltDamageTick
stock GetPlayerDeltDamageTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_DeltDamageTick];
}

// ply_ExitVehicleTick
stock GetPlayerVehicleExitTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_ExitVehicleTick];
}

// ply_LastChatMessageTick
stock GetPlayerLastChatTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return gPlayerData[playerid][ply_LastChatMessageTick];
}

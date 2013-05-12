#include <YSI\y_hooks>

#define MAX_SPRAYTAG		(16)
#define SPT_MAX_PROGRESS	(25.0)

enum E_SPRAYTAG_DATA
{
	spt_objID,
	spt_areaID,
	spt_text[24],
	Float:spt_posX,
	Float:spt_posY,
	Float:spt_posZ,
	Float:spt_rotX,
	Float:spt_rotY,
	Float:spt_rotZ
}

new
	spt_Data[MAX_SPRAYTAG][E_SPRAYTAG_DATA],
	Iterator:spt_Iterator<MAX_SPRAYTAG>,

	spt_Spraying[MAX_PLAYERS],
	Timer:spt_SprayTimer[MAX_PLAYERS];

hook OnGameModeInit()
{
	for(new i;i<MAX_PLAYERS;i++)
		spt_Spraying[i] = -1;
}

stock AddSprayTag(Float:posx, Float:posy, Float:posz, Float:rotx, Float:roty, Float:rotz)
{
	new id = Iter_Free(spt_Iterator);
	
	rotz -= 180.0;

	spt_Data[id][spt_objID]		= CreateDynamicObject(19477, posx, posy, posz, rotx, roty, rotz);
	spt_Data[id][spt_areaID]	= CreateDynamicSphere(posx, posy, posz, 1.5, 0, 0);
    spt_Data[id][spt_text]		= "12345678901234567890123";
    spt_Data[id][spt_posX]		= posx;
    spt_Data[id][spt_posY]		= posy;
    spt_Data[id][spt_posZ]		= posz;
    spt_Data[id][spt_rotX]		= rotx;
    spt_Data[id][spt_rotY]		= roty;
    spt_Data[id][spt_rotZ]		= rotz;

    SetDynamicObjectMaterialText(spt_Data[id][spt_objID], 0, "HELLFIRE", OBJECT_MATERIAL_SIZE_512x256, "IMPACT", 72, 1, 0xFFFF0000, 0, 1);

	Iter_Add(spt_Iterator, id);
	return id;
}
stock DeleteSprayTag(tagid)
{
	new next;

	DestroyDynamicObject(spt_Data[tagid][spt_objID]);
    spt_Data[tagid][spt_posX] = 0.0;
    spt_Data[tagid][spt_posY] = 0.0;
    spt_Data[tagid][spt_posZ] = 0.0;
    spt_Data[tagid][spt_rotX] = 0.0;
    spt_Data[tagid][spt_rotY] = 0.0;
    spt_Data[tagid][spt_rotZ] = 0.0;

	Iter_SafeRemove(spt_Iterator, tagid, next);
	return next;
}
stock SetSprayTagText(tagid, text[], colour = -1, font[] = "Arial Black")
{
    format(spt_Data[tagid][spt_text], 24, text);
    SetDynamicObjectMaterialText(spt_Data[tagid][spt_objID], 0, text, OBJECT_MATERIAL_SIZE_512x256, font, 72, 1, colour, 0, 1);
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : spt_Iterator)
	{
	    if(areaid == spt_Data[i][spt_areaID])
	    {
	        if(!strcmp(spt_Data[i][spt_text], gPlayerName[playerid]))
	        {
				ShowActionText(playerid, "You have already tagged this", 3000, 150);
				return 1;
			}

			if(GetPlayerWeapon(playerid) == WEAPON_SPRAYCAN)
			{
				ShowActionText(playerid, "Hold ~b~FIRE ~w~to spray your tag", 3000, 150);
			}
			else
			{
				ShowActionText(playerid, "~r~You need a spray can.", 3000, 140);
			}

	    }
	}
    return CallLocalFunction("spt_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea spt_OnPlayerEnterDynamicArea
forward spt_OnPlayerEnterDynamicArea(playerid, areaid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_FIRE)
	{
	    new
			wepState = GetPlayerWeaponState(playerid),
			wepID = GetPlayerWeapon(playerid);

	    if(wepID != WEAPON_SPRAYCAN || wepState == WEAPONSTATE_RELOADING || wepState == WEAPONSTATE_NO_BULLETS || spt_Spraying[playerid] != -1)
	        return 0;

		foreach(new i : spt_Iterator)
		{
			if(IsPlayerInDynamicArea(playerid, spt_Data[i][spt_areaID]))
			{
				if(!strcmp(spt_Data[i][spt_text], gPlayerName[playerid]))
					return 1;

				spt_Spraying[playerid] = i;
				spt_SprayTimer[playerid] = repeat SprayTag(playerid, i);

				SetPlayerProgressBarMaxValue(playerid, ActionBar, SPT_MAX_PROGRESS);
				SetPlayerProgressBarValue(playerid, ActionBar, 0.0);
				ShowPlayerProgressBar(playerid, ActionBar);
			}
		}

	}
	if(oldkeys & KEY_FIRE)
	{
		if(spt_Spraying[playerid] != -1)
		{
		    stop spt_SprayTimer[playerid];
			spt_Spraying[playerid] = -1;

		    HidePlayerProgressBar(playerid, ActionBar);
		}
	}
    return 1;
}

timer SprayTag[100](playerid, tagid)
{
	new
		name[MAX_PLAYER_NAME],
		colour = GetPlayerColor(playerid),
		Float:progress = GetPlayerProgressBarValue(playerid, ActionBar),
		animIdx = GetPlayerAnimationIndex(playerid),
		Float:ang;

	GetPlayerFacingAngle(playerid, ang);
	
	if(ang>180)ang=360-ang;
	
	if(animIdx != 1167 && animIdx != 1160 && animIdx != 1161 && animIdx != 1162 && animIdx != 1163)return CancelTagging(playerid);
	if( (ang-(spt_Data[tagid][spt_rotZ]+90.0)) > 30.0 )return CancelTagging(playerid);

	progress += 1.0;
	SetPlayerProgressBarValue(playerid, ActionBar, progress);
	UpdatePlayerProgressBar(playerid, ActionBar);
	
	if(progress == SPT_MAX_PROGRESS)
	{
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		SetSprayTagText(tagid, name, colour >>> 8 | colour << 24, "Arial Black");
		SetPlayerProgressBarValue(playerid, ActionBar, 0.0);
		HidePlayerProgressBar(playerid, ActionBar);
		spt_Spraying[playerid] = -1;
		stop spt_SprayTimer[playerid];
	}
	return 1;
}
CancelTagging(playerid)
{
	stop spt_SprayTimer[playerid];
	HidePlayerProgressBar(playerid, ActionBar);
	spt_Spraying[playerid] = -1;
	return 0;
}

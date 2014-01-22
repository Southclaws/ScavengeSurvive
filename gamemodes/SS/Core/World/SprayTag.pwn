#include <YSI\y_hooks>

#define MAX_SPRAYTAG		(32)
#define TAG_SPRAY_TIME		(2500)

enum E_SPRAYTAG_DATA
{
		tag_objId,
		tag_areaId,
		tag_text[24],
Float:	tag_posX,
Float:	tag_posY,
Float:	tag_posZ,
Float:	tag_rotX,
Float:	tag_rotY,
Float:	tag_rotZ
}

static
		tag_Data		[MAX_SPRAYTAG][E_SPRAYTAG_DATA],
		tag_Total;

static
		tag_CurrentTag	[MAX_PLAYERS],
		tag_Spraying	[MAX_PLAYERS];


public OnLoad()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		tag_CurrentTag[i] = -1;
		tag_Spraying[i] = -1;
	}

	CreateNewSprayTag(-399.76999, 1514.92004, 75.26000,   0.00000, 0.00000, 0.00000);
	CreateNewSprayTag(-229.34000, 1082.34998, 20.29000,   0.00000, 0.00000, 0.00000);
	CreateNewSprayTag(-2442.16992, 2299.22998, 5.71000,   0.00000, 0.00000, 270.00000);
	CreateNewSprayTag(-2662.94995, 2121.43994, 2.14000,   0.00000, 0.00000, 180.00000);
	CreateNewSprayTag(146.92000, 1831.78003, 18.02000,   0.00000, 0.00000, 90.00000);
	CreateNewSprayTag(1172.88086, -1313.05103, 14.24630,   10.00000, 0.00000, 180.00000);
	CreateNewSprayTag(1237.39001, -1631.59998, 28.02000,   0.00000, 0.00000, 91.00000);
	CreateNewSprayTag(1118.51100, -1540.14001, 23.66000,   0.00000, 0.00000, 178.46001);
	CreateNewSprayTag(1202.10999, -1201.55005, 20.47000,   0.00000, 0.00000, 90.00000);
	CreateNewSprayTag(1264.15002, -1270.28003, 14.26000,   0.00000, 0.00000, 270.00000);
	CreateNewSprayTag(-1908.90003, 299.56000, 41.52000,   0.00000, 0.00000, 180.00000);
	CreateNewSprayTag(-2636.69995, 635.52002, 15.13000,   0.00000, 0.00000, 0.00000);
	CreateNewSprayTag(-2224.75000, 881.27002, 84.13000,   0.00000, 0.00000, 90.00000);
	CreateNewSprayTag(-1788.31995, 748.41998, 25.36000,   0.00000, 0.00000, 270.00000);

	#if defined tag_OnLoad
        tag_OnLoad();
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad tag_OnLoad
#if defined tag_OnLoad
    forward tag_OnLoad();
#endif


CreateNewSprayTag(Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	new count;

	stmt_bind_value(gStmt_SprayTagExists, 0, DB::TYPE_FLOAT, x);
	stmt_bind_value(gStmt_SprayTagExists, 1, DB::TYPE_FLOAT, y);
	stmt_bind_value(gStmt_SprayTagExists, 2, DB::TYPE_FLOAT, z);
	stmt_bind_result_field(gStmt_SprayTagExists, 0, DB::TYPE_INT, count);

	if(stmt_execute(gStmt_SprayTagExists))
	{
		stmt_fetch_row(gStmt_SprayTagExists);

		if(count == 0)
		{
			stmt_bind_value(gStmt_SprayTagInsert, 0, DB::TYPE_STRING, "HELLFIRE", 8);
			stmt_bind_value(gStmt_SprayTagInsert, 1, DB::TYPE_FLOAT, x);
			stmt_bind_value(gStmt_SprayTagInsert, 2, DB::TYPE_FLOAT, y);
			stmt_bind_value(gStmt_SprayTagInsert, 3, DB::TYPE_FLOAT, z);
			stmt_bind_value(gStmt_SprayTagInsert, 4, DB::TYPE_FLOAT, rx);
			stmt_bind_value(gStmt_SprayTagInsert, 5, DB::TYPE_FLOAT, ry);
			stmt_bind_value(gStmt_SprayTagInsert, 6, DB::TYPE_FLOAT, rz);

			stmt_execute(gStmt_SprayTagInsert);
		}
	}
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock AddSprayTag(Float:posx, Float:posy, Float:posz, Float:rotx, Float:roty, Float:rotz)
{
	rotz -= 180.0;

	tag_Data[tag_Total][tag_objId]	= CreateDynamicObject(19477, posx, posy, posz, rotx, roty, rotz);
	tag_Data[tag_Total][tag_areaId]	= CreateDynamicSphere(posx, posy, posz, 2.0, 0, 0);
	tag_Data[tag_Total][tag_posX]	= posx;
	tag_Data[tag_Total][tag_posY]	= posy;
	tag_Data[tag_Total][tag_posZ]	= posz;
	tag_Data[tag_Total][tag_rotX]	= rotx;
	tag_Data[tag_Total][tag_rotY]	= roty;
	tag_Data[tag_Total][tag_rotZ]	= rotz;

	SetDynamicObjectMaterialText(tag_Data[tag_Total][tag_objId], 0, "HELLFIRE", OBJECT_MATERIAL_SIZE_512x256, "IMPACT", 72, 1, 0xFFFF0000, 0, 1);

	return tag_Total++;
}

stock SetSprayTagText(tagid, text[], colour = -1, font[] = "Arial Black")
{
	format(tag_Data[tagid][tag_text], 24, text);
	SetDynamicObjectMaterialText(tag_Data[tagid][tag_objId], 0, text, OBJECT_MATERIAL_SIZE_512x256, font, 72, 1, colour, 0, 1);
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


public OnPlayerEnterDynamicArea(playerid, areaid)
{
	for(new i; i < tag_Total; i++)
	{
		if(areaid == tag_Data[i][tag_areaId])
		{
			new name[MAX_PLAYER_NAME];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			tag_CurrentTag[playerid] = i;

			if(!strcmp(tag_Data[i][tag_text], name))
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

			break;
		}
	}
	#if defined tag_OnPlayerEnterDynamicArea
        return tag_OnPlayerEnterDynamicArea(playerid, areaid);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea tag_OnPlayerEnterDynamicArea
#if defined tag_OnPlayerEnterDynamicArea
    forward tag_OnPlayerEnterDynamicArea(playerid, areaid);
#endif

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	if(0 <= tag_CurrentTag[playerid] < MAX_SPRAYTAG)
	{
		if(areaid == tag_Data[tag_CurrentTag[playerid]][tag_areaId])
		{
			tag_CurrentTag[playerid] = -1;
		}
	}

	#if defined tag_OnPlayerLeaveDynamicArea
        return tag_OnPlayerLeaveDynamicArea(playerid, areaid);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnPlayerLeaveDynamicArea
	#undef OnPlayerLeaveDynamicArea
#else
	#define _ALS_OnPlayerLeaveDynamicArea
#endif
#define OnPlayerLeaveDynamicArea tag_OnPlayerLeaveDynamicArea
#if defined tag_OnPlayerLeaveDynamicArea
    forward tag_OnPlayerLeaveDynamicArea(playerid, areaid);
#endif

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_FIRE)
	{
		if(tag_CurrentTag[playerid] != -1)
		{
			new
				weaponstate = GetPlayerWeaponState(playerid),
				weaponid = GetPlayerWeapon(playerid);

			if(weaponid != WEAPON_SPRAYCAN || weaponstate == WEAPONSTATE_RELOADING || weaponstate == WEAPONSTATE_NO_BULLETS || tag_Spraying[playerid] != -1)
				return 0;

			StartSprayingTag(playerid, tag_CurrentTag[playerid]);
		}
	}
	if(oldkeys & KEY_FIRE)
	{
		if(tag_Spraying[playerid] != -1)
		{
			StopSprayingTag(playerid);
		}
	}
	return 1;
}

StartSprayingTag(playerid, tagid)
{
	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	if(!strcmp(tag_Data[tagid][tag_text], name))
		return 0;

	tag_Spraying[playerid] = tagid;

	StartHoldAction(playerid, TAG_SPRAY_TIME);

	return 1;
}

StopSprayingTag(playerid)
{
	tag_Spraying[playerid] = -1;

	StopHoldAction(playerid);
}

public OnHoldActionUpdate(playerid, progress)
{
	if(tag_Spraying[playerid] != -1)
	{
		new
			animidx = GetPlayerAnimationIndex(playerid),
			Float:angle;

		GetPlayerFacingAngle(playerid, angle);
		
		angle = absoluteangle(angle - (tag_Data[tag_Spraying[playerid]][tag_rotZ] + 270.0));

		
		if(!(135.0 < angle < 225.0))
		{
			StopSprayingTag(playerid);
			return 1;
		}

		if(animidx != 1167 && animidx != 1160 && animidx != 1161 && animidx != 1162 && animidx != 1163)
		{
			StopSprayingTag(playerid);
			return 1;
		}

		return 1;
	}

	#if defined tag_OnHoldActionUpdate
        return tag_OnHoldActionUpdate(playerid, progress);
    #elseif
        return 0;
    #endif
}

#if defined _ALS_OnHoldActionUpdate
	#undef OnHoldActionUpdate
#else
	#define _ALS_OnHoldActionUpdate
#endif
#define OnHoldActionUpdate tag_OnHoldActionUpdate
#if defined tag_OnHoldActionUpdate
    forward tag_OnHoldActionUpdate(playerid, progress);
#endif

public OnHoldActionFinish(playerid)
{
	if(tag_Spraying[playerid] != -1)
	{
		new name[MAX_PLAYER_NAME];

		GetPlayerName(playerid, name, MAX_PLAYER_NAME);

		SetSprayTagText(tag_Spraying[playerid], name, 0xFFFF00FF, "Arial Black");
		StopSprayingTag(playerid);

		return 1;
	}

	#if defined tag_OnHoldActionFinish
        return tag_OnHoldActionFinish(playerid);
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish tag_OnHoldActionFinish
#if defined tag_OnHoldActionFinish
    forward tag_OnHoldActionFinish(playerid);
#endif


/*==============================================================================

	Load and Save

==============================================================================*/


LoadSprayTags()
{
	new
		name[MAX_PLAYER_NAME],
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz;

	stmt_bind_result_field(gStmt_SprayTagLoad, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(gStmt_SprayTagLoad, 1, DB::TYPE_FLOAT, x);
	stmt_bind_result_field(gStmt_SprayTagLoad, 2, DB::TYPE_FLOAT, y);
	stmt_bind_result_field(gStmt_SprayTagLoad, 3, DB::TYPE_FLOAT, z);
	stmt_bind_result_field(gStmt_SprayTagLoad, 4, DB::TYPE_FLOAT, rx);
	stmt_bind_result_field(gStmt_SprayTagLoad, 5, DB::TYPE_FLOAT, ry);
	stmt_bind_result_field(gStmt_SprayTagLoad, 6, DB::TYPE_FLOAT, rz);

	stmt_execute(gStmt_SprayTagLoad);

	while(stmt_fetch_row(gStmt_SprayTagLoad))
	{
		SetSprayTagText(AddSprayTag(x, y, z, rx, ry, rz), name, 0xFFFF00FF);
	}

	printf("Loaded %d Spray Tags", tag_Total);
}

SaveSprayTags()
{
	for(new i; i < tag_Total; i++)
	{
		stmt_bind_value(gStmt_SprayTagSave, 0, DB::TYPE_STRING, tag_Data[i][tag_text], MAX_PLAYER_NAME);
		stmt_bind_value(gStmt_SprayTagSave, 1, DB::TYPE_FLOAT, tag_Data[i][tag_posX]);
		stmt_bind_value(gStmt_SprayTagSave, 2, DB::TYPE_FLOAT, tag_Data[i][tag_posY]);
		stmt_bind_value(gStmt_SprayTagSave, 3, DB::TYPE_FLOAT, tag_Data[i][tag_posZ]);

		stmt_execute(gStmt_SprayTagSave);
	}
}

ReloadTags()
{
	SaveSprayTags();

	for(new i; i < tag_Total; i++)
	{
		DestroyDynamicObject(tag_Data[i][tag_objId]);
		DestroyDynamicArea(tag_Data[i][tag_areaId]);
	}

	tag_Total = 0;

	LoadSprayTags();
}

CMD:reloadtags(playerid, params[])
{
	ReloadTags();

	return 1;
}

CMD:gototag(playerid, params[])
{
	new id = strval(params);

	SetPlayerPos(playerid, tag_Data[id][tag_posX], tag_Data[id][tag_posY], tag_Data[id][tag_posZ]);
}

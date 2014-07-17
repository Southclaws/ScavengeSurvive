#include <YSI\y_hooks>

#define MAX_SPRAYTAG		(32)
#define TAG_SPRAY_TIME		(2500)
#define WORLD_TABLE_SPRAYTAG		"SprayTag"
#define FIELD_SPRAYTAG_NAME			"name"		// 00
#define FIELD_SPRAYTAG_POSX			"posx"		// 01
#define FIELD_SPRAYTAG_POSY			"posy"		// 02
#define FIELD_SPRAYTAG_POSZ			"posz"		// 03
#define FIELD_SPRAYTAG_ROTX			"rotx"		// 04
#define FIELD_SPRAYTAG_ROTY			"roty"		// 05
#define FIELD_SPRAYTAG_ROTZ			"rotz"		// 06

enum
{
	FIELD_ID_SPRAYTAG_NAME,
	FIELD_ID_SPRAYTAG_POSX,
	FIELD_ID_SPRAYTAG_POSY,
	FIELD_ID_SPRAYTAG_POSZ,
	FIELD_ID_SPRAYTAG_ROTX,
	FIELD_ID_SPRAYTAG_ROTY,
	FIELD_ID_SPRAYTAG_ROTZ
}

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
				tag_Total,
DBStatement:	stmt_SprayTagExists,
DBStatement:	stmt_SprayTagInsert,
DBStatement:	stmt_SprayTagLoad,
DBStatement:	stmt_SprayTagSave;


static
				tag_CurrentTag	[MAX_PLAYERS],
				tag_Spraying	[MAX_PLAYERS];


hook OnGameModeInit()
{
	db_free_result(db_query(gWorld, "CREATE TABLE IF NOT EXISTS "WORLD_TABLE_SPRAYTAG" (\
		"FIELD_SPRAYTAG_NAME" TEXT,\
		"FIELD_SPRAYTAG_POSX" REAL,\
		"FIELD_SPRAYTAG_POSY" REAL,\
		"FIELD_SPRAYTAG_POSZ" REAL,\
		"FIELD_SPRAYTAG_ROTX" REAL,\
		"FIELD_SPRAYTAG_ROTY" REAL,\
		"FIELD_SPRAYTAG_ROTZ" REAL)"));

	DatabaseTableCheck(gWorld, WORLD_TABLE_SPRAYTAG, 7);

	stmt_SprayTagExists	= db_prepare(gWorld, "SELECT COUNT(*) FROM "WORLD_TABLE_SPRAYTAG" WHERE "FIELD_SPRAYTAG_POSX" = ? AND "FIELD_SPRAYTAG_POSY" = ? AND "FIELD_SPRAYTAG_POSZ" = ?");
	stmt_SprayTagInsert	= db_prepare(gWorld, "INSERT INTO "WORLD_TABLE_SPRAYTAG" VALUES(?, ?, ?, ?, ?, ?, ?)");
	stmt_SprayTagLoad	= db_prepare(gWorld, "SELECT * FROM "WORLD_TABLE_SPRAYTAG"");
	stmt_SprayTagSave	= db_prepare(gWorld, "UPDATE "WORLD_TABLE_SPRAYTAG" SET "FIELD_SPRAYTAG_NAME" = ? WHERE "FIELD_SPRAYTAG_POSX" = ? AND "FIELD_SPRAYTAG_POSY" = ? AND "FIELD_SPRAYTAG_POSZ" = ?");

	for(new i; i < MAX_PLAYERS; i++)
	{
		tag_CurrentTag[i] = -1;
		tag_Spraying[i] = -1;
	}
}


CreateNewSprayTag(Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	new count;

	stmt_bind_value(stmt_SprayTagExists, 0, DB::TYPE_FLOAT, x);
	stmt_bind_value(stmt_SprayTagExists, 1, DB::TYPE_FLOAT, y);
	stmt_bind_value(stmt_SprayTagExists, 2, DB::TYPE_FLOAT, z);
	stmt_bind_result_field(stmt_SprayTagExists, 0, DB::TYPE_INT, count);

	if(!stmt_execute(stmt_SprayTagExists))
		return 0;

	stmt_fetch_row(stmt_SprayTagExists);

	if(count == 0)
	{
		stmt_bind_value(stmt_SprayTagInsert, 0, DB::TYPE_STRING, "HELLFIRE", 8);
		stmt_bind_value(stmt_SprayTagInsert, 1, DB::TYPE_FLOAT, x);
		stmt_bind_value(stmt_SprayTagInsert, 2, DB::TYPE_FLOAT, y);
		stmt_bind_value(stmt_SprayTagInsert, 3, DB::TYPE_FLOAT, z);
		stmt_bind_value(stmt_SprayTagInsert, 4, DB::TYPE_FLOAT, rx);
		stmt_bind_value(stmt_SprayTagInsert, 5, DB::TYPE_FLOAT, ry);
		stmt_bind_value(stmt_SprayTagInsert, 6, DB::TYPE_FLOAT, rz);

		stmt_execute(stmt_SprayTagInsert);
	}

	return 1;
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
	#else
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
	#else
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
	#else
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
	#else
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

	stmt_bind_result_field(stmt_SprayTagLoad, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_SprayTagLoad, 1, DB::TYPE_FLOAT, x);
	stmt_bind_result_field(stmt_SprayTagLoad, 2, DB::TYPE_FLOAT, y);
	stmt_bind_result_field(stmt_SprayTagLoad, 3, DB::TYPE_FLOAT, z);
	stmt_bind_result_field(stmt_SprayTagLoad, 4, DB::TYPE_FLOAT, rx);
	stmt_bind_result_field(stmt_SprayTagLoad, 5, DB::TYPE_FLOAT, ry);
	stmt_bind_result_field(stmt_SprayTagLoad, 6, DB::TYPE_FLOAT, rz);

	stmt_execute(stmt_SprayTagLoad);

	while(stmt_fetch_row(stmt_SprayTagLoad))
	{
		SetSprayTagText(AddSprayTag(x, y, z, rx, ry, rz), name, 0xFFFF00FF);
	}

	printf("Loaded %d Spray Tags", tag_Total);
}

SaveSprayTags()
{
	for(new i; i < tag_Total; i++)
	{
		stmt_bind_value(stmt_SprayTagSave, 0, DB::TYPE_STRING, tag_Data[i][tag_text], MAX_PLAYER_NAME);
		stmt_bind_value(stmt_SprayTagSave, 1, DB::TYPE_FLOAT, tag_Data[i][tag_posX]);
		stmt_bind_value(stmt_SprayTagSave, 2, DB::TYPE_FLOAT, tag_Data[i][tag_posY]);
		stmt_bind_value(stmt_SprayTagSave, 3, DB::TYPE_FLOAT, tag_Data[i][tag_posZ]);

		stmt_execute(stmt_SprayTagSave);
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

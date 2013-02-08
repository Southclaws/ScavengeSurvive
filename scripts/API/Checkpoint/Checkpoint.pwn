#define MAX_CHECKPOINT			(256)
#define MAX_CHECKPOINT_MSG_LEN	(128)

enum (<<=1)
{
	b_msg = 1,
	b_label,
	b_icon,
	b_delete
}
enum OPTIONAL_DATA
{
	i_world,
	i_interior,
	i_playerid,
	Text3D:i_labelID,
	i_iconID,
	i_objectID,
	Float:f_rotateAxis[3],
	i_msgTime
}

enum ENUM_CHECKPOINT_DATA
{
	cp_areaID,
	Float:cp_posX,
	Float:cp_posY,
	Float:cp_posZ,
	Float:cp_diameter,
	cp_msg[MAX_CHECKPOINT_MSG_LEN],
	cp_boolSet,
	cp_optData[OPTIONAL_DATA]
}


new
			CheckPointData[MAX_CHECKPOINT][ENUM_CHECKPOINT_DATA],
Iterator:	CheckpointIndex<MAX_CHECKPOINT>;


forward OnPlayerActivateCheckpoint(playerid, checkpointid);


stock CreateCheckPoint(
	Float:x, Float:y, Float:z, Float:size, // standard parameters
	world=-1, interior=-1, playerid=-1, Float:streamdist=200.0, deleteOnActivate=0, // standard options
	Msg[]="", msgTime=0, // Msg options
	label=0, labelcolour=YELLOW, labelLOS=0, // label options
	icon=0, iconColour=RED, // icon options
	objectmodel=-1, Float:rotation[3] = {0.0, 0.0, 0.0}) // object options

{
	new id = Iter_Free(CheckpointIndex);

	CheckPointData[id][cp_areaID]					= CreateDynamicSphere(x, y, z, size, world, interior, playerid);
	CheckPointData[id][cp_posX]						= x;
	CheckPointData[id][cp_posY]						= y;
	CheckPointData[id][cp_posZ]						= z;
	CheckPointData[id][cp_diameter]					= size;
	CheckPointData[id][cp_optData][i_world]			= world;
	CheckPointData[id][cp_optData][i_interior]		= interior;
	CheckPointData[id][cp_optData][i_playerid]  	= playerid;

	if(!isnull(Msg))
	{
		strcat(CheckPointData[id][cp_msg], Msg);
		CheckPointData[id][cp_optData][i_msgTime] = msgTime;
		t:CheckPointData[id][cp_boolSet]<b_msg>;
	}
	if(label)
	{
		CheckPointData[id][cp_optData][i_labelID]=CreateDynamic3DTextLabel(Msg, labelcolour, x, y, z, streamdist, _, _, labelLOS, world, interior, playerid, streamdist);
		t:CheckPointData[id][cp_boolSet]<b_label>;
	}
	if(icon)
	{
	    CheckPointData[id][cp_optData][i_iconID]=CreateDynamicMapIcon(x, y, z, 0, iconColour, world, interior, playerid, streamdist);
		t:CheckPointData[id][cp_boolSet]<b_icon>;
	}
	if(objectmodel!=-1)
	{
		CheckPointData[id][cp_optData][f_rotateAxis] = rotation;
		CheckPointData[id][cp_optData][i_objectID]=CreateDynamicObject(objectmodel, x, y, z, rotation[0], rotation[1], rotation[2], world, interior, playerid, streamdist);
	}
	if(deleteOnActivate)t:CheckPointData[id][cp_boolSet]<b_delete>;

	Iter_Add(CheckpointIndex, id);
	
	printf("Created CP - INDEX SIZE: %d", Iter_Count(CheckpointIndex));
	
	return id;
}
stock DestroyCheckPoint(id)
{
	if(!Iter_Contains(CheckpointIndex, id))return 0;

	DestroyDynamicArea(CheckPointData[id][cp_areaID]);
	CheckPointData[id][cp_posX] = 0.0;
	CheckPointData[id][cp_posY] = 0.0;
	CheckPointData[id][cp_posZ] = 0.0;
	CheckPointData[id][cp_diameter] = 0.0;
	CheckPointData[id][cp_optData][i_world]		= -1;
	CheckPointData[id][cp_optData][i_interior]	= -1;
	CheckPointData[id][cp_optData][i_playerid]  = -1;

	if(!isnull(CheckPointData[id][cp_msg]))
	{
	    CheckPointData[id][cp_msg][0]=0;
	}
	if(CheckPointData[id][cp_boolSet]&b_label)
	{
		DestroyDynamic3DTextLabel(CheckPointData[id][cp_optData][i_labelID]);
	}
	if(CheckPointData[id][cp_boolSet]&b_icon)
	{
		DestroyDynamicMapIcon(CheckPointData[id][cp_optData][i_iconID]);
	}
	if(CheckPointData[id][cp_optData][i_objectID]!=-1)
	{
		StopDynamicObject(CheckPointData[id][cp_optData][i_objectID]);
		DestroyDynamicObject(CheckPointData[id][cp_optData][i_objectID]);
	}
	CheckPointData[id][cp_boolSet]=0;
	
	Iter_Remove(CheckpointIndex, id);

	printf("Deleted CP - INDEX SIZE: %d", Iter_Count(CheckpointIndex));

	return 1;
}

stock IsValidCheckPoint(id)
{
	if(!Iter_Contains(CheckpointIndex, id))return 0;
	return 1;
}

Internal_ActivateCheckpoint(playerid, id)
{
	if(CheckPointData[id][cp_boolSet]&b_msg)ShowMsgBox(playerid, CheckPointData[id][cp_msg], CheckPointData[id][cp_optData][i_msgTime]);
	OnPlayerActivateCheckpoint(playerid, id);
	if(CheckPointData[id][cp_boolSet]&b_delete)DestroyCheckPoint(id);
}

// Extras

stock SetCheckPointMessage(buttonid, Msg[])
{
	strcpy(CheckPointData[id][cp_msg], Msg);
	PlayerLoop(i)if(bPlayerGameSettings[i]&vMsgBox)PlayerTextDrawSetString(i, MsgBox, Msg);
}


public OnPlayerEnterDynamicArea(playerid, areaid)
{
	foreach(new i : CheckpointIndex)
    {
		if(areaid == CheckPointData[i][cp_areaID])
		{
			Internal_ActivateCheckpoint(playerid, i);
		}
    }
	return CallLocalFunction("cp_OnPlayerEnterDynamicArea", "dd", playerid, areaid);
}
#if defined _ALS_OnPlayerEnterDynamicArea
	#undef OnPlayerEnterDynamicArea
#else
	#define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea cp_OnPlayerEnterDynamicArea
forward OnPlayerEnterDynamicArea(playerid, areaid);



#include <YSI\y_hooks>
#include <YSI\y_timers>


// Max Values
#define MAX_TURRET				(8)
#define MAX_ROCKET				(4)
#define MAX_RKTNODE				(8)

#define ROCKET_OBJECT			(354)

// Various Offsets
#define VELOCITY_MULTIPLIER		(2.5)
#define PIVOT_Z_OFFSET			(1.5)
#define BARREL_Z_OFFSET			(1.6)
#define BARREL_TIP_OFFSET		(1.6)
#define CAMERA_Z_OFFSET			(2.5)
#define CAM_ROT_OFFSET			(119.0)
#define CAM_DIS_OFFSET			(2.0)
#define TURRET_LENGTH			(10.9)
#define ROTATION_SPEED			(0.07)
#define MOVEMENT_SPEED			(1.0)
#define RECOIL_DISTANCE			(1.5) // Unused, for now...

#define DEFAULT_VELOCITY		(50.0)
#define DEFAULT_ELEVATION		(20.0)
#define DEFAULT_ROTATION		(180.0)
#define DEFAULT_GRAVITY			(9.8)
#define DEFAULT_FIRERATE		(300)

// Types
#define TURRET_TYPE_TRAJ		(0)
#define TURRET_TYPE_FLAK		(1)


new
// Turret
Iterator:   tur_Index<MAX_TURRET>,
			tur_userID			[MAX_TURRET],
			tur_type			[MAX_TURRET],
			tur_fireTick		[MAX_TURRET],
			tur_btnEnter		[MAX_TURRET],
			inTurret			[MAX_PLAYERS],
Timer:		tur_updateTimer		[MAX_PLAYERS],
			bool:tur_canFire	[MAX_TURRET],
//			bool:tur_recoil		[MAX_TURRET],

// Fire Data
Float:		tur_velocity		[MAX_TURRET] = {DEFAULT_VELOCITY, ...},
Float:		tur_elevation		[MAX_TURRET] = {DEFAULT_ELEVATION, ...},
Float:		tur_rotation		[MAX_TURRET] = {DEFAULT_ROTATION, ...},
Float:		tur_gravity			[MAX_TURRET] = {DEFAULT_GRAVITY, ...},
			tur_fireRate		[MAX_TURRET] = {DEFAULT_FIRERATE, ...},

// Turret
Float:		tur_posX			[MAX_TURRET],
Float:		tur_posY			[MAX_TURRET],
Float:		tur_posZ			[MAX_TURRET],
Float:		tur_tipX			[MAX_TURRET],
Float:		tur_tipY			[MAX_TURRET],
Float:		tur_tipZ			[MAX_TURRET],

// Rocket
Iterator:   rkt_Index<MAX_ROCKET>,
			rkt_type			[MAX_ROCKET],
			rkt_turretID		[MAX_ROCKET],
			rkt_object			[MAX_ROCKET],
			rkt_node			[MAX_ROCKET],
			rkt_trajData		[MAX_ROCKET][MAX_RKTNODE][FLIGHT_DATA],
Float:		rkt_posX			[MAX_ROCKET],
Float:		rkt_posY			[MAX_ROCKET],
Float:		rkt_posZ			[MAX_ROCKET],
Float:		rkt_rotR			[MAX_ROCKET],
Float:		rkt_rotE			[MAX_ROCKET],
Float:		rkt_velo			[MAX_ROCKET],

// Objs
			tur_objBase			[MAX_TURRET],
			tur_objPivot		[MAX_TURRET],
			tur_objBarrel		[MAX_TURRET],
			tur_objCamera		[MAX_TURRET];



#if defined FILTERSCRIPT
hook OnFilterScriptInit()
#else
hook OnGameModeInit()
#endif
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		inTurret[i] = -1;
	}
	for(new i;i<MAX_TURRET;i++)
	{
		tur_velocity[i] = DEFAULT_VELOCITY;
		tur_elevation[i] = DEFAULT_ELEVATION;
		tur_rotation[i] = DEFAULT_ROTATION;
		tur_gravity[i] = DEFAULT_GRAVITY;
		tur_fireRate[i] = DEFAULT_FIRERATE;
	}
	return 1;
}


/*
 *
 *  Turrets are created like any other entity
 *  and you can destroy them too.
 *  Might add some more dynamic functions
 *  like moving, and getting data for external use.
 *
 */



CreateTurret(Float:x, Float:y, Float:z, Float:buttonPos = 0.0, type = TURRET_TYPE_TRAJ)
{
	new id = Iter_Free(tur_Index);

    tur_objBase[id]		= CreateDynamicObject(3277, x, y, z, 0.00, 0.00, 0.00);
	tur_objPivot[id]	= CreateDynamicObject(2888, x, y, z+PIVOT_Z_OFFSET, -90.00, 0.00, -90.00);
	tur_objBarrel[id]	= CreateDynamicObject(16101, x, y, z+BARREL_Z_OFFSET, 45.00, 0.00, -90.00);
	tur_objCamera[id]	= CreateDynamicObject(19300, x, y, z+CAMERA_Z_OFFSET, 0.0, 0.0, 0.0);

	tur_btnEnter[id]	= CreateButton(
		x + (3.5 * floatsin(buttonPos, degrees)),
		y + (3.5 * floatcos(buttonPos, degrees)),
		z, "Press F to use Turret");

	SetButtonLabel(tur_btnEnter[id], "Turret");

	tur_velocity[id]	= DEFAULT_VELOCITY;
	tur_elevation[id]	= DEFAULT_ELEVATION;
	tur_rotation[id]	= DEFAULT_ROTATION;
	tur_gravity[id]		= DEFAULT_GRAVITY;
	tur_fireRate[id]	= DEFAULT_FIRERATE;

	tur_posX[id]		= x;
	tur_posY[id]		= y;
	tur_posZ[id]		= z;
	tur_userID[id]      = -1;
	tur_type[id]		= type;

	Iter_Add(tur_Index, id);

	return id;
}
stock DestroyTurret(id)
{
	if(!Iter_Contains(tur_Index, id))return 0;

	DestroyDynamicObject(tur_objBase[id]);
	DestroyDynamicObject(tur_objPivot[id]);
	DestroyDynamicObject(tur_objBarrel[id]);
	DestroyDynamicObject(tur_objCamera[id]);
	DestroyButton(tur_btnEnter[id]);

	Iter_Remove(tur_Index, id);
	
	return 1;
}
SetTurretAngles(id, Float:rotation, Float:elevation)
{
	if(elevation < 0.0)elevation = 0.0;

    tur_rotation[id] = rotation;
    tur_elevation[id] = elevation;

	if(tur_type[id] == TURRET_TYPE_TRAJ)
		tur_canFire[id] = false;

	else
		tur_canFire[id] = true;

	MoveDynamicObject(tur_objPivot[id],
		tur_posX[id]+(0.1 * floatsin(-rotation+180.0, degrees)),
		tur_posY[id]+(0.1 * floatcos(-rotation+180.0, degrees)),
		tur_posZ[id]+PIVOT_Z_OFFSET,

		ROTATION_SPEED,
		-90, 0.0, -rotation+180.0);

	MoveDynamicObject(tur_objBarrel[id],
		tur_posX[id]+(0.1 * floatsin(-rotation+180.0, degrees)),
		tur_posY[id]+(0.1 * floatcos(-rotation+180.0, degrees)),
		tur_posZ[id]+BARREL_Z_OFFSET,

		ROTATION_SPEED,
		-elevation+90, 0.0, -rotation+180.0);

	MoveDynamicObject(tur_objCamera[id],
		tur_posX[id]+(CAM_DIS_OFFSET * floatsin(rotation+CAM_ROT_OFFSET, degrees)),
		tur_posY[id]+(CAM_DIS_OFFSET * floatcos(rotation+CAM_ROT_OFFSET, degrees)),
		tur_posZ[id]+CAMERA_Z_OFFSET, MOVEMENT_SPEED);

}
FireTurret(id)
{
	new
	    tmpObjId,
		Float:objPos[3],
		Float:objRot[3], // XYZ - Elevation, Roll, Rotation
		Float:tmpRot[2]; // XZ - Elevation, Rotation (after offsets applied)

	GetDynamicObjectPos(tur_objBarrel[id], objPos[0], objPos[1], objPos[2]);
	GetDynamicObjectRot(tur_objBarrel[id], objRot[0], objRot[1], objRot[2]);

    tmpRot[0] = -objRot[0]+90.0;
    tmpRot[1] = -objRot[2]+180.0;

	tur_tipX[id] = tur_posX[id] + ( (TURRET_LENGTH * floatcos(tmpRot[0], degrees)) * floatsin(tmpRot[1], degrees));
	tur_tipY[id] = tur_posY[id] + ( (TURRET_LENGTH * floatcos(tmpRot[0], degrees)) * floatcos(tmpRot[1], degrees));
	tur_tipZ[id] = tur_posZ[id] + BARREL_TIP_OFFSET + (TURRET_LENGTH * floatsin(tmpRot[0], degrees));

	if(CreateRocket(id, tur_tipX[id], tur_tipY[id], tur_tipZ[id], tmpRot[1], tmpRot[0], tur_velocity[id], tur_type[id]) != -1)
	{
		tmpObjId = CreateDynamicObject(18730,
			tur_tipX[id], tur_tipY[id], tur_tipZ[id]+BARREL_Z_OFFSET,
			objRot[0]+90.0, objRot[1], objRot[2]);

		defer DestroyParticle(tmpObjId);

		for(new i;i<MAX_PLAYERS;i++)
			PlayerPlaySound(i, 1159, tur_tipX[id], tur_tipY[id], tur_tipZ[id]);
	}

	return 1;
}
timer DestroyParticle[3000](id)
{
	DestroyDynamicObject(id);
}
EnterTurret(playerid, turretid)
{
	tur_updateTimer[playerid] = repeat TurretRotationUpdate(playerid);

	tur_userID[turretid] = playerid;
	inTurret[playerid] = turretid;

    AttachCameraToDynamicObject(playerid, tur_objCamera[turretid]);
    SetPlayerPos(playerid, tur_posX[turretid], tur_posY[turretid], tur_posZ[turretid]);
}
ExitTurret(playerid)
{
	new
	    Float:x,
	    Float:y,
	    Float:z;

	GetButtonPos(tur_btnEnter[inTurret[playerid]], x, y, z);
	SetPlayerPos(playerid, x, y, z);
	SetCameraBehindPlayer(playerid);

	tur_userID[inTurret[playerid]] = -1;
	inTurret[playerid] = -1;

	stop tur_updateTimer[playerid];
}



/*
 *
 *  Rockets in a separate kind of script!
 *  This allows you to create them without using the turret,
 *  for instance a vehicle rocket or something!
 *
 */



CreateRocket(baseid, Float:x, Float:y, Float:z, Float:rotation, Float:elevation, Float:velocity, type = TURRET_TYPE_TRAJ)
{
	new id = Iter_Free(rkt_Index);

	if(id == -1)
		return -1;

    rkt_turretID[id]	= baseid;
	rkt_posX[id]		= x;
	rkt_posY[id]		= y;
    rkt_posZ[id]		= z;
	rkt_rotR[id]		= rotation;
	rkt_rotE[id]		= elevation;
	rkt_velo[id]		= velocity;
	rkt_node[id]		= 1;
	rkt_type[id]		= type;

	rkt_object[id] = CreateDynamicObject(ROCKET_OBJECT, x, y, z, 0.0, 0.0, 0.0);

	if(type == TURRET_TYPE_TRAJ)
	{
		GetFlightData(0.0, velocity, elevation, rkt_trajData[id], MAX_RKTNODE, tur_gravity[id]);

		MoveDynamicObject(rkt_object[id],
			x + (rkt_trajData[id][rkt_node[id]][FLIGHT_DISTANCE] * floatsin(rotation, degrees)),
			y + (rkt_trajData[id][rkt_node[id]][FLIGHT_DISTANCE] * floatcos(rotation, degrees)),
			z + rkt_trajData[id][rkt_node[id]][FLIGHT_HEIGHT], velocity*VELOCITY_MULTIPLIER);
	}
	if(type == TURRET_TYPE_FLAK)
	{
		MoveDynamicObject(rkt_object[id],
			x += ( 80.0 * floatsin(rotation, degrees) * floatcos(elevation, degrees) ),
			y += ( 80.0 * floatcos(rotation, degrees) * floatcos(elevation, degrees) ),
			z += ( 80.0 * floatsin(elevation, degrees) ), 80.0);
	}

	Iter_Add(rkt_Index, id);

	return id;
}
ExplodeRocket(id)
{
	if(!Iter_Contains(rkt_Index, id))return 0;

	if(rkt_type[id] == TURRET_TYPE_TRAJ)
	{
		CreateExplosion(
			rkt_posX[id] + (rkt_trajData[id][MAX_RKTNODE-1][FLIGHT_DISTANCE] * floatsin(rkt_rotR[id], degrees)),
			rkt_posY[id] + (rkt_trajData[id][MAX_RKTNODE-1][FLIGHT_DISTANCE] * floatcos(rkt_rotR[id], degrees)),
			tur_posZ[rkt_turretID[id]], 7, 20.0);
	}
	if(rkt_type[id] == TURRET_TYPE_FLAK)
	{
	    new
	        Float:x,
	        Float:y,
	        Float:z;

		GetDynamicObjectPos(rkt_object[id], x, y, z);

		CreateExplosion(x, y, z, 7, 20.0);
	}
	DestroyDynamicObject(rkt_object[id]);

	rkt_posX[id] = 0.0;
	rkt_posY[id] = 0.0;
    rkt_posZ[id] = 0.0;
	rkt_rotR[id] = 0.0;
	rkt_rotE[id] = 0.0;
	rkt_velo[id] = 0.0;
	rkt_node[id] = 0;
	
	Iter_SafeRemove(rkt_Index, id, id);

	return id;
}

timer TurretRotationUpdate[100](playerid)
{
	new
	    id = inTurret[playerid],

		k,
		ud,
		lr,

		Float:camX,
		Float:camY,
		Float:camZ,

		Float:vecX,
		Float:vecY,
		Float:vecZ,

		Float:camR,
		Float:camE;

	GetPlayerKeys(tur_userID[id], k, ud, lr);
	GetPlayerCameraPos(tur_userID[id], camX, camY, camZ);
	GetPlayerCameraFrontVector(tur_userID[id], vecX, vecY, vecZ);

	camR = -GetAngleToPoint(camX, camY, camX+vecX, camY+vecY);
    camE = 90-floatabs(atan2(floatsqroot(floatpower(vecX, 2.0) + floatpower(vecY, 2.0)), vecZ)); // Thanks to RyDeR

	if(camR != tur_rotation[id] || camE != tur_elevation[id])SetTurretAngles(id, camR, camE);

//	format(str, 128, "Rotation: %f~n~Elevation: %f~n~Velocity: %f", camR, camE, tur_velocity[id]);
//	ShowMsgBox(tur_userID[id], str, 0, 200);
}



/*
 *  The hooked callbacks from the main script
 *
 */



//hook OnDynamicObjectMoved(objectid)
public OnDynamicObjectMoved(objectid)
{
	foreach(new i : tur_Index)
	{
		if(objectid == tur_objBarrel[i])
		{
			tur_canFire[i] = true;
		}
	}
	foreach(new i : rkt_Index)
	{
		if(i > MAX_ROCKET)continue;
		if(objectid == rkt_object[i])
		{
			if(rkt_type[i] == TURRET_TYPE_TRAJ)
			{
				rkt_node[i]++;

				if(rkt_node[i] == MAX_RKTNODE-1)
				{
					MoveDynamicObject(rkt_object[i],
						rkt_posX[i] + (rkt_trajData[i][MAX_RKTNODE-1][FLIGHT_DISTANCE] * floatsin(rkt_rotR[i], degrees)),
						rkt_posY[i] + (rkt_trajData[i][MAX_RKTNODE-1][FLIGHT_DISTANCE] * floatcos(rkt_rotR[i], degrees)),
						tur_posZ[rkt_turretID[i]], rkt_velo[i]);
				}
				else if(rkt_node[i] == MAX_RKTNODE)
				{
					i = ExplodeRocket(i);
					return 1;
				}
				else
				{
					MoveDynamicObject(rkt_object[i],
						rkt_posX[i] + (rkt_trajData[i][rkt_node[i]][FLIGHT_DISTANCE] * floatsin(rkt_rotR[i], degrees)),
						rkt_posY[i] + (rkt_trajData[i][rkt_node[i]][FLIGHT_DISTANCE] * floatcos(rkt_rotR[i], degrees)),
						rkt_posZ[i] + rkt_trajData[i][rkt_node[i]][FLIGHT_HEIGHT], rkt_velo[i]*VELOCITY_MULTIPLIER);
				}
			}
			if(rkt_type[i] == TURRET_TYPE_FLAK)
			{
				if(rkt_node[i] == 20)
				{
					i = ExplodeRocket(i);
					return 1;
				}

			    new
			        Float:x,
			        Float:y,
			        Float:z;

				GetDynamicObjectPos(objectid, x, y, z);

				PlayerLoop(j)
				{
					if(IsPointInDynamicArea(gPlayerArea[j], x, y, z))
					{
						i = ExplodeRocket(i);
						return 1;
					}
				}

				MoveDynamicObject(rkt_object[i],
					x += ( 20.0 * floatsin(rkt_rotR[i], degrees) * floatcos(rkt_rotE[i], degrees) ),
					y += ( 20.0 * floatcos(rkt_rotR[i], degrees) * floatcos(rkt_rotE[i], degrees) ),
					z += ( 20.0 * floatsin(rkt_rotE[i], degrees) ),
					rkt_velo[i]);

                rkt_node[i]++;
			}
		}
	}
    return CallLocalFunction("tur_OnDynamicObjectMoved", "d", objectid);
}
#if defined _ALS_OnDynamicObjectMoved
    #undef OnDynamicObjectMoved
#else
    #define _ALS_OnDynamicObjectMoved
#endif
#define OnDynamicObjectMoved tur_OnDynamicObjectMoved
forward tur_OnDynamicObjectMoved(objectid);


public OnButtonPress(playerid, buttonid)
{
	print("OnButtonPress <Turret Script>");
	foreach(new i : tur_Index)
	{
		if(buttonid == tur_btnEnter[i])
		{
			EnterTurret(playerid, i);
			return 1;
		}
	}
    return CallLocalFunction("tur_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
    #undef OnButtonPress
#else
    #define _ALS_OnButtonPress
#endif
#define OnButtonPress tur_OnButtonPress
forward tur_OnButtonPress(playerid, buttonid);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_FIRE)
	{
		new id = inTurret[playerid];
		if(Iter_Contains(tur_Index, id))
		{
			if(tur_canFire[id] && (tickcount() - tur_fireTick[id]) > tur_fireRate[id])
			{
				FireTurret(id);
				tur_fireTick[id] = tickcount();
			}
		}
	}
	if(newkeys & KEY_CROUCH && inTurret[playerid] != -1)
	{
		ExitTurret(playerid);
		return 1;
	}
	return 1;
}

/*
stock DrawPath()
{
	GetFlightData(0.0, tur_velocity[id], tur_elevation, tur_trajData);
	for(new i;i<MAX_NODES;i++)
	{
		SetDynamicObjectPos(RkObj[i],
			tur_tipX + (tur_trajData[i][FLIGHT_DISTANCE] * floatsin(tur_rotation, degrees)),
			tur_tipY + (tur_trajData[i][FLIGHT_DISTANCE] * floatcos(tur_rotation, degrees)),
			tur_tipZ + tur_trajData[i][FLIGHT_HEIGHT]);
	}

}
stock showpath()
{
	GetFlightData(0.0, tur_velocity[id], tur_elevation[id], tur_trajData[id]);
	for(new i;i<MAX_NODES;i++)
	{
		RkObj[i] = CreateDynamicObject(1598,
			tur_posX + (tur_trajData[i][FLIGHT_DISTANCE] * floatsin(tur_rotation, degrees)),
			tur_posY + (tur_trajData[i][FLIGHT_DISTANCE] * floatcos(tur_rotation, degrees)),
			tur_posZ + tur_trajData[i][FLIGHT_HEIGHT],
			0.0, 0.0, 0.0);
	}
}

map editor data

CreateObject(3277, 292.00, 2036.00, 17.50,   0.00, 0.00, 0.00);
CreateObject(2888, 292.00, 2036.00, 19.00,   -90.00, 0.00, 180.00);
CreateObject(16101, 292.00, 2036.00, 19.10,   45.00, 0.00, 180.00);
*/

CMD:setrate(playerid, params[])
{
    tur_fireRate[inTurret[playerid]] = strval(params);
	return 1;
}
CMD:setgrav(playerid, params[])
{
    tur_gravity[inTurret[playerid]] = floatstr(params);
	return 1;
}


/*
stock GetXYZFromAngle(&Float:x, &Float:y, &Float:z, Float:angle, Float:elevation, Float:distance)
    x += ( distance*floatsin(-angle,degrees)*floatcos(elevation,degrees) ),y += ( distance*floatcos(-angle,degrees)*floatcos(elevation,degrees) ),z += ( distance*floatsin(elevation,degrees) );

*/

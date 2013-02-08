#define MAX_BALLOON			5

#define BLN_MOVE_SPEED		(10.0)
#define BLN_SLOW_SPEED		(1.0)
#define BLN_INCREMENT		(1.0)
#define BLN_LIFT_HEIGHT		(10.0)
#define BLN_ACCEL_TICK		(1500)
#define BLN_DECEL_DIST		(50.0)
#define BLN_BASKET_OFFSET	(1.14)

#define BLN_STATE_IDLE		(0)
#define BLN_STATE_LIFTOFF	(2)
#define BLN_STATE_MOVE		(3)
#define BLN_STATE_LANDING	(4)


enum E_BALLOON_DATA
{
	bln_object,
	bln_button[2],

	Float:bln_posX[2],
	Float:bln_posY[2],
	Float:bln_posZ[2],
	Float:bln_rotZ[2]
}
new
	bln_Data[MAX_BALLOON][E_BALLOON_DATA],
	bln_State[MAX_BALLOON],
	bln_Base[MAX_BALLOON],
	Iterator:bln_Index<MAX_BALLOON>;


stock CreateBalloon(Float:x1, Float:y1, Float:z1, Float:r1, Float:x2, Float:y2, Float:z2, Float:r2)
{
	new id = Iter_Free(bln_Index);
	if(id>MAX_BALLOON)return 0;

	bln_Data[id][bln_object]	= CreateDynamicObject(19335, x1, y1, z1, r1, 0.0, 0.0, 0);
	bln_Data[id][bln_button][0]	= CreateButton(x1, y1, (z1+BLN_BASKET_OFFSET), "Press F to activate Balloon", 0);
	bln_Data[id][bln_button][1]	= CreateButton(x2, y2, (z2+BLN_BASKET_OFFSET), "Press F to activate Balloon", 0);

	bln_Data[id][bln_posX][0]=x1;
	bln_Data[id][bln_posY][0]=y1;
	bln_Data[id][bln_posZ][0]=z1;
	bln_Data[id][bln_rotZ][0]=r1;

	bln_Data[id][bln_posX][1]=x2;
	bln_Data[id][bln_posY][1]=y2;
	bln_Data[id][bln_posZ][1]=z2;
	bln_Data[id][bln_rotZ][1]=r2;

	bln_State[id]=BLN_STATE_IDLE;

	Iter_Add(bln_Index, id);
	return id;
}
stock DestroyBalloon(id)
{
	if(!Iter_Contains(bln_Index, id))return 0;

	Iter_Remove(bln_Index, id);
	DestroyDynamicObject(bln_Data[id][bln_object]);
	DestroyButton(bln_Data[id][bln_button][0]);
	DestroyButton(bln_Data[id][bln_button][1]);
	return 1;
}


MoveBalloon(id)
{
	if(bln_State[id]==BLN_STATE_LIFTOFF)
	{
		MoveDynamicObject(bln_Data[id][bln_object],
			bln_Data[id][bln_posX][bln_Base[id]],
			bln_Data[id][bln_posY][bln_Base[id]],
			bln_Data[id][bln_posZ][bln_Base[id]] + BLN_LIFT_HEIGHT,
			BLN_SLOW_SPEED, 0.0, 0.0, bln_Data[id][bln_rotZ][bln_Base[id]]);
	}
	else if(bln_State[id]==BLN_STATE_MOVE)
	{
		MoveDynamicObject(bln_Data[id][bln_object],
			bln_Data[id][bln_posX][bln_Base[id]],
			bln_Data[id][bln_posY][bln_Base[id]],
			bln_Data[id][bln_posZ][bln_Base[id]] + BLN_LIFT_HEIGHT,
			BLN_MOVE_SPEED, 0.0, 0.0, bln_Data[id][bln_rotZ][bln_Base[id]]);
	}
	else if(bln_State[id]==BLN_STATE_LANDING)
	{
		MoveDynamicObject(bln_Data[id][bln_object],
			bln_Data[id][bln_posX][bln_Base[id]],
			bln_Data[id][bln_posY][bln_Base[id]],
			bln_Data[id][bln_posZ][bln_Base[id]],
			BLN_SLOW_SPEED, 0.0, 0.0, bln_Data[id][bln_rotZ][bln_Base[id]]);
	}
	else bln_State[id]=BLN_STATE_IDLE;
}


//


public OnButtonPress(playerid, buttonid)
{
	foreach(new i : bln_Index)
	{
		if(buttonid == bln_Data[i][bln_button][bln_Base[i]] && bln_State[i] == BLN_STATE_IDLE)
		{
			bln_State[i]=BLN_STATE_LIFTOFF;
			MoveBalloon(i);
			break;
		}
	}
	return CallLocalFunction("BLN_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress BLN_OnButtonPress
forward OnButtonPress(playerid, buttonid);


//


public OnDynamicObjectMoved(objectid)
{
	foreach(new i : bln_Index)
	{
		if(objectid == bln_Data[i][bln_object])
		{
			if(bln_State[i] == BLN_STATE_LIFTOFF)
			{
			    bln_Base[i] = !bln_Base[i];
			    bln_State[i] = BLN_STATE_MOVE;
			    MoveBalloon(i);
			}
			else if(bln_State[i] == BLN_STATE_MOVE)
			{
				bln_State[i] = BLN_STATE_LANDING;
				MoveBalloon(i);
			}
			else bln_State[i] = BLN_STATE_IDLE;
			break;
		}
	}
	return CallLocalFunction("bln_OnDynamicObjectMoved", "d", objectid);
}
#if defined _ALS_OnDynamicObjectMoved
	#undef OnDynamicObjectMoved
#else
	#define _ALS_OnDynamicObjectMoved
#endif
#define OnDynamicObjectMoved bln_OnDynamicObjectMoved
forward OnDynamicObjectMoved(objectid);



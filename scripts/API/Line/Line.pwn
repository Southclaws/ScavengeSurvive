#define MAX_LINE (32)
#define LIN_MAX_OBJ (512)


enum E_LINE_DATA
{
		lin_model,
		lin_objArray[LIN_MAX_OBJ],
		lin_objCount,
Float:  lin_objLength,
Float:	lin_maxLength,

Float:	lin_posX,
Float:	lin_posY,
Float:	lin_posZ,

Float:	lin_dstX,
Float:	lin_dstY,
Float:	lin_dstZ,

Float:	lin_rotX,
Float:	lin_rotY,
Float:	lin_rotZ,

		lin_world,
		lin_interior
}


new
		lin_Data[MAX_LINE][E_LINE_DATA],
		Iterator:lin_Index<MAX_LINE>;


stock CreateLineSegment(modelid, Float:objlength,
	Float:PointX, Float:PointY, Float:PointZ,
	Float:DestX, Float:DestY, Float:DestZ,
	Float:RotX = 0.0, Float:RotY = 0.0, Float:RotZ = 0.0,
	worldid = 0, interiorid = 0, Float:maxlength = 100.0)
{
	new
		id = Iter_Free(lin_Index),
		Float:rx,
		Float:ry,
		Float:rz,
		Float:vx = DestX - PointX,
		Float:vy = DestY - PointY,
		Float:vz = DestZ - PointZ,
		Float:tmpdist,
		Float:distToDest,
		count;

	rz = -(atan2(vy, vx)-90.0);
	rx = -(floatabs(atan2(floatsqroot(floatpower(vx, 2.0) + floatpower(vy, 2.0)), vz))-90.0);

	distToDest = floatsqroot( (vx*vx) + (vy*vy) + (vz*vz) );
	count = floatround(distToDest / objlength);

	for(new i; i < count; i++)
	{
	    if(i == count-1)
			tmpdist = distToDest - objlength;

	    else
			tmpdist = (objlength * i);// - (objlength / 2.0);

		lin_Data[id][lin_objArray][i] = CreateDynamicObject(modelid,
			PointX + ( tmpdist * floatsin(rz, degrees) * floatcos(rx, degrees) ),
			PointY + ( tmpdist * floatcos(rz, degrees) * floatcos(rx, degrees) ),
			PointZ + ( tmpdist * floatsin(rx, degrees) ),
			rx + RotX,
			ry + RotY,
			-rz + RotZ,
			worldid, interiorid);

		if(tmpdist > maxlength)break;
	}
	
	lin_Data[id][lin_maxLength]		= maxlength;
	lin_Data[id][lin_model]			= modelid;
	lin_Data[id][lin_objCount]		= count;
	lin_Data[id][lin_objLength]		= objlength;

	lin_Data[id][lin_posX]			= PointX;
	lin_Data[id][lin_posY]			= PointY;
	lin_Data[id][lin_posZ]			= PointZ;

	lin_Data[id][lin_dstX]			= DestX;
	lin_Data[id][lin_dstY]			= DestY;
	lin_Data[id][lin_dstZ]			= DestZ;

	lin_Data[id][lin_rotX]			= RotX;
	lin_Data[id][lin_rotY]			= RotY;
	lin_Data[id][lin_rotZ]			= RotZ;

	lin_Data[id][lin_world]			= worldid;
	lin_Data[id][lin_interior]		= interiorid;


	Iter_Add(lin_Index, id);

    SetLineSegmentDest(id, DestX, DestY, DestZ);

	return id;
}
stock DestroyLineSegment(id)
{
	if(!Iter_Contains(lin_Index, id))return 0;

	for(new i; i < lin_Data[id][lin_objCount]; i++)
	{
		if(IsValidDynamicObject(lin_Data[id][lin_objArray][i]))
			DestroyDynamicObject(lin_Data[id][lin_objArray][i]);
	}

	Iter_Remove(lin_Index, id);
	return 1;
}

stock SetLineSegmentDest(id, Float:DestX, Float:DestY, Float:DestZ)
{
	if(!Iter_Contains(lin_Index, id))return 0;

	lin_Data[id][lin_dstX] = DestX;
	lin_Data[id][lin_dstY] = DestY;
	lin_Data[id][lin_dstZ] = DestZ;

	UpdateLineSegment(id);

	return 1;
}
stock SetLineSegmentPoint(id, Float:PointX, Float:PointY, Float:PointZ)
{
	if(!Iter_Contains(lin_Index, id))return 0;

	lin_Data[id][lin_posX] = PointX;
	lin_Data[id][lin_posY] = PointY;
	lin_Data[id][lin_posZ] = PointZ;

	UpdateLineSegment(id);

	return 1;
}

stock UpdateLineSegment(id)
{
	new
		Float:rx,
		Float:ry,
		Float:rz,
		Float:vx = lin_Data[id][lin_dstX] - lin_Data[id][lin_posX],
		Float:vy = lin_Data[id][lin_dstY] - lin_Data[id][lin_posY],
		Float:vz = lin_Data[id][lin_dstZ] - lin_Data[id][lin_posZ],
		Float:tmpdist,
		Float:distToDest,
		count;

	rz = -(atan2(vy, vx)-90.0);
	rx = -(floatabs(atan2(floatsqroot(floatpower(vx, 2.0) + floatpower(vy, 2.0)), vz))-90.0);

	distToDest = floatsqroot( (vx*vx) + (vy*vy) + (vz*vz) );
	count = floatround(distToDest / lin_Data[id][lin_objLength]) + 1;

	for(new i = -1; i < count; i++)
	{
		if(i == -1)
			tmpdist = 0;

		else if(i >= count-2)
			tmpdist = distToDest - lin_Data[id][lin_objLength];

		else
			tmpdist = (lin_Data[id][lin_objLength] * i) + (lin_Data[id][lin_objLength] / 2.0);

		if(!IsValidDynamicObject(lin_Data[id][lin_objArray][i+1]))
		{
			lin_Data[id][lin_objArray][i+1] = CreateDynamicObject(lin_Data[id][lin_model],
				lin_Data[id][lin_posX] + ( tmpdist * floatsin(rz, degrees) * floatcos(rx, degrees) ),
				lin_Data[id][lin_posY] + ( tmpdist * floatcos(rz, degrees) * floatcos(rx, degrees) ),
				lin_Data[id][lin_posZ] + ( tmpdist * floatsin(rx, degrees) ),
				rx + lin_Data[id][lin_rotX],
				ry + lin_Data[id][lin_rotY],
				-rz + lin_Data[id][lin_rotZ],
				lin_Data[id][lin_world], lin_Data[id][lin_interior]);
		}
		else
		{
			SetDynamicObjectPos(lin_Data[id][lin_objArray][i+1],
				lin_Data[id][lin_posX] + ( tmpdist * floatsin(rz, degrees) * floatcos(rx, degrees) ),
				lin_Data[id][lin_posY] + ( tmpdist * floatcos(rz, degrees) * floatcos(rx, degrees) ),
				lin_Data[id][lin_posZ] + ( tmpdist * floatsin(rx, degrees) ) );

			SetDynamicObjectRot(lin_Data[id][lin_objArray][i+1],
				rx + lin_Data[id][lin_rotX],
				ry + lin_Data[id][lin_rotY],
				-rz + lin_Data[id][lin_rotZ]);
		}
		if(tmpdist > lin_Data[id][lin_maxLength])break;
	}
	if(count < lin_Data[id][lin_objCount])
	{
		for(new i = count; i < LIN_MAX_OBJ; i++)
		{
		    if(IsValidDynamicObject(lin_Data[id][lin_objArray][i]))
		        DestroyDynamicObject(lin_Data[id][lin_objArray][i]);
		}
	}
	lin_Data[id][lin_objCount] = count;
}

stock SetLineSegmentModel(id, modelid, Float:objlength)
{
	if(!Iter_Contains(lin_Index, id))return 0;

	lin_Data[id][lin_model] = modelid;
    lin_Data[id][lin_objLength] = objlength;


	for(new i; i < lin_Data[id][lin_objCount]; i++)
	{
		if(IsValidDynamicObject(lin_Data[id][lin_objArray][i]))
			Streamer_SetIntData(STREAMER_TYPE_OBJECT, lin_Data[id][lin_objArray][i], E_STREAMER_MODEL_ID, modelid);
	}
    SetLineSegmentDest(id, lin_Data[id][lin_dstX], lin_Data[id][lin_dstY], lin_Data[id][lin_dstZ]);

	return 1;
}
stock SetLineSegmentModelAngles(id, Float:RotX, Float:RotY, Float:RotZ)
{
	if(!Iter_Contains(lin_Index, id))return 0;

	lin_Data[id][lin_rotX] = RotX;
	lin_Data[id][lin_rotY] = RotY;
	lin_Data[id][lin_rotZ] = RotZ;

    SetLineSegmentDest(id, lin_Data[id][lin_dstX], lin_Data[id][lin_dstY], lin_Data[id][lin_dstZ]);

	return 1;
}


stock GetLineSegmentPointPos(id, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(lin_Index, id))return 0;

	x = lin_Data[id][lin_posX];
	y = lin_Data[id][lin_posY];
	z = lin_Data[id][lin_posZ];

	return 1;
}
stock GetLineSegmentDestPos(id, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(lin_Index, id))return 0;

	x = lin_Data[id][lin_dstX];
	y = lin_Data[id][lin_dstY];
	z = lin_Data[id][lin_dstZ];

	return 1;
}
stock GetLineSegmentVector(id, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(lin_Index, id))return 0;

	new
		Float:vx = lin_Data[id][lin_dstX] - lin_Data[id][lin_posX],
		Float:vy = lin_Data[id][lin_dstY] - lin_Data[id][lin_posY],
		Float:vz = lin_Data[id][lin_dstZ] - lin_Data[id][lin_posZ],
		Float:rx,
		Float:rz;

	rx = -(floatabs(atan2(floatsqroot(floatpower(vx, 2.0) + floatpower(vy, 2.0)), vz))-90.0);
	rz = -(atan2(vy, vx)-90.0);

	x = floatsin(rz, degrees) * floatcos(rx, degrees);
	y = floatcos(rz, degrees) * floatcos(rx, degrees);
	z = floatsin(rx, degrees);

	return 1;
}
stock Float:GetLineSegmentMaxLength(id)
{
	if(!Iter_Contains(lin_Index, id))return 0.0;

	return lin_Data[id][lin_maxLength];
}
stock Float:GetDistanceToLineSegmentPoint(id, Float:FromX, Float:FromY, Float:FromZ)
{
	if(!Iter_Contains(lin_Index, id))return 0.0;

	new
		Float:vx = FromX - lin_Data[id][lin_posX],
		Float:vy = FromY - lin_Data[id][lin_posY],
		Float:vz = FromZ - lin_Data[id][lin_posZ];

	return floatsqroot( (vx*vx) + (vy*vy) + (vz*vz) );
}

stock Float:GetLineLength(id)
{
	if(!Iter_Contains(lin_Index, id))return 0.0;
	new
		Float:vx = lin_Data[id][lin_dstX] - lin_Data[id][lin_posX],
		Float:vy = lin_Data[id][lin_dstY] - lin_Data[id][lin_posY],
		Float:vz = lin_Data[id][lin_dstZ] - lin_Data[id][lin_posZ];

	return floatsqroot( (vx*vx) + (vy*vy) + (vz*vz) );
}

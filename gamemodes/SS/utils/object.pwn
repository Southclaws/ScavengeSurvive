stock CreateTimedDynamicObject(model, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, lifetime)
{
	defer DestroyDynamicObject_Delay(CreateDynamicObject(model, x, y, z, rx, ry, rz), lifetime);
}

timer DestroyDynamicObject_Delay[lifetime](objectid, lifetime)
{
	#pragma unused lifetime
	DestroyDynamicObject(objectid);
}

/*
	Credits to Emmet_

	http://forum.sa-mp.com/showpost.php?p=2884743&postcount=4256
*/
stock MoveObjectEx(objectid, time, Float:x, Float:y, Float:z, Float:rx = -1000.0, Float:ry = -1000.0, Float:rz = -1000.0)
{
	if (!IsValidObject(objectid))
		return 0;

	static
		Float:fX,
		Float:fY,
		Float:fZ,
		Float:fDist;
		
	GetObjectPos(objectid, fX, fY, fZ);
	fDist = floatsqroot(((fX - x) * (fX - x)) + ((fY - y) * (fY - y)) + ((fZ - z) * (fZ - z))); 

	MoveObject(objectid, x, y, z, floatdiv(floatsqroot(x + y + z), time / floatmul(fDist, 15)), rx, ry, rz);
	return 1;
}

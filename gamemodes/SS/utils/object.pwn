stock CreateTimedDynamicObject(model, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, lifetime)
{
	defer DestroyDynamicObject_Delay(CreateDynamicObject(model, x, y, z, rx, ry, rz), lifetime);
}

timer DestroyDynamicObject_Delay[lifetime](objectid, lifetime)
{
	#pragma unused lifetime
	DestroyDynamicObject(objectid);
}

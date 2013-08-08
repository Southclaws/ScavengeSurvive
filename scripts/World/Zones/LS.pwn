public OnLoad()
{
	print("Loading Los Santos");

	CreateFuelOutlet(1941.65625, -1778.45313, 14.14063, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(1941.65625, -1774.31250, 14.14063, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(1941.65625, -1771.34375, 14.14063, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(1941.65625, -1767.28906, 14.14063, 2.0, 100.0, frandom(40.0));

	CreateZipline(
		2159.08, -986.47, 70.59,
		2063.30, -993.57, 59.38, .worldid = 3);

	CreateZipline(
		2152.75, -1027.94, 73.47,
		2191.36, -1051.42, 57.25, .worldid = 3);

	CreateZipline(
		2228.26, -1120.77, 48.88,
		2200.78, -1096.47, 42.13, .worldid = 3);

	return CallLocalFunction("santos_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad santos_OnLoad
forward santos_OnLoad();

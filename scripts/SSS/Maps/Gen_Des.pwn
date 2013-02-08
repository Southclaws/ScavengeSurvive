public OnLoad()
{
	new
		buttonid[2];

	buttonid[0]=CreateButton(-101.579933, 1374.613769, 10.4698, "Press F to enter", 0, 0);
	buttonid[1]=CreateButton(-217.913787, 1402.804199, 27.7734, "Press F to exit", 0, 18);
	LinkTP(buttonid[0], buttonid[1]);

	AddSprayTag(-399.77, 1514.92, 75.26, 0.00, 0.00, 0.00);
	AddSprayTag(-229.34, 1082.35, 20.29, 0.00, 0.00, 0.00);
	AddSprayTag(-2442.17, 2299.23, 5.71, 0.00, 0.00, 270.00);
	AddSprayTag(-2662.95, 2121.44, 2.14, 0.00, 0.00, 180.00);
	AddSprayTag(146.92, 1831.78, 18.02, 0.00, 0.00, 90.00);

	CreateTurret(287.0, 2047.0, 17.5, 270.0, .type = 1);
	CreateTurret(335.0, 1843.0, 17.5, 270.0, .type = 1);
	CreateTurret(10.0, 1805.0, 17.40, 180.0, .type = 1);

	return CallLocalFunction("gendes_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad gendes_OnLoad
forward gendes_OnLoad();



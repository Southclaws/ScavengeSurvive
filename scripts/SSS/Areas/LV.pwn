public OnLoad()
{
	print("Loading Las Venturas");

	CreateLadder(1177.6424, -1305.6337, 13.9241, 29.0859, 0.0);

	AddSprayTag(2267.55, 1518.13, 46.33, 0.00, 0.00, 180.00);

	District_KACC();

	return CallLocalFunction("venturas_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad venturas_OnLoad
forward venturas_OnLoad();

District_KACC()
{
	new buttonid[1];

	CreateObject(19273, 2503.98120, 2780.09302, 11.36690, 0.00000, 0.00000, 90.00000);

	buttonid[0] = CreateButton(2503.98120, 2780.09302, 11.36690, "Press "#KEYTEXT_INTERACT" to activate");

	CreateDoor(985, buttonid,
		2497.36523438, 2777.06933594, 11.55891800, 0.00000000, 0.00000000, 90.00000000,
		2497.36523438, 2785.06933594, 11.55891800, 0.00000000, 0.00000000, 90.00000000,
		.movesound = 6000, .stopsound = 6002);

	CreateDoor(986, buttonid,
		2497.35888672, 2769.11181641, 11.55891800, 0.00000000, 0.00000000, 90.00000000,
		2497.36523438, 2761.11181641, 11.55891800, 0.00000000, 0.00000000, 90.00000000,
		.movesound = 6000, .stopsound = 6002);
}

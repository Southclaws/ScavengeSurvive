public OnLoad()
{
	print("Loading Las Venturas");

	CreateLadder(1177.6424, -1305.6337, 13.9241, 29.0859, 0.0);

	AddSprayTag(2267.55, 1518.13, 46.33, 0.00, 0.00, 180.00);

	return CallLocalFunction("venturas_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad venturas_OnLoad
forward venturas_OnLoad();

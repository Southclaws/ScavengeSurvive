public OnLoad()
{
	CreateBalloon(-2237.60, -1711.45, 479.88, 0.0, 1529.81, -1358.07, 328.37, 0.0);

	return CallLocalFunction("genflint_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad genflint_OnLoad
forward genflint_OnLoad();



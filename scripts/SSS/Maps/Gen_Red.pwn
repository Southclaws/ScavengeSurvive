public OnLoad()
{

	return CallLocalFunction("genred_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad genred_OnLoad
forward genred_OnLoad();



public OnLoad()
{
	print("Loading Red County");

	return CallLocalFunction("redcounty_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad redcounty_OnLoad
forward redcounty_OnLoad();

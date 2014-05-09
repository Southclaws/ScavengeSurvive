#define FILTERSCRIPT



#include <a_samp>
#include <ZCMD>


CMD:wait(playerid, params[])
{
	new seconds = strval(params);

	wait(seconds * 1000);
}


stock wait(time)
{
	new stamp = tickcount();
	while (tickcount() - stamp < time)
	{
	}
	return 1;
}


#include <a_samp>
#include <matrix>


static
	BuildObj,
	BuildActive;


CMD:d(playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	BuildActive = true;
	BuildObj = CreateDynamicObject(2904, x, y, z + 1.1859, 90.0, 90.0, 0.0);

	return 1;
}


public OnPlayerUpdate(playerid)
{
	if(!BuildActive)
		return 1;

	new k, ud, lr;
	GetPlayerKeys(playerid, k, ud, lr);

	new Float:x, Float:y;

	if(ud == KEY_UP)
		//

	else if(ud == KEY_DOWN)
		//

	if(lr == KEY_LEFT)
		//

	else if(lr == KEY_RIGHT)
		//


	return 1;
}

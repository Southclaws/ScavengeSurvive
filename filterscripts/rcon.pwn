#include <a_samp>

public OnRconCommand(cmd[])
{
	if(!strcmp(cmd, "restart"))
	{
		CallRemoteFunction("RestartGamemode", "");
	}
}

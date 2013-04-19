#define MAX_INVALID_LOGIN 5

static
	IpList[MAX_INVALID_LOGIN][1 char],
	IpListIdx;

public OnServerMessage(const msg[])
{
	if(IpListIdx >= MAX_INVALID_LOGIN)
		return 0;

	if(!sscanf(msg, "{'Kicking'} p<.>dddd {'because they didn't logon to the game'}", IpList[IpListIdx]{0}, IpList[IpListIdx]{1}, IpList[IpListIdx]{2}, IpList[IpListIdx]{3}))
	{
		MsgAdminsF(3, YELLOW, " >  Invalid login from %d.%d.%d.%d", IpList[IpListIdx]{0}, IpList[IpListIdx]{1}, IpList[IpListIdx]{2}, IpList[IpListIdx]{3});
		for(new i; i < IpListIdx; i++)
		{
			if(IpList[i][0] == 0)
				continue;

			if(IpList[IpListIdx][0] == IpList[i][0])
				return 0;
		}

		IpListIdx++;

		if(IpListIdx == MAX_INVALID_LOGIN)
		{
			RestartGamemode();
			return 1;
		}
	}
	return 1;
}

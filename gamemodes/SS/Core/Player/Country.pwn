enum E_COUNTRY_DATA
{
			cntr_Hostname[60],
			cntr_Code[3],
			cntr_Country[92],
			cntr_Region[43],
			cntr_ISP[60],
			cntr_Proxy
}


static
			PlayerCountryData[MAX_PLAYERS][E_COUNTRY_DATA],
			PlayerLookupRetries[MAX_PLAYERS],
			PlayerSessionData[MAX_PLAYERS],
Iterator:	PlayerSessionIndex<MAX_PLAYERS>;

static
			MaxRetries = 5;


forward OnLookupResponse(sessionid, response, data[]);


public OnPlayerLogin(playerid)
{
	_cntr_HandleLogin(playerid);

	#if defined cntr_OnPlayerLogin
		return cntr_OnPlayerLogin(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLogin
	#undef OnPlayerLogin
#else
	#define _ALS_OnPlayerLogin
#endif

#define OnPlayerLogin cntr_OnPlayerLogin
#if defined cntr_OnPlayerLogin
	forward cntr_OnPlayerLogin(playerid);
#endif

public OnPlayerRegister(playerid)
{
	_cntr_HandleLogin(playerid);

	#if defined cntr_OnPlayerRegister
		return cntr_OnPlayerRegister(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerRegister
	#undef OnPlayerRegister
#else
	#define _ALS_OnPlayerRegister
#endif

#define OnPlayerRegister cntr_OnPlayerRegister
#if defined cntr_OnPlayerRegister
	forward cntr_OnPlayerRegister(playerid);
#endif

_cntr_HandleLogin(playerid)
{
	_cntr_UseDatabase(playerid);
	_cntr_UseWeb(playerid);
}

_cntr_UseDatabase(playerid)
{
	GetPlayerCountry(playerid, PlayerCountryData[playerid][cntr_Country], 45);

	if(!strcmp(PlayerCountryData[playerid][cntr_Country], "Unknown"))
		return 0;

	return 1;
}

_cntr_UseWeb(playerid)
{
	new
		cell,
		ip[16],
		query[60];

	GetPlayerIp(playerid, ip, sizeof(ip));
	format(query, sizeof(query), "lookupffs.com/api.php?ip=%s", ip);

	cell = Iter_Free(PlayerSessionIndex);
	PlayerSessionData[cell] = playerid;
	Iter_Add(PlayerSessionIndex, cell);

	HTTP(cell, HTTP_GET, query, "", "OnLookupResponse");

	return 1;
}

public OnLookupResponse(sessionid, response, data[])
{
	if(!(0 <= sessionid < MAX_PLAYERS))
	{
		printf("ERROR: OnLookupResponse sessionid out of bounds (%d)", sessionid);
		return;
	}

	new playerid = PlayerSessionData[sessionid];
	Iter_Remove(PlayerSessionIndex, sessionid);

	if(IsPlayerConnected(playerid))
		return;

	if(response != 200 || isnull(data))
	{
		if(PlayerLookupRetries[playerid] < MaxRetries)
		{
			PlayerLookupRetries[playerid]++;
			_cntr_UseWeb(playerid);
		}

		return;
	}

	new
		pos,
		country[45],
		proxy[2];

	_cntr_GetXMLData(data, "host", PlayerCountryData[playerid][cntr_Hostname], pos, 60);
	_cntr_GetXMLData(data, "code", PlayerCountryData[playerid][cntr_Code], pos, 3);
	_cntr_GetXMLData(data, "country", country, pos, 45);
	_cntr_GetXMLData(data, "region", PlayerCountryData[playerid][cntr_Region], pos, 43);
	_cntr_GetXMLData(data, "isp", PlayerCountryData[playerid][cntr_ISP], pos, 60);
	_cntr_GetXMLData(data, "proxy", proxy, pos, 2);

	if(strcmp(PlayerCountryData[playerid][cntr_Country], country, true, 45))
		format(PlayerCountryData[playerid][cntr_Country], 92, "%s/%s", PlayerCountryData[playerid][cntr_Country], country);

	PlayerCountryData[playerid][cntr_Proxy] = strval(proxy);

	printf("[COUNTRY] Player country: '%s' (host: '%s' proxy: %d)",
		PlayerCountryData[playerid][cntr_Country],
		PlayerCountryData[playerid][cntr_Hostname],
		PlayerCountryData[playerid][cntr_Proxy]);

	return;
}

_cntr_GetXMLData(string[], tag[], output[], &start, maxlength = sizeof(output))
{
	new end = start = (strfind(string, tag, true, start) + strlen(tag) + 1);

	print(string[start]);

	while(string[end] != '<' && string[end] != '\0' && end - start < maxlength)
		end++;

	strmid(output, string, start, end, maxlength);
}


stock GetPlayerCountryDataAsString(playerid, output[], len = sizeof(output))
{
	if(!IsPlayerConnected(playerid))
		return 0;

	format(output, len, "\
		Hostname: '%s'\n\
		Code: '%s'\n\
		Country: '%s'\n\
		Region: '%s'\n\
		ISP: '%s'\n\
		Proxy: %s",
		PlayerCountryData[playerid][cntr_Hostname],
		PlayerCountryData[playerid][cntr_Code],
		PlayerCountryData[playerid][cntr_Country],
		PlayerCountryData[playerid][cntr_Region],
		PlayerCountryData[playerid][cntr_ISP],
		PlayerCountryData[playerid][cntr_Proxy] ? ("Yes") : ("No"));

	return 1;
}

// cntr_Hostname[60],
stock GetPlayerCachedHostname(playerid, output[], len = sizeof(output))
{
	if(!IsPlayerConnected(playerid))
		return 0;

	output[0] = EOS;
	strcat(output, PlayerCountryData[playerid][cntr_Hostname], len);

	return 1;
}

// cntr_Code[3],
stock GetPlayerCachedCountryCode(playerid, output[], len = sizeof(output))
{
	if(!IsPlayerConnected(playerid))
		return 0;

	output[0] = EOS;
	strcat(output, PlayerCountryData[playerid][cntr_Code], len);

	return 1;
}

// cntr_Country[45],
stock GetPlayerCachedCountryName(playerid, output[], len = sizeof(output))
{
	if(!IsPlayerConnected(playerid))
		return 0;

	output[0] = EOS;
	strcat(output, PlayerCountryData[playerid][cntr_Country], len);

	return 1;
}

// cntr_Region[43],
stock GetPlayerCachedRegion(playerid, output[], len = sizeof(output))
{
	if(!IsPlayerConnected(playerid))
		return 0;

	output[0] = EOS;
	strcat(output, PlayerCountryData[playerid][cntr_Region], len);

	return 1;
}

// cntr_ISP[60],
stock GetPlayerCachedISP(playerid, output[], len = sizeof(output))
{
	if(!IsPlayerConnected(playerid))
		return 0;

	output[0] = EOS;
	strcat(output, PlayerCountryData[playerid][cntr_ISP], len);

	return 1;
}

// cntr_Proxy
stock IsPlayerUsingProxy(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return PlayerCountryData[playerid][cntr_Proxy];
}

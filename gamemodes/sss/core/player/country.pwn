/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


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
   Iterator:PlayerSessionIndex<MAX_PLAYERS>;

static
			MaxRetries = 5;


forward OnLookupResponse(sessionid, response, data[]);


hook OnPlayerLogin(playerid)
{
	dbg("global", CORE, "[OnPlayerLogin] in /gamemodes/sss/core/player/country.pwn");

	_cntr_HandleLogin(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerRegister(playerid)
{
	dbg("global", CORE, "[OnPlayerRegister] in /gamemodes/sss/core/player/country.pwn");

	_cntr_HandleLogin(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_cntr_HandleLogin(playerid)
{
	_cntr_ClearData(playerid);
	_cntr_UseDatabase(playerid);
	_cntr_UseWeb(playerid);
}

_cntr_ClearData(playerid)
{
	PlayerCountryData[playerid][cntr_Hostname][0] = EOS;
	PlayerCountryData[playerid][cntr_Code][0] = EOS;
	PlayerCountryData[playerid][cntr_Country][0] = EOS;
	PlayerCountryData[playerid][cntr_Region][0] = EOS;
	PlayerCountryData[playerid][cntr_ISP][0] = EOS;
	PlayerCountryData[playerid][cntr_Proxy] = 0;
}

_cntr_UseDatabase(playerid)
{
// Causes sqlitei errors for some reason, disabled for now.
//	GetPlayerCountry(playerid, PlayerCountryData[playerid][cntr_Country], 45);

	if(!strcmp(PlayerCountryData[playerid][cntr_Country], "Unknown"))
		return 0;

	return 1;
}

_cntr_UseWeb(playerid)
{
	new
		cell,
		ip[16],
		query[66];

	GetPlayerIp(playerid, ip, sizeof(ip));
	format(query, sizeof(query), "legacy.iphub.info/api.php?ip=%s&source=ScavengeSurvive", ip);

	cell = Iter_Free(PlayerSessionIndex);

	if(cell == ITER_NONE)
	{
		err("[_cntr_UseWeb] cell == ITER_NONE");
		return 0;
	}

	PlayerSessionData[cell] = playerid;
	Iter_Add(PlayerSessionIndex, cell);

	HTTP(cell, HTTP_GET, query, "", "OnLookupResponse");

	return 1;
}

public OnLookupResponse(sessionid, response, data[])
{
	if(!(0 <= sessionid < MAX_PLAYERS))
	{
		err("OnLookupResponse sessionid out of bounds (%d)", sessionid);
		return;
	}

	new playerid = PlayerSessionData[sessionid];
	Iter_Remove(PlayerSessionIndex, sessionid);

	if(!IsPlayerConnected(playerid))
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
		proxy[2];

	_cntr_GetXMLData(data, "host", PlayerCountryData[playerid][cntr_Hostname], pos, 60);
	_cntr_GetXMLData(data, "code", PlayerCountryData[playerid][cntr_Code], pos, 3);
	_cntr_GetXMLData(data, "country", PlayerCountryData[playerid][cntr_Country], pos, 92);
	_cntr_GetXMLData(data, "region", PlayerCountryData[playerid][cntr_Region], pos, 43);
	_cntr_GetXMLData(data, "isp", PlayerCountryData[playerid][cntr_ISP], pos, 60);
	_cntr_GetXMLData(data, "proxy", proxy, pos, 2);

	PlayerCountryData[playerid][cntr_Proxy] = strval(proxy);

	log("[COUNTRY] Player country: '%s' (host: '%s' proxy: %d)",
		PlayerCountryData[playerid][cntr_Country],
		PlayerCountryData[playerid][cntr_Hostname],
		PlayerCountryData[playerid][cntr_Proxy]);

	if(PlayerCountryData[playerid][cntr_Proxy])
		KickPlayer(playerid, "Proxy connection detected, these are not allowed.");

	return;
}

_cntr_GetXMLData(string[], tag[], output[], &start, maxlength = sizeof(output))
{
	new end = start = (strfind(string, tag, true, start) + strlen(tag) + 1);

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

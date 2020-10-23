/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaws" Keene

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


#include <a_samp>
#include <zcmd>

public OnFilterScriptInit()
{
	for(new i;i<MAX_PLAYERS;i++)if(IsPlayerNPC(i))Kick(i);

	ConnectNPC("Tester0", "1");
	ConnectNPC("Tester1", "1");
	ConnectNPC("Tester2", "1");
	ConnectNPC("Tester3", "1");
	ConnectNPC("Tester4", "1");

	for(new i;i<MAX_PLAYERS;i++)if(IsPlayerNPC(i))
	{
		SetSpawnInfo(i, 255, 287, 0.0 + i, 0.0, 3.0, 270.0, 0, 0, 0, 0, 0, 0);
		SpawnPlayer(i);
		SetPlayerPos(i, 0.0 + 3*i, 0.0, 3.0);
	}

	SetTimer("spawn", 5000, false);
}

forward spawn();
public spawn()
{

	for(new i;i<MAX_PLAYERS;i++)if(IsPlayerNPC(i))
	{
		SetSpawnInfo(i, 255, 287, 0.0 + i, 0.0, 3.0, 270.0, 0, 0, 0, 0, 0, 0);
		SpawnPlayer(i);
		SetPlayerPos(i, 0.0 + 3*i, 0.0, 3.0);
	}
	return 1;
}



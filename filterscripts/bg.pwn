/* ---------------------------------
	 FCNPC Plugin Sample FS

- File: FCNPC.pwn
- Author: OrMisicL
---------------------------------*/

#define FILTERSCRIPT

#include <a_samp>
#include <FCNPC>

#define COLOR_GREY 0xAFAFAFAA
#define COLOR_RED  0xB35959AA

#define MAX_BODYGUARDS 6

forward UpdateGuards();

enum EBodyguard
{
	id,
	follow,
	aimat,
	shootat,
};

new Bodyguard[MAX_PLAYERS][MAX_BODYGUARDS][EBodyguard];
new Bodyguards[MAX_PLAYERS];
new LastPlayerId = INVALID_PLAYER_ID;

public OnFilterScriptInit()
{
	printf("");
	printf("-------------------------------------------------");
	printf("     FCNPC - Fully Customizable NPC Filterscript");
	printf("");
	printf("- Author: OrMisicL");
	printf("-------------------------------------------------");
	printf("");
	// Create the guards update timer
 	SetTimer("UpdateGuards", 100, -1);
}

public OnPlayerConnect(playerid)
{
	Bodyguards[playerid] = 0;
	for(new i = 0; i < MAX_BODYGUARDS; i++)
	{
		Bodyguard[playerid][i][id] = INVALID_NPC_ID;
		// Reset bodyguard stats
 		Bodyguard[playerid][i][follow] = 0;
 		Bodyguard[playerid][i][aimat] = INVALID_PLAYER_ID;
		Bodyguard[playerid][i][shootat] = INVALID_PLAYER_ID;
	}
	return 1;
}

public OnPlayerDisconnect(playerid)
{
	for(new i = 0; i < Bodyguards[playerid]; i++)
	{
	  	// Delete the bodyguard NPC
	  	FCNPC_Destroy(Bodyguard[playerid][i][id]);
	  	// Free the slot
		Bodyguard[playerid][i][id] = INVALID_NPC_ID;
		// Reset bodyguard stats
 		Bodyguard[playerid][i][follow] = 0;
 		Bodyguard[playerid][i][aimat] = INVALID_PLAYER_ID;
		Bodyguard[playerid][i][shootat] = INVALID_PLAYER_ID;
	}
	Bodyguards[playerid] = 0;
	return 1;
}

public UpdateGuards()
{
	// Loop through all the players
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		// Validate the player processing
		if(!IsPlayerConnected(i) || !Bodyguards[i])
		    continue;
		    
		// Loop through all the player guards
		for(new j = 0; j < Bodyguards[i]; j++)
		{
			// Process the guard follow
			if(Bodyguard[i][j][follow] == 1)
			{
				// Get the owner position
		 		new Float:x, Float:y, Float:z, Float:nx, Float:ny, Float:nz;
		 		GetPlayerPos(i, x, y, z);
		 		// Get the npc position
				FCNPC_GetPosition(Bodyguard[i][j][id], nx, ny, nz);
				// Check if we need to make him follow
				if(((x - nx) > 2.0 || (x - nx) < -2.0) || ((y - ny) > 2.0 || (y - ny) < -2.0))
				    FCNPC_GoTo(Bodyguard[i][j][id], x + 2, y + 2, z, MOVE_TYPE_RUN, 1);
    			else
		   			FCNPC_Stop(Bodyguard[i][j][id]);
			}
		}
	}
	return 1;
}

public FCNPC_OnCreate(npcid)
{
	if(LastPlayerId == INVALID_PLAYER_ID)
 	{
		printf("created NPC %d", npcid);
	 	FCNPC_Spawn(npcid, 21, 0.0, 0.0, 1.0);
 	    return 1;
    }
	// Get the current player pos
	new Float:x, Float:y, Float:z;
	GetPlayerPos(LastPlayerId, x, y, z);
	// Get interior
	new interior = GetPlayerInterior(LastPlayerId);
	// Generate a random skin for the bodyguard and spawn him
	FCNPC_Spawn(npcid, (random(5) + 163), x + 2, y + 2, z);
	FCNPC_SetInterior(npcid, interior);
	// Give him some weapons and ammo
	FCNPC_SetWeapon(npcid, (random(3) + 22));
	FCNPC_SetAmmo(npcid, 400);
	LastPlayerId = INVALID_PLAYER_ID;
	return 1;
}

public FCNPC_OnSpawn(npcid)
{
	new msg[24];
 	format(msg, 24, "NPC %d has spawned", npcid);
 	SendClientMessageToAll(0xFF00FF00, msg);
 	printf("NPC %d has spawned", npcid);
 	return 1;
}

public FCNPC_OnRespawn(npcid)
{
 	printf("NPC %d has respawned", npcid);
 	return 1;
}

public FCNPC_OnFinishPlayback(npcid)
{
	new msg[32];
 	format(msg, 32, "NPC %d has finished his playback");
 	SendClientMessageToAll(0xFF00FF00, msg);
 	return 1;
}

strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	new cmd[128];
	new idx;
	new tmp[64];
	cmd = strtok(cmdtext, idx);
	// Bodyguard command
	if(!strcmp(cmd, "/bg", true))
	{
	    // Get the options
	    tmp = strtok(cmdtext, idx);
		// Check params
		if(!strlen(tmp))
		{
		    SendClientMessage(playerid, COLOR_GREY, "Use: /bodyguard [option]");
		    SendClientMessage(playerid, COLOR_GREY, "add, delete, follow, unfollow");
		    return 1;
	 	}
	 	// Add bodyguard
	 	if(!strcmp(tmp, "add", true))
	 	{
			new guards = Bodyguards[playerid];
			// Check the bodyguards count for player
			if(guards == MAX_BODYGUARDS)
	  		{
	    		SendClientMessage(playerid, COLOR_RED, "Maximum bodyguards allowed per player is reached");
		    	return 1;
	  		}
	  		// Format a bodyguard name
	  		new name[24];
	  		format(name, 24, "guard_%d_%d", playerid, guards + 1);
 		 	// Increase the player bodyguards
		 	Bodyguards[playerid]++;
	  		// Create a new bodyguard NPC
	  		LastPlayerId = playerid;
	  		new npc = FCNPC_Create(name);
	  		if(npc == INVALID_NPC_ID)
	  		{
	     		SendClientMessage(playerid, COLOR_RED, "Failed to create the bodyguard (no slot available ?)");
				Bodyguards[playerid]--;
				return 1;
	  		}
		 	// Set the bodyguard slot
		 	Bodyguard[playerid][guards][id] = npc;
		 	// Reset bodyguard stats
		 	Bodyguard[playerid][guards][follow] = 0;
		 	Bodyguard[playerid][guards][aimat] = INVALID_PLAYER_ID;
   			Bodyguard[playerid][guards][shootat] = INVALID_PLAYER_ID;
			return 1;
	 	}
	  	if(!strcmp(tmp, "delete", true))
	 	{
			new guard = Bodyguards[playerid];
			// Check the bodyguards count for player
			if(guard == 0)
	  		{
	    		SendClientMessage(playerid, COLOR_RED, "No bodyguards to delete");
		    	return 1;
	  		}
	  		// Delete the bodyguard NPC
	  		FCNPC_Destroy(Bodyguard[playerid][guard - 1][id]);
		 	// Free the bodyguard slot
		 	Bodyguard[playerid][guard - 1][id] = INVALID_NPC_ID;
		 	// Decrease the player bodyguards
		 	Bodyguards[playerid]--;
		 	return 1;
	 	}
	  	if(!strcmp(tmp, "follow", true))
	 	{
			new guards = Bodyguards[playerid];
			// Check the bodyguards count for player
			if(guards == 0)
	  		{
	    		SendClientMessage(playerid, COLOR_RED, "No bodyguards to follow");
		    	return 1;
	  		}
  		 	// Get the guard id
	    	tmp = strtok(cmdtext, idx);
			// Check params
			if(!strlen(tmp))
			{
			    SendClientMessage(playerid, COLOR_GREY, "Use: /bodyguard follow [id]");
			    return 1;
		 	}
	    	if(strval(tmp) < 0 || strval(tmp) > guards)
	    	{
	    		SendClientMessage(playerid, COLOR_RED, "Invalid bodyguard");
		    	return 1;
	    	}
			// Set the bodyguard follow flag
			Bodyguard[playerid][strval(tmp) - 1][follow] = 1;
		 	return 1;
	 	}
  		if(!strcmp(tmp, "unfollow", true))
	 	{
			new guards = Bodyguards[playerid];
			// Check the bodyguards count for player
			if(guards == 0)
	  		{
	    		SendClientMessage(playerid, COLOR_RED, "No bodyguards to unfollow");
		    	return 1;
	  		}
  		 	// Get the guard id
	    	tmp = strtok(cmdtext, idx);
			// Check params
			if(!strlen(tmp))
			{
			    SendClientMessage(playerid, COLOR_GREY, "Use: /bodyguard unfollow [id]");
			    return 1;
		 	}
	    	if(strval(tmp) < 0 || strval(tmp) > guards)
	    	{
	    		SendClientMessage(playerid, COLOR_RED, "Invalid bodyguard");
		    	return 1;
	    	}
			// Reset the bodyguard follow flag
			Bodyguard[playerid][strval(tmp) - 1][follow] = 0;
		 	return 1;
	 	}
  		if(!strcmp(tmp, "enter", true))
	 	{
			new guards = Bodyguards[playerid];
			// Check the bodyguards count for player
			if(guards == 0)
	  		{
	    		SendClientMessage(playerid, COLOR_RED, "No bodyguards to enter vehicle");
		    	return 1;
	  		}
  		 	// Get the guard id
	    	tmp = strtok(cmdtext, idx);
			// Check params
			if(!strlen(tmp))
			{
			    SendClientMessage(playerid, COLOR_GREY, "Use: /bodyguard enter [id] [id]");
			    return 1;
		 	}
	    	if(strval(tmp) < 0 || strval(tmp) > guards)
	    	{
	    		SendClientMessage(playerid, COLOR_RED, "Invalid bodyguard");
		    	return 1;
	    	}
			// Make the bodyguard enter my vehicle
			FCNPC_EnterVehicle(Bodyguard[playerid][strval(tmp) - 1][id], GetPlayerVehicleID(playerid), 1);
		 	return 1;
	 	}
  		if(!strcmp(tmp, "exit", true))
	 	{
			new guards = Bodyguards[playerid];
			// Check the bodyguards count for player
			if(guards == 0)
	  		{
	    		SendClientMessage(playerid, COLOR_RED, "No bodyguards to exit vehicle");
		    	return 1;
	  		}
  		 	// Get the guard id
	    	tmp = strtok(cmdtext, idx);
			// Check params
			if(!strlen(tmp))
			{
			    SendClientMessage(playerid, COLOR_GREY, "Use: /bodyguard enter [id] [id]");
			    return 1;
		 	}
	    	if(strval(tmp) < 0 || strval(tmp) > guards)
	    	{
	    		SendClientMessage(playerid, COLOR_RED, "Invalid bodyguard");
		    	return 1;
	    	}
			// Make the bodyguard exit the vehicle
			FCNPC_ExitVehicle(Bodyguard[playerid][strval(tmp) - 1][id]);
		 	return 1;
	 	}
 		if(!strcmp(tmp, "drunk", true))
		{
			new guards = Bodyguards[playerid];
			// Check the bodyguards count for player
			if(guards == 0)
	  		{
	    		SendClientMessage(playerid, COLOR_RED, "No bodyguards make them drunk");
		    	return 1;
	  		}
  		 	// Get the guard id
	    	tmp = strtok(cmdtext, idx);
			// Check params
			if(!strlen(tmp))
			{
			    SendClientMessage(playerid, COLOR_GREY, "Use: /bodyguard drunk [id] [id]");
			    return 1;
		 	}
	    	if(strval(tmp) < 0 || strval(tmp) > guards)
	    	{
	    		SendClientMessage(playerid, COLOR_RED, "Invalid bodyguard");
		    	return 1;
	    	}
        	FCNPC_ApplyAnimation(Bodyguard[playerid][strval(tmp) - 1][id], 1189);
        	return 1;
 		}
		if(!strcmp(tmp, "setnormal", true))
		{
			new guards = Bodyguards[playerid];
			// Check the bodyguards count for player
			if(guards == 0)
	  		{
	    		SendClientMessage(playerid, COLOR_RED, "No bodyguards to reset to normal");
		    	return 1;
	  		}
  		 	// Get the guard id
	    	tmp = strtok(cmdtext, idx);
			// Check params
			if(!strlen(tmp))
			{
			    SendClientMessage(playerid, COLOR_GREY, "Use: /bodyguard setnormal [id] [id]");
			    return 1;
		 	}
	    	if(strval(tmp) < 0 || strval(tmp) > guards)
	    	{
	    		SendClientMessage(playerid, COLOR_RED, "Invalid bodyguard");
		    	return 1;
	    	}
	    	FCNPC_ClearAnimations(Bodyguard[playerid][strval(tmp) - 1][id]);
        	return 1;
 		}
 		if(!strcmp(tmp, "getanim", true))
		{
			// Format a bodyguard name
			new msg[24];
			format(msg, 24, "Anim: %d", FCNPC_GetAnimationIndex(0));
			SendClientMessage(playerid, COLOR_GREY, msg);
        	return 1;
 		}
 	}
 	return 1;
}

new _npc = 0;

public OnRconCommand(cmd[])
{
	if(!strcmp(cmd, "npc", true))
	{
		new name[24];
		format(name, 24, "test_%d", _npc + 1);
		_npc = FCNPC_Create(name);
	}
	if(!strcmp(cmd, "enter", true))
	{
	    FCNPC_EnterVehicle(_npc, 0, 0);
	}
	return 1;
}




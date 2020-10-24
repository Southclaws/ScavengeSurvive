/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


// -----------------------------------------------------------------------------
// Example Filterscript for the new SF ZomboTech Building and Lab with Elevator
// ----------------------------------------------------------------------------
// Original elevator code by Zamaroht in 2010
//
// Updated by Kye in 2011
// * Added a sound effect for the elevator starting/stopping
//
// Edited by Matite in January 2015
// * Added code to remove the existing building, add the new buildings and
//   adapted the elevator code so it works in this new building
//
//
// This script creates the new SF ZomboTech building and the lab objects, removes
// the existing GTASA building object and creates an elevator that can be used to
// travel between the building foyer and the lab.
//
// You can un-comment the OnPlayerCommandText callback below to enable a simple
// teleport command (/zl) that teleports you to the ZomboTech Lab elevator.
//
// Warning...
// This script uses a total of:
// * 9 objects = 1 for the elevator, 2 for the elevator doors, 4 for the elevator
//   floor doors and 2 for the buildings (replacement ZomboTech building and lab)
// * 3 3D Text Labels = 2 on the floors and 1 in the elevator
// * 1 dialog (for the elevator)
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
// Includes
// --------

// SA-MP include
#include <a_samp>

// For PlaySoundForPlayersInRange()
#include "../include/gl_common.inc"

// -----------------------------------------------------------------------------
// Defines
// -------

// Movement speed of the elevator
#define ELEVATOR_SPEED      (5.0)

// Movement speed of the doors
#define DOORS_SPEED         (5.0)

// Time in ms that the elevator will wait in each floor before continuing with the queue...
// be sure to give enough time for doors to open
#define ELEVATOR_WAIT_TIME  (5000)

// Dialog ID for the ZomboTech building elevator dialog
#define DIALOG_ID           (875)

// Position defines
#define X_DOOR_CLOSED       (-1951.603027)
#define X_DOOR_L_OPENED     X_DOOR_CLOSED + 1.6
#define X_DOOR_R_OPENED     X_DOOR_CLOSED - 1.6
#define GROUND_Z_COORD      (47.451492)
#define X_ELEVATOR_POS      (-1951.603027)
#define Y_ELEVATOR_POS      (636.418334)

// Elevator state defines
#define ELEVATOR_STATE_IDLE     (0)
#define ELEVATOR_STATE_WAITING  (1)
#define ELEVATOR_STATE_MOVING   (2)

// Invalid floor define
#define INVALID_FLOOR           (-1)

// -----------------------------------------------------------------------------
// Constants
// ---------

// Elevator floor names for the 3D text labels
static FloorNames[2][] =
{
	"Ground Floor",
	"ZomboTech Lab"
};

// Elevator floor Z heights
static Float:FloorZOffsets[2] =
{
    0.0,		// Ground Floor
    -21.628007	// ZomboTech Lab   -21.598007
};

// -----------------------------------------------------------------------------
// Variables
// ---------

// Stores the created object numbers of the replacement building and the lab so
// they can be destroyed when the filterscript is unloaded
new SFZomboTechBuildingObject;
new SFZomboTechLabObject;

// Stores the created object numbers of the elevator, the elevator doors and
// the elevator floor doors so they can be destroyed when the filterscript
// is unloaded
new Obj_Elevator, Obj_ElevatorDoors[2],	Obj_FloorDoors[2][2];

// Stores a reference to the 3D text labels used on each floor and inside the
// elevator itself so they can be detroyed when the filterscript is unloaded
new Text3D:Label_Elevator, Text3D:Label_Floors[2];

// Stores the current state of the elevator (ie ELEVATOR_STATE_IDLE,
// ELEVATOR_STATE_WAITING or ELEVATOR_STATE_MOVING)
new ElevatorState;

// Stores the current floor the elevator is on or heading to... if the value is
// ELEVATOR_STATE_IDLE or ELEVATOR_STATE_WAITING this is the current floor. If
// the value is ELEVATOR_STATE_MOVING then it is the floor it's moving to
new	ElevatorFloor;

// Stores the elevator queue for each floor
new ElevatorQueue[2];

// Stores who requested the floor for the elevator queue...
// FloorRequestedBy[floor_id] = playerid;  (stores who requested which floor)
new	FloorRequestedBy[2];

// Used for a timer that makes the elevator move faster after players start
// surfing the object
new ElevatorBoostTimer;

// -----------------------------------------------------------------------------
// Function Forwards
// -----------------

// Public:
forward CallElevator(playerid, floorid);    // You can use INVALID_PLAYER_ID too.
forward ShowElevatorDialog(playerid);

// Private:
forward Elevator_Initialize();
forward Elevator_Destroy();

forward Elevator_OpenDoors();
forward Elevator_CloseDoors();
forward Floor_OpenDoors(floorid);
forward Floor_CloseDoors(floorid);

forward Elevator_MoveToFloor(floorid);
forward Elevator_Boost(floorid);        	// Increases the elevator speed until it reaches 'floorid'.
forward Elevator_TurnToIdle();

forward ReadNextFloorInQueue();
forward RemoveFirstQueueFloor();
forward AddFloorToQueue(floorid);
forward IsFloorInQueue(floorid);
forward ResetElevatorQueue();

forward DidPlayerRequestElevator(playerid);

forward Float:GetElevatorZCoordForFloor(floorid);
forward Float:GetDoorsZCoordForFloor(floorid);

// -----------------------------------------------------------------------------
// Callbacks
// ---------

// Un-comment the OnPlayerCommandText callback below (remove the "/*" and the "*/")
// to enable a simple teleport command (/zl) which teleports the player to
// the Zombotech Lab elevator.

/*
public OnPlayerCommandText(playerid, cmdtext[])
{
	// Check command text
	if (strcmp("/zl", cmdtext, true, 3) == 0)
	{
	    // Set the interior
		SetPlayerInterior(playerid, 0);

		// Set player position and facing angle
		SetPlayerPos(playerid, -1957.11 + random(2), 644.36 + random(2), 47.6);
		SetPlayerFacingAngle(playerid, 215);

		// Fix camera position after teleporting
		SetCameraBehindPlayer(playerid);

		// Send a gametext message to the player
		GameTextForPlayer(playerid, "~b~~h~ZomboTech Lab!", 3000, 3);

	    // Exit here
	    return 1;
	}

	// Exit here (return 0 as the command was not handled in this filterscript)
	return 0;
}
*/

public OnFilterScriptInit()
{
    // Display information in the Server log
	print("\n");
	print("  |---------------------------------------------------");
	print("  |--- SF ZomboTech Filterscript");
    print("  |--  Script v1.01");
    print("  |--  12th January 2015");
	print("  |---------------------------------------------------");

	// Create the SF ZomboTech Building object
    SFZomboTechBuildingObject = CreateObject(19593, -1951.687500, 660.023986, 89.507797, 0, 0, 0);

    // Create the SF ZomboTech Lab object
    SFZomboTechLabObject = CreateObject(19594, -1951.687500, 660.023986, 29.507797, 0, 0, 0);

    // Display information in the Server log
    print("  |--  SF ZomboTech Building and Lab objects created");

    // Reset the elevator queue
	ResetElevatorQueue();
	
	// Create the elevator object, the elevator doors and the floor doors
	Elevator_Initialize();
	
	// Display information in the Server log
    print("  |--  SF ZomboTech Building Elevator created");
    print("  |---------------------------------------------------");
    
    // Loop
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        // Check if the player is connected and not a NPC
        if (IsPlayerConnected(i) && !IsPlayerNPC(i))
        {
            // Remove default GTASA SF ZomboTech map object and LOD for the player
            // (so any player currently ingame does not have to rejoin for them
			//  to be removed when this filterscript is loaded)
			RemoveBuildingForPlayer(i, 10027, -1951.687500, 660.023986, 89.507797, 250.0); // Building
			RemoveBuildingForPlayer(i, 9939, -1951.687500, 660.023986, 89.507797, 250.0); // LOD
        }
    }

	// Exit here
	return 1;
}

public OnFilterScriptExit()
{
    // Check for valid object
	if (IsValidObject(SFZomboTechBuildingObject))
	{
		// Destroy the SF ZombotTech Building object
		DestroyObject(SFZomboTechBuildingObject);

		// Display information in the Server log
		print("  |---------------------------------------------------");
    	print("  |--  SF ZomboTech Building object destroyed");
    }

    // Check for valid object
	if (IsValidObject(SFZomboTechLabObject))
	{
		// Destroy the SF ZomboTech Lab object
		DestroyObject(SFZomboTechLabObject);

		// Display information in the Server log
    	print("  |--  SF ZomboTech Lab object destroyed");
    }
    
    // Destroy the elevator, the elevator doors and the elevator floor doors
	Elevator_Destroy();
	
	// Display information in the Server log
    print("  |--  SF ZomboTech Building Elevator destroyed");
    print("  |---------------------------------------------------");
    	
    // Exit here
	return 1;
}

public OnPlayerConnect(playerid)
{
    // Remove default GTASA SF ZomboTech map object and LOD for the player
	RemoveBuildingForPlayer(playerid, 10027, -1951.687500, 660.023986, 89.507797, 250.0); // Building
	RemoveBuildingForPlayer(playerid, 9939, -1951.687500, 660.023986, 89.507797, 250.0); // LOD

	// Exit here
	return 1;
}

public OnObjectMoved(objectid)
{
    new Float:x, Float:y, Float:z;
	for(new i; i < sizeof(Obj_FloorDoors); i ++)
	{
		if(objectid == Obj_FloorDoors[i][0])
		{
		    GetObjectPos(Obj_FloorDoors[i][0], x, y, z);

            // A floor door has shut so move the elevator to the next floor in the queue
		    if (x == X_DOOR_CLOSED)
		    {
				Elevator_MoveToFloor(ElevatorQueue[0]);
				RemoveFirstQueueFloor();
			}
		}
	}
	
	if(objectid == Obj_Elevator)   // The elevator reached the specified floor.
	{
	    KillTimer(ElevatorBoostTimer);  // Kills the timer, in case the elevator reached the floor before boost.

	    FloorRequestedBy[ElevatorFloor] = INVALID_PLAYER_ID;

	    Elevator_OpenDoors();
	    Floor_OpenDoors(ElevatorFloor);

	    GetObjectPos(Obj_Elevator, x, y, z);
	    Label_Elevator	= Create3DTextLabel("{CCCCCC}Press '{FFFFFF}~k~~CONVERSATION_YES~{CCCCCC}' to use elevator", 0xCCCCCCAA, X_ELEVATOR_POS - 1.8, Y_ELEVATOR_POS + 1.6, z - 0.6, 4.0, 0, 1);

	    ElevatorState 	= ELEVATOR_STATE_WAITING;
	    SetTimer("Elevator_TurnToIdle", ELEVATOR_WAIT_TIME, 0);
	}

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_ID)
    {
        if(!response)
            return 0;

        if(FloorRequestedBy[listitem] != INVALID_PLAYER_ID || IsFloorInQueue(listitem))
            GameTextForPlayer(playerid, "~r~The floor is already in the queue", 3500, 4);
		else if(DidPlayerRequestElevator(playerid))
		    GameTextForPlayer(playerid, "~r~You already requested the elevator", 3500, 4);
		else
	        CallElevator(playerid, listitem);

		return 1;
    }

	return 0;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid) && (newkeys & KEY_YES))
	{
	    new Float:pos[3];
	    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);

		// log("X = %0.2f | Y = %0.2f | Z = %0.2f", pos[0], pos[1], pos[2]);
	    
	    if(pos[1] < (Y_ELEVATOR_POS + 1.8) && pos[1] > (Y_ELEVATOR_POS - 1.8) && pos[0] < (X_ELEVATOR_POS + 1.8) && pos[0] > (X_ELEVATOR_POS - 1.8))    // He is using the elevator button
	        ShowElevatorDialog(playerid);
		else    // Is the player using a floor button?
		{
		    if(pos[1] > (Y_ELEVATOR_POS + 1.81) && pos[1] < (Y_ELEVATOR_POS + 3.8) && pos[0] < (X_ELEVATOR_POS - 1.81) && pos[0] > (X_ELEVATOR_POS - 3.8))
		    {
		        // Create variable
		        new i = 0;
		        
		        // Check for ground floor
		        if (pos[2] > (GROUND_Z_COORD - 2) && pos[2] < (GROUND_Z_COORD + 2))
		        {
		            i = 0;
		        }
		        else i = 1;
		        
		        // log("Floor = %d | State = %d | i = %d", ElevatorFloor, ElevatorState, i);
		        
		        // Check if the elevator is not moving and already on the requested floor
		        if (ElevatorState != ELEVATOR_STATE_MOVING && ElevatorFloor == i)
		        {
		            // Display a gametext message and exit here
		            GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~r~ZomboTech Elevator~n~~r~Is Already On~n~~r~This Floor!", 3000, 5);
		            return 1;
		        }
				
			    // log("Call Elevator to Floor %i", i);
			    
				CallElevator(playerid, i);
				GameTextForPlayer(playerid, "~r~Elevator called", 3500, 4);
		    }
		}
	}

	return 1;
}

// ------------------------ Functions ------------------------
stock Elevator_Initialize()
{
	// Initializes the elevator.

	Obj_Elevator 			= CreateObject(18755, X_ELEVATOR_POS, Y_ELEVATOR_POS, GROUND_Z_COORD, 0.000000, 0.000000, 270.000000);
	Obj_ElevatorDoors[0] 	= CreateObject(18757, X_ELEVATOR_POS, Y_ELEVATOR_POS, GROUND_Z_COORD, 0.000000, 0.000000, 270.000000);
	Obj_ElevatorDoors[1] 	= CreateObject(18756, X_ELEVATOR_POS, Y_ELEVATOR_POS, GROUND_Z_COORD, 0.000000, 0.000000, 270.000000);

	Label_Elevator          = Create3DTextLabel("{CCCCCC}Press '{FFFFFF}~k~~CONVERSATION_YES~{CCCCCC}' to use elevator", 0xCCCCCCAA, X_ELEVATOR_POS - 1.8, Y_ELEVATOR_POS + 1.6, GROUND_Z_COORD - 0.6, 4.0, 0, 1);

	new string[128],
		Float:z;

	for(new i; i < sizeof(Obj_FloorDoors); i ++)
	{
	    Obj_FloorDoors[i][0] 	= CreateObject(18757, X_ELEVATOR_POS, Y_ELEVATOR_POS + 0.245, GetDoorsZCoordForFloor(i), 0.000000, 0.000000, 270.000000);
		Obj_FloorDoors[i][1] 	= CreateObject(18756, X_ELEVATOR_POS, Y_ELEVATOR_POS + 0.245, GetDoorsZCoordForFloor(i), 0.000000, 0.000000, 270.000000);

		format(string, sizeof(string), "{CCCCCC}[%s]\n{CCCCCC}Press '{FFFFFF}~k~~CONVERSATION_YES~{CCCCCC}' to call", FloorNames[i]);

		if(i == 0)
		    z = 47.460277;
		else
		    z = 25.820274;

		Label_Floors[i]         = Create3DTextLabel(string, 0xCCCCCCAA, X_ELEVATOR_POS - 2.5, Y_ELEVATOR_POS + 2.5, z - 0.2, 10.5, 0, 1);
	}

	// Open ground floor doors:
	Floor_OpenDoors(0);
	Elevator_OpenDoors();

	return 1;
}

stock Elevator_Destroy()
{
	// Destroys the elevator and the elevator doors
	DestroyObject(Obj_Elevator);
	DestroyObject(Obj_ElevatorDoors[0]);
	DestroyObject(Obj_ElevatorDoors[1]);
	
	// Destroy the 3D text label inside the elevator
	Delete3DTextLabel(Label_Elevator);

	// Loop
	for(new i; i < sizeof(Obj_FloorDoors); i ++)
	{
	    // Destroy the elevator floor doors and the floor 3D text labels
	    DestroyObject(Obj_FloorDoors[i][0]);
		DestroyObject(Obj_FloorDoors[i][1]);
		Delete3DTextLabel(Label_Floors[i]);
	}

	return 1;
}

stock Elevator_OpenDoors()
{
	// Opens the elevator's doors.

	new Float:x, Float:y, Float:z;

	GetObjectPos(Obj_ElevatorDoors[0], x, y, z);
	MoveObject(Obj_ElevatorDoors[0], X_DOOR_L_OPENED, y, z, DOORS_SPEED);
	MoveObject(Obj_ElevatorDoors[1], X_DOOR_R_OPENED, y, z, DOORS_SPEED);

	return 1;
}

stock Elevator_CloseDoors()
{
    // Closes the elevator's doors.

    if(ElevatorState == ELEVATOR_STATE_MOVING)
	    return 0;

    new Float:x, Float:y, Float:z;

	GetObjectPos(Obj_ElevatorDoors[0], x, y, z);
	MoveObject(Obj_ElevatorDoors[0], X_DOOR_CLOSED, y, z, DOORS_SPEED);
	MoveObject(Obj_ElevatorDoors[1], X_DOOR_CLOSED, y, z, DOORS_SPEED);

	return 1;
}

stock Floor_OpenDoors(floorid)
{
    // Opens the doors at the specified floor.

    MoveObject(Obj_FloorDoors[floorid][0], X_DOOR_L_OPENED, Y_ELEVATOR_POS + 0.245, GetDoorsZCoordForFloor(floorid), DOORS_SPEED);
	MoveObject(Obj_FloorDoors[floorid][1], X_DOOR_R_OPENED, Y_ELEVATOR_POS + 0.245, GetDoorsZCoordForFloor(floorid), DOORS_SPEED);
	
	PlaySoundForPlayersInRange(6401, 50.0, X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid) + 5.0);

	return 1;
}

stock Floor_CloseDoors(floorid)
{
    // Closes the doors at the specified floor.

    MoveObject(Obj_FloorDoors[floorid][0], X_ELEVATOR_POS, Y_ELEVATOR_POS + 0.245, GetDoorsZCoordForFloor(floorid), DOORS_SPEED);
	MoveObject(Obj_FloorDoors[floorid][1], X_ELEVATOR_POS, Y_ELEVATOR_POS + 0.245, GetDoorsZCoordForFloor(floorid), DOORS_SPEED);
	
	PlaySoundForPlayersInRange(6401, 50.0, X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid) + 5.0);

	return 1;
}

stock Elevator_MoveToFloor(floorid)
{
	// Moves the elevator to specified floor (doors are meant to be already closed).

	ElevatorState = ELEVATOR_STATE_MOVING;
	ElevatorFloor = floorid;

	// Move the elevator slowly, to give time to clients to sync the object surfing. Then, boost it up:
	MoveObject(Obj_Elevator, X_ELEVATOR_POS, Y_ELEVATOR_POS, GetElevatorZCoordForFloor(floorid), 0.25);
    MoveObject(Obj_ElevatorDoors[0], X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), 0.25);
    MoveObject(Obj_ElevatorDoors[1], X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), 0.25);
    Delete3DTextLabel(Label_Elevator);

	ElevatorBoostTimer = SetTimerEx("Elevator_Boost", 2000, 0, "i", floorid);

	return 1;
}

public Elevator_Boost(floorid)
{
	// Increases the elevator's speed until it reaches 'floorid'
	StopObject(Obj_Elevator);
	StopObject(Obj_ElevatorDoors[0]);
	StopObject(Obj_ElevatorDoors[1]);
	
	MoveObject(Obj_Elevator, X_ELEVATOR_POS, Y_ELEVATOR_POS, GetElevatorZCoordForFloor(floorid), ELEVATOR_SPEED);
    MoveObject(Obj_ElevatorDoors[0], X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), ELEVATOR_SPEED);
    MoveObject(Obj_ElevatorDoors[1], X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), ELEVATOR_SPEED);

	return 1;
}

public Elevator_TurnToIdle()
{
	ElevatorState = ELEVATOR_STATE_IDLE;
	ReadNextFloorInQueue();

	return 1;
}

stock RemoveFirstQueueFloor()
{
	// Removes the data in ElevatorQueue[0], and reorders the queue accordingly.

	for(new i; i < sizeof(ElevatorQueue) - 1; i ++)
	    ElevatorQueue[i] = ElevatorQueue[i + 1];

	ElevatorQueue[sizeof(ElevatorQueue) - 1] = INVALID_FLOOR;

	return 1;
}

stock AddFloorToQueue(floorid)
{
 	// Adds 'floorid' at the end of the queue.

	// Scan for the first empty space:
	new slot = -1;
	for(new i; i < sizeof(ElevatorQueue); i ++)
	{
	    if(ElevatorQueue[i] == INVALID_FLOOR)
	    {
	        slot = i;
	        break;
	    }
	}

	if(slot != -1)
	{
	    ElevatorQueue[slot] = floorid;

     	// If needed, move the elevator.
	    if(ElevatorState == ELEVATOR_STATE_IDLE)
	        ReadNextFloorInQueue();

	    return 1;
	}

	return 0;
}

stock ResetElevatorQueue()
{
	// Resets the queue.

	for(new i; i < sizeof(ElevatorQueue); i ++)
	{
	    ElevatorQueue[i] 	= INVALID_FLOOR;
	    FloorRequestedBy[i] = INVALID_PLAYER_ID;
	}

	return 1;
}

stock IsFloorInQueue(floorid)
{
	// Checks if the specified floor is currently part of the queue.

	for(new i; i < sizeof(ElevatorQueue); i ++)
	    if(ElevatorQueue[i] == floorid)
	        return 1;

	return 0;
}

stock ReadNextFloorInQueue()
{
	// Reads the next floor in the queue, closes doors, and goes to it.

	if(ElevatorState != ELEVATOR_STATE_IDLE || ElevatorQueue[0] == INVALID_FLOOR)
	    return 0;

	Elevator_CloseDoors();
	Floor_CloseDoors(ElevatorFloor);

	return 1;
}

stock DidPlayerRequestElevator(playerid)
{
	for(new i; i < sizeof(FloorRequestedBy); i ++)
	    if(FloorRequestedBy[i] == playerid)
	        return 1;

	return 0;
}

stock ShowElevatorDialog(playerid)
{
	new string[512];
	for(new i; i < sizeof(ElevatorQueue); i ++)
	{
	    if(FloorRequestedBy[i] != INVALID_PLAYER_ID)
	        strcat(string, "{FF0000}");

	    strcat(string, FloorNames[i]);
	    strcat(string, "\n");
	}

	ShowPlayerDialog(playerid, DIALOG_ID, DIALOG_STYLE_LIST, "ZomboTech Elevator...", string, "Accept", "Cancel");

	return 1;
}

stock CallElevator(playerid, floorid)
{
	// Calls the elevator (also used with the elevator dialog).

	if(FloorRequestedBy[floorid] != INVALID_PLAYER_ID || IsFloorInQueue(floorid))
	    return 0;

	FloorRequestedBy[floorid] = playerid;
	AddFloorToQueue(floorid);

	return 1;
}

stock Float:GetElevatorZCoordForFloor(floorid)
    return (GROUND_Z_COORD + FloorZOffsets[floorid]);

stock Float:GetDoorsZCoordForFloor(floorid)
	return (GROUND_Z_COORD + FloorZOffsets[floorid]);

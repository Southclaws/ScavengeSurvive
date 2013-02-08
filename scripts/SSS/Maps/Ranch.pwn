new
	ItemType:item_HardDrive = INVALID_ITEM_TYPE,
	ItemType:item_Key = INVALID_ITEM_TYPE,

	RanchPcButton,
	RanchHdd,
	RanchPcState,
	RanchPcObj,
	RanchPcCam,
	RanchPcPlayerViewing[MAX_PLAYERS],

	QuarryShedNote,
	QuarryShedPC,
	QuarryDoor,
	QuarryDoorKey,
	QuarryDoorState,

	CaveDoor,
	CaveLift,
	CaveLiftButtonT,
	CaveLiftButtonB,
	LiftPos;


public OnLoad()
{
	new
		buttonid[2];

	RanchHdd			= CreateItem(item_HardDrive, -693.1787, 942.0, 15.93, 90.0, 0.0, 37.5, .zoffset = FLOOR_OFFSET);
	QuarryDoorKey		= CreateItem(item_Key, -2813.96, -1530.55, 140.97, 0.36, -85.14, 25.00);

	RanchPcCam = LoadCameraMover("ranch");
	CreateDynamicObject(2574, -2811.88, -1530.59, 139.84, 0.00, 0.00, 180.00);
	CaveLift=CreateDynamicObject(7246, -2759.4704589844, 3756.869140625, 6.9, 270, 180, 340.91540527344, 0);


	// Quarry

	RanchPcButton = CreateButton(-691.1692, 942.1066, 13.6328, "Press F to use", 0);
	QuarryShedNote = CreateButton(491.629486, 782.667846, -22.067182, "Press F to use", 0);
	QuarryShedPC = CreateButton(489.710601, 785.067932, -22.021251, "Press F to use", 0);

	QuarryDoor = CreateButton(495.451873, 780.096191, -21.747426, "Press F to enter", 0); // quarry
	CaveDoor = CreateButton(-2702.358398, 3801.477050, 52.652801, "Press F to enter", 0); // cave 1

	buttonid[0]=CreateButton(-2811.1840, -1524.0532, 140.8437, "Press F to enter", 0);
	CreateDoor(1497, buttonid,
		-2811.41, -1524.75, 139.84,   0.00, 0.00, 455.82,
		-2811.41, -1524.72, 139.84,   0.00, 0.00, 570.18, .maxbuttons = 1, .movespeed = 0.1);

	buttonid[0]=CreateButton(-2821.0671, -1518.6484, 140.8437, "Press F to enter", 0);
	CreateDoor(1497, buttonid,
		-2821.19, -1519.46, 139.84, 0.00, 0.00, 450.60,
		-2821.19, -1519.44, 139.84, 0.00, 0.00, 353.28, .maxbuttons = 1, .movespeed = 0.1);


	buttonid[0]=CreateButton(-2796.933349, 3682.779785, 02.515481, "Press F to enter", 0); // cave 1
	buttonid[1]=CreateButton(-785.9272, 3727.1111, 0.5293, "Press F to enter", 0); // cave 2
	LinkTP(buttonid[0], buttonid[1]);

	// Subway/Metro interior 1=inside 2=surface

	buttonid[0]=CreateButton(-1007.395263, 5782.741210, 42.951477, "Press F to climb up the ladder", 0);
	buttonid[1]=CreateButton(2526.719482, -1648.620605, 14.471982, "Press F to climb down the ladder", 0);
	LinkTP(buttonid[0], buttonid[1]);

	buttonid[0]=CreateButton(250.599380, -154.643936, -50.768798, "Press F to enter", 0);
	buttonid[1]=CreateButton(247.878799, -154.444061, 02.399550, "Press F to enter", 0);
	LinkTP(buttonid[0], buttonid[1]);

	buttonid[0]=CreateButton(-2276.608642, 5324.488281, 41.677970, "Press F to enter", 0);
	buttonid[1]=CreateButton(-734.773986, 3861.994628, 12.482711, "Press F to enter", 0); // cave
	LinkTP(buttonid[0], buttonid[1]);

	// Fort Claw underground

	buttonid[0]=CreateButton(246.698684, -178.849655, -50.199367, "Press F to enter", 0); // underground
	buttonid[1]=CreateButton(-952.559326, 5137.799804, 46.183383, "Press F to enter", 0); // metro station
	LinkTP(buttonid[0], buttonid[1]);

	CreateButton(-972.153869, 4303.185058, 48.666248, "~r~Locked", 0);

	// Lift Sequence

	CaveLiftButtonT=CreateButton(-2764.0332, 3757.0466, 46.8343, "Press F to use the lift", 0);
	CaveLiftButtonB=CreateButton(-2764.3410, 3755.5153, 8.2390, "Press F to use the lift", 0);
	LiftPos=0;

	// Fort Claw Door

	buttonid[0] = CreateButton(264.316284, -171.135223, -50.206447, "Press F to activate", 0);
	buttonid[1] = CreateButton(265.862182, -170.113632, -50.204307, "Press F to activate", 0);
	CreateDoor(5779, buttonid,
		265.0330, -168.9362, -49.9792, 0.0, 0.0, 0.0,
		265.0322, -168.9355, -46.8575, 0.0, 0.0, 0.0,
		.worldid = 0);


	return CallLocalFunction("ranch_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad ranch_OnLoad
forward ranch_OnLoad();


public OnButtonPress(playerid, buttonid)
{
	if(buttonid==RanchPcButton)
	{
	    if(RanchPcState == 0)ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Computer", "You try to turn on the computer but the hard disk is missing.\nYou wonder where it could be and think it's mighty suspicious.\nThere is nothing useful nearby.", "Close", "");
	    if(RanchPcState == 1)
	    {
			if(RanchPcPlayerViewing[playerid])
			{
			    ExitCamera(playerid);
			    TogglePlayerControllable(playerid, true);
			    RanchPcPlayerViewing[playerid] = false;
			}
			else
			{
			    PlayCameraMover(playerid, RanchPcCam, .loop = true, .tp = false);
			    RanchPcPlayerViewing[playerid] = true;
			}
	    }

	}
	if(buttonid==QuarryShedNote)
	{
	    ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Note",
			"The note reads:\n\nThere's been strange goings on in the old shaft next to my work hut!\n\
			I don't want people looking around it so I locked it up. I left a copy of the key in my ranch house\n\
			in ... .. .\n\n\nThe rest of the note has been torn off.", "Close", "");
	}
	if(buttonid==QuarryShedPC)
	{
	    ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Computer", "You try to turn on the computer but the hard disk is missing.\nYou wonder where it could be and think it's mighty suspicious.\nThere is nothing useful nearby.", "Close", "");
	}

	if(buttonid == QuarryDoor)
	{
	    if(QuarryDoorState == 0)ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Door", "You pull on the door but it won't budge, the lock seems sturdy.\nThere's no way you can get through here without a key.\nPerhaps you should search the shed?", "Close", "");
	    else
	    {
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerPos(playerid, -2702.358398, 3801.477050, 52.652801);
			FreezePlayer(playerid, 1000);
	    }
	}
	if(buttonid == CaveDoor)
	{
	    SetPlayerVirtualWorld(playerid, 0);
		SetPlayerPos(playerid, 495.451873, 780.096191, -21.747426);
	}
	if(buttonid==CaveLiftButtonT)
	{
		if(LiftPos)
		{
		    MoveDynamicObject(CaveLift, -2759.4704589844, 3756.869140625, 6.9, 2.0, 270, 180, 340.9);
		    LiftPos=0;
		}
		else
		{
		    MoveDynamicObject(CaveLift, -2759.4704589844, 3756.869140625, 45.4, 2.0, 270, 180, 340.9);
		    LiftPos=1;
		}
	}
	if(buttonid==CaveLiftButtonB)
	{
		if(LiftPos)
		{
		    MoveDynamicObject(CaveLift, -2759.4704589844, 3756.869140625, 45.4, 2.0, 270, 180, 340.9);
		    LiftPos=0;
		}
		else
		{
		    MoveDynamicObject(CaveLift, -2759.4704589844, 3756.869140625, 6.9, 2.0, 270, 180, 340.9);
		    LiftPos=1;
		}
	}

    return CallLocalFunction("ranch_OnButtonPress", "ddd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
    #undef OnButtonPress
#else
    #define _ALS_OnButtonPress
#endif
#define OnButtonPress ranch_OnButtonPress
forward ranch_OnButtonPress(playerid, buttonid);


public OnPlayerUseItemWithButton(playerid, buttonid, itemid)
{
	if(buttonid == RanchPcButton && itemid == RanchHdd)
	{
	    ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Computer", "You begin reattaching the hard drive to the computer.", "Close", "");
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 0, 0, 0, 1, 450);
		defer AttachRanchHdd(playerid);
	}
	if(QuarryDoorState == 0 && buttonid == QuarryDoor && itemid == QuarryDoorKey)
	{
	    ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Door", "You have unlocked the mystery door!", "Close", "");
	    QuarryDoorState = 1;
	}

    return CallLocalFunction("int_OnPlayerUseItemWithButton", "ddd", playerid, buttonid, itemid);
}
#if defined _ALS_OnPlayerUseItemWithButton
    #undef OnPlayerUseItemWithButton
#else
    #define _ALS_OnPlayerUseItemWithButton
#endif
#define OnPlayerUseItemWithButton int_OnPlayerUseItemWithButton
forward int_OnPlayerUseItemWithButton(playerid, buttonid, itemid);


timer AttachRanchHdd[2500](playerid)
{
	DestroyItem(RanchHdd);
	ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Computer", "You successfully install the hard drive without electricuting yourself, well done!", "Close", "");
    ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
    RanchPcState = 1;

	RanchPcObj = CreateDynamicObject(19475, -690.966735, 942.852416, 13.642812, 0.000000, 0.000000, -110.324981),
	SetDynamicObjectMaterialText(RanchPcObj, 0,
		"system:\n\
		  >login terminal\\root\\user\\steve\n\
		  >open diary\\entry\\recent\n\
		   I have left the ranch, they are after me\n\
		   whoever finds this, I decided to go to a friends\n\
		   place on chilliad, he was dead when I got there\n\
		   I've hidden the key there, they won't find it\n\
		   I dont know how long it will be before they find me",
		OBJECT_MATERIAL_SIZE_512x512, "Courier New", 16, 1, -1, 0, 0);
}

public OnDoorStateChange(doorid, doorstate)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetDoorPos(doorid, x, y, z);

	if(doorstate == DR_STATE_OPENING || doorstate == DR_STATE_CLOSING)
	{
		PlaySound(6000, x, y, z);
	}
	if(doorstate == DR_STATE_OPEN || doorstate == DR_STATE_CLOSED)
	{
		PlaySound(6002, x, y, z);
	}
}

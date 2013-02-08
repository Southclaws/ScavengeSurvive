#include <YSI\y_hooks>


// Entities

new
	ch_gate,
	ch_doorBtn,
	ch_door,
	ch_walton,
	ch_battery,
	ch_fusebox,
	ch_keypad,
	ch_keypadprt;

// Variables

new
	bool:ch_doorstate = false;


public OnLoad()
{
	new buttons[1];


	ch_gate = CreateButton(-2307.81, -1650.67, 484.36, "Press F to activate", 0);

	buttons[0] = ch_gate;

	CreateDoor(975, buttons,
		-2312.10, -1652.69, 484.41,   0.00, 0.00, -154.50,
		-2317.88, -1655.44, 484.41,   0.00, 0.00, -154.50,
		.maxbuttons = 1, .movespeed = 1.0, .closedelay = -1);


	ch_doorBtn = CreateButton(-2311.4900, -1647.7000, 484.3600, "Press F to use", 0, 0);

	buttons[0] = ch_doorBtn;

	ch_door = CreateDoor(1498, buttons,
		-2311.2200, -1647.4800, 482.7210, 0.0000, 0.0000, 25.1400,
		-2311.2083, -1647.4178, 482.7395, 0.0000, 0.0000, 111.6000,
		.maxbuttons = 1, .movespeed = 0.1, .closedelay = -1);

//	-2310.5117, -1647.1541, 483.9890 inside door

	ch_battery = CreateItem(item_battery, -2316.15, -1646.64, 483.43, 0.00, 0.00, 32.04);
	ch_fusebox = CreateItem(item_fusebox, -2315.67, -1644.89, 483.06, 0.00, 0.00, 262.98, .zoffset = FLOOR_OFFSET/2);

	ch_keypad = CreateDynamicObject(19273, -2311.4968, -1647.6813, 484.3600, 0.0000, 0.0000, 26.2200);

	ch_walton = CreateDynamicObject(12957, -2317.19, -1644.16, 483.42, -0.30, -0.84, 27.72);
	#pragma unused ch_walton

	ch_doorstate = false;

	AddItemToContainer(
		CreateContainer("Generator", 6, -2318.9067, -1636.5662, 483.7031),
		CreateItem(item_Medkit, -2322.9257, -1639.8038, 483.7031));

	return CallLocalFunction("mtchil_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad mtchil_OnLoad
forward mtchil_OnLoad();

public OnPlayerActivateDoor(playerid, doorid, newstate)
{
	if(doorid == ch_door)
	{
		if(IsValidItem(GetPlayerItem(playerid)))
			return 1;

		if(ch_doorstate == false && !IsValidItem(GetPlayerItem(playerid)))
		{
			ShowPlayerDialog(playerid, d_NULL, DIALOG_STYLE_MSGBOX, "Door", "The keypad seems broken", "Close", "");
			return 1;
		}
	}

	return 0;
}


public OnPlayerUseItemWithButton(playerid, buttonid, itemid)
{
	print("item with button chil");
	if(buttonid == ch_doorBtn)
	{
		if(itemid == ch_fusebox)
		{
			DestroyItem(ch_fusebox);
			ch_fusebox = INVALID_ITEM_ID;
			ch_doorstate = true;
		}
		if(itemid == ch_battery)
		{
			DestroyButton(ch_doorBtn);
			ch_keypadprt = CreateDynamicObject(18724, -2311.4900, -1647.7000, 482.3600, 0.0000, 0.0000, 26.2200);
			defer ch_keypadprt_destroy();
			defer ch_keypad_move();
		}
	}
	print("item with button chil end");

    return CallLocalFunction("ch_OnPlayerUseItemWithButton", "ddd", playerid, buttonid, itemid);
}
#if defined _ALS_OnPlayerUseItemWithButton
    #undef OnPlayerUseItemWithButton
#else
    #define _ALS_OnPlayerUseItemWithButton
#endif
#define OnPlayerUseItemWithButton ch_OnPlayerUseItemWithButton
forward ch_OnPlayerUseItemWithButton(playerid, buttonid, itemid);


timer ch_keypad_move[400]()
{
	MoveDynamicObject(ch_keypad, -2311.5601, -1647.6781, 484.2200, 2.8, 0.0000, 32.0000, 26.0000);	
}
timer ch_keypadprt_destroy[2000]()
{
	DestroyDynamicObject(ch_keypadprt);
}

/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


// Entities


new
	Button:ch_gate,
	Button:ch_doorBtn,
	ch_door,
	ch_walton,
	Item:ch_battery,
	Item:ch_fusebox,
	ch_keypad,
	ch_keypadprt;


// Variables


new
	bool:ch_doorstate = false;


hook OnGameModeInit()
{
	new Button:buttons[1];


	ch_gate = CreateButton(-2307.81, -1650.67, 484.36, "Press F to activate", 0);

	buttons[0] = ch_gate;

	CreateDoor(975, buttons,
		-2312.10, -1652.69, 484.41,   0.00, 0.00, -154.50,
		-2317.88, -1655.44, 484.41,   0.00, 0.00, -154.50,
		.maxButtons = 1, .moveSpeed = 1.0, .closeDelay = -1);


	ch_doorBtn = CreateButton(-2311.4900, -1647.7000, 484.3600, "Press F to use", 0, 0);

	buttons[0] = ch_doorBtn;

	ch_door = CreateDoor(1498, buttons,
		-2311.2200, -1647.4800, 482.7210, 0.0000, 0.0000, 25.1400,
		-2311.2083, -1647.4178, 482.7395, 0.0000, 0.0000, 111.6000,
		.maxButtons = 1, .moveSpeed = 0.1, .closeDelay = -1);

//	-2310.5117, -1647.1541, 483.9890 inside door

	ch_battery = CreateItem(item_Battery, -2316.15, -1646.64, 483.43, 0.00, 0.00, 32.04);
	ch_fusebox = CreateItem(item_Fusebox, -2315.67, -1644.89, 483.06, 0.00, 0.00, 262.98);

	ch_keypad = CreateDynamicObject(19273, -2311.4968, -1647.6813, 484.3600, 0.0000, 0.0000, 26.2200);

	ch_walton = CreateDynamicObject(12957, -2317.19, -1644.16, 483.42, -0.30, -0.84, 27.72);
	#pragma unused ch_walton

	ch_doorstate = false;

	// AddItemToContainer(CreateContainer("Generator", 6, CreateButton(-2318.9067, -1636.5662, 483.7031, "Generator")), CreateItem(item_Medkit));

	// Building

	CreateDynamicObject(1411, -2316.07, -1654.99, 484.25,   0.00, 0.00, -154.92);
	CreateDynamicObject(1411, -2305.65, -1649.83, 484.25,   0.00, 0.00, -153.54);
	CreateDynamicObject(1411, -2300.96, -1647.49, 484.25,   0.00, 0.00, -153.54);
	CreateDynamicObject(1411, -2296.26, -1645.12, 484.25,   0.00, 0.00, -153.54);
	CreateDynamicObject(1411, -2291.54, -1642.77, 484.25,   0.00, 0.00, -153.54);
	CreateDynamicObject(1411, -2290.33, -1638.93, 484.25,   0.00, 0.00, -63.06);
	CreateDynamicObject(1411, -2292.71, -1634.23, 484.25,   0.00, 0.00, -63.06);
	CreateDynamicObject(1411, -2295.09, -1629.55, 484.25,   0.00, 0.00, -63.06);
	CreateDynamicObject(1411, -2297.48, -1624.87, 484.25,   0.00, 0.00, -63.06);
	CreateDynamicObject(19364, -2296.21, -1640.02, 484.49,   0.00, 0.00, -63.54);
	CreateDynamicObject(19364, -2295.58, -1637.82, 484.49,   0.00, 0.00, -153.54);
	CreateDynamicObject(19364, -2297.00, -1634.98, 484.49,   0.00, 0.00, -153.54);
	CreateDynamicObject(19364, -2298.42, -1632.11, 484.49,   0.00, 0.00, -153.54);
	CreateDynamicObject(19364, -2299.85, -1629.23, 484.49,   0.00, 0.00, -153.54);
	CreateDynamicObject(19364, -2301.23, -1626.46, 484.49,   0.00, 0.00, -153.54);
	CreateDynamicObject(19364, -2299.07, -1641.45, 484.49,   0.00, 0.00, -63.54);
	CreateDynamicObject(19364, -2301.94, -1642.88, 484.49,   0.00, 0.00, -63.54);
	CreateDynamicObject(19364, -2304.81, -1644.31, 484.49,   0.00, 0.00, -63.54);
	CreateDynamicObject(19364, -2307.68, -1645.74, 484.49,   0.00, 0.00, -63.54);
	CreateDynamicObject(19393, -2310.55, -1647.14, 484.49,   0.00, 0.00, -64.38);
	CreateDynamicObject(19364, -2312.62, -1646.44, 484.49,   0.00, 0.00, -153.54);
	CreateDynamicObject(19364, -2314.04, -1643.59, 484.49,   0.00, 0.00, -153.54);
	CreateDynamicObject(19364, -2315.48, -1640.72, 484.49,   0.00, 0.00, -153.54);
	CreateDynamicObject(19364, -2316.90, -1637.85, 484.49,   0.00, 0.00, -153.54);
	CreateDynamicObject(19364, -2318.33, -1634.97, 484.49,   0.00, 0.00, -153.54);
	CreateDynamicObject(19364, -2317.64, -1632.94, 484.49,   0.00, 0.00, -63.54);
	CreateDynamicObject(19364, -2314.78, -1631.51, 484.49,   0.00, 0.00, -63.54);
	CreateDynamicObject(19364, -2311.90, -1630.08, 484.49,   0.00, 0.00, -63.54);
	CreateDynamicObject(19364, -2309.03, -1628.65, 484.49,   0.00, 0.00, -63.54);
	CreateDynamicObject(19364, -2306.16, -1627.22, 484.49,   0.00, 0.00, -63.54);
	CreateDynamicObject(19364, -2303.29, -1625.79, 484.49,   0.00, 0.00, -63.54);
	CreateDynamicObject(1411, -2301.26, -1623.60, 484.25,   0.00, 0.00, 26.46);
	CreateDynamicObject(1411, -2305.92, -1625.94, 484.25,   0.00, 0.00, 26.46);
	CreateDynamicObject(1411, -2310.61, -1628.27, 484.25,   0.00, 0.00, 26.46);
	CreateDynamicObject(1411, -2315.30, -1630.61, 484.25,   0.00, 0.00, 26.46);
	CreateDynamicObject(1411, -2320.02, -1632.95, 484.25,   0.00, 0.00, 26.46);
	CreateDynamicObject(1411, -2324.72, -1635.27, 484.25,   0.00, 0.00, 26.46);
	CreateDynamicObject(1411, -2330.80, -1641.47, 484.25,   0.00, 0.00, 113.46);
	CreateDynamicObject(1411, -2328.71, -1646.29, 484.25,   0.00, 0.00, 113.46);
	CreateDynamicObject(1411, -2326.61, -1651.11, 484.25,   0.00, 0.00, 113.46);
	CreateDynamicObject(1411, -2324.51, -1655.91, 484.25,   0.00, 0.00, 113.88);
	CreateDynamicObject(1411, -2320.78, -1657.28, 484.25,   0.00, 0.00, -153.36);
	CreateDynamicObject(1411, -2329.41, -1637.63, 484.25,   0.00, 0.00, 26.46);
	CreateDynamicObject(3804, -2318.78, -1634.55, 485.14,   0.00, 0.00, 205.92);
	CreateDynamicObject(19362, -2316.63, -1634.30, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2315.20, -1637.17, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2313.77, -1640.05, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2312.41, -1642.73, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2311.00, -1645.59, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2307.87, -1644.03, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2304.75, -1642.47, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2297.23, -1638.64, 482.73,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2300.34, -1640.21, 482.73,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2303.49, -1641.75, 482.73,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2298.65, -1635.77, 482.73,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2300.07, -1632.92, 482.73,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2301.46, -1630.14, 482.73,   0.00, 90.00, -153.42);
	CreateDynamicObject(19362, -2302.86, -1627.31, 482.73,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2305.94, -1628.97, 482.73,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2304.91, -1638.88, 482.73,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2306.34, -1636.01, 482.73,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2307.78, -1633.14, 482.73,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2309.07, -1630.54, 482.73,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2301.77, -1637.36, 482.73,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2304.58, -1631.71, 482.73,   0.00, 90.00, -153.42);
	CreateDynamicObject(19362, -2303.14, -1634.58, 482.73,   0.00, 90.00, -153.42);
	CreateDynamicObject(19362, -2313.51, -1632.75, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2310.37, -1631.19, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2306.15, -1639.62, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2307.58, -1636.77, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2308.98, -1633.96, 482.65,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2312.05, -1635.61, 482.65,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2309.28, -1641.18, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2310.73, -1638.31, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2312.06, -1635.61, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19362, -2309.03, -1633.90, 482.66,   0.00, 90.00, -153.54);
	CreateDynamicObject(19353, -2304.90, -1644.15, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2307.78, -1645.57, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19383, -2310.62, -1646.99, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2302.03, -1642.72, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2299.15, -1641.29, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2296.28, -1639.86, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2295.75, -1637.90, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2297.17, -1635.03, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2298.60, -1632.15, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2300.03, -1629.28, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2301.42, -1626.48, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2312.55, -1646.21, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2313.99, -1643.34, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2315.40, -1640.47, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2316.83, -1637.60, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2318.17, -1634.91, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2317.43, -1633.03, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2314.56, -1631.61, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2311.70, -1630.17, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2308.81, -1628.74, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2305.94, -1627.32, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2303.18, -1625.94, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2305.05, -1642.34, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2306.49, -1639.47, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2307.91, -1636.59, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19353, -2307.07, -1634.48, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2309.34, -1633.72, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19383, -2310.53, -1631.35, 484.33,   0.00, 0.00, -153.54);
	CreateDynamicObject(19399, -2304.82, -1633.36, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19383, -2302.58, -1632.24, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(19353, -2300.56, -1631.24, 484.33,   0.00, 0.00, -63.54);
	CreateDynamicObject(1998, -2308.92, -1636.44, 482.75,   0.00, 0.00, 118.44);
	CreateDynamicObject(2311, -2308.58, -1641.10, 482.73,   0.00, 0.00, -63.42);
	CreateDynamicObject(1958, -2305.29, -1633.01, 483.72,   0.00, 0.00, 25.98);
	CreateDynamicObject(14820, -2306.56, -1633.68, 483.86,   0.00, 0.00, 26.10);
	CreateDynamicObject(1671, -2309.50, -1635.78, 483.18,   0.00, 0.00, -37.98);
	CreateDynamicObject(1703, -2306.14, -1643.76, 482.75,   0.00, 0.00, -153.12);
	CreateDynamicObject(1703, -2306.65, -1640.77, 482.75,   0.00, 0.00, -63.48);
	CreateDynamicObject(1703, -2309.15, -1644.31, 482.75,   0.00, 0.00, -243.54);
	CreateDynamicObject(16780, -2311.59, -1638.92, 485.90,   0.00, 0.00, 19.14);
	CreateDynamicObject(2239, -2305.28, -1643.34, 482.75,   0.00, 0.00, -113.28);
	CreateDynamicObject(2239, -2307.84, -1637.52, 482.75,   0.00, 0.00, -83.34);
	CreateDynamicObject(2106, -2308.33, -1641.51, 483.24,   0.00, 0.00, 0.00);
	CreateDynamicObject(936, -2317.49, -1633.87, 483.21,   0.00, 0.00, 26.88);
	CreateDynamicObject(2500, -2316.93, -1633.08, 483.68,   0.00, 0.00, 27.96);
	CreateDynamicObject(1209, -2316.91, -1636.55, 482.74,   0.00, 0.00, 117.36);
	CreateDynamicObject(2065, -2310.02, -1633.79, 482.75,   0.00, 0.00, -61.98);
	CreateDynamicObject(2065, -2310.31, -1633.20, 482.75,   0.00, 0.00, -63.72);
	CreateDynamicObject(2001, -2315.92, -1637.98, 482.75,   0.00, 0.00, 0.00);
	CreateDynamicObject(2010, -2308.61, -1645.19, 482.75,   0.00, 0.00, 0.00);
	CreateDynamicObject(2437, -2317.33, -1633.27, 483.68,   0.00, 0.00, 0.00);
	CreateDynamicObject(2132, -2316.20, -1633.14, 482.75,   0.00, 0.00, 26.10);
	CreateDynamicObject(2147, -2314.32, -1632.21, 482.75,   0.00, 0.00, -334.02);
	CreateDynamicObject(2862, -2316.25, -1632.98, 483.80,   0.00, 0.00, -118.32);
	CreateDynamicObject(2205, -2303.98, -1632.25, 482.82,   0.00, 0.00, -514.08);
	CreateDynamicObject(2205, -2306.10, -1633.28, 482.82,   0.00, 0.00, -513.78);
	CreateDynamicObject(2184, -2302.03, -1636.81, 482.82,   0.00, 0.00, -224.28);
	CreateDynamicObject(1958, -2304.80, -1632.78, 483.72,   0.00, 0.00, 26.28);
	CreateDynamicObject(2149, -2317.98, -1633.97, 483.80,   0.00, 0.00, 48.00);
	CreateDynamicObject(2190, -2304.11, -1632.75, 483.76,   0.00, 0.00, 208.02);
	CreateDynamicObject(3386, -2300.22, -1630.36, 482.82,   0.00, 0.00, 27.18);
	CreateDynamicObject(3388, -2301.16, -1628.40, 482.82,   0.00, 0.00, 26.40);
	CreateDynamicObject(3396, -2299.16, -1632.88, 482.82,   0.00, 0.00, 25.68);
	CreateDynamicObject(19317, -2296.48, -1639.68, 483.57,   -11.46, 1.08, -155.94);
	CreateDynamicObject(19318, -2295.73, -1638.45, 483.51,   -12.00, 0.00, -61.32);
	CreateDynamicObject(19317, -2304.11, -1635.50, 483.60,   -10.00, 0.00, -119.58);
	CreateDynamicObject(19319, -2296.20, -1637.53, 483.51,   -12.00, 0.00, -61.32);
	CreateDynamicObject(16780, -2302.04, -1637.36, 485.90,   0.00, 0.00, -20.88);
	CreateDynamicObject(19422, -2303.67, -1636.00, 483.61,   -8.04, 0.66, 0.00);
	CreateDynamicObject(19422, -2302.93, -1636.53, 483.61,   -8.04, 0.66, -68.94);
	CreateDynamicObject(19422, -2299.48, -1632.66, 483.73,   -8.04, 0.66, -59.52);
	CreateDynamicObject(19422, -2304.43, -1632.25, 483.77,   -8.04, 0.66, -65.04);
	CreateDynamicObject(19422, -2305.63, -1632.72, 483.77,   -8.04, 0.66, -220.62);
	CreateDynamicObject(17037, -2317.06, -1642.75, 485.11,   0.00, 0.00, -153.54);
	CreateDynamicObject(19377, -2309.34, -1641.11, 486.11,   0.00, 90.00, -153.54);
	CreateDynamicObject(19377, -2312.08, -1635.59, 486.10,   0.00, 90.00, -153.54);
	CreateDynamicObject(19377, -2304.47, -1631.75, 486.10,   0.00, 90.00, -153.54);
	CreateDynamicObject(19377, -2301.66, -1637.34, 486.10,   0.00, 90.00, -153.54);
	CreateDynamicObject(13758, -2327.05, -1638.38, 500.73,   0.00, 0.00, 2.76);
	CreateDynamicObject(920, -2318.28, -1636.41, 483.19,   0.00, 0.00, -63.30);
	CreateDynamicObject(943, -2319.94, -1635.71, 483.43,   0.00, 0.00, 116.22);
	CreateDynamicObject(1687, -2326.85, -1638.37, 483.50,   0.00, 0.00, 26.40);
	CreateDynamicObject(19273, -2307.81, -1650.67, 484.36,   0.00, 0.00, 26.46);
	CreateDynamicObject(19273, -2307.80, -1650.67, 484.36,   0.00, 0.00, -153.54);

	// Sign

	SetDynamicObjectMaterialText(
		CreateDynamicObject(18244, -2309.60, -1646.11, 487.69,   90.00, 0.00, 25.86),
		0, "Mt. Chill\nRadio", OBJECT_MATERIAL_SIZE_512x256, "Impact", 72, 0, -1, 4278216843, 1);
}

hook OnPlayerActivateDoor(playerid, doorid, newstate)
{
	if(doorid == ch_door)
	{
		if(IsValidItem(GetPlayerItem(playerid)))
			return Y_HOOKS_BREAK_RETURN_1;

		if(ch_doorstate == false && !IsValidItem(GetPlayerItem(playerid)))
		{
			Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Door", "The keypad seems broken", "Close", "");
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithBtn(playerid, Button:buttonid, Item:itemid)
{
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

	return Y_HOOKS_CONTINUE_RETURN_0;
}

timer ch_keypad_move[400]()
{
	MoveDynamicObject(ch_keypad, -2311.5601, -1647.6781, 484.2200, 2.8, 0.0000, 32.0000, 26.0000);	
}
timer ch_keypadprt_destroy[2000]()
{
	DestroyDynamicObject(ch_keypadprt);
}

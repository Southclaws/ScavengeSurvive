/*==============================================================================


	Southclaws's Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>
#include <SIF\extensions\MultiButton.pwn>

// "Mutli-Button Door" puzzle
#define _INST_MULTIBTNDOOR_MAX	(44)


// Class defaults (in all instanced interiors)
enum E_INST_MBD_DATA
{
			mbd_worldid,
			mbd_entrBtn,
			mbd_exitBtn,
Float:		mbd_exitPosX,
Float:		mbd_exitPosY,
Float:		mbd_exitPosZ,
Float:		mbd_entrPosX,
Float:		mbd_entrPosY,
Float:		mbd_entrPosZ,
			mbd_roomType
}


static
			mbd_Data[_INST_MULTIBTNDOOR_MAX][E_INST_MBD_DATA],
			mbd_EntryButtonInst[BTN_MAX] = {-1, ...},
			mbd_TotalInstances,

			mbd_Objects_Gate[_INST_MULTIBTNDOOR_MAX],
			mbd_MultiTrigger[_INST_MULTIBTNDOOR_MAX],
			mbd_MultiTriggerInst[MBT_MAX] = {-1, ...};


// Instance dependent storage
static


EnterIntInst_MultiBtnDoor(playerid, instworld)
{
	Streamer_UpdateEx(playerid, mbd_Data[instworld][mbd_entrPosX], mbd_Data[instworld][mbd_entrPosY], mbd_Data[instworld][mbd_entrPosZ], mbd_Data[instworld][mbd_worldid]);
	SetPlayerPos(playerid, mbd_Data[instworld][mbd_entrPosX], mbd_Data[instworld][mbd_entrPosY], mbd_Data[instworld][mbd_entrPosZ]);
	SetPlayerVirtualWorld(playerid, mbd_Data[instworld][mbd_worldid]);
	SetPlayerInterior(playerid, 1);
	FreezePlayer(playerid, 5000);

	return 1;
}

ExitIntInst_MutiBtnDoor(playerid, instworld)
{
	SetPlayerPos(playerid, mbd_Data[instworld][mbd_exitPosX], mbd_Data[instworld][mbd_exitPosY], mbd_Data[instworld][mbd_exitPosZ]);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
}

CreateMBD(Float:exitx, Float:exity, Float:exitz, roomtype)
{
	mbd_Data[mbd_TotalInstances][mbd_worldid] = mbd_TotalInstances + 100;
	mbd_Data[mbd_TotalInstances][mbd_exitPosX] = exitx;
	mbd_Data[mbd_TotalInstances][mbd_exitPosY] = exity;
	mbd_Data[mbd_TotalInstances][mbd_exitPosZ] = exitz;
	mbd_Data[mbd_TotalInstances][mbd_roomType] = roomtype;

	// TODO: Move this to object-loader API and load using functions.
	switch(roomtype)
	{
		case 0: _mbt_CreateRoom_0(mbd_TotalInstances);
		case 1: _mbt_CreateRoom_1(mbd_TotalInstances);
	}

	mbd_Data[mbd_TotalInstances][mbd_entrBtn] = CreateButton(exitx, exity, exitz, "Press "KEYTEXT_INTERACT" to enter", .label = 1, .labeltext = "House");
	mbd_Data[mbd_TotalInstances][mbd_exitBtn] = CreateButton(mbd_Data[mbd_TotalInstances][mbd_entrPosX], mbd_Data[mbd_TotalInstances][mbd_entrPosY], mbd_Data[mbd_TotalInstances][mbd_entrPosZ], "Exit", mbd_Data[mbd_TotalInstances][mbd_worldid], 1, _, 1, "Exit");

	mbd_EntryButtonInst[mbd_Data[mbd_TotalInstances][mbd_entrBtn]] = mbd_TotalInstances;
	mbd_EntryButtonInst[mbd_Data[mbd_TotalInstances][mbd_exitBtn]] = mbd_TotalInstances;

	mbd_TotalInstances++;
}

_mbt_CreateRoom_0(instworld)
{
	mbd_Data[instworld][mbd_entrPosX] = -8.6034;
	mbd_Data[instworld][mbd_entrPosY] = 1.9629;
	mbd_Data[instworld][mbd_entrPosZ] = 22.0630;

	// Create buttons
	new list[3];
	list[0] = CreateButton(0.26101, 1.27191, 23.10903, "Button", mbd_Data[instworld][mbd_worldid], 1);
	list[1] = CreateButton(-4.32445, -9.04405, 22.77993, "Button", mbd_Data[instworld][mbd_worldid], 1);
	list[2] = CreateButton(7.69853, -8.88137, 23.16210, "Button", mbd_Data[instworld][mbd_worldid], 1);
	mbd_MultiTrigger[instworld] = CreateMultiButtonTrigger(MBT_TYPE_SEQUENCE, 500, list);

	mbd_MultiTriggerInst[mbd_MultiTrigger[instworld]] = instworld;

	// Gate to open, move to -6.2269, -7.4441, 22.4547
	mbd_Objects_Gate[instworld] = CreateDynamicObject(19303, -7.89487, -7.44414, 22.45467,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);

	// Entrance door: 1504-1507
	CreateDynamicObject(1507, -9.37020, 2.96800, 21.25180,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);

	CreateDynamicObject(6959, 0.00000, 0.00000, 20.00000,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(15041, 0.06772, -1.96441, 23.25471,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1308, -8.85616, -7.55512, 19.68349,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1308, -11.11932, -7.56707, 18.13558,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(12914, -12.06179, -1.25252, 20.19253,   7.26000, 21.82001, 110.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(3302, -10.26185, -7.31071, 22.50448,   -92.82001, -0.36000, -9.42000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(16637, -1.81976, 1.02771, 22.34516,   20.21998, -1.44000, 91.80000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1502, 2.91038, 0.99254, 21.25403,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1502, 2.90931, -3.31702, 21.25403,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1502, -1.08390, -3.30160, 21.25400,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1753, -13.82913, -1.49566, 21.69439,   -90.00000, 0.00000, -82.61999, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1819, -13.10517, 0.14783, 21.25163,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2029, -6.23164, -5.19968, 21.25084,   0.00000, 0.00000, 80.27999, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2079, -5.98812, -6.53789, 21.84165,   0.00000, 0.00000, -75.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2079, -5.05897, -5.48895, 21.84165,   0.00000, 0.00000, -10.31999, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2079, -5.12561, -2.65226, 21.51567,   0.00000, 90.00000, 92.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2079, -7.44520, -5.49550, 21.51570,   90.00000, 90.00000, 210.85989, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2090, -0.36492, -6.20138, 21.25262,   0.00000, 0.00000, 87.35998, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2299, 6.26737, -5.68336, 21.25213,   0.00000, 0.00000, 180.54001, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2298, 2.47964, 3.28425, 21.24965,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2307, 5.90179, 2.95644, 21.25130,   0.00000, 0.00000, -91.26001, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2307, 5.87497, 5.02518, 21.25130,   0.00000, 0.00000, -90.12001, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2306, 2.14520, 2.80297, 21.25179,   0.00000, 0.00000, -178.55998, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1786, 2.24778, 1.32923, 22.25002,   0.00000, 0.00000, -178.97998, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1754, 0.60041, 4.87288, 21.25151,   0.00000, 0.00000, 73.38000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2306, 1.26004, 6.51351, 21.25006,   0.00000, 0.00000, 86.75999, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2306, -0.05123, -7.02892, 21.25331,   0.00000, 0.00000, -91.80000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2307, -2.28168, -9.00360, 22.74551,   270.00000, 0.00000, 349.56003, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1752, 1.33808, -7.11274, 22.25086,   0.00000, 0.00000, -91.85999, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1754, 0.75917, -8.62178, 21.25297,   0.00000, 0.00000, -116.10000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2008, -3.70177, -4.08329, 21.25319,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2008, 6.09305, -4.01453, 21.25319,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2306, 3.36575, -7.43574, 21.25233,   0.00000, 0.00000, 90.78001, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1752, 1.94236, -7.38174, 22.24938,   0.00000, 0.00000, 93.71999, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1788, 2.40707, -7.49248, 21.25237,   0.00000, 0.00000, 89.52000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2307, 3.42705, -6.09052, 21.25167,   0.00000, 0.00000, 89.81998, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2251, -6.21887, -4.72349, 22.92024,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1742, -6.05604, 2.99942, 21.25028,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1742, -4.49132, 1.95940, 21.25028,   0.00000, 0.00000, -89.52001, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(3302, 7.54839, -1.68839, 22.10518,   1.14000, -87.54003, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1965, 8.24237, -1.78990, 22.38921,   12.12000, -3.54000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2922, 0.26101, 1.27191, 23.10903,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2922, -4.32445, -9.04405, 22.77993,   0.00000, 0.00000, -88.97997, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2922, 7.69853, -8.88137, 23.16210,   0.00000, 0.00000, 89.64000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2262, 7.10899, -8.78135, 21.40957,   -6.54000, 0.54000, -89.10000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(913, 0.51490, 2.85654, 22.09544,   0.00000, 0.00000, -262.73972, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2131, -5.07542, -9.70441, 21.25244,   0.00000, 0.00000, -90.35998, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2338, -5.10000, -12.73780, 21.25210,   0.00000, 0.00000, -89.22000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2337, -5.12280, -11.72050, 21.25370,   0.00000, 0.00000, 270.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2336, -6.08400, -12.73640, 21.25410,   0.00000, 0.00000, 180.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2117, -11.02023, -10.24629, 21.25348,   0.00000, 0.00000, -89.81998, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1739, -12.06945, -10.29340, 22.07187,   0.00000, 0.00000, 185.28004, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1739, -12.05138, -11.41486, 22.07187,   0.00000, 0.00000, 185.28004, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1739, -11.16453, -12.28726, 22.07187,   0.00000, 0.00000, 240.78001, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1739, -9.13009, -12.12822, 21.54385,   90.00000, 6.00000, 398.25989, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1739, -11.51853, -8.93810, 22.07187,   0.00000, 0.00000, 120.66005, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1739, -9.97253, -9.84661, 22.07187,   0.00000, 0.00000, 45.72006, mbd_Data[instworld][mbd_worldid], 1);

	CreateSaveBlockArea(CreateDynamicSphere(0.0, 0.0, 0.0, 50.0, mbd_Data[instworld][mbd_worldid], 1), mbd_Data[instworld][mbd_entrPosX], mbd_Data[instworld][mbd_entrPosY], mbd_Data[instworld][mbd_entrPosZ]);
	CreateStaticLootSpawn(-7.3336, -9.7528, 21.2515, GetLootIndexFromName("world_survivor"), 100.0, 6, mbd_Data[instworld][mbd_worldid], 1);
}

_mbt_CreateRoom_1(instworld)
{
	mbd_Data[instworld][mbd_entrPosX] = -3.8379;
	mbd_Data[instworld][mbd_entrPosY] = -8.4037;
	mbd_Data[instworld][mbd_entrPosZ] = 16.9831;

	CreateDynamicObject(15058, 0.00000, 0.00000, 20.00000,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(6959, 0.00000, 0.00000, 15.90425,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(16637, -5.96581, 7.72439, 21.95270,   29.81999, 1.32000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1507, -4.55677, -9.19119, 16.06164,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1753, 7.06868, 10.22916, 16.06096,   0.00000, 0.00000, -62.64001, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1753, 8.06672, 6.17823, 16.06096,   0.00000, 0.00000, -122.45998, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1819, 6.03968, 7.36747, 16.06222,   0.00000, 0.00000, 0.00000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2299, 5.86608, 7.82586, 20.56542,   0.00000, 0.00000, -91.61999, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2307, 2.03797, 6.54518, 20.56578,   0.00000, 0.00000, 86.28001, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(1786, 2.05743, 10.80399, 21.01437,   94.92002, 164.99976, -157.50002, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2306, 5.01228, 9.66055, 20.56448,   0.00000, 0.00000, -13.02000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2008, 1.25090, 2.32390, 20.56558,   0.00000, 0.00000, 95.46000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2029, 1.13894, -6.00281, 16.06135,   0.00000, 0.00000, 36.66000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(3302, 2.16526, -6.34999, 16.66943,   39.90000, 7.01999, 28.62000, mbd_Data[instworld][mbd_worldid], 1);
	CreateDynamicObject(2079, 1.34490, -1.56782, 16.67602,   0.00000, 0.00000, -28.62000, mbd_Data[instworld][mbd_worldid], 1);

	CreateSaveBlockArea(CreateDynamicSphere(0.0, 0.0, 0.0, 50.0, mbd_Data[instworld][mbd_worldid], 1), mbd_Data[instworld][mbd_entrPosX], mbd_Data[instworld][mbd_entrPosY], mbd_Data[instworld][mbd_entrPosZ]);
}


hook OnGameModeInit()
{
	CreateMBD(1928.89709, 2774.31934, 10.7447, random(2));
	CreateMBD(1967.37476, 2765.92334, 10.7447, random(2));
	CreateMBD(1992.53406, 2764.37500, 10.7447, random(2));
	CreateMBD(2018.52954, 2766.25415, 10.7447, random(2));
	CreateMBD(2039.51758, 2766.17334, 10.7447, random(2));
	CreateMBD(2049.73145, 2764.37891, 10.7447, random(2));
	CreateMBD(1735.57458, 2690.86499, 10.7447, random(2));
	CreateMBD(1703.83240, 2689.23145, 10.7447, random(2));
	CreateMBD(1678.51782, 2691.22095, 10.7447, random(2));
	CreateMBD(1652.52478, 2709.13672, 10.7447, random(2));
	CreateMBD(1627.31885, 2711.08569, 10.7447, random(2));
	CreateMBD(1601.21082, 2709.17627, 10.7447, random(2));
	CreateMBD(1580.34204, 2709.35522, 10.7447, random(2));
	CreateMBD(1570.10193, 2711.32764, 10.7447, random(2));
	CreateMBD(1599.46265, 2757.34253, 10.7447, random(2));
	CreateMBD(1550.57788, 2845.83545, 10.7447, random(2));
	CreateMBD(1575.66248, 2843.56592, 10.7447, random(2));
	CreateMBD(1588.56836, 2797.59717, 10.7447, random(2));
	CreateMBD(1601.81641, 2845.77979, 10.7447, random(2));
	CreateMBD(1622.70251, 2845.50049, 10.7447, random(2));
	CreateMBD(1632.93567, 2843.88525, 10.7447, random(2));
	CreateMBD(1664.72473, 2845.92358, 10.7447, random(2));
	CreateMBD(1623.55615, 2567.70142, 10.7447, random(2));
	CreateMBD(1596.50916, 2567.69873, 10.7447, random(2));
	CreateMBD(1564.51721, 2565.93262, 10.7447, random(2));
	CreateMBD(1551.59058, 2567.78320, 10.7447, random(2));
	CreateMBD(1513.42053, 2565.83276, 10.7447, random(2));
	CreateMBD(1503.24146, 2567.53101, 10.7447, random(2));
	CreateMBD(1500.50891, 2535.42969, 10.7447, random(2));
	CreateMBD(1454.37659, 2525.53003, 10.7447, random(2));
	CreateMBD(1451.38867, 2565.81836, 10.7447, random(2));
	CreateMBD(1441.65747, 2567.65649, 10.7447, random(2));
	CreateMBD(1417.89771, 2567.86230, 10.7447, random(2));
	CreateMBD(1408.14539, 2524.66650, 10.7447, random(2));
	CreateMBD(1362.77747, 2525.56592, 10.7447, random(2));
	CreateMBD(1359.72461, 2565.64648, 10.7447, random(2));
	CreateMBD(1349.63940, 2567.52002, 10.7447, random(2));
	CreateMBD(1325.62000, 2567.55420, 10.7447, random(2));
	CreateMBD(1316.49329, 2524.50562, 10.7447, random(2));
	CreateMBD(1274.35730, 2522.48877, 10.7447, random(2));
	CreateMBD(1269.90479, 2554.39819, 10.7447, random(2));
	CreateMBD(1271.77954, 2564.39917, 10.7447, random(2));
	CreateMBD(1225.30994, 2584.87573, 10.7447, random(2));
	CreateMBD(1223.32104, 2616.84473, 10.7447, random(2));

}


hook OnMultiButtonTrigger(triggerid, success)
{
	if(success)
	{
		if(mbd_MultiTriggerInst[triggerid] != -1)
		{
			MoveDynamicObject(mbd_Objects_Gate[mbd_MultiTriggerInst[triggerid]], -6.2269, -7.4441, 22.4547, 0.8);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnButtonPress(playerid, buttonid)
{
	if(mbd_EntryButtonInst[buttonid] != -1)
	{
		if(buttonid == mbd_Data[mbd_EntryButtonInst[buttonid]][mbd_entrBtn])
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetButtonPos(buttonid, x, y, z);
			EnterIntInst_MultiBtnDoor(playerid, mbd_EntryButtonInst[buttonid]);
		}

		if(buttonid == mbd_Data[mbd_EntryButtonInst[buttonid]][mbd_exitBtn])
		{
			ExitIntInst_MutiBtnDoor(playerid, mbd_EntryButtonInst[buttonid]);
			return Y_HOOKS_BREAK_RETURN_0;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

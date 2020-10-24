/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


// Keypad IDs
enum
{
	k_ControlTower,
	k_MainGate,
	k_AirstripGate,
	k_BlastDoor,
	k_Storage,
	k_StorageWatch,
	k_Generator,
	k_PassageTop,
	k_PassageBottom,
	k_Catwalk,
	k_Headquarters1,
	k_Headquarters2,
	k_Shaft,
	k_Lockup
}


new
	code_ControlTower,
	code_MainGate,
	code_AirstripGate,
	code_BlastDoor,
	code_Inner,
	code_Storage,
	code_StorageWatch,
	code_Generator,
	code_PassageTop,
	code_PassageBottom,
	code_Catwalk,
	code_Headquarters,
	code_Shaft,

	Button:btn_ControlTower,
	Button:btn_StorageWatch,

	lock_ControlTower,
	lock_StorageWatch,

	door_Main,
	door_Airstrip,
	door_BlastDoor1,
	door_BlastDoor2,
	door_Storage,
	door_Generator,
	door_PassageTop,
	door_PassageBottom,
	door_Catwalk,
	door_Headquarters1,
	door_Headquarters2,
	door_Shaft;

hook OnGameModeInit()
{
	new
		Button:buttonid[2];

	code_ControlTower	= 1000 + random(8999);
	code_MainGate		= 1000 + random(8999);
	code_AirstripGate	= 1000 + random(8999);
	code_BlastDoor		= 1000 + random(8999);
	code_Inner			= 1000 + random(8999);
	code_Storage		= 1000 + random(8999);
	code_StorageWatch	= 1000 + random(8999);
	code_Generator		= 1000 + random(8999);
	code_PassageTop		= 1000 + random(8999);
	code_PassageBottom	= 1000 + random(8999);
	code_Catwalk		= 1000 + random(8999);
	code_Headquarters	= 1000 + random(8999);
	code_Shaft			= 1000 + random(8999);

	lock_ControlTower = 1;
	lock_StorageWatch = 1;

	btn_ControlTower = CreateButton(211.6015, 1812.2878, 21.8594, "Press "KEYTEXT_INTERACT" to interact");
	btn_StorageWatch = CreateButton(246.4888, 1861.1544, 14.0840, "Press "KEYTEXT_INTERACT" to interact");

	// Main Gate Block
	CreateObject(971, 96.88655, 1923.33936, 17.58039, 0.00000, 0.00000, 90.00000);
	CreateObject(971, 96.88655, 1923.33936, 13.61467, 0.00000, 0.00000, 90.00000);
	CreateObject(19273, 117.87466, 1932.37390, 19.57730, 0.00000, 0.00000, 270.00000);

	// Main Gate
	buttonid[0] = CreateButton(117.8747, 1932.3739, 19.5773, "Press to activate gate");
	door_Main = CreateDoor(19313, buttonid,
		134.91060, 1941.52124, 21.77760, 0.00000, 0.00000, 0.00000,
		120.9106, 1941.52124, 21.77760, 0.00000, 0.00000, 0.00000,
		.maxButtons = 1, .moveSound = 6000, .stopSound = 6002, .closeDelay = -1);

	// Airstrip Gate
	buttonid[0] = CreateButton(280.7763, 1828.0514, 2.3915, "Press to activate gate");
	door_Airstrip = CreateDoor(19313, buttonid,
		285.98541, 1822.31140, 20.09470, 0.00000, 0.00000, 270.00000,
		285.98541, 1834.31140, 20.09470, 0.00000, 0.00000, 270.00000,
		.maxButtons = 1, .moveSound = 6000, .stopSound = 6002, .closeDelay = -1);

	// Main Blast Doors
	buttonid[0] = CreateButton(210.3842, 1876.6578, 13.1406, "Press to activate door");
	buttonid[1] = CreateButton(209.5598, 1874.3828, 13.1469, "Press to activate door");
	door_BlastDoor1 = CreateDoor(2927, buttonid,
		215.9915, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		219.8936, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		.moveSound = 6000, .stopSound = 6002, .moveSpeed = 0.4, .closeDelay = -1);
	door_BlastDoor2 = CreateDoor(2929, buttonid,
		211.8555, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		207.8556, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		.moveSound = 6000, .stopSound = 6002, .moveSpeed = 0.4, .closeDelay = -1);

	// First door - to storage room
	buttonid[0] = CreateButton(237.4928, 1871.3110, 11.4609, "Press to activate door");
	buttonid[1] = CreateButton(239.3345, 1870.4381, 11.4609, "Press to activate door");
	door_Storage = CreateDoor(5422, buttonid,
		238.4573, 1872.2921, 12.4737, 0.0, 0.0, 0.0,
		238.4573, 1872.2921, 14.6002, 0.0, 0.0, 0.0,
		.moveSound = 6000, .stopSound = 6002, .closeDelay = -1);

	// Storage room to generator room
	buttonid[0] = CreateButton(247.3196, 1842.8588, 8.7614, "Press to activate door");
	buttonid[1] = CreateButton(247.3196, 1840.5961, 8.7578, "Press to activate door");
	door_Generator = CreateDoor(5422, buttonid,
		248.275406, 1842.032104, 9.7770, 0.0, 0.0, 90.0,
		248.270325, 1842.033691, 11.9806, 0.0, 0.0, 90.0,
		.moveSound = 6000, .stopSound = 6002, .closeDelay = -1);

	// Big doors in storage room leading to passage
	buttonid[0] = CreateButton(255.3204, 1842.7847, 8.7578, "Press to activate door");
	buttonid[1] = CreateButton(257.0612, 1843.4278, 8.7578, "Press to activate door");
	door_PassageTop = CreateDoor(9093, buttonid,
		256.3291, 1845.7827, 9.5281, 0.0, 0.0, 0.0,
		256.3291, 1845.7827, 12.1, 0.0, 0.0, 0.0,
		.moveSound = 6000, .stopSound = 6002, .closeDelay = -1);

	// Big doors in generator room leading to passage
	buttonid[0] = CreateButton(255.5610, 1832.4649, 4.7109, "Press to activate door");
	buttonid[1] = CreateButton(257.0517, 1833.1218, 4.7109, "Press to activate door");
	door_PassageBottom = CreateDoor(9093, buttonid,
		256.3094, 1835.3549, 5.4820, 0.0, 0.0, 0.0,
		256.3094, 1835.3549, 8.0035, 0.0, 0.0, 0.0,
		.moveSound = 6000, .stopSound = 6002, .closeDelay = -1);

	// Generator room leading to walkway
	buttonid[0] = CreateButton(249.3303, 1805.2384, 7.4796, "Press to activate door");
	buttonid[1] = CreateButton(249.0138, 1806.8889, 7.5546, "Press to activate door");
	door_Catwalk = CreateDoor(5422, buttonid,
		248.3001, 1805.8772, 8.5633, 0.0, 0.0, 90.0,
		248.3001, 1805.8772, 10.8075, 0.0, 0.0, 90.0,
		.moveSound = 6000, .stopSound = 6002, .closeDelay = -1);

	// Headquaters room
	buttonid[0] = CreateButton(234.1869, 1821.3165, 7.4141, "Press to activate door");
	buttonid[1] = CreateButton(228.3555, 1820.2427, 7.4141, "Press to activate door");
	door_Headquarters1 = CreateDoor(1508, buttonid,
		233.793884, 1825.885498, 7.097370, 0.0, 0.0, 0.0,
		233.793884, 1827.063477, 7.097370, 0.0, 0.0, 0.0,
		.moveSound = 6000, .stopSound = 6002, .closeDelay = -1);
	door_Headquarters2 = CreateDoor(1508, buttonid,
		233.793884, 1819.572388, 7.097370, 0.0, 0.0, 0.0,
		233.793884, 1818.413452, 7.097370, 0.0, 0.0, 0.0,
		.moveSound = 6000, .stopSound = 6002, .closeDelay = -1);

	// Labs to Shaft
	buttonid[0] = CreateButton(269.4969, 1873.1721, 8.6094, "Press to activate door");
	buttonid[1] = CreateButton(270.6281, 1875.8774, 8.4375, "Press to activate door");
	door_Shaft = CreateDoor(5422, buttonid,
		268.0739, 1875.3544, 9.6097, 0.0, 0.0, 90.0,
		268.0739, 1875.3544, 11.6097, 0.0, 0.0, 90.0,
		.moveSound = 6000, .stopSound = 6002, .closeDelay = -1);


	buttonid[0] = CreateButton(279.1897, 1833.1392, 18.0874, "Press to enter", .label = 1);
	buttonid[1] = CreateButton(279.2243, 1832.3821, 2.7813, "Press to enter", .label = 1);
	// TODO: Rewrite this function!
	// LinkTP(buttonid[0], buttonid[1]);

	// Gatehouse

	CreateDynamicObject(19357, 276.24899, 1828.42322, 3.32440,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19357, 276.25061, 1831.20764, 3.32440,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19357, 277.94299, 1832.67493, 3.32440,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19357, 280.55209, 1832.67346, 3.32440,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19357, 282.01669, 1831.15625, 3.32440,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19357, 282.01620, 1828.37256, 3.32440,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19357, 280.50211, 1826.90527, 3.32440,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19357, 277.71649, 1826.90625, 3.32440,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 278.08920, 1831.00085, 1.63700,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 280.17731, 1831.00122, 1.63500,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 280.18079, 1828.59717, 1.63300,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 278.08710, 1828.59924, 1.63100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 278.08920, 1831.00085, 5.10790,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 280.17731, 1831.00122, 5.10590,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 280.18079, 1828.59717, 5.10390,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 278.08710, 1828.59924, 5.10190,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(2924, 278.50809, 1832.64355, 2.91050,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2008, 281.29547, 1828.57593, 1.72020,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1806, 280.78928, 1827.51904, 1.72025,   0.00000, 0.00000, -77.34000);
	CreateDynamicObject(1810, 276.82968, 1828.57532, 1.72273,   0.00000, 0.00000, -216.29999);
	CreateDynamicObject(957, 279.11783, 1829.81799, 4.98342,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2197, 281.47403, 1831.01660, 1.72283,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2370, 276.80917, 1829.70593, 1.69380,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1810, 278.31662, 1830.44849, 1.72273,   0.00000, 0.00000, -57.71994);
	CreateDynamicObject(1810, 277.30359, 1831.40881, 1.72270,   0.00000, 90.00000, 52.50009);
	CreateDynamicObject(2601, 277.36951, 1829.54724, 2.64652,   0.00000, 0.00000, 100.92001);
	CreateDynamicObject(2601, 276.57266, 1830.59314, 2.62448,   0.00000, 0.00000, -106.98005);
	CreateDynamicObject(2601, 277.76572, 1829.62732, 2.62449,   0.00000, 0.00000, -134.76004);

	// Misc

	CreateDynamicObject(2922, 96.66000, 1918.65002, 18.96000,   0.00000, 0.00000, -270.00000);
	CreateDynamicObject(2922, 96.69000, 1918.67004, 18.96000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2922, 209.78000, 1876.57996, 13.60000,   0.00000, 0.00000, -82.38000);
	CreateDynamicObject(2922, 209.52000, 1874.75000, 13.60000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2922, 226.31000, 1870.93994, 13.93000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2922, 227.98000, 1870.95996, 13.93000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2922, 237.75000, 1870.95996, 11.72000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2922, 238.59000, 1870.94995, 11.72000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2922, 247.19000, 1842.17004, 9.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2922, 249.24001, 1806.54004, 8.09000,   0.00000, 0.00000, 56.25000);
	CreateDynamicObject(2922, 249.31000, 1805.63000, 8.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2922, 233.84000, 1821.00000, 7.92000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2922, 229.03000, 1820.43005, 7.71000,   0.00000, 0.00000, 74.45000);
	CreateDynamicObject(2922, 229.03000, 1820.43005, 7.71000,   0.00000, 0.00000, 74.45000);
	CreateDynamicObject(2922, 270.16000, 1873.71997, 9.42000,   0.00000, 0.00000, 89.14000);
	CreateDynamicObject(2922, 270.94000, 1875.48999, 9.39000,   0.00000, 0.00000, -0.86000);
	CreateDynamicObject(2921, 274.54001, 1883.45996, -23.61000,   0.00000, 0.00000, 56.25000);
	CreateDynamicObject(2921, 201.03999, 1857.65002, 14.75000,   0.00000, 0.00000, 236.25000);
	CreateDynamicObject(2951, 196.96001, 1872.62000, 12.05000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2951, 196.96001, 1866.31995, 12.05000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2950, 199.80000, 1869.05005, 14.84000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2950, 199.80000, 1865.62000, 14.84000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2951, 197.25000, 1865.80005, 11.99000,   89.94000, 0.00000, -180.00000);
	CreateDynamicObject(2951, 197.22000, 1873.26001, 11.99000,   89.94000, 0.00000, 0.00000);
	CreateDynamicObject(2929, 199.50999, 1871.58997, 13.69000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2929, 199.50999, 1867.48999, 13.69000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2951, 191.33000, 1866.31995, 12.05000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2951, 191.42999, 1872.62000, 12.05000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2951, 191.59000, 1873.26001, 11.99000,   89.94000, 0.00000, 0.00000);
	CreateDynamicObject(2951, 191.62000, 1865.80005, 11.99000,   89.94000, 0.00000, -180.00000);
	CreateDynamicObject(2977, 271.39999, 1854.81995, 7.76000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2978, 271.39001, 1854.82996, 7.76000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2953, 268.39001, 1857.85999, 8.82000,   0.00000, 0.00000, -67.50000);
	CreateDynamicObject(2976, 268.95999, 1857.16003, 8.81000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3017, 268.48001, 1858.72998, 8.81400,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1225, 206.03000, 1920.44995, 17.05000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 210.86000, 1921.44995, 17.05000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 208.35001, 1921.63000, 17.05000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 205.69000, 1921.66003, 17.05000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 206.99001, 1921.60999, 17.05000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 207.56000, 1920.50000, 17.05000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 233.82001, 1936.27002, 24.90000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 232.78999, 1936.12000, 24.90000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 233.47000, 1935.46997, 24.90000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 201.75999, 1875.64001, 12.55000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 202.45000, 1874.08997, 12.55000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 201.86000, 1873.10999, 12.55000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 225.25999, 1859.45996, 12.55000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 224.89999, 1860.69995, 12.55000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 225.50000, 1861.26001, 12.55000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 225.67000, 1860.23999, 12.55000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(1225, 225.72000, 1858.15002, 12.55000,   0.00000, 0.00000, -303.75000);
	CreateDynamicObject(3633, 282.70999, 1884.28003, 17.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(12913, 161.80000, 1834.71997, 19.27000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(10814, 110.21000, 1840.02002, 20.75000,   0.00000, 0.00000, -270.00000);
	CreateDynamicObject(1618, 226.31000, 1866.18994, 15.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1618, 220.64999, 1873.81006, 14.95000,   0.00000, 0.00000, -270.00000);
	CreateDynamicObject(1687, 206.66000, 1860.55005, 12.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1689, 265.04001, 1856.94995, 17.85000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2978, -4.62000, 1882.25000, 16.52000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2978, -4.62000, 1882.25000, 16.53000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3092, -2.15000, 1881.30005, 16.73000,   -99.69000, 109.15000, 0.00000);
	CreateDynamicObject(3082, -0.95000, 1882.03003, 16.75000,   91.96000, 0.00000, 0.00000);
	CreateDynamicObject(3066, 16.97000, 1836.31995, 17.69000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3048, -9.50000, 1878.76001, 16.45000,   -1.72000, 3.44000, 56.25000);
	CreateDynamicObject(3044, -2.37000, 1882.20996, 16.68000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3044, -2.37000, 1882.20996, 16.68000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16682, 268.82999, 1901.02002, -11.71000,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(16681, 268.47000, 1902.25000, -17.28000,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2927, 269.14001, 1893.73999, -12.97000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14407, 264.60999, 1897.25000, -18.11000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(18084, 271.92001, 1894.52002, -13.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18084, 273.97000, 1894.52002, -13.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18084, 273.97000, 1894.52002, -13.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18084, 273.97000, 1894.52002, -13.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16404, -145.12000, 1961.72998, 16.26000,   0.00000, 0.00000, 22.50000);
	CreateDynamicObject(16404, -143.00999, 1956.26001, 16.23000,   0.00000, 0.00000, 202.50000);
	CreateDynamicObject(16637, -140.53000, 1955.39001, 15.72000,   0.00000, 9.45000, 112.50000);
	CreateDynamicObject(16637, -143.32001, 1954.17004, 15.85000,   0.00000, 5.16000, 112.50000);
	CreateDynamicObject(16637, -144.63000, 1963.70996, 15.88000,   0.00000, 5.16000, 292.50000);
	CreateDynamicObject(16637, -146.85001, 1962.96997, 15.89000,   0.00000, 359.14001, 292.50000);
	CreateDynamicObject(16637, -144.11000, 1962.69995, 17.83000,   0.00000, 62.74000, 292.50000);
	CreateDynamicObject(16637, -146.17999, 1961.82996, 17.85000,   0.00000, 62.74000, 292.50000);
	CreateDynamicObject(16637, -143.69000, 1955.27002, 17.75000,   0.00000, 62.74000, 112.50000);
	CreateDynamicObject(16637, -141.07001, 1956.31995, 17.74000,   0.00000, 62.74000, 112.50000);
	CreateDynamicObject(3387, -140.91000, 1956.21997, 14.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3389, -141.14999, 1957.57996, 14.30000,   0.00000, 0.00000, 22.50000);
	CreateDynamicObject(3388, -141.62000, 1958.90002, 14.31000,   0.00000, 0.00000, 11.25000);
	CreateDynamicObject(3390, -143.11000, 1961.55005, 14.33000,   0.00000, 0.00000, 22.50000);
	CreateDynamicObject(16637, -142.41000, 1960.22998, 18.18000,   0.00000, 92.82000, 202.58000);
	CreateDynamicObject(16637, -141.97000, 1959.18005, 18.18000,   0.00000, 92.82000, 202.58000);
	CreateDynamicObject(3791, -146.78999, 1952.51001, 14.88000,   0.00000, 0.00000, 11.25000);
	CreateDynamicObject(1224, -149.42000, 1952.34998, 14.82000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1224, -150.80000, 1953.39001, 14.74000,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(1224, -150.42000, 1952.93005, 16.05000,   0.00000, 0.00000, 56.25000);
	CreateDynamicObject(3864, -152.41000, 1963.52002, 20.34000,   0.00000, 0.00000, 146.25000);
	CreateDynamicObject(3864, -159.53000, 1955.22998, 20.12000,   0.00000, 0.00000, 202.50000);
	CreateDynamicObject(3864, -126.25000, 1881.95996, 22.24000,   0.00000, 0.00000, 315.00000);
	CreateDynamicObject(3864, -138.71001, 1921.10999, 20.78000,   0.00000, 0.00000, 67.50000);
	CreateDynamicObject(3864, -155.00000, 1913.50000, 20.90000,   0.00000, 0.00000, 146.25000);
	CreateDynamicObject(3864, -140.37000, 1874.20996, 22.49000,   0.00000, 0.00000, 258.75000);
	CreateDynamicObject(1225, -151.67000, 1954.58997, 14.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -139.58000, 1953.64001, 14.68000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -150.63000, 1902.31006, 15.56000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -149.62000, 1902.43994, 15.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -150.17000, 1903.56995, 15.45000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -151.64999, 1902.46997, 15.62000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -152.07001, 1903.93005, 15.55000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -151.25000, 1905.09998, 15.43000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -152.92000, 1905.68994, 15.52000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -150.72000, 1900.10999, 15.71000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -129.07001, 1884.79004, 16.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -128.89999, 1885.81006, 16.26000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1225, -130.08000, 1886.26001, 16.22000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(10029, -77.24000, 1908.93005, 5.34000,   0.00000, 0.00000, 191.25000);
	CreateDynamicObject(2922, 247.57001, 1840.60999, 9.21000,   0.00000, 0.00000, -91.32000);
	CreateDynamicObject(2922, 257.01001, 1843.06995, 9.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2922, 255.92000, 1842.78003, 9.21000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2922, 257.04999, 1832.76001, 5.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2922, 255.92000, 1832.43994, 5.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3117, 246.71663, 1861.98657, 20.62875,   90.00000, 0.00000, 398.98010);
	CreateDynamicObject(3095, 268.37225, 1884.12219, 15.74065,   0.00000, 0.00000, 0.00000);
}

hook OnButtonPress(playerid, Button:buttonid)
{
	if(buttonid == btn_ControlTower)
	{
		if(lock_ControlTower)
		{
			ShowKeypad(playerid, k_ControlTower, code_ControlTower);

			if(GetItemType(GetPlayerItem(playerid)) == item_HackDevice)
				HackKeypad(playerid, k_ControlTower, code_ControlTower);
		}
		else
		{
			ShowCodeList1(playerid);
		}
	}

	if(buttonid == btn_StorageWatch)
	{
		if(lock_StorageWatch)
		{
			ShowKeypad(playerid, k_StorageWatch, code_StorageWatch);

			if(GetItemType(GetPlayerItem(playerid)) == item_HackDevice)
				HackKeypad(playerid, k_StorageWatch, code_ControlTower);
		}
		else
		{
			ShowCodeList2(playerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerActivateDoor(playerid, doorid, newstate)
{
	if(doorid == door_Main)
		return PlayerActivateDoorButton(playerid, k_MainGate, code_ControlTower);

	if(doorid == door_Airstrip)
		return PlayerActivateDoorButton(playerid, k_AirstripGate, code_AirstripGate);

	if(doorid == door_BlastDoor1)
		return PlayerActivateDoorButton(playerid, k_BlastDoor, code_BlastDoor);

	if(doorid == door_BlastDoor2)
		return PlayerActivateDoorButton(playerid, k_BlastDoor, code_BlastDoor);

	if(doorid == door_Storage)
		return PlayerActivateDoorButton(playerid, k_Storage, code_Storage);

	if(doorid == door_Generator)
		return PlayerActivateDoorButton(playerid, k_Generator, code_Generator);

	if(doorid == door_PassageTop)
		return PlayerActivateDoorButton(playerid, k_PassageTop, code_PassageTop);

	if(doorid == door_PassageBottom)
		return PlayerActivateDoorButton(playerid, k_PassageBottom, code_PassageBottom);

	if(doorid == door_Catwalk)
		return PlayerActivateDoorButton(playerid, k_Catwalk, code_Catwalk);

	if(doorid == door_Headquarters1)
		return PlayerActivateDoorButton(playerid, k_Headquarters1, code_Headquarters);

	if(doorid == door_Headquarters2)
		return PlayerActivateDoorButton(playerid, k_Headquarters2, code_Headquarters);

	if(doorid == door_Shaft)
		return PlayerActivateDoorButton(playerid, k_Shaft, code_Shaft);


	return Y_HOOKS_CONTINUE_RETURN_0;
}

PlayerActivateDoorButton(playerid, keypad, code)
{
	ShowKeypad(playerid, keypad, code);

	if(GetItemType(GetPlayerItem(playerid)) == item_HackDevice)
		HackKeypad(playerid, keypad, code);

	return Y_HOOKS_BREAK_RETURN_1;
}

hook OnPlayerKeypadEnter(playerid, keypadid, code, match)
{
	new Item:itemid = GetPlayerItem(playerid);

	if(GetItemType(itemid) == item_HackDevice)
		DestroyItem(itemid);

	if(keypadid == k_ControlTower)
	{
		if(code == match)
		{
			lock_ControlTower = 0;
			ShowCodeList1(playerid);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_MainGate)
	{
		if(code == match)
		{
			OpenDoor(door_Main);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_AirstripGate)
	{
		if(code == match)
		{
			OpenDoor(door_Airstrip);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_BlastDoor)
	{
		if(code == match)
		{
			OpenDoor(door_BlastDoor1);
			OpenDoor(door_BlastDoor2);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_Storage)
	{
		if(code == match)
		{
			OpenDoor(door_Storage);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_StorageWatch)
	{
		if(code == match)
		{
			lock_StorageWatch = 0;
			ShowCodeList2(playerid);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_Generator)
	{
		if(code == match)
		{
			OpenDoor(door_Generator);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_PassageTop)
	{
		if(code == match)
		{
			OpenDoor(door_PassageTop);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_PassageBottom)
	{
		if(code == match)
		{
			OpenDoor(door_PassageBottom);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_Catwalk)
	{
		if(code == match)
		{
			OpenDoor(door_Catwalk);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_Headquarters1)
	{
		if(code == match)
		{
			OpenDoor(door_Headquarters1);
			OpenDoor(door_Headquarters2);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_Headquarters2)
	{
		if(code == match)
		{
			OpenDoor(door_Headquarters1);
			OpenDoor(door_Headquarters2);
			HideKeypad(playerid);
		}
	}
	if(keypadid == k_Shaft)
	{
		if(code == match)
		{
			OpenDoor(door_Shaft);
			HideKeypad(playerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

ShowCodeList1(playerid)
{
	new str[268];

	format(str, 268,
		""C_ORANGE"Keycodes for security system. SECTOR 01:\n\n\
		\t"C_WHITE"Control Tower:"C_YELLOW"\t%d\n\
		\t"C_WHITE"Main gate:"C_YELLOW"\t\t%d\n\
		\t"C_WHITE"Airstrip Gate:"C_YELLOW"\t\t%d\n\
		\t"C_WHITE"Blast Door:"C_YELLOW"\t\t%d\n\
		\t"C_WHITE"Inner Door 1:"C_YELLOW"\t\t%d\n\
		\t"C_WHITE"Inner Door 2:"C_YELLOW"\t\t%d",
		code_ControlTower,
		code_MainGate,
		code_AirstripGate,
		code_BlastDoor,
		code_Inner,
		code_Storage);

	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Main Control", str, "Close", "");
}

ShowCodeList2(playerid)
{
	new str[268];

	format(str, 268,
		""C_ORANGE"Keycodes for security system. SECTOR 02:\n\n\
		\t"C_WHITE"Generator:"C_YELLOW"\t\t%d\n\
		\t"C_WHITE"Passage 1:"C_YELLOW"\t\t%d\n\
		\t"C_WHITE"Passage 2:"C_YELLOW"\t\t%d\n\
		\t"C_WHITE"Catwalk:"C_YELLOW"\t\t%d\n\
		\t"C_WHITE"Headquarters:"C_YELLOW"\t\t%d\n\
		\t"C_WHITE"Shaft:"C_YELLOW"\t\t\t%d",
		code_Generator,
		code_PassageTop,
		code_PassageBottom,
		code_Catwalk,
		code_Headquarters,
		code_Shaft);

	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Main Control", str, "Close", "");
}

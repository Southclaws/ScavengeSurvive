/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


Load_BC()
{
	CreateFuelOutlet(603.48438, 1707.23438, 6.17969, 2.0, 130.0, frandom(40));
	CreateFuelOutlet(606.89844, 1702.21875, 6.17969, 2.0, 130.0, frandom(40));
	CreateFuelOutlet(610.25000, 1697.26563, 6.17969, 2.0, 130.0, frandom(40));
	CreateFuelOutlet(613.71875, 1692.26563, 6.17969, 2.0, 130.0, frandom(40));
	CreateFuelOutlet(617.12500, 1687.45313, 6.17969, 2.0, 130.0, frandom(40));
	CreateFuelOutlet(620.53125, 1682.46094, 6.17969, 2.0, 130.0, frandom(40));
	CreateFuelOutlet(624.04688, 1677.60156, 6.17969, 2.0, 130.0, frandom(40));
/*
	new
		buttonid[2];

	buttonid[0]=CreateButton(-101.579933, 1374.613769, 10.4698, "Press F to enter", 0, 0, .label = 1);
	buttonid[1]=CreateButton(-217.913787, 1402.804199, 27.7734, "Press F to exit", 0, 18, .label = 1);
	LinkTP(buttonid[0], buttonid[1]);

	buttonid[0]=CreateButton(-89.3299, 1378.2357, 10.4698, "Press F to enter", 0, 0, .label = 1);
	buttonid[1]=CreateButton(-229.2949, 1401.2293, 27.7656, "Press F to exit", 0, 18, .label = 1);
	LinkTP(buttonid[0], buttonid[1]);
*/

//	CreateTurret(287.0, 2047.0, 17.5, 270.0, .type = 1);
//	CreateTurret(335.0, 1843.0, 17.5, 270.0, .type = 1);
//	CreateTurret(10.0, 1805.0, 17.40, 180.0, .type = 1);

	BC_District_Payasdas();
	BC_District_Verdant();
	BC_District_Area69();
	BC_District_BoneEast();
	BC_District_BigEar();
	BC_District_Probe();
	BC_District_Octane();
	BC_District_Carson();
	BC_District_Hunter();
	BC_District_BoneGen();

	DefineSupplyDropPos("Fort Carson", 7.24142, 959.94550, 18.55249);
	DefineSupplyDropPos("Bone County East", 631.26288, 1587.61060, 6.64180);
	DefineSupplyDropPos("Bone County Canyons", -301.43231, 1877.09180, 41.23884);
	DefineSupplyDropPos("Verdant Meadows", 373.16586, 2511.17383, 15.47215);
}


BC_District_Payasdas()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'BC_District_Payasdas' please wait...");

	CreateStaticLootSpawn(-162.708709, 2764.035888, 61.619419,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-168.285522, 2727.203857, 61.401859,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-203.731369, 2768.484619, 61.414489,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-233.143493, 2807.560058, 61.044498,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-223.076278, 2769.812011, 61.664821,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-227.106353, 2710.550048, 61.970890,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-237.129318, 2667.802734, 62.853168,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-208.540206, 2709.003662, 61.682670,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-156.562393, 2757.083007, 61.641391,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-169.301849, 2707.579345, 61.543369,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-288.177001, 2693.833007, 61.677829,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-275.950531, 2718.287109, 61.634281,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-271.417144, 2693.314208, 61.680278,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-248.806610, 2597.715576, 61.847240,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-273.614624, 2608.187011, 61.841560,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-261.148162, 2780.222167, 61.661090,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-260.884399, 2770.615234, 61.064338,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-272.409545, 2733.763671, 61.513278,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-312.386749, 2730.335937, 61.672260,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-283.993072, 2758.130371, 61.248088,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-280.644531, 2688.977050, 61.678348,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-327.989471, 2666.785644, 62.133331,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-228.150283, 2723.678222, 61.682880,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-249.832748, 2607.897705, 61.847091,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-209.815765, 2724.346923, 61.681121,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-302.710906, 2659.179687, 61.809040,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-318.250671, 2659.071044, 62.855571,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-287.796661, 2672.083984, 61.608058,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-281.290161, 2655.822998, 61.693790,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-257.019378, 2701.185302, 61.516048,		GetLootIndexFromName("world_police"), 20.0);
	CreateStaticLootSpawn(-218.358703, 2718.873779, 65.796173,		GetLootIndexFromName("world_police"), 20.0);
	CreateStaticLootSpawn(-237.108871, 2664.212402, 72.680557,		GetLootIndexFromName("world_survivor"), 10.0);
}
BC_District_Verdant()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'BC_District_Verdant' please wait...");

	CreateStaticLootSpawn(377.433288, 2594.337890, 15.473210,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(413.673675, 2536.922363, 18.147050,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(333.301483, 2411.031982, 15.932689,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(317.414733, 2437.994873, 15.460869,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(343.714630, 2452.511962, 15.697560,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(335.502563, 2588.122070, 16.599290,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(359.815277, 2443.253906, 15.468689,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(264.689086, 2438.466064, 15.463820,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(195.621383, 2440.040771, 15.569600,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(183.712142, 2411.090576, 15.460220,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(132.321807, 2436.524414, 15.459259,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(252.980865, 2407.009765, 15.453200,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(276.013336, 2413.548339, 15.570630,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(239.351226, 2429.862548, 15.787619,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(184.965927, 2614.452636, 15.500800,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(172.821929, 2588.638427, 16.523790,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(147.525558, 2616.916015, 15.454420,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(107.927993, 2586.395751, 15.609470,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(144.097076, 2588.772460, 15.424510,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(213.336227, 2572.491699, 15.294650,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(267.162506, 2586.913574, 15.458689,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(265.649780, 2640.915283, 15.449060,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(301.596221, 2608.199951, 15.728349,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(174.361663, 2645.372802, 15.447669,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(224.016815, 2633.021728, 15.814640,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(239.051315, 2588.242675, 15.460140,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(159.029357, 2408.611572, 16.788700,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(390.299835, 2600.653320, 15.471940,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(382.123107, 2594.098144, 15.473270,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(334.141387, 2549.690185, 15.788629,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(379.127563, 2608.570312, 15.470140,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(421.697753, 2436.841552, 15.491189,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(386.480133, 2472.729003, 15.488229,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(386.624755, 2436.415283, 15.490920,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(423.173767, 2472.744384, 15.487649,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(333.627655, 2534.738037, 15.793889,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(289.942260, 2540.886962, 15.809129,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(128.898010, 2410.936035, 15.460410,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(281.386535, 2535.868164, 15.809490,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(281.035614, 2551.513183, 15.805100,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(325.057800, 2541.703369, 15.795559,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(316.000061, 2539.791748, 15.800450,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(300.391143, 2534.761474, 15.809490,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(299.802062, 2551.362548, 15.804080,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(412.859893, 2542.858154, 27.911420,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(415.271728, 2531.437988, 18.169780,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(428.595092, 2466.588867, 24.125110,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(385.826263, 2601.038085, 15.471960,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(405.649749, 2449.825195, 15.490610,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(380.857299, 2445.670410, 24.118299,		GetLootIndexFromName("world_survivor"), 10.0);

	CreateHackerTrap(7412.60131, 2543.074218, 25.582199,			GetLootIndexFromName("world_military"));
}
BC_District_Area69()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'BC_District_Area69' please wait...");

	CreateStaticLootSpawn(211.756774, 1859.329711, 12.133520,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(222.789550, 1855.840698, 11.984900,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(203.165679, 1863.224121, 12.132530,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(282.037750, 1817.693603, 0.360879,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(203.303207, 1873.450927, 12.133110,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(246.959304, 1876.901489, 7.756219,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(258.814300, 1860.482055, 7.754519,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(259.031188, 1869.543212, 7.755280,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(249.372360, 1871.699829, 7.554029,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(249.724105, 1860.335693, 7.754690,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(249.013397, 1866.425537, 7.554689,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(265.332031, 1853.947143, 7.756140,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(284.797668, 2036.117919, 16.633859,		GetLootIndexFromName("world_police"), 40.0);
	CreateStaticLootSpawn(248.058303, 1790.751464, 4.166090,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(247.804946, 1788.826171, 4.165550,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(247.135955, 1788.972534, 4.165629,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(247.476898, 1790.169311, 4.165959,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(252.626037, 1791.155029, 4.165939,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(252.595413, 1789.963989, 4.165760,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(251.477813, 1791.097778, 4.165989,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(249.187973, 1790.940063, 4.166069,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(250.302703, 1790.965820, 4.166019,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(254.188293, 1787.143676, 4.164579,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(254.933929, 1788.467407, 4.165030,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(252.379196, 1787.479492, 4.164690,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(249.998016, 1787.703369, 4.164760,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(251.339187, 1787.543701, 4.164710,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(253.980957, 1788.848510, 4.165190,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(249.626846, 1789.052368, 4.165510,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(248.470626, 1788.860717, 4.165520,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(250.872894, 1789.167480, 4.165470,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(253.040969, 1788.894653, 4.165259,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(251.706054, 1789.168579, 4.165420,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(254.004135, 1790.169433, 4.165569,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(324.983032, 1834.511230, 4.832769,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(289.901397, 1814.969848, 0.359109,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(317.605102, 1829.395141, 4.835010,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(329.515197, 1855.417358, 6.825709,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(309.195159, 1834.726318, 4.838500,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(299.302703, 1839.891113, 6.822740,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(276.755187, 1840.123901, 6.825210,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(292.811920, 1829.148559, 7.039259,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(298.277557, 1816.844360, 3.705339,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(292.771850, 1833.008056, 7.038119,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(224.645309, 1822.854370, 5.409949,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(255.099899, 1790.889770, 4.165719,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(249.732833, 1779.918090, 4.161520,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(220.335327, 1826.858764, 5.411250,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(297.295928, 1845.003173, 6.723299,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(220.536560, 1818.290649, 5.410709,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(272.238739, 1872.903808, 7.754749,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(249.102676, 1787.627685, 4.164710,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(233.237854, 1934.927490, 24.491230,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(162.388549, 1933.473388, 24.492790,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(268.802307, 1989.967529, 16.627479,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(253.770767, 1776.721557, 4.160820,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(252.898452, 1777.262573, 4.161009,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(247.196517, 1859.092163, 13.080730,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(269.084136, 2011.108154, 16.629150,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(224.403671, 1872.269165, 12.734829,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(103.700347, 1901.312377, 24.486280,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(113.805397, 1814.055419, 24.490510,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(262.035400, 1807.495239, 24.489570,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(269.351257, 1955.406738, 16.625820,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(167.880004, 1850.185302, 24.485120,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(268.052581, 1895.066406, 24.487150,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(273.727447, 1879.394897, -31.398050,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(273.706054, 1887.101196, -31.396299,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(263.613555, 1878.852905, -31.397949,		GetLootIndexFromName("world_military"), 8.0);
	CreateStaticLootSpawn(313.761383, 1855.416137, 6.823629,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(275.550964, 1859.105468, 8.810230,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(269.105133, 1858.099487, 8.810290,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(297.336242, 1823.914916, 6.826139,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(277.973724, 1824.291137, 6.824940,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(285.615692, 1828.997192, 7.038969,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(296.376464, 1840.227905, 6.822539,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(302.703552, 1828.084838, 4.835949,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(329.968231, 1839.570190, 6.823140,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(314.026428, 1839.290283, 6.826019,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(309.335144, 1829.380859, 4.838250,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(324.172485, 1829.173217, 4.836060,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(273.410736, 1889.630615, -30.421230,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(262.802246, 1882.213745, -30.347030,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(215.384201, 1822.808105, 5.410850,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(295.534362, 1814.649291, 3.706389,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(261.293182, 1816.288208, 0.359880,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(263.455413, 1886.542968, -31.396120,		GetLootIndexFromName("world_survivor"), 10.0);

	CreateHackerTrap(250.966644, 1777.734375, 4.161170,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(252.487274, 1785.738159, 4.164050,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(251.883483, 1783.548706, 4.163259,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(252.522598, 1785.029907, 4.163790,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(253.905334, 1785.449951, 4.163949,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(253.226806, 1783.215087, 4.163139,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(251.440322, 1785.401123, 4.163919,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(246.760894, 1787.169311, 4.164539,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(248.001358, 1787.676757, 4.164720,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(247.618255, 1785.863647, 4.164070,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(249.861343, 1785.931396, 4.164100,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(248.888107, 1785.989746, 4.164120,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(254.268676, 1784.390625, 4.163579,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(247.033706, 1784.185424, 4.163459,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(248.984436, 1784.533447, 4.163599,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(246.312789, 1780.512939, 4.162129,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(249.651947, 1777.317626, 4.161009,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(246.838943, 1777.742797, 4.161149,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(251.380920, 1781.127563, 4.162370,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(252.917343, 1781.226562, 4.162409,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(254.308044, 1781.366699, 4.162489,				GetLootIndexFromName("world_military"));
	CreateHackerTrap(249.463699, 1782.034301, 4.162690,				GetLootIndexFromName("world_military"));
}
BC_District_BoneEast()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'BC_District_BoneEast' please wait...");

	CreateStaticLootSpawn(790.219055, 1990.437377, 4.361800,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(701.584167, 1992.585693, 4.535160,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(693.793334, 1965.575927, 4.529550,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(768.644165, 1989.181274, 4.313670,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(780.413391, 1938.017578, 4.467870,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(783.019409, 1949.468505, 4.320300,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(754.628784, 1969.566894, 4.312240,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(644.629943, 1678.698120, 5.985320,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(777.995605, 1871.567016, 3.895370,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(794.932495, 1687.400756, 4.273230,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(788.445922, 1702.668823, 4.271689,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(767.759216, 2006.543457, 5.059020,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(771.091979, 2087.356933, 5.705599,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(766.993774, 2057.097656, 5.697919,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(766.731140, 2042.452636, 5.701660,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(765.246276, 2087.796875, 5.705540,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(766.780578, 2074.275878, 5.690360,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(784.543701, 1953.345214, 4.689839,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(763.453491, 1877.133789, 4.104249,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(665.431518, 1702.237792, 6.183770,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(754.365417, 1956.481079, 4.313670,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(673.237426, 1705.912719, 6.181600,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(807.706420, 1669.841674, 4.276509,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(813.658508, 1673.877075, 4.274240,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(804.169128, 1666.024169, 4.276519,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(798.737548, 1670.248657, 4.276430,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(771.694458, 1868.071411, 7.091889,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(697.375915, 1991.932373, 7.627580,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(768.840637, 1876.517089, 7.086490,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(787.046752, 1681.969116, 7.177010,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(667.891845, 1713.228149, 9.806329,		GetLootIndexFromName("world_survivor"), 10.0);
}
BC_District_BigEar()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'BC_District_BigEar' please wait...");

	CreateStaticLootSpawn(-299.839294, 1577.899414, 74.346000,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-324.601623, 1535.770629, 74.552757,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-285.389465, 1562.626953, 74.350852,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-308.537475, 1538.216308, 74.553390,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-270.813873, 1547.747314, 74.353103,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-346.005767, 1547.739746, 74.556480,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-397.228210, 1509.460449, 74.553459,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-225.502059, 1407.639404, 68.926612,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-340.537261, 1536.767089, 74.560440,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-368.378967, 1508.486083, 74.559776,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-346.804016, 1580.773803, 75.264961,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-360.628326, 1594.172729, 75.795349,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-331.857910, 1594.761474, 75.149459,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-319.940673, 1547.849609, 74.557586,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-334.840820, 1548.047973, 74.556427,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-345.378326, 1608.751831, 74.794219,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-226.494766, 1404.072998, 72.073638,		GetLootIndexFromName("world_survivor"), 10.0);
}
BC_District_Probe()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'BC_District_Probe' please wait...");

	CreateStaticLootSpawn(-226.105682, 1405.623779, 26.767429,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-16.725469, 1385.647094, 8.141059,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-223.680587, 1397.573242, 27.367929,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-226.357452, 1401.491699, 26.768659,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(25.633699, 1363.988037, 8.140810,			GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(9.902290, 1342.286254, 8.147990,			GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-25.699829, 1360.316284, 8.147139,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(0.290670, 1389.991821, 8.138830,			GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-226.976074, 1410.879882, 26.766370,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-87.732368, 1378.449462, 9.266280,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-227.804336, 1396.644775, 27.368450,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-223.525146, 1410.911132, 26.767929,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-26.539789, 1349.489257, 8.149729,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-30.184959, 1369.222900, 8.145730,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(26.189359, 1342.072021, 8.146659,			GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(8.310959, 1377.217285, 8.139530,			GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-101.560493, 1365.855468, 9.260160,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-102.598632, 1374.171020, 9.261280,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-93.175300, 1364.588378, 9.262379,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-219.953491, 1404.425415, 26.767999,		GetLootIndexFromName("world_survivor"), 10.0);
}
BC_District_Octane()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'BC_District_Octane' please wait...");

	CreateStaticLootSpawn(406.390502, 1161.583251, 6.903639,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(502.410369, 1119.108764, 13.740139,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(711.367980, 1204.533447, 12.385020,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(317.622833, 1155.077880, 7.582119,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(303.804077, 1138.420288, 7.578979,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(398.134613, 1158.175659, 7.343679,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(419.038360, 1414.852050, 7.543509,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(534.092712, 1474.308105, 4.565539,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(433.595092, 1570.021606, 11.759650,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(404.414794, 1466.857788, 7.161159,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(627.937866, 1357.235717, 12.163160,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(562.631225, 1311.023071, 10.236080,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(602.667480, 1501.857055, 8.021780,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(578.049804, 1427.667480, 11.301899,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(417.753784, 1166.663574, 6.881309,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(258.689056, 1383.936523, 9.549200,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(577.598388, 1222.436157, 10.707090,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(512.728454, 1116.753784, 13.983510,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(712.143127, 1193.937011, 12.385560,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(640.637512, 1238.122558, 10.682990,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(634.523193, 1250.863647, 10.669329,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(571.136840, 1217.445922, 10.820360,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(258.719604, 1358.765380, 9.546999,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(215.507736, 1373.093750, 9.563980,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(150.130493, 1356.327148, 9.525540,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(259.074829, 1433.159912, 9.547089,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(259.364624, 1459.235595, 9.549960,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(150.800659, 1431.161254, 9.551639,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(184.493652, 1465.885253, 9.556730,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(151.101119, 1395.591064, 9.540240,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(217.861404, 1444.793945, 9.551670,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(354.287384, 1304.203613, 12.342359,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(312.878173, 1147.319091, 7.583069,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(489.798919, 1309.195190, 9.054280,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(434.902099, 1270.613403, 9.015930,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(192.338745, 1393.987670, 9.565739,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(220.406066, 1423.235229, 9.563639,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(258.495056, 1409.092651, 9.465370,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(229.030288, 1404.713500, 9.575699,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(246.486312, 1410.604736, 22.373430,		GetLootIndexFromName("world_survivor"), 15.0);
	CreateStaticLootSpawn(246.559066, 1435.287719, 22.373479,		GetLootIndexFromName("world_survivor"), 15.0);
	CreateStaticLootSpawn(246.607559, 1360.743041, 22.371690,		GetLootIndexFromName("world_survivor"), 15.0);
	CreateStaticLootSpawn(246.618774, 1385.139282, 22.371110,		GetLootIndexFromName("world_survivor"), 15.0);
	CreateStaticLootSpawn(542.179809, 1557.241333, -0.013129,		GetLootIndexFromName("world_survivor"), 15.0);
	CreateStaticLootSpawn(112.207893, 1479.111450, 9.552849,		GetLootIndexFromName("world_survivor"), 15.0);
	CreateStaticLootSpawn(113.102928, 1339.979125, 9.567819,		GetLootIndexFromName("world_survivor"), 15.0);
	CreateStaticLootSpawn(614.924499, 1549.649902, 3.934360,		GetLootIndexFromName("world_survivor"), 15.0);
	CreateStaticLootSpawn(596.327392, 1250.829101, 27.739919,		GetLootIndexFromName("world_survivor"), 15.0);
	CreateStaticLootSpawn(596.116455, 1255.403808, 27.729589,		GetLootIndexFromName("world_survivor"), 15.0);
	CreateStaticLootSpawn(713.606140, 1596.020996, 3.042929,		GetLootIndexFromName("world_survivor"), 15.0);
}
BC_District_Carson()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'BC_District_Carson' please wait...");

	CreateItem(item_Workbench, 318.60028, 1145.81543, 7.54844, 0.0, 0.0, -181.56007);

	CreateStaticLootSpawn(-204.049407, 1052.944702, 18.736200,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-203.905685, 1061.835571, 18.736690,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(65.135223, 1163.147705, 17.655750,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(89.157058, 1168.156738, 21.825420,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(77.920936, 1162.654052, 17.656190,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-205.839736, 1088.196533, 18.735580,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-33.426929, 1113.334106, 19.217029,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-23.135469, 1114.517822, 18.714950,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-204.570755, 1144.440917, 18.735729,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-204.341598, 1119.357055, 18.736669,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-204.417831, 1138.453735, 18.735839,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(97.640556, 1180.266357, 17.651760,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-69.601142, 1211.764282, 21.438690,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-69.604797, 1225.859130, 18.641120,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-78.062438, 1228.821655, 21.436689,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-102.062942, 1234.083251, 21.438310,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-102.978973, 1234.224121, 18.737890,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-89.887222, 1228.272216, 18.730970,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-18.946399, 1178.588256, 18.555719,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-53.866489, 1189.645751, 18.358779,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(12.006520, 1211.052124, 18.340040,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-26.889520, 1213.639648, 18.355289,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(11.449620, 1218.927490, 18.342010,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-100.277313, 1120.716064, 18.734220,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-108.015319, 1138.215698, 18.735540,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-182.437820, 1063.553466, 18.737749,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-181.196105, 1132.080932, 18.736949,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-180.773727, 1088.333862, 18.736370,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-182.449951, 1034.459472, 18.737150,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-127.090858, 1189.898071, 18.732749,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-145.579528, 1175.053344, 18.732410,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-91.836112, 1189.939208, 18.730779,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-178.120391, 1110.414672, 18.737089,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-148.918701, 1079.832031, 18.733770,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-182.115127, 1163.408935, 18.735740,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-203.433456, 1171.875244, 18.737239,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-203.784667, 1183.302856, 18.736360,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-205.025650, 1153.021972, 18.736299,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(4.809790, 1113.626953, 19.228820,			GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(0.807669, 1079.924560, 18.718629,			GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-28.619119, 1045.020874, 19.206310,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-180.198440, 1177.948364, 18.884870,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-98.874778, 1083.860595, 18.735500,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-181.848449, 1186.428955, 18.736129,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-48.205039, 1082.596313, 19.221139,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(110.137466, 1104.607421, 12.607029,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-145.277206, 930.899841, 18.553699,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-271.326690, 1003.717224, 19.226549,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-330.382324, 1120.523559, 19.937059,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-326.474639, 1163.808837, 19.935609,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-297.659149, 1115.140991, 19.932609,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-255.780654, 994.320678, 19.223880,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-226.435653, 984.888610, 18.588209,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-218.836486, 973.875366, 18.481670,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-126.752647, 860.225952, 17.085060,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-149.582260, 911.813598, 18.076040,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-147.509963, 887.833312, 17.626550,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-11.705389, 975.067016, 18.791820,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-43.136520, 962.950988, 18.764270,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(32.274921, 923.794372, 22.592670,			GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(64.988723, 1006.645141, 12.660110,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(17.394319, 909.714538, 22.909460,			GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-371.365478, 1106.607421, 18.734670,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-53.325649, 898.172790, 20.953329,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-368.887115, 1168.644287, 19.267549,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-60.703941, 972.405883, 18.803110,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-362.300109, 1110.604492, 19.930160,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-360.320556, 1140.386962, 19.936639,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-187.405075, 1209.844604, 18.694589,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-144.232223, 1222.746459, 18.894910,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-206.270645, 1212.087158, 18.885250,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-251.117218, 1142.984985, 19.224229,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-257.320739, 1177.969482, 19.011709,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-260.443817, 1165.581176, 19.225410,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-94.863327, 887.967346, 19.857339,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-259.863952, 1040.428466, 19.231460,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-125.978393, 970.968261, 18.862970,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-260.471191, 1127.795410, 19.232900,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-262.546875, 1073.498535, 19.232749,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-218.834335, 1136.086914, 18.732580,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-0.697420, 952.045654, 18.593759,			GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(24.824829, 969.502014, 18.737670,			GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(16.687189, 949.826232, 18.920339,			GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-211.172851, 1038.739501, 18.731260,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-168.528472, 1031.273071, 18.728790,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-211.712173, 1075.494384, 18.732019,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-142.434143, 1163.397094, 18.731529,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-122.636718, 1076.776977, 18.779270,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-139.123672, 1070.201904, 18.731649,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-165.130218, 1059.386474, 18.729990,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-130.765762, 878.851257, 17.710119,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-219.544250, 1031.890380, 18.736179,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-117.765167, 923.193176, 19.406930,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-225.387664, 1076.661254, 18.735109,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-217.193954, 1064.911376, 18.734859,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-217.221298, 1047.601440, 18.735940,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-79.309776, 936.247497, 19.514970,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-210.878646, 1176.967163, 18.732700,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-219.442825, 1172.644531, 18.733280,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-219.053237, 1149.256713, 18.732599,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-54.212238, 937.348510, 19.787269,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-51.115051, 920.814514, 20.911560,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-210.234924, 1159.062988, 18.732440,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(50.004970, 1222.297241, 17.929319,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(59.683120, 1217.600830, 17.845819,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-27.102190, 1164.611083, 18.369670,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-90.538032, 1123.737915, 18.734439,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-100.857643, 1075.194580, 18.735830,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(111.702293, 1113.239501, 12.609279,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-208.867355, 1221.032958, 18.885169,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-190.538574, 1219.323852, 18.733329,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-307.551849, 1039.625732, 18.718660,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-43.765048, 1177.711059, 18.426610,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-87.487213, 1236.745849, 18.734260,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-146.486312, 1238.239379, 18.641139,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-147.856750, 1134.229614, 18.732509,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-116.913070, 1134.292114, 18.732559,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-136.848464, 1116.640991, 19.190359,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-176.555877, 1126.560546, 18.730749,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-167.246536, 1170.509887, 18.734029,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-94.656997, 1164.000244, 18.725570,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-158.315338, 1122.975830, 18.736209,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-113.623260, 1126.732421, 18.739110,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-77.892303, 1110.508544, 18.734510,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-77.442260, 1136.508666, 18.735149,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-217.332962, 979.176147, 18.501010,		GetLootIndexFromName("world_police"), 20.0);
	CreateStaticLootSpawn(-331.796661, 1058.507934, 18.850950,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(-314.688903, 1050.707153, 19.335269,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(-332.046203, 1049.622558, 18.850439,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(-325.865997, 1050.232543, 19.335189,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(-338.081787, 1049.800781, 18.851850,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(-318.559417, 1049.322265, 19.334999,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(-321.981170, 1049.464843, 19.335149,		GetLootIndexFromName("world_medical"), 20.0);
	CreateStaticLootSpawn(-208.205947, 1085.446166, 26.486820,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-177.174240, 1111.713867, 29.049179,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-227.681381, 976.515258, 21.278089,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-216.774002, 978.982971, 21.938270,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-176.402938, 1084.354736, 25.103900,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(71.329132, 1217.019165, 22.197910,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(110.565567, 1019.749145, 12.603650,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-215.235107, 1119.215820, 34.648849,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(53.950950, 1217.278808, 22.652080,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-52.753311, 1185.876586, 23.080619,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-315.828460, 1134.307739, 18.729959,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-306.247711, 1163.030151, 18.635370,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-374.772430, 1128.111694, 18.664449,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-360.997985, 1198.928222, 18.738489,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-339.770843, 1176.718627, 18.722009,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-305.888977, 1118.847412, 18.727710,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-0.394650, 1126.914672, 18.661199,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-26.157819, 1119.407714, 18.716949,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-50.896221, 1128.907226, 18.713079,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-46.246780, 1051.903808, 18.663030,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-29.474679, 1069.872314, 18.716640,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(6.758530, 1083.380981, 18.719419,			GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-246.328918, 1185.205078, 18.721729,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-245.698181, 1059.426513, 18.726419,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-239.647338, 997.336547, 18.724409,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-264.953338, 990.264404, 18.676839,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-255.290832, 1159.561767, 18.724609,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-245.331588, 1133.955078, 18.640810,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-245.723236, 1068.867797, 18.658399,		GetLootIndexFromName("world_industrial"), 20.0);

}
BC_District_Hunter()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'BC_District_Hunter' please wait...");

	CreateItem(item_Workbench, 585.17377, 873.72583, -43.51944, 0.0, 0.0, 94.26003);

	CreateStaticLootSpawn(627.578979, 894.678649, -42.107200,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(578.331787, 829.218872, -30.850990,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(591.060485, 878.450073, -43.504810,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(591.337158, 868.772277, -43.502510,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(680.804504, 845.106262, -43.965888,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(823.437805, 857.840393, 11.054739,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(815.093627, 864.144470, 11.071479,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(670.060974, 825.733825, -43.965450,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(712.892639, 909.567138, -19.662990,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(586.737182, 877.752929, -43.505859,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(490.787933, 789.598449, -23.100080,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(323.204498, 856.567504, 19.398349,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(320.458709, 874.007995, 19.398880,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(562.789123, 823.181823, -23.132949,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(677.806396, 901.917602, -41.251388,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(587.467285, 868.175354, -43.503448,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(691.817749, 893.956848, -40.211181,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(568.314575, 824.260559, -23.132759,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(495.127593, 785.502502, -23.075759,		GetLootIndexFromName("world_survivor"), 10.0);
}
BC_District_BoneGen()
{
	ChatMsgAll(YELLOW, " >  Loading world region: 'BC_District_BoneGen' please wait...");

	CreateItem(item_Workbench, -371.56595, 2235.98975, 41.43906, 0.0, 0.0, 12.84000);

	CreateStaticLootSpawn(-583.062133, 2713.019042, 70.823257,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-13.895059, 2345.650634, 23.131660,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-551.655273, 2592.609619, 52.930320,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-36.337589, 2347.065673, 23.131919,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-674.146789, 2706.751953, 69.659271,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-736.013122, 2746.930664, 46.221889,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-605.083496, 2716.697753, 71.720092,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-625.312194, 2714.389404, 71.365707,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-546.354675, 2616.551513, 52.496181,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-377.800720, 2242.189941, 41.603599,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-798.536193, 2259.297363, 57.972450,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-385.928405, 2217.766845, 41.425331,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-364.538177, 2222.307128, 41.498550,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-309.805694, 1762.794311, 42.633949,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-545.437561, 2571.026367, 52.499248,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-332.086578, 2224.452880, 41.509391,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-323.462036, 1851.641235, 41.496849,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-760.894653, 2762.958007, 44.760108,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-787.384887, 2753.500244, 44.650768,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-789.328125, 2757.031494, 44.847740,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-776.944213, 2762.333984, 44.726848,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-828.882751, 2754.932617, 44.820899,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-812.847961, 2763.490966, 44.816181,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-844.227722, 2744.323242, 44.810180,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-866.749145, 2750.536621, 44.983020,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-881.115051, 2757.923828, 45.062850,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-314.933471, 830.342224, 13.237990,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-852.365478, 2760.675537, 44.981529,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-789.359924, 2764.553955, 47.252590,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-760.082702, 2764.932617, 47.251491,		GetLootIndexFromName("world_civilian"), 20.0);
	CreateStaticLootSpawn(-418.083282, 2222.179199, 41.419910,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-429.900817, 2252.611572, 41.424148,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-350.724853, 2239.731201, 41.508750,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-363.913879, 2263.687011, 41.477569,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-451.246734, 2229.808105, 41.423179,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-320.205413, 842.688110, 13.235569,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-329.155883, 825.614379, 13.236049,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-13.420499, 2350.712646, 23.130630,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-27.980180, 2356.891601, 23.132839,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-309.929168, 1770.002929, 42.632080,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-489.220642, 614.169372, 0.774900,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-305.987030, 1780.561645, 41.780170,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-316.828247, 1799.826782, 42.635169,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-551.967468, 2595.404296, 52.930328,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-766.490539, 2773.825683, 44.759788,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-662.617309, 2305.950195, 135.073318,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-595.948486, 2720.095703, 71.365837,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-741.514770, 2751.244873, 46.308731,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-792.932678, 2770.867187, 44.701049,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-729.619506, 2747.050781, 46.222488,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-480.463439, 2180.354736, 40.856418,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-802.773193, 2260.641357, 57.657630,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-845.069763, 2752.810791, 44.824779,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-793.376525, 2257.507080, 58.195529,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-395.922515, 2214.293701, 41.416900,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-806.412780, 2239.297607, 40.838630,		GetLootIndexFromName("world_industrial"), 20.0);
	CreateStaticLootSpawn(-329.620483, 835.750122, 13.237870,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-319.849517, 839.114746, 16.536439,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-462.673278, 635.911315, 13.051130,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-454.851623, 614.706909, 15.737050,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-792.759948, 2765.642822, 49.801288,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-331.133422, 818.287841, 13.427390,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-323.574249, 818.120971, 13.420280,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-317.767333, 815.742370, 13.514579,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-662.589660, 2313.452392, 141.931838,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-810.595886, 2429.505859, 155.963317,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-772.308166, 2423.595703, 156.082061,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-793.702453, 2265.871337, 58.064628,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-417.360626, 2246.704833, 41.425289,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-465.200988, 2187.044921, 45.706848,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-10.564240, 2329.213378, 23.302949,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-18.395889, 2322.289550, 23.302610,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-27.389709, 2320.724609, 23.302759,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-417.139739, 1356.921264, 11.771269,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-555.274108, 2580.320312, 64.810043,		GetLootIndexFromName("world_survivor"), 10.0);
	CreateStaticLootSpawn(-9.954810, 2336.925292, 23.302459,		GetLootIndexFromName("world_survivor"), 10.0);

}

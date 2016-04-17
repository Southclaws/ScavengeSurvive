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


Load_BC()
{
	print("\n[OnGameModeInit] Initialising 'World/BC'...");

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
	MsgAll(YELLOW, " >  Loading world region: 'BC_District_Payasdas' please wait...");

	CreateStaticLootSpawn(-162.708709, 2764.035888, 61.619419,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-168.285522, 2727.203857, 61.401859,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-203.731369, 2768.484619, 61.414489,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-233.143493, 2807.560058, 61.044498,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-223.076278, 2769.812011, 61.664821,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-227.106353, 2710.550048, 61.970890,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-237.129318, 2667.802734, 62.853168,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-208.540206, 2709.003662, 61.682670,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-156.562393, 2757.083007, 61.641391,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-169.301849, 2707.579345, 61.543369,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-288.177001, 2693.833007, 61.677829,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-275.950531, 2718.287109, 61.634281,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-271.417144, 2693.314208, 61.680278,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-248.806610, 2597.715576, 61.847240,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-273.614624, 2608.187011, 61.841560,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-261.148162, 2780.222167, 61.661090,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-260.884399, 2770.615234, 61.064338,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-272.409545, 2733.763671, 61.513278,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-312.386749, 2730.335937, 61.672260,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-283.993072, 2758.130371, 61.248088,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-280.644531, 2688.977050, 61.678348,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-327.989471, 2666.785644, 62.133331,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-228.150283, 2723.678222, 61.682880,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-249.832748, 2607.897705, 61.847091,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-209.815765, 2724.346923, 61.681121,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-302.710906, 2659.179687, 61.809040,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-318.250671, 2659.071044, 62.855571,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-287.796661, 2672.083984, 61.608058,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-281.290161, 2655.822998, 61.693790,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-257.019378, 2701.185302, 61.516048,		loot_Police, 20.0);
	CreateStaticLootSpawn(-218.358703, 2718.873779, 65.796173,		loot_Police, 20.0);
	CreateStaticLootSpawn(-237.108871, 2664.212402, 72.680557,		loot_Survivor, 10.0);
}
BC_District_Verdant()
{
	MsgAll(YELLOW, " >  Loading world region: 'BC_District_Verdant' please wait...");

	CreateStaticLootSpawn(377.433288, 2594.337890, 15.473210,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(413.673675, 2536.922363, 18.147050,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(333.301483, 2411.031982, 15.932689,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(317.414733, 2437.994873, 15.460869,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(343.714630, 2452.511962, 15.697560,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(335.502563, 2588.122070, 16.599290,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(359.815277, 2443.253906, 15.468689,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(264.689086, 2438.466064, 15.463820,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(195.621383, 2440.040771, 15.569600,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(183.712142, 2411.090576, 15.460220,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(132.321807, 2436.524414, 15.459259,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(252.980865, 2407.009765, 15.453200,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(276.013336, 2413.548339, 15.570630,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(239.351226, 2429.862548, 15.787619,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(184.965927, 2614.452636, 15.500800,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(172.821929, 2588.638427, 16.523790,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(147.525558, 2616.916015, 15.454420,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(107.927993, 2586.395751, 15.609470,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(144.097076, 2588.772460, 15.424510,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(213.336227, 2572.491699, 15.294650,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(267.162506, 2586.913574, 15.458689,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(265.649780, 2640.915283, 15.449060,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(301.596221, 2608.199951, 15.728349,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(174.361663, 2645.372802, 15.447669,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(224.016815, 2633.021728, 15.814640,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(239.051315, 2588.242675, 15.460140,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(159.029357, 2408.611572, 16.788700,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(390.299835, 2600.653320, 15.471940,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(382.123107, 2594.098144, 15.473270,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(334.141387, 2549.690185, 15.788629,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(379.127563, 2608.570312, 15.470140,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(421.697753, 2436.841552, 15.491189,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(386.480133, 2472.729003, 15.488229,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(386.624755, 2436.415283, 15.490920,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(423.173767, 2472.744384, 15.487649,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(333.627655, 2534.738037, 15.793889,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(289.942260, 2540.886962, 15.809129,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(128.898010, 2410.936035, 15.460410,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(281.386535, 2535.868164, 15.809490,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(281.035614, 2551.513183, 15.805100,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(325.057800, 2541.703369, 15.795559,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(316.000061, 2539.791748, 15.800450,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(300.391143, 2534.761474, 15.809490,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(299.802062, 2551.362548, 15.804080,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(412.859893, 2542.858154, 27.911420,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(415.271728, 2531.437988, 18.169780,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(428.595092, 2466.588867, 24.125110,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(385.826263, 2601.038085, 15.471960,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(405.649749, 2449.825195, 15.490610,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(380.857299, 2445.670410, 24.118299,		loot_Survivor, 10.0);

	CreateHackerTrap(7412.60131, 2543.074218, 25.582199,			loot_Military);
}
BC_District_Area69()
{
	MsgAll(YELLOW, " >  Loading world region: 'BC_District_Area69' please wait...");

	CreateStaticLootSpawn(211.756774, 1859.329711, 12.133520,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(222.789550, 1855.840698, 11.984900,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(203.165679, 1863.224121, 12.132530,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(282.037750, 1817.693603, 0.360879,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(203.303207, 1873.450927, 12.133110,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(246.959304, 1876.901489, 7.756219,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(258.814300, 1860.482055, 7.754519,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(259.031188, 1869.543212, 7.755280,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(249.372360, 1871.699829, 7.554029,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(249.724105, 1860.335693, 7.754690,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(249.013397, 1866.425537, 7.554689,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(265.332031, 1853.947143, 7.756140,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(284.797668, 2036.117919, 16.633859,		loot_Police, 40.0);
	CreateStaticLootSpawn(248.058303, 1790.751464, 4.166090,		loot_Military, 8.0);
	CreateStaticLootSpawn(247.804946, 1788.826171, 4.165550,		loot_Military, 8.0);
	CreateStaticLootSpawn(247.135955, 1788.972534, 4.165629,		loot_Military, 8.0);
	CreateStaticLootSpawn(247.476898, 1790.169311, 4.165959,		loot_Military, 8.0);
	CreateStaticLootSpawn(252.626037, 1791.155029, 4.165939,		loot_Military, 8.0);
	CreateStaticLootSpawn(252.595413, 1789.963989, 4.165760,		loot_Military, 8.0);
	CreateStaticLootSpawn(251.477813, 1791.097778, 4.165989,		loot_Military, 8.0);
	CreateStaticLootSpawn(249.187973, 1790.940063, 4.166069,		loot_Military, 8.0);
	CreateStaticLootSpawn(250.302703, 1790.965820, 4.166019,		loot_Military, 8.0);
	CreateStaticLootSpawn(254.188293, 1787.143676, 4.164579,		loot_Military, 8.0);
	CreateStaticLootSpawn(254.933929, 1788.467407, 4.165030,		loot_Military, 8.0);
	CreateStaticLootSpawn(252.379196, 1787.479492, 4.164690,		loot_Military, 8.0);
	CreateStaticLootSpawn(249.998016, 1787.703369, 4.164760,		loot_Military, 8.0);
	CreateStaticLootSpawn(251.339187, 1787.543701, 4.164710,		loot_Military, 8.0);
	CreateStaticLootSpawn(253.980957, 1788.848510, 4.165190,		loot_Military, 8.0);
	CreateStaticLootSpawn(249.626846, 1789.052368, 4.165510,		loot_Military, 8.0);
	CreateStaticLootSpawn(248.470626, 1788.860717, 4.165520,		loot_Military, 8.0);
	CreateStaticLootSpawn(250.872894, 1789.167480, 4.165470,		loot_Military, 8.0);
	CreateStaticLootSpawn(253.040969, 1788.894653, 4.165259,		loot_Military, 8.0);
	CreateStaticLootSpawn(251.706054, 1789.168579, 4.165420,		loot_Military, 8.0);
	CreateStaticLootSpawn(254.004135, 1790.169433, 4.165569,		loot_Military, 8.0);
	CreateStaticLootSpawn(324.983032, 1834.511230, 4.832769,		loot_Military, 8.0);
	CreateStaticLootSpawn(289.901397, 1814.969848, 0.359109,		loot_Military, 8.0);
	CreateStaticLootSpawn(317.605102, 1829.395141, 4.835010,		loot_Military, 8.0);
	CreateStaticLootSpawn(329.515197, 1855.417358, 6.825709,		loot_Military, 8.0);
	CreateStaticLootSpawn(309.195159, 1834.726318, 4.838500,		loot_Military, 8.0);
	CreateStaticLootSpawn(299.302703, 1839.891113, 6.822740,		loot_Military, 8.0);
	CreateStaticLootSpawn(276.755187, 1840.123901, 6.825210,		loot_Military, 8.0);
	CreateStaticLootSpawn(292.811920, 1829.148559, 7.039259,		loot_Military, 8.0);
	CreateStaticLootSpawn(298.277557, 1816.844360, 3.705339,		loot_Military, 8.0);
	CreateStaticLootSpawn(292.771850, 1833.008056, 7.038119,		loot_Military, 8.0);
	CreateStaticLootSpawn(224.645309, 1822.854370, 5.409949,		loot_Military, 8.0);
	CreateStaticLootSpawn(255.099899, 1790.889770, 4.165719,		loot_Military, 8.0);
	CreateStaticLootSpawn(249.732833, 1779.918090, 4.161520,		loot_Military, 8.0);
	CreateStaticLootSpawn(220.335327, 1826.858764, 5.411250,		loot_Military, 8.0);
	CreateStaticLootSpawn(297.295928, 1845.003173, 6.723299,		loot_Military, 8.0);
	CreateStaticLootSpawn(220.536560, 1818.290649, 5.410709,		loot_Military, 8.0);
	CreateStaticLootSpawn(272.238739, 1872.903808, 7.754749,		loot_Military, 8.0);
	CreateStaticLootSpawn(249.102676, 1787.627685, 4.164710,		loot_Military, 8.0);
	CreateStaticLootSpawn(233.237854, 1934.927490, 24.491230,		loot_Military, 8.0);
	CreateStaticLootSpawn(162.388549, 1933.473388, 24.492790,		loot_Military, 8.0);
	CreateStaticLootSpawn(268.802307, 1989.967529, 16.627479,		loot_Military, 8.0);
	CreateStaticLootSpawn(253.770767, 1776.721557, 4.160820,		loot_Military, 8.0);
	CreateStaticLootSpawn(252.898452, 1777.262573, 4.161009,		loot_Military, 8.0);
	CreateStaticLootSpawn(247.196517, 1859.092163, 13.080730,		loot_Military, 8.0);
	CreateStaticLootSpawn(269.084136, 2011.108154, 16.629150,		loot_Military, 8.0);
	CreateStaticLootSpawn(224.403671, 1872.269165, 12.734829,		loot_Military, 8.0);
	CreateStaticLootSpawn(103.700347, 1901.312377, 24.486280,		loot_Military, 8.0);
	CreateStaticLootSpawn(113.805397, 1814.055419, 24.490510,		loot_Military, 8.0);
	CreateStaticLootSpawn(262.035400, 1807.495239, 24.489570,		loot_Military, 8.0);
	CreateStaticLootSpawn(269.351257, 1955.406738, 16.625820,		loot_Military, 8.0);
	CreateStaticLootSpawn(167.880004, 1850.185302, 24.485120,		loot_Military, 8.0);
	CreateStaticLootSpawn(268.052581, 1895.066406, 24.487150,		loot_Military, 8.0);
	CreateStaticLootSpawn(273.727447, 1879.394897, -31.398050,		loot_Military, 8.0);
	CreateStaticLootSpawn(273.706054, 1887.101196, -31.396299,		loot_Military, 8.0);
	CreateStaticLootSpawn(263.613555, 1878.852905, -31.397949,		loot_Military, 8.0);
	CreateStaticLootSpawn(313.761383, 1855.416137, 6.823629,		loot_Medical, 20.0);
	CreateStaticLootSpawn(275.550964, 1859.105468, 8.810230,		loot_Medical, 20.0);
	CreateStaticLootSpawn(269.105133, 1858.099487, 8.810290,		loot_Medical, 20.0);
	CreateStaticLootSpawn(297.336242, 1823.914916, 6.826139,		loot_Medical, 20.0);
	CreateStaticLootSpawn(277.973724, 1824.291137, 6.824940,		loot_Medical, 20.0);
	CreateStaticLootSpawn(285.615692, 1828.997192, 7.038969,		loot_Medical, 20.0);
	CreateStaticLootSpawn(296.376464, 1840.227905, 6.822539,		loot_Medical, 20.0);
	CreateStaticLootSpawn(302.703552, 1828.084838, 4.835949,		loot_Medical, 20.0);
	CreateStaticLootSpawn(329.968231, 1839.570190, 6.823140,		loot_Medical, 20.0);
	CreateStaticLootSpawn(314.026428, 1839.290283, 6.826019,		loot_Medical, 20.0);
	CreateStaticLootSpawn(309.335144, 1829.380859, 4.838250,		loot_Medical, 20.0);
	CreateStaticLootSpawn(324.172485, 1829.173217, 4.836060,		loot_Medical, 20.0);
	CreateStaticLootSpawn(273.410736, 1889.630615, -30.421230,		loot_Medical, 20.0);
	CreateStaticLootSpawn(262.802246, 1882.213745, -30.347030,		loot_Medical, 20.0);
	CreateStaticLootSpawn(215.384201, 1822.808105, 5.410850,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(295.534362, 1814.649291, 3.706389,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(261.293182, 1816.288208, 0.359880,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(263.455413, 1886.542968, -31.396120,		loot_Survivor, 10.0);

	CreateHackerTrap(250.966644, 1777.734375, 4.161170,				loot_Military);
	CreateHackerTrap(252.487274, 1785.738159, 4.164050,				loot_Military);
	CreateHackerTrap(251.883483, 1783.548706, 4.163259,				loot_Military);
	CreateHackerTrap(252.522598, 1785.029907, 4.163790,				loot_Military);
	CreateHackerTrap(253.905334, 1785.449951, 4.163949,				loot_Military);
	CreateHackerTrap(253.226806, 1783.215087, 4.163139,				loot_Military);
	CreateHackerTrap(251.440322, 1785.401123, 4.163919,				loot_Military);
	CreateHackerTrap(246.760894, 1787.169311, 4.164539,				loot_Military);
	CreateHackerTrap(248.001358, 1787.676757, 4.164720,				loot_Military);
	CreateHackerTrap(247.618255, 1785.863647, 4.164070,				loot_Military);
	CreateHackerTrap(249.861343, 1785.931396, 4.164100,				loot_Military);
	CreateHackerTrap(248.888107, 1785.989746, 4.164120,				loot_Military);
	CreateHackerTrap(254.268676, 1784.390625, 4.163579,				loot_Military);
	CreateHackerTrap(247.033706, 1784.185424, 4.163459,				loot_Military);
	CreateHackerTrap(248.984436, 1784.533447, 4.163599,				loot_Military);
	CreateHackerTrap(246.312789, 1780.512939, 4.162129,				loot_Military);
	CreateHackerTrap(249.651947, 1777.317626, 4.161009,				loot_Military);
	CreateHackerTrap(246.838943, 1777.742797, 4.161149,				loot_Military);
	CreateHackerTrap(251.380920, 1781.127563, 4.162370,				loot_Military);
	CreateHackerTrap(252.917343, 1781.226562, 4.162409,				loot_Military);
	CreateHackerTrap(254.308044, 1781.366699, 4.162489,				loot_Military);
	CreateHackerTrap(249.463699, 1782.034301, 4.162690,				loot_Military);
}
BC_District_BoneEast()
{
	MsgAll(YELLOW, " >  Loading world region: 'BC_District_BoneEast' please wait...");

	CreateStaticLootSpawn(790.219055, 1990.437377, 4.361800,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(701.584167, 1992.585693, 4.535160,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(693.793334, 1965.575927, 4.529550,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(768.644165, 1989.181274, 4.313670,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(780.413391, 1938.017578, 4.467870,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(783.019409, 1949.468505, 4.320300,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(754.628784, 1969.566894, 4.312240,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(644.629943, 1678.698120, 5.985320,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(777.995605, 1871.567016, 3.895370,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(794.932495, 1687.400756, 4.273230,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(788.445922, 1702.668823, 4.271689,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(767.759216, 2006.543457, 5.059020,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(771.091979, 2087.356933, 5.705599,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(766.993774, 2057.097656, 5.697919,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(766.731140, 2042.452636, 5.701660,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(765.246276, 2087.796875, 5.705540,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(766.780578, 2074.275878, 5.690360,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(784.543701, 1953.345214, 4.689839,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(763.453491, 1877.133789, 4.104249,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(665.431518, 1702.237792, 6.183770,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(754.365417, 1956.481079, 4.313670,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(673.237426, 1705.912719, 6.181600,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(807.706420, 1669.841674, 4.276509,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(813.658508, 1673.877075, 4.274240,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(804.169128, 1666.024169, 4.276519,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(798.737548, 1670.248657, 4.276430,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(771.694458, 1868.071411, 7.091889,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(697.375915, 1991.932373, 7.627580,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(768.840637, 1876.517089, 7.086490,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(787.046752, 1681.969116, 7.177010,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(667.891845, 1713.228149, 9.806329,		loot_Survivor, 10.0);
}
BC_District_BigEar()
{
	MsgAll(YELLOW, " >  Loading world region: 'BC_District_BigEar' please wait...");

	CreateStaticLootSpawn(-299.839294, 1577.899414, 74.346000,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-324.601623, 1535.770629, 74.552757,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-285.389465, 1562.626953, 74.350852,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-308.537475, 1538.216308, 74.553390,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-270.813873, 1547.747314, 74.353103,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-346.005767, 1547.739746, 74.556480,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-397.228210, 1509.460449, 74.553459,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-225.502059, 1407.639404, 68.926612,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-340.537261, 1536.767089, 74.560440,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-368.378967, 1508.486083, 74.559776,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-346.804016, 1580.773803, 75.264961,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-360.628326, 1594.172729, 75.795349,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-331.857910, 1594.761474, 75.149459,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-319.940673, 1547.849609, 74.557586,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-334.840820, 1548.047973, 74.556427,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-345.378326, 1608.751831, 74.794219,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-226.494766, 1404.072998, 72.073638,		loot_Survivor, 10.0);
}
BC_District_Probe()
{
	MsgAll(YELLOW, " >  Loading world region: 'BC_District_Probe' please wait...");

	CreateStaticLootSpawn(-226.105682, 1405.623779, 26.767429,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-16.725469, 1385.647094, 8.141059,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-223.680587, 1397.573242, 27.367929,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-226.357452, 1401.491699, 26.768659,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(25.633699, 1363.988037, 8.140810,			loot_Civilian, 20.0);
	CreateStaticLootSpawn(9.902290, 1342.286254, 8.147990,			loot_Civilian, 20.0);
	CreateStaticLootSpawn(-25.699829, 1360.316284, 8.147139,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(0.290670, 1389.991821, 8.138830,			loot_Civilian, 20.0);
	CreateStaticLootSpawn(-226.976074, 1410.879882, 26.766370,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-87.732368, 1378.449462, 9.266280,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-227.804336, 1396.644775, 27.368450,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-223.525146, 1410.911132, 26.767929,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-26.539789, 1349.489257, 8.149729,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-30.184959, 1369.222900, 8.145730,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(26.189359, 1342.072021, 8.146659,			loot_Industrial, 20.0);
	CreateStaticLootSpawn(8.310959, 1377.217285, 8.139530,			loot_Industrial, 20.0);
	CreateStaticLootSpawn(-101.560493, 1365.855468, 9.260160,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-102.598632, 1374.171020, 9.261280,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-93.175300, 1364.588378, 9.262379,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-219.953491, 1404.425415, 26.767999,		loot_Survivor, 10.0);
}
BC_District_Octane()
{
	MsgAll(YELLOW, " >  Loading world region: 'BC_District_Octane' please wait...");

	CreateStaticLootSpawn(406.390502, 1161.583251, 6.903639,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(502.410369, 1119.108764, 13.740139,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(711.367980, 1204.533447, 12.385020,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(317.622833, 1155.077880, 7.582119,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(303.804077, 1138.420288, 7.578979,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(398.134613, 1158.175659, 7.343679,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(419.038360, 1414.852050, 7.543509,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(534.092712, 1474.308105, 4.565539,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(433.595092, 1570.021606, 11.759650,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(404.414794, 1466.857788, 7.161159,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(627.937866, 1357.235717, 12.163160,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(562.631225, 1311.023071, 10.236080,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(602.667480, 1501.857055, 8.021780,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(578.049804, 1427.667480, 11.301899,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(417.753784, 1166.663574, 6.881309,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(258.689056, 1383.936523, 9.549200,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(577.598388, 1222.436157, 10.707090,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(512.728454, 1116.753784, 13.983510,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(712.143127, 1193.937011, 12.385560,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(640.637512, 1238.122558, 10.682990,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(634.523193, 1250.863647, 10.669329,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(571.136840, 1217.445922, 10.820360,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(258.719604, 1358.765380, 9.546999,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(215.507736, 1373.093750, 9.563980,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(150.130493, 1356.327148, 9.525540,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(259.074829, 1433.159912, 9.547089,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(259.364624, 1459.235595, 9.549960,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(150.800659, 1431.161254, 9.551639,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(184.493652, 1465.885253, 9.556730,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(151.101119, 1395.591064, 9.540240,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(217.861404, 1444.793945, 9.551670,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(354.287384, 1304.203613, 12.342359,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(312.878173, 1147.319091, 7.583069,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(489.798919, 1309.195190, 9.054280,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(434.902099, 1270.613403, 9.015930,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(192.338745, 1393.987670, 9.565739,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(220.406066, 1423.235229, 9.563639,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(258.495056, 1409.092651, 9.465370,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(229.030288, 1404.713500, 9.575699,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(246.486312, 1410.604736, 22.373430,		loot_Survivor, 15.0);
	CreateStaticLootSpawn(246.559066, 1435.287719, 22.373479,		loot_Survivor, 15.0);
	CreateStaticLootSpawn(246.607559, 1360.743041, 22.371690,		loot_Survivor, 15.0);
	CreateStaticLootSpawn(246.618774, 1385.139282, 22.371110,		loot_Survivor, 15.0);
	CreateStaticLootSpawn(542.179809, 1557.241333, -0.013129,		loot_Survivor, 15.0);
	CreateStaticLootSpawn(112.207893, 1479.111450, 9.552849,		loot_Survivor, 15.0);
	CreateStaticLootSpawn(113.102928, 1339.979125, 9.567819,		loot_Survivor, 15.0);
	CreateStaticLootSpawn(614.924499, 1549.649902, 3.934360,		loot_Survivor, 15.0);
	CreateStaticLootSpawn(596.327392, 1250.829101, 27.739919,		loot_Survivor, 15.0);
	CreateStaticLootSpawn(596.116455, 1255.403808, 27.729589,		loot_Survivor, 15.0);
	CreateStaticLootSpawn(713.606140, 1596.020996, 3.042929,		loot_Survivor, 15.0);
}
BC_District_Carson()
{
	MsgAll(YELLOW, " >  Loading world region: 'BC_District_Carson' please wait...");

	CreateWorkBench(318.60028, 1145.81543, 8.04844, -181.56007);

	CreateStaticLootSpawn(-204.049407, 1052.944702, 18.736200,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-203.905685, 1061.835571, 18.736690,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(65.135223, 1163.147705, 17.655750,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(89.157058, 1168.156738, 21.825420,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(77.920936, 1162.654052, 17.656190,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-205.839736, 1088.196533, 18.735580,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-33.426929, 1113.334106, 19.217029,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-23.135469, 1114.517822, 18.714950,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-204.570755, 1144.440917, 18.735729,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-204.341598, 1119.357055, 18.736669,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-204.417831, 1138.453735, 18.735839,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(97.640556, 1180.266357, 17.651760,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-69.601142, 1211.764282, 21.438690,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-69.604797, 1225.859130, 18.641120,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-78.062438, 1228.821655, 21.436689,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-102.062942, 1234.083251, 21.438310,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-102.978973, 1234.224121, 18.737890,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-89.887222, 1228.272216, 18.730970,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-18.946399, 1178.588256, 18.555719,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-53.866489, 1189.645751, 18.358779,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(12.006520, 1211.052124, 18.340040,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-26.889520, 1213.639648, 18.355289,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(11.449620, 1218.927490, 18.342010,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-100.277313, 1120.716064, 18.734220,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-108.015319, 1138.215698, 18.735540,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-182.437820, 1063.553466, 18.737749,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-181.196105, 1132.080932, 18.736949,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-180.773727, 1088.333862, 18.736370,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-182.449951, 1034.459472, 18.737150,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-127.090858, 1189.898071, 18.732749,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-145.579528, 1175.053344, 18.732410,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-91.836112, 1189.939208, 18.730779,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-178.120391, 1110.414672, 18.737089,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-148.918701, 1079.832031, 18.733770,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-182.115127, 1163.408935, 18.735740,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-203.433456, 1171.875244, 18.737239,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-203.784667, 1183.302856, 18.736360,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-205.025650, 1153.021972, 18.736299,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(4.809790, 1113.626953, 19.228820,			loot_Civilian, 20.0);
	CreateStaticLootSpawn(0.807669, 1079.924560, 18.718629,			loot_Civilian, 20.0);
	CreateStaticLootSpawn(-28.619119, 1045.020874, 19.206310,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-180.198440, 1177.948364, 18.884870,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-98.874778, 1083.860595, 18.735500,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-181.848449, 1186.428955, 18.736129,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-48.205039, 1082.596313, 19.221139,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(110.137466, 1104.607421, 12.607029,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-145.277206, 930.899841, 18.553699,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-271.326690, 1003.717224, 19.226549,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-330.382324, 1120.523559, 19.937059,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-326.474639, 1163.808837, 19.935609,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-297.659149, 1115.140991, 19.932609,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-255.780654, 994.320678, 19.223880,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-226.435653, 984.888610, 18.588209,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-218.836486, 973.875366, 18.481670,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-126.752647, 860.225952, 17.085060,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-149.582260, 911.813598, 18.076040,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-147.509963, 887.833312, 17.626550,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-11.705389, 975.067016, 18.791820,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-43.136520, 962.950988, 18.764270,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(32.274921, 923.794372, 22.592670,			loot_Civilian, 20.0);
	CreateStaticLootSpawn(64.988723, 1006.645141, 12.660110,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(17.394319, 909.714538, 22.909460,			loot_Civilian, 20.0);
	CreateStaticLootSpawn(-371.365478, 1106.607421, 18.734670,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-53.325649, 898.172790, 20.953329,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-368.887115, 1168.644287, 19.267549,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-60.703941, 972.405883, 18.803110,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-362.300109, 1110.604492, 19.930160,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-360.320556, 1140.386962, 19.936639,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-187.405075, 1209.844604, 18.694589,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-144.232223, 1222.746459, 18.894910,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-206.270645, 1212.087158, 18.885250,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-251.117218, 1142.984985, 19.224229,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-257.320739, 1177.969482, 19.011709,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-260.443817, 1165.581176, 19.225410,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-94.863327, 887.967346, 19.857339,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-259.863952, 1040.428466, 19.231460,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-125.978393, 970.968261, 18.862970,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-260.471191, 1127.795410, 19.232900,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-262.546875, 1073.498535, 19.232749,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-218.834335, 1136.086914, 18.732580,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-0.697420, 952.045654, 18.593759,			loot_Industrial, 20.0);
	CreateStaticLootSpawn(24.824829, 969.502014, 18.737670,			loot_Industrial, 20.0);
	CreateStaticLootSpawn(16.687189, 949.826232, 18.920339,			loot_Industrial, 20.0);
	CreateStaticLootSpawn(-211.172851, 1038.739501, 18.731260,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-168.528472, 1031.273071, 18.728790,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-211.712173, 1075.494384, 18.732019,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-142.434143, 1163.397094, 18.731529,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-122.636718, 1076.776977, 18.779270,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-139.123672, 1070.201904, 18.731649,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-165.130218, 1059.386474, 18.729990,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-130.765762, 878.851257, 17.710119,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-219.544250, 1031.890380, 18.736179,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-117.765167, 923.193176, 19.406930,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-225.387664, 1076.661254, 18.735109,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-217.193954, 1064.911376, 18.734859,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-217.221298, 1047.601440, 18.735940,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-79.309776, 936.247497, 19.514970,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-210.878646, 1176.967163, 18.732700,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-219.442825, 1172.644531, 18.733280,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-219.053237, 1149.256713, 18.732599,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-54.212238, 937.348510, 19.787269,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-51.115051, 920.814514, 20.911560,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-210.234924, 1159.062988, 18.732440,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(50.004970, 1222.297241, 17.929319,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(59.683120, 1217.600830, 17.845819,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-27.102190, 1164.611083, 18.369670,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-90.538032, 1123.737915, 18.734439,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-100.857643, 1075.194580, 18.735830,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(111.702293, 1113.239501, 12.609279,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-208.867355, 1221.032958, 18.885169,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-190.538574, 1219.323852, 18.733329,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-307.551849, 1039.625732, 18.718660,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-43.765048, 1177.711059, 18.426610,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-87.487213, 1236.745849, 18.734260,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-146.486312, 1238.239379, 18.641139,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-147.856750, 1134.229614, 18.732509,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-116.913070, 1134.292114, 18.732559,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-136.848464, 1116.640991, 19.190359,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-176.555877, 1126.560546, 18.730749,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-167.246536, 1170.509887, 18.734029,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-94.656997, 1164.000244, 18.725570,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-158.315338, 1122.975830, 18.736209,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-113.623260, 1126.732421, 18.739110,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-77.892303, 1110.508544, 18.734510,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-77.442260, 1136.508666, 18.735149,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-217.332962, 979.176147, 18.501010,		loot_Police, 20.0);
	CreateStaticLootSpawn(-331.796661, 1058.507934, 18.850950,		loot_Medical, 20.0);
	CreateStaticLootSpawn(-314.688903, 1050.707153, 19.335269,		loot_Medical, 20.0);
	CreateStaticLootSpawn(-332.046203, 1049.622558, 18.850439,		loot_Medical, 20.0);
	CreateStaticLootSpawn(-325.865997, 1050.232543, 19.335189,		loot_Medical, 20.0);
	CreateStaticLootSpawn(-338.081787, 1049.800781, 18.851850,		loot_Medical, 20.0);
	CreateStaticLootSpawn(-318.559417, 1049.322265, 19.334999,		loot_Medical, 20.0);
	CreateStaticLootSpawn(-321.981170, 1049.464843, 19.335149,		loot_Medical, 20.0);
	CreateStaticLootSpawn(-208.205947, 1085.446166, 26.486820,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-177.174240, 1111.713867, 29.049179,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-227.681381, 976.515258, 21.278089,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-216.774002, 978.982971, 21.938270,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-176.402938, 1084.354736, 25.103900,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(71.329132, 1217.019165, 22.197910,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(110.565567, 1019.749145, 12.603650,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-215.235107, 1119.215820, 34.648849,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(53.950950, 1217.278808, 22.652080,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-52.753311, 1185.876586, 23.080619,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-315.828460, 1134.307739, 18.729959,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-306.247711, 1163.030151, 18.635370,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-374.772430, 1128.111694, 18.664449,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-360.997985, 1198.928222, 18.738489,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-339.770843, 1176.718627, 18.722009,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-305.888977, 1118.847412, 18.727710,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-0.394650, 1126.914672, 18.661199,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-26.157819, 1119.407714, 18.716949,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-50.896221, 1128.907226, 18.713079,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-46.246780, 1051.903808, 18.663030,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-29.474679, 1069.872314, 18.716640,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(6.758530, 1083.380981, 18.719419,			loot_Industrial, 20.0);
	CreateStaticLootSpawn(-246.328918, 1185.205078, 18.721729,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-245.698181, 1059.426513, 18.726419,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-239.647338, 997.336547, 18.724409,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-264.953338, 990.264404, 18.676839,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-255.290832, 1159.561767, 18.724609,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-245.331588, 1133.955078, 18.640810,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-245.723236, 1068.867797, 18.658399,		loot_Industrial, 20.0);

}
BC_District_Hunter()
{
	MsgAll(YELLOW, " >  Loading world region: 'BC_District_Hunter' please wait...");

	CreateWorkBench(585.17377, 873.72583, -43.01944, 94.26003);

	CreateStaticLootSpawn(627.578979, 894.678649, -42.107200,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(578.331787, 829.218872, -30.850990,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(591.060485, 878.450073, -43.504810,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(591.337158, 868.772277, -43.502510,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(680.804504, 845.106262, -43.965888,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(823.437805, 857.840393, 11.054739,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(815.093627, 864.144470, 11.071479,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(670.060974, 825.733825, -43.965450,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(712.892639, 909.567138, -19.662990,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(586.737182, 877.752929, -43.505859,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(490.787933, 789.598449, -23.100080,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(323.204498, 856.567504, 19.398349,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(320.458709, 874.007995, 19.398880,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(562.789123, 823.181823, -23.132949,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(677.806396, 901.917602, -41.251388,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(587.467285, 868.175354, -43.503448,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(691.817749, 893.956848, -40.211181,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(568.314575, 824.260559, -23.132759,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(495.127593, 785.502502, -23.075759,		loot_Survivor, 10.0);
}
BC_District_BoneGen()
{
	MsgAll(YELLOW, " >  Loading world region: 'BC_District_BoneGen' please wait...");

	CreateWorkBench(-371.56595, 2235.98975, 41.93906, 12.84000);

	CreateStaticLootSpawn(-583.062133, 2713.019042, 70.823257,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-13.895059, 2345.650634, 23.131660,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-551.655273, 2592.609619, 52.930320,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-36.337589, 2347.065673, 23.131919,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-674.146789, 2706.751953, 69.659271,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-736.013122, 2746.930664, 46.221889,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-605.083496, 2716.697753, 71.720092,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-625.312194, 2714.389404, 71.365707,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-546.354675, 2616.551513, 52.496181,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-377.800720, 2242.189941, 41.603599,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-798.536193, 2259.297363, 57.972450,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-385.928405, 2217.766845, 41.425331,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-364.538177, 2222.307128, 41.498550,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-309.805694, 1762.794311, 42.633949,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-545.437561, 2571.026367, 52.499248,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-332.086578, 2224.452880, 41.509391,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-323.462036, 1851.641235, 41.496849,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-760.894653, 2762.958007, 44.760108,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-787.384887, 2753.500244, 44.650768,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-789.328125, 2757.031494, 44.847740,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-776.944213, 2762.333984, 44.726848,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-828.882751, 2754.932617, 44.820899,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-812.847961, 2763.490966, 44.816181,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-844.227722, 2744.323242, 44.810180,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-866.749145, 2750.536621, 44.983020,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-881.115051, 2757.923828, 45.062850,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-314.933471, 830.342224, 13.237990,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-852.365478, 2760.675537, 44.981529,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-789.359924, 2764.553955, 47.252590,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-760.082702, 2764.932617, 47.251491,		loot_Civilian, 20.0);
	CreateStaticLootSpawn(-418.083282, 2222.179199, 41.419910,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-429.900817, 2252.611572, 41.424148,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-350.724853, 2239.731201, 41.508750,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-363.913879, 2263.687011, 41.477569,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-451.246734, 2229.808105, 41.423179,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-320.205413, 842.688110, 13.235569,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-329.155883, 825.614379, 13.236049,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-13.420499, 2350.712646, 23.130630,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-27.980180, 2356.891601, 23.132839,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-309.929168, 1770.002929, 42.632080,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-489.220642, 614.169372, 0.774900,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-305.987030, 1780.561645, 41.780170,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-316.828247, 1799.826782, 42.635169,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-551.967468, 2595.404296, 52.930328,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-766.490539, 2773.825683, 44.759788,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-662.617309, 2305.950195, 135.073318,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-595.948486, 2720.095703, 71.365837,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-741.514770, 2751.244873, 46.308731,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-792.932678, 2770.867187, 44.701049,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-729.619506, 2747.050781, 46.222488,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-480.463439, 2180.354736, 40.856418,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-802.773193, 2260.641357, 57.657630,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-845.069763, 2752.810791, 44.824779,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-793.376525, 2257.507080, 58.195529,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-395.922515, 2214.293701, 41.416900,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-806.412780, 2239.297607, 40.838630,		loot_Industrial, 20.0);
	CreateStaticLootSpawn(-329.620483, 835.750122, 13.237870,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-319.849517, 839.114746, 16.536439,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-462.673278, 635.911315, 13.051130,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-454.851623, 614.706909, 15.737050,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-792.759948, 2765.642822, 49.801288,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-331.133422, 818.287841, 13.427390,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-323.574249, 818.120971, 13.420280,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-317.767333, 815.742370, 13.514579,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-662.589660, 2313.452392, 141.931838,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-810.595886, 2429.505859, 155.963317,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-772.308166, 2423.595703, 156.082061,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-793.702453, 2265.871337, 58.064628,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-417.360626, 2246.704833, 41.425289,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-465.200988, 2187.044921, 45.706848,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-10.564240, 2329.213378, 23.302949,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-18.395889, 2322.289550, 23.302610,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-27.389709, 2320.724609, 23.302759,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-417.139739, 1356.921264, 11.771269,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-555.274108, 2580.320312, 64.810043,		loot_Survivor, 10.0);
	CreateStaticLootSpawn(-9.954810, 2336.925292, 23.302459,		loot_Survivor, 10.0);

}

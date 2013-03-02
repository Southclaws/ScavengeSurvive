public OnLoad()
{
	print("Loading Flint County");

	CreateBalloon(-2237.60, -1711.45, 479.88, 0.0, 1529.81, -1358.07, 328.37, 0.0);

	CreateFuelOutlet(-2246.7031, -2559.7109, 31.0625, 2.0, 100.0, float(random(100)));
	CreateFuelOutlet(-2241.7188, -2562.2891, 31.0625, 2.0, 100.0, float(random(100)));

	CreateFuelOutlet(-1600.6719, -2707.8047, 47.9297, 2.0, 100.0, float(random(100)));
	CreateFuelOutlet(-1603.9922, -2712.2031, 47.9297, 2.0, 100.0, float(random(100)));
	CreateFuelOutlet(-1607.3047, -2716.6016, 47.9297, 2.0, 100.0, float(random(100)));
	CreateFuelOutlet(-1610.6172, -2721.0000, 47.9297, 2.0, 100.0, float(random(100)));

	CreateFuelOutlet(-85.2422, -1165.0313, 2.6328, 2.0, 100.0, float(random(130)));
	CreateFuelOutlet(-90.1406, -1176.6250, 2.6328, 2.0, 100.0, float(random(130)));
	CreateFuelOutlet(-92.1016, -1161.7891, 2.9609, 2.0, 100.0, float(random(130)));
	CreateFuelOutlet(-97.0703, -1173.7500, 3.0313, 2.0, 100.0, float(random(130)));


	CreateLadder(-1056.0153, -628.1323, 32.0012, 130.1213, 180.0);
	CreateLadder(-1059.8658, -617.5842, 34.0942, 130.1221, 270.0);
	CreateLadder(-1073.3224, -645.8720, 32.0078, 56.6255, 180.0);
	CreateLadder(-1111.0469, -645.8738, 32.0078, 56.6202, 180.0);
	CreateLadder(-1097.3682, -640.2991, 34.0896, 44.2146, 0.0);
	CreateLadder(-1063.1298, -640.0430, 34.0896, 44.2146, 0.0);
	CreateLadder(-1099.8262, -719.3637, 32.0078, 54.7115, 180.0);
	CreateLadder(-1055.5986, -719.3712, 32.0078, 54.7115, 180.0);
	CreateLadder(-1013.4467, -719.3651, 32.0078, 54.7115, 180.0);

	return CallLocalFunction("flintcounty_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad flintcounty_OnLoad
forward flintcounty_OnLoad();

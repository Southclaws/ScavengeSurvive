#include <a_samp>


#define OUTPUT_FILE						"MapMoverOutput.txt"
#define ADJUSTMENT_POSITION_OFFSET_X	(0.0)
#define ADJUSTMENT_POSITION_OFFSET_Y	(0.0)
#define ADJUSTMENT_POSITION_OFFSET_Z	(0.0)
#define ADJUSTMENT_ROTATION_OFFSET_X	(0.0)
#define ADJUSTMENT_ROTATION_OFFSET_Y	(0.0)
#define ADJUSTMENT_ROTATION_OFFSET_Z	(45.0)
#define CreateObject					AdjustObject


new
	Float:origin_x,
	Float:origin_y,
	Float:origin_z,
	bool:origin_set = false;


public OnFilterScriptInit()
{
CreateObject(19357, 276.24899, 1828.42322, 3.32440,   0.00000, 0.00000, 0.00000);
CreateObject(19357, 276.25061, 1831.20764, 3.32440,   0.00000, 0.00000, 0.00000);
CreateObject(19357, 277.94299, 1832.67493, 3.32440,   0.00000, 0.00000, 90.00000);
CreateObject(19357, 280.55209, 1832.67346, 3.32440,   0.00000, 0.00000, 90.00000);
CreateObject(19357, 282.01669, 1831.15625, 3.32440,   0.00000, 0.00000, 0.00000);
CreateObject(19357, 282.01620, 1828.37256, 3.32440,   0.00000, 0.00000, 0.00000);
CreateObject(19357, 280.50211, 1826.90527, 3.32440,   0.00000, 0.00000, 90.00000);
CreateObject(19357, 277.71649, 1826.90625, 3.32440,   0.00000, 0.00000, 90.00000);
CreateObject(19362, 278.08920, 1831.00085, 1.63700,   0.00000, 90.00000, 0.00000);
CreateObject(19362, 280.17731, 1831.00122, 1.63500,   0.00000, 90.00000, 0.00000);
CreateObject(19362, 280.18079, 1828.59717, 1.63300,   0.00000, 90.00000, 0.00000);
CreateObject(19362, 278.08710, 1828.59924, 1.63100,   0.00000, 90.00000, 0.00000);
CreateObject(19362, 278.08920, 1831.00085, 5.10790,   0.00000, 90.00000, 0.00000);
CreateObject(19362, 280.17731, 1831.00122, 5.10590,   0.00000, 90.00000, 0.00000);
CreateObject(19362, 280.18079, 1828.59717, 5.10390,   0.00000, 90.00000, 0.00000);
CreateObject(19362, 278.08710, 1828.59924, 5.10190,   0.00000, 90.00000, 0.00000);
CreateObject(2924, 278.50809, 1832.64355, 2.91050,   0.00000, 0.00000, 180.00000);
CreateObject(2008, 281.29547, 1828.57593, 1.72020,   0.00000, 0.00000, 270.00000);
CreateObject(1806, 280.78928, 1827.51904, 1.72025,   0.00000, 0.00000, -77.34000);
CreateObject(1810, 276.82968, 1828.57532, 1.72273,   0.00000, 0.00000, -216.29999);
CreateObject(957, 279.11783, 1829.81799, 4.98342,   0.00000, 0.00000, 0.00000);
CreateObject(2197, 281.47403, 1831.01660, 1.72283,   0.00000, 0.00000, 0.00000);
CreateObject(2370, 276.80917, 1829.70593, 1.69380,   0.00000, 0.00000, 0.00000);
CreateObject(1810, 278.31662, 1830.44849, 1.72273,   0.00000, 0.00000, -57.71994);
CreateObject(1810, 277.30359, 1831.40881, 1.72270,   0.00000, 90.00000, 52.50009);
CreateObject(2601, 277.36951, 1829.54724, 2.64652,   0.00000, 0.00000, 100.92001);
CreateObject(2601, 276.57266, 1830.59314, 2.62448,   0.00000, 0.00000, -106.98005);
CreateObject(2601, 277.76572, 1829.62732, 2.62449,   0.00000, 0.00000, -134.76004);
}

AdjustObject(model, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(!origin_set)
	{
		origin_x = x;
		origin_y = y;
		origin_z = z;
		origin_set = true;
	}

	new
		File:file,
		string[128],
		Float:offset_x = origin_x - x,
		Float:offset_y = origin_y - y,
		Float:offset_z = origin_z - z,
		Float:cos_x,
		Float:cos_y,
		Float:cos_z,
		Float:sin_x,
		Float:sin_y,
		Float:sin_z;

	cos_x = floatcos(ADJUSTMENT_ROTATION_OFFSET_X, degrees),
	cos_y = floatcos(ADJUSTMENT_ROTATION_OFFSET_Y, degrees),
	cos_z = floatcos(ADJUSTMENT_ROTATION_OFFSET_Z, degrees),
	sin_x = floatsin(ADJUSTMENT_ROTATION_OFFSET_X, degrees),
	sin_y = floatsin(ADJUSTMENT_ROTATION_OFFSET_Y, degrees),
	sin_z = floatsin(ADJUSTMENT_ROTATION_OFFSET_Z, degrees);

	x = origin_x + offset_x * cos_y * cos_z - offset_x * sin_x * sin_y * sin_z - offset_y * cos_x * sin_z + offset_z * sin_y * cos_z + offset_z * sin_x * cos_y * sin_z;
	y = origin_y + offset_x * cos_y * sin_z + offset_x * sin_x * sin_y * cos_z + offset_y * cos_x * cos_z + offset_z * sin_y * sin_z - offset_z * sin_x * cos_y * cos_z;
	z = origin_z - offset_x * cos_x * sin_y + offset_y * sin_x + offset_z * cos_x * cos_y;

	format(string, 128, "CreateObject(%d, %f, %f, %f, %f, %f, %f);\r\n",
		model, x, y, z, rx + ADJUSTMENT_ROTATION_OFFSET_X, ry + ADJUSTMENT_ROTATION_OFFSET_Y, rz + ADJUSTMENT_ROTATION_OFFSET_Z);

	if(!fexist(OUTPUT_FILE))
		file = fopen(OUTPUT_FILE, io_write);

	else
		file = fopen(OUTPUT_FILE, io_append);

	fwrite(file, string);
	fclose(file);

	return 1;
}


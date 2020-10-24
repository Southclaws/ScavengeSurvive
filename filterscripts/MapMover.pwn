/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
#include <sscanf2>


#define INPUT_FILE						"Maps/OCEAN/OilRig/development/Rig_center.txt"
#define OUTPUT_FILE						"Maps/OCEAN/OilRig/Rig_southwest.map"
#define ADJUSTMENT_POSITION_OFFSET_X	(4000.0)
#define ADJUSTMENT_POSITION_OFFSET_Y	(-4000.0)
#define ADJUSTMENT_POSITION_OFFSET_Z	(0.0)
#define ADJUSTMENT_ROTATION_OFFSET_X	(0.0)
#define ADJUSTMENT_ROTATION_OFFSET_Y	(0.0)
#define ADJUSTMENT_ROTATION_OFFSET_Z	(0.0)


new stock
	Float:origin_x,
	Float:origin_y,
	Float:origin_z,
	bool:origin_set = false;


public OnFilterScriptInit()
{
	if(!fexist(INPUT_FILE))
	{
		printf("Input file '%s' does not exist", INPUT_FILE);
		return;
	}

	new
		File:inputfile,
		File:outputfile,
		line[128],
		model,
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz;

	inputfile = fopen(INPUT_FILE, io_read);
	outputfile = fopen(OUTPUT_FILE, io_write);

	while(fread(inputfile, line))
	{
		if(!sscanf(line, "p<(>{s[20]}p<,>dfffffp<)>f{s[4]}", model, x, y, z, rx, ry, rz))
		{
			AdjustPosition(x, y, z, rx, ry, rz);

			format(line, 128, "CreateObject(%d, %f, %f, %f, %f, %f, %f);\r\n", model, x, y, z, rx, ry, rz);

			fwrite(outputfile, line);
		}
	}

	printf("Map successfully moved %.2fm East, %.2fm North, %.2f Vertically.", ADJUSTMENT_POSITION_OFFSET_X, ADJUSTMENT_POSITION_OFFSET_Y, ADJUSTMENT_POSITION_OFFSET_Z);

	fclose(inputfile);
	fclose(outputfile);
}

AdjustPosition(&Float:x, &Float:y, &Float:z, &Float:rx, &Float:ry, &Float:rz)
{
	x += ADJUSTMENT_POSITION_OFFSET_X;
	y += ADJUSTMENT_POSITION_OFFSET_Y;
	z += ADJUSTMENT_POSITION_OFFSET_Z;
}

#endinput

AdjustPosition(model, &Float:x, &Float:y, &Float:z, &Float:rx, &Float:ry, &Float:rz)
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

	return 1;
}

/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
#include <MapAndreas>			// -
#include <easybmp>				// -
#include <YSI\y_iterate>		// -
#include "inc/virtualcanvas"	// -
#include <streamer>				// -
#include <formatex>				// -

#pragma dynamic 64000
#define FILENAME "./scriptfiles/txmap/basic_small.bmp"


enum
{
	E_ROADS,	// roads
	E_SHRUB_S,	// small shrubs
	E_SHRUB_C,	// country shrubs
	E_SHRUB_L,	// lighter shrubs
	E_SHRUB_D,	// desert shrubs
	E_WATER		// water
}


static
obj_arr_E_ROADS[]=
{
	18862,
	647,
	692,
	759,
	760,
	762,
	800,
	801,
	802,
	803,
	804,
	805,
	806,
	807,
	808,
	809,
	810,
	811,
	812,
	813,
	814,
	815,
	816,
	818,
	819,
	820,
	821,
	822,
	823,
	824,
	825,
	826,
	827
},

obj_arr_E_SHRUB_S[]=
{
	647,
	692,
	759,
	760,
	762,
	800,
	801,
	802,
	803,
	804,
	805,
	806,
	807,
	808,
	809,
	810,
	811,
	812,
	813,
	814,
	815,
	816,
	818,
	819,
	820,
	821,
	822,
	823,
	824,
	825,
	826,
	827
},

obj_arr_E_SHRUB_C[]=
{
	654,
	655,
	656,
	657,
	658,
	659,
	660,
	661
},

obj_arr_E_SHRUB_L[]=
{
	647,
	692,
	759,
	760,
	762,
	800,
	801,
	802,
	803,
	804,
	805,
	806,
	807,
	808,
	809,
	810,
	811,
	812,
	813,
	814,
	815,
	816,
	818,
	819,
	820,
	821,
	822,
	823,
	824,
	825,
	826,
	827
},

obj_arr_E_SHRUB_D[]=
{
	647,
	692,
	759,
	760,
	762,
	800,
	801,
	802,
	803,
	804,
	805,
	806,
	807,
	808,
	809,
	810,
	811,
	812,
	813,
	814,
	815,
	816,
	818,
	819,
	820,
	821,
	822,
	823,
	824,
	825,
	826,
	827
},

obj_arr_E_WATER[]=
{
	1243,
	1243
};


static
	VirtualCanvas:vc,
	res_x,
	res_y;


public OnFilterScriptInit()
{
	MapAndreas_Init(MAP_ANDREAS_MODE_FULL);

	FImageOpen(FILENAME);
	res_x = GetImageWidth(FILENAME);
	res_y = GetImageHeight(FILENAME);

	vc = CreateVirtualCanvas(-3000, 3000, 3000.0, -3000.0, res_x, res_y);

	_ProcessBitmapLoop();

	print("Task complete.");

	return 1;
}

_ProcessBitmapLoop()
{
	for(new i; i < res_x; i++)
	{
		for(new j; j < res_y; j++)
		{
			_ProcessPixel(i, j);
		}
	}
}

_ProcessPixel(pix_x, pix_y)
{
	new
		Float:pos_x,
		Float:pos_y,
		Float:pos_z,
		pix_r,
		pix_g,
		pix_b,
		rgba;

	pix_r = FGetImageRAtPos(pix_x, pix_y);
	pix_g = FGetImageGAtPos(pix_x, pix_y);
	pix_b = FGetImageBAtPos(pix_x, pix_y);
	rgba = (pix_r<<24 | pix_g<<16 | pix_b<<8 | 0xFF);

	// If the pixel is white, skip.
	if(rgba == 0xFFFFFFFF)
		return 0;

	GetVirtualCanvasPos(vc, pix_x, pix_y, pos_x, pos_y);

	// If out the world bounds, skip (causes a MapAndreas crash)
	if(!(-2990.0 < pos_x < 2990.0) || !(-2990.0 < pos_y < 2990.0))
		return 0;

	MapAndreas_FindZ_For2DCoord(pos_x, pos_y, pos_z);

//	if(rgba == 0x000000FF) // roads
//	{
//		if(random(100) < 5)
//		{
//			_CreateFoliage(/*E_ROADS*/E_SHRUB_C, pos_x, pos_y, pos_z);
//			// CreateDynamic3DTextLabel("[ROAD]", rgba, pos_x, pos_y, pos_z, 1000.0);
//			//printf("[_ProcessPixel] [ROAD] rgba: [%x]=%d.%d.%d, p: %f, %f, %f", rgba, pix_r, pix_g, pix_b, pos_x, pos_y, pos_z);
//		}
//	}

	if(rgba == 0x3fbf00FF) // shrubs1
	{
		if(random(100) < 30)
		{
			_CreateFoliage(/*E_SHRUB_S*/E_SHRUB_C, pos_x, pos_y, pos_z);
			// CreateDynamic3DTextLabel("[SMALLSHRUBS]", rgba, pos_x, pos_y, pos_z, 1000.0);
			//printf("[_ProcessPixel] [SMALLSHRUBS] rgba: [%x]=%d.%d.%d, p: %f, %f, %f", rgba, pix_r, pix_g, pix_b, pos_x, pos_y, pos_z);
		}
	}

	if(rgba == 0x3f3f00FF) // redcounty shrubs
	{
		if(random(100) < 50)
		{
			_CreateFoliage(/*E_SHRUB_C*/E_SHRUB_C, pos_x, pos_y, pos_z);
			// CreateDynamic3DTextLabel("[DARKSHRUBS]", rgba, pos_x, pos_y, pos_z, 1000.0);
			//printf("[_ProcessPixel] [DARKSHRUBS] rgba: [%x]=%d.%d.%d, p: %f, %f, %f", rgba, pix_r, pix_g, pix_b, pos_x, pos_y, pos_z);
		}
	}

	if(rgba == 0x3f7f3fFF) // lighter shrubs
	{
		if(random(100) < 50)
		{
			_CreateFoliage(E_SHRUB_L, pos_x, pos_y, pos_z);
			// CreateDynamic3DTextLabel("[LIGHTSHRUBS]", rgba, pos_x, pos_y, pos_z, 1000.0);
			//printf("[_ProcessPixel] [LIGHTSHRUBS] rgba: [%x]=%d.%d.%d, p: %f, %f, %f", rgba, pix_r, pix_g, pix_b, pos_x, pos_y, pos_z);
		}
	}

	if(rgba == 0x3f3f00FF) // desert shrubs
	{
		if(random(100) < 50)
		{
			_CreateFoliage(/*E_SHRUB_D*/E_SHRUB_C, pos_x, pos_y, pos_z);
			// CreateDynamic3DTextLabel("[DESERTSHRUBS]", rgba, pos_x, pos_y, pos_z, 1000.0);
			//printf("[_ProcessPixel] [DESERTSHRUBS] rgba: [%x]=%d.%d.%d, p: %f, %f, %f", rgba, pix_r, pix_g, pix_b, pos_x, pos_y, pos_z);
		}
	}

//	if(rgba == 0x3f7fbfFF) // water
//	{
//		if(random(100) < 1)
//		{
//			_CreateFoliage(E_WATER, pos_x, pos_y, pos_z);
//			// CreateDynamic3DTextLabel("[WATER]", rgba, pos_x, pos_y, pos_z, 1000.0);
//			//printf("[_ProcessPixel] [WATER] rgba: [%x]=%d.%d.%d, p: %f, %f, %f", rgba, pix_r, pix_g, pix_b, pos_x, pos_y, pos_z);
//		}
//	}

	return 1;
}

_CreateFoliage(type, Float:x, Float:y, Float:z)
{
	new model;

	switch(type)
	{
		case E_ROADS: model = obj_arr_E_ROADS[random(sizeof(obj_arr_E_ROADS))];
		case E_SHRUB_S: model = obj_arr_E_SHRUB_S[random(sizeof(obj_arr_E_SHRUB_S))];
		case E_SHRUB_C: model = obj_arr_E_SHRUB_C[random(sizeof(obj_arr_E_SHRUB_C))];
		case E_SHRUB_L: model = obj_arr_E_SHRUB_L[random(sizeof(obj_arr_E_SHRUB_L))];
		case E_SHRUB_D: model = obj_arr_E_SHRUB_D[random(sizeof(obj_arr_E_SHRUB_D))];
		case E_WATER: model = obj_arr_E_WATER[random(sizeof(obj_arr_E_WATER))];
	}

	CreateDynamicObject(model, x, y, z, 0.0, 0.0, 0.0);
}

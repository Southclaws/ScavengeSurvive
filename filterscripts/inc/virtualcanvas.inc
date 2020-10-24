/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


/*
	Virtual Canvas
		For scaling squares and stuff like that.
		It literally has 3 functions work it out.
*/


#if !defined MAX_VIRTUAL_CANVAS
	#define MAX_VIRTUAL_CANVAS (VirtualCanvas:64)
#endif

#define INVALID_VIRTUAL_CANVAS (VirtualCanvas:-1)


enum E_VIRTUAL_CANVAS_DATA
{
Float:		canv_minX,
Float:		canv_maxX,
Float:		canv_minY,
Float:		canv_maxY,
			canv_resX,
			canv_resY
}


static
			canv_Data[MAX_VIRTUAL_CANVAS][E_VIRTUAL_CANVAS_DATA],
Iterator:	canv_Index<_:MAX_VIRTUAL_CANVAS>;


stock VirtualCanvas:CreateVirtualCanvas(Float:minx, Float:maxx, Float:miny, Float:maxy, resolution_x, resolution_y)
{
	new VirtualCanvas:id = VirtualCanvas:Iter_Free(canv_Index);

	if(id == INVALID_VIRTUAL_CANVAS)
		return INVALID_VIRTUAL_CANVAS;

	canv_Data[id][canv_minX] = minx;
	canv_Data[id][canv_maxX] = maxx;
	canv_Data[id][canv_minY] = miny;
	canv_Data[id][canv_maxY] = maxy;
	canv_Data[id][canv_resX] = resolution_x;
	canv_Data[id][canv_resY] = resolution_y;

	Iter_Add(canv_Index, _:id);

	return id;
}

stock DestroyVirtualCanvas(VirtualCanvas:virtualcanvas)
{
	if(!Iter_Contains(canv_Index, _:virtualcanvas))
		return 0;

	canv_Data[id][canv_minX] = 0.0;
	canv_Data[id][canv_maxX] = 0.0;
	canv_Data[id][canv_minY] = 0.0;
	canv_Data[id][canv_maxY] = 0.0;
	canv_Data[id][canv_resX] = 0;
	canv_Data[id][canv_resY] = 0;

	Iter_Remove(canv_Index, _:virtualcanvas);

	return 1;
}

stock GetVirtualCanvasPos(VirtualCanvas:virtualcanvas, res_x, res_y, &Float:x, &Float:y)
{
	if(!Iter_Contains(canv_Index, _:virtualcanvas))
		return 0;

	x = canv_Data[virtualcanvas][canv_minX] + (((canv_Data[virtualcanvas][canv_maxX] - canv_Data[virtualcanvas][canv_minX]) / canv_Data[virtualcanvas][canv_resX]) * float(res_x));
	y = canv_Data[virtualcanvas][canv_minY] + (((canv_Data[virtualcanvas][canv_maxY] - canv_Data[virtualcanvas][canv_minY]) / canv_Data[virtualcanvas][canv_resY]) * float(res_y));

	return 1;
}

// canv_minX
// canv_maxX
// canv_minY
// canv_maxY
// canv_resX
// canv_resY

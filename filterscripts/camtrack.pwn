/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <YSI\y_iterate>
#include <Line>


#define MAX_CAM_NODE (500)

stock Float:Distance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
	return floatsqroot((((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2))+((z1-z2)*(z1-z2))));


static
		CamTrackID = INVALID_PLAYER_ID,
		CamTrackViewer = INVALID_PLAYER_ID,
		CamTrackObjList[MAX_CAM_NODE] = {INVALID_OBJECT_ID, ...},
		CamTrackLineList[MAX_CAM_NODE] = {INVALID_LINE_SEGMENT_ID, ...},
		CamTrackObjIdx,
Float:	CamTrackX,
Float:	CamTrackY,
Float:	CamTrackZ;

CMD:camtrack(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	{
		SendClientMessage(playerid, -1, "RCON only command");
		return 1;
	}

	CamTrackID = strval(params);
	CamTrackViewer = playerid;

	if(!IsPlayerConnected(CamTrackID))
	{
		_RemoveCamNodes();
	}

	SendClientMessage(playerid, -1, "Type '/camtrack -1' to deactivate");

	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(CamTrackID == playerid)
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerCameraPos(playerid, x, y, z);

		if(Distance(x, y, z, CamTrackX, CamTrackY, CamTrackZ) > 0.0)
		{
			if(CamTrackObjIdx == MAX_CAM_NODE)
				CamTrackObjIdx = 0;

			if(CamTrackX * CamTrackY * CamTrackZ != 0.0)
			{
				DestroyLineSegment(CamTrackLineList[CamTrackObjIdx]);
				CamTrackLineList[CamTrackObjIdx] = CreateLineSegment(2997, 0.1,
					CamTrackX, CamTrackY, CamTrackZ,
					x, y, z,
					_, _, _,
					_, _, _, CamTrackViewer);
			}

			DestroyDynamicObject(CamTrackObjList[CamTrackObjIdx]);
			CamTrackObjList[CamTrackObjIdx] = CreateDynamicObject(2995, CamTrackX, CamTrackY, CamTrackZ, 0.0, 0.0, 0.0, _, _, CamTrackViewer);

			CamTrackX = x;
			CamTrackY = y;
			CamTrackZ = z;
			CamTrackObjIdx++;

			new str[128], Float:vx, Float:vy, Float:vz;
			GetPlayerCameraFrontVector(playerid, vx, vy, vz);
			format(str, 128, "POS: %f, %f, %f VEC: %f, %f, %f", x, y, z, vx, vy, vz);
			SendClientMessage(CamTrackViewer, -1, str);
		}
	}

	return 1;
}

_RemoveCamNodes()
{
	for(new i; i < MAX_CAM_NODE; i++)
	{
		DestroyDynamicObject(CamTrackObjList[i]);
		DestroyLineSegment(CamTrackLineList[i]);
	}
}

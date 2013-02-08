#include <YSI\y_hooks>


new
		tick_CrouchKey[MAX_PLAYERS],
Timer:	SitDownTimer[MAX_PLAYERS];


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
	{
		if(IsPlayerIdle(playerid))
		{
			if(newkeys == KEY_CROUCH)
			{
				tick_CrouchKey[playerid] = tickcount();
				SitDownTimer[playerid] = defer SitDown(playerid);
			}
			if(oldkeys == KEY_CROUCH)
			{
				if(tickcount() - tick_CrouchKey[playerid] < 250)
				{
					stop SitDownTimer[playerid];
				}
			}
		}
		if(newkeys & KEY_CROUCH || newkeys & KEY_SPRINT || newkeys & KEY_JUMP)
		{
			if(GetPlayerAnimationIndex(playerid) == 43 || GetPlayerAnimationIndex(playerid) == 1497)
			{
				ApplyAnimation(playerid, "SUNBATHE", "PARKSIT_M_OUT", 4.0, 0, 0, 0, 0, 0);
			}
		}
	}
}

timer SitDown[300](playerid)
{
	ApplyAnimation(playerid, "SUNBATHE", "PARKSIT_M_IN", 4.0, 0, 0, 0, 0, 0);
	defer SitLoop(playerid);
}

timer SitLoop[1900](playerid)
{
	ApplyAnimation(playerid, "BEACH", "PARKSIT_M_LOOP", 4.0, 1, 0, 0, 0, 0);
}

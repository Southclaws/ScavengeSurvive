#include <YSI\y_hooks>


new
		tick_CrouchKey[MAX_PLAYERS],
Timer:	SitDownTimer[MAX_PLAYERS];


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerTotalVelocity(playerid) == 0.0)
		{
			if(newkeys == KEY_CROUCH)
			{
				tick_CrouchKey[playerid] = tickcount();
				SitDownTimer[playerid] = defer SitDown(playerid);
			}

			if(oldkeys == KEY_CROUCH)
			{
				if(GetTickCountDifference(tickcount(), tick_CrouchKey[playerid]) < 250)
				{
					stop SitDownTimer[playerid];
				}
			}

			if(newkeys & KEY_SPRINT && newkeys & KEY_CROUCH)
			{
				if(!IsPlayerKnockedOut(playerid))
				{
					if(GetPlayerAnimationIndex(playerid) == 1381)
					{
						ClearAnimations(playerid);
					}
					else
					{
						ApplyAnimation(playerid, "ROB_BANK", "SHP_HandsUp_Scr", 4.0, 0, 1, 1, 1, 0);
					}
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
		if(newkeys & KEY_JUMP && !(oldkeys & KEY_JUMP) && GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
		{
			if(random(100) < 60)
				ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff", 4.1, 0, 1, 1, 0, 0);
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

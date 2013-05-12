#define MAX_BALLOON			5

#define BLN_COST		100 // How much it costs to take a balloon ride! Thanks to andrewgrob for the idea :)
#define BLN_NOTENOUGHCASHMSG	"You don't have enough money to take a balloon ride :( It costs $"#BLN_COST"."

#define BLN_MOVE_SPEED		(10.0)
#define BLN_SLOW_SPEED		(1.0)
#define BLN_INCREMENT		(1.0)
#define BLN_LIFT_HEIGHT		(10.0)
#define BLN_ACCEL_TICK		(1500)
#define BLN_DECEL_DIST		(50.0)
#define BLN_BASKET_OFFSET	(1.14)

#define BLN_FRAME_IDLE		-1
#define BLN_FRAME_LIFTOFF	0
#define BLN_FRAME_MOVE		1
#define BLN_FRAME_LANDING	2

#define X			0
#define Y			1
#define Z			2
#define R			3

new
	BLN_Object[MAX_BALLOON],
	BLN_Frame[MAX_BALLOON],
	BLN_Button[MAX_BALLOON][2],
	BLN_idUsed[MAX_BALLOON],
	Float:BLN_Pos[MAX_BALLOON][2][4],
	BLN_CurrentPos[MAX_BALLOON];

AddBalloon(Float:x1, Float:y1, Float:z1, Float:r1, Float:x2, Float:y2, Float:z2, Float:r2)
{
	new id;
	while(BLN_idUsed[id])id++;
	if(id>MAX_BALLOON)return 0;
	BLN_Object[id]=CreateDynamicObject(19335, x1, y1, z1, r1, 0.0, 0.0, FREEROAM_WORLD);
	BLN_Button[id][0]=CreateButton(x1, y1, (z1+BLN_BASKET_OFFSET), "Press F to activate Balloon", FREEROAM_WORLD);
	BLN_Button[id][1]=CreateButton(x2, y2, (z2+BLN_BASKET_OFFSET), "Press F to activate Balloon", FREEROAM_WORLD);

	BLN_Pos[id][0][0]=x1;
	BLN_Pos[id][0][1]=y1;
	BLN_Pos[id][0][2]=z1;
	BLN_Pos[id][0][3]=r1;

	BLN_Pos[id][1][0]=x2;
	BLN_Pos[id][1][1]=y2;
	BLN_Pos[id][1][2]=z2;
	BLN_Pos[id][1][3]=r2;

	BLN_Frame[id]=BLN_FRAME_IDLE;
	BLN_idUsed[id]=true;
	return id;
}
MoveBalloon(id)
{
	if(BLN_Frame[id]==BLN_FRAME_LIFTOFF)
	{
		MoveDynamicObject(BLN_Object[id], BLN_Pos[id][BLN_CurrentPos[id]][X], BLN_Pos[id][BLN_CurrentPos[id]][Y], (BLN_Pos[id][BLN_CurrentPos[id]][Z]+BLN_LIFT_HEIGHT), BLN_SLOW_SPEED, _, _, BLN_Pos[id][BLN_CurrentPos[id]][R]);
	}
	else if(BLN_Frame[id]==BLN_FRAME_MOVE)
	{
		MoveDynamicObject(BLN_Object[id], BLN_Pos[id][BLN_CurrentPos[id]][X], BLN_Pos[id][BLN_CurrentPos[id]][Y], (BLN_Pos[id][BLN_CurrentPos[id]][Z]+BLN_LIFT_HEIGHT), BLN_MOVE_SPEED, _, _, BLN_Pos[id][BLN_CurrentPos[id]][R]);
	}
	else if(BLN_Frame[id]==BLN_FRAME_LANDING)
	{
		MoveDynamicObject(BLN_Object[id], BLN_Pos[id][BLN_CurrentPos[id]][X], BLN_Pos[id][BLN_CurrentPos[id]][Y], BLN_Pos[id][BLN_CurrentPos[id]][Z], BLN_SLOW_SPEED, _, _, BLN_Pos[id][BLN_CurrentPos[id]][R]);
	}
	else BLN_Frame[id]=BLN_FRAME_IDLE;
}

script_Balloon_ObjectMove(id)
{
	if(BLN_Frame[id]==BLN_FRAME_LIFTOFF)
	{
	    BLN_CurrentPos[id]=~BLN_CurrentPos[id];
	    BLN_Frame[id]=BLN_FRAME_MOVE;
	    MoveBalloon(id);
	}
	else if(BLN_Frame[id]==BLN_FRAME_MOVE)
	{
		BLN_Frame[id]=BLN_FRAME_LANDING;
		MoveBalloon(id);
	}
	else BLN_Frame[id]=BLN_FRAME_IDLE;
}


//


public OnButtonPress(playerid, buttonid)
{
	for(new i;i<MAX_BALLOON;i++)
	{
		if(buttonid==BLN_Button[i][0] || buttonid==BLN_Button[i][1])
		{
		    if(buttonid==BLN_Button[i][BLN_CurrentPos[i]] && BLN_Frame[i]==BLN_FRAME_IDLE)
		    {
				BLN_Frame[i]=BLN_FRAME_LIFTOFF;
				MoveBalloon(i);
			}
			else ShowActionText(playerid, "Balloon isn't here yet", 3000);
			break;
		}
	}
	CallLocalFunction("BLN_OnButtonPress", "dd", playerid, buttonid);
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress BLN_OnButtonPress
forward OnButtonPress(playerid, buttonid);


//


public OnDynamicObjectMoved(objectid)
{
	for(new i;i<MAX_BALLOON;i++)if(objectid==BLN_Object[i])script_Balloon_ObjectMove(i);
	CallLocalFunction("BLN_OnDynamicObjectMoved", "d", objectid);
}
#if defined _ALS_OnDynamicObjectMoved
	#undef OnDynamicObjectMoved
#else
	#define _ALS_OnDynamicObjectMoved
#endif
#define OnDynamicObjectMoved BLN_OnDynamicObjectMoved
forward OnDynamicObjectMoved(objectid);

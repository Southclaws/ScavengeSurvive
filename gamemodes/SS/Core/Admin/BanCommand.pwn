#include <YSI\y_hooks>


enum (<<=1)
{
	BAN_DIE = 1,
	BAN_VEH_DESTROY,
	BAN_DELETE_ACCOUNT
}


static
	ban_CurrentTarget[MAX_PLAYERS],
	ban_CurrentReason[MAX_PLAYERS][MAX_BAN_REASON],
	ban_CurrentDuration[MAX_PLAYERS],
	ban_CurrentOptions[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	ban_CurrentTarget[playerid] = INVALID_PLAYER_ID;
	ban_CurrentReason[playerid][0] = EOS;
	ban_CurrentDuration[playerid] = 0;
	ban_CurrentOptions[playerid] = 0;
}

BanPlayerByCommand(playerid, targetid)
{
	TogglePlayerControllable(targetid, false);

	FormatBanReasonDialog(playerid);

	ban_CurrentTarget[playerid] = targetid;
}

CancelBan(playerid)
{
	TogglePlayerControllable(ban_CurrentTarget[playerid], true);

	ban_CurrentTarget[playerid] = INVALID_PLAYER_ID;
	ban_CurrentReason[playerid][0] = EOS;
	ban_CurrentDuration[playerid] = 0;
	ban_CurrentOptions[playerid] = 0;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_BanReason)
	{
		if(response)
		{
			ban_CurrentReason[playerid][0] = EOS;
			strcat(ban_CurrentReason[playerid], inputtext);

			FormatBanDurationDialog(playerid);
		}
		else
		{
			CancelBan(playerid);
		}
	}

	if(dialogid == d_BanDuration)
	{
		if(response)
		{
			if(!strcmp(inputtext, "forever", true))
			{
				ban_CurrentDuration[playerid] = 0;
				FormatBanOptionsDialog(playerid);
				return 1;
			}

			new
				value,
				type[16];

			if(sscanf(inputtext, "ds[16]", value, type))
			{
				FormatBanDurationDialog(playerid);
				return 1;
			}

			if(value <= 0)
			{
				FormatBanDurationDialog(playerid);
				return 1;
			}

			if(!strcmp(type, "day", true, 3))
			{
				ban_CurrentDuration[playerid] = value * 86400;
				FormatBanOptionsDialog(playerid);
				return 1;
			}

			if(!strcmp(type, "week", true, 4))
			{
				ban_CurrentDuration[playerid] = value * 604800;
				FormatBanOptionsDialog(playerid);
				return 1;
			}

			if(!strcmp(type, "month", true, 5))
			{
				ban_CurrentDuration[playerid] = value * 2628000;
				FormatBanOptionsDialog(playerid);
				return 1;
			}
		}
		else
		{
			FormatBanReasonDialog(playerid);
		}
	}

	if(dialogid == d_BanOptions)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					if(ban_CurrentOptions[playerid] & BAN_DIE)
						f:ban_CurrentOptions[playerid]<BAN_DIE>;

					else
						t:ban_CurrentOptions[playerid]<BAN_DIE>;

					FormatBanOptionsDialog(playerid);
				}
				case 1:
				{
					if(ban_CurrentOptions[playerid] & BAN_VEH_DESTROY)
						f:ban_CurrentOptions[playerid]<BAN_VEH_DESTROY>;

					else
						t:ban_CurrentOptions[playerid]<BAN_VEH_DESTROY>;

					FormatBanOptionsDialog(playerid);
				}
				case 2:
				{
					if(ban_CurrentOptions[playerid] & BAN_DELETE_ACCOUNT)
						f:ban_CurrentOptions[playerid]<BAN_DELETE_ACCOUNT>;

					else
						t:ban_CurrentOptions[playerid]<BAN_DELETE_ACCOUNT>;

					FormatBanOptionsDialog(playerid);
				}
				case 3:
				{
					FinaliseBan(playerid);
				}
			}
		}
		else
		{
			FormatBanDurationDialog(playerid);
		}
	}

	return 1;
}

FormatBanReasonDialog(playerid)
{
	ShowPlayerDialog(playerid, d_BanReason, DIALOG_STYLE_INPUT, "Please enter ban reason",
		"Enter the ban reason below. The character limit is 128. After this screen you can choose the ban duration.",
		"Continue", "Cancel");
}

FormatBanDurationDialog(playerid)
{
	ShowPlayerDialog(playerid, d_BanDuration, DIALOG_STYLE_INPUT, "Please enter ban duration",
		"Enter the ban duration below. You can type a number then one of either: 'days', 'weeks' or 'months'. Type 'forever' for perma-ban.",
		"Continue", "Cancel");
}

FormatBanOptionsDialog(playerid)
{
	new str[102];

	format(str, sizeof(str),
		"Kill player on ban: %s\n\
		Destroy vehicle on ban: %s\n\
		Delete account on ban: %s\n\
		Finalize Ban",
		(ban_CurrentOptions[playerid] & BAN_DIE) ? ("true") : ("false"),
		(ban_CurrentOptions[playerid] & BAN_VEH_DESTROY) ? ("true") : ("false"),
		(ban_CurrentOptions[playerid] & BAN_DELETE_ACCOUNT) ? ("true") : ("false"));

	ShowPlayerDialog(playerid, d_BanOptions, DIALOG_STYLE_LIST, "Choose some ban options below", str, "Continue", "Back");
}

FinaliseBan(playerid)
{
	new
		targetid = ban_CurrentTarget[playerid],
		name[MAX_PLAYER_NAME];

	GetPlayerName(targetid, name, MAX_PLAYER_NAME);

	if(ban_CurrentOptions[playerid] & BAN_DIE)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:r;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, r);

		DropItems(targetid, x, y, z, r);

		f:gPlayerBitData[targetid]<Alive>;
	}

	if(ban_CurrentOptions[playerid] & BAN_VEH_DESTROY)
	{
		DestroyVehicle(GetPlayerLastVehicle(targetid));
	}

	if(!BanPlayerByName(name, ban_CurrentReason[playerid], playerid, ban_CurrentDuration[playerid]))
	{
		Msg(playerid, RED, " >  An error occurred.");
		return 0;
	}

	if(ban_CurrentOptions[playerid] & BAN_DELETE_ACCOUNT)
	{
		DeleteAccount(name);
	}

	MsgF(playerid, YELLOW, " >  Banned "C_BLUE"%s", name);

	return 1;
}

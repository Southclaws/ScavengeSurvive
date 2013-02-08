#include <YSI\y_hooks>

#if defined AddCashText

stock GivePlayerMoneyEx(playerid, money)
{
	new
		tmpstr[16],
		sign;

	if(money > 0)
		sign = '+';

	else
		sign = '-';

	format(tmpstr, 16, "%c$%d", sign, abs(money));

	PlayerTextDrawSetString(playerid, AddCashText, tmpstr);
	PlayerTextDrawShow(playerid, AddCashText);
	GivePlayerMoney(playerid, money);

	defer HideCashText(playerid);

	return 1;
}
timer HideCashText[2000](playerid)
{
	PlayerTextDrawHide(playerid, AddCashText);
}
#define GivePlayerMoney GivePlayerMoneyEx

#endif

#if defined AddScoreText

stock GivePlayerScore(playerid, score)
{
	new
		tmpstr[16],
		sign;

	if(score > 0)
		sign = '+';

	else
		sign = '-';

	format(tmpstr, 16, "%c%dpts", sign, abs(score));

	PlayerTextDrawSetString(playerid, AddScoreText, tmpstr);
	PlayerTextDrawShow(playerid, AddScoreText);
	SetPlayerScore(playerid, GetPlayerScore(playerid) + score);

	defer HideScoreText(playerid);

	return 1;
}
timer HideScoreText[2000](playerid)
{
	PlayerTextDrawHide(playerid, AddScoreText);
}

#endif


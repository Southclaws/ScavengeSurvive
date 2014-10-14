#include <YSI\y_hooks>


#define MAX_INFO_MESSAGE			(8)
#define MAX_INFO_MESSAGE_LEN		(128)


static
		ifm_Messages[MAX_INFO_MESSAGE][MAX_INFO_MESSAGE_LEN],
		ifm_Total,
		ifm_Interval,
		ifm_Current;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'InfoMessage'...");

	ifm_Messages[0] = "(info 1) Please update the 'server/infomsgs' array in '"SETTINGS_FILE"'.";
	ifm_Messages[1] = "(info 1) Please update the 'server/infomsgs' array in '"SETTINGS_FILE"'.";
	ifm_Messages[2] = "(info 1) Please update the 'server/infomsgs' array in '"SETTINGS_FILE"'.";

	GetSettingStringArray("infomessage/messages", ifm_Messages, 3, ifm_Messages, ifm_Total);
	GetSettingInt("infomessage/interval", 5, ifm_Interval);

	defer InfoMessage(); // Todo: move to info message module
}

timer InfoMessage[ifm_Interval * 60000]()
{
	if(ifm_Current >= ifm_Total)
		ifm_Current = 0;

	MsgAll(YELLOW, sprintf(" >  "C_BLUE"%s", ifm_Messages[ifm_Current]));

	ifm_Current++;

	defer InfoMessage();
}

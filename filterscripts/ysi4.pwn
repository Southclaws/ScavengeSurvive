/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaws" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <a_samp>

#include <crashdetect>				// By Zeex					http://forum.sa-mp.com/showthread.php?t=262796
#include <sscanf2>					// By Y_Less:				https://github.com/Southclaws/sscanf2
#include <YSI_4\y_utils>			// By Y_Less, 3.1:			https://github.com/Southclaws/YSI-3.1
#include <YSI_4\y_va>
#include <YSI_4\y_timers>
#include <YSI_4\y_hooks>
#include <YSI_4\y_iterate>
#include <YSI_4\y_ini>
#include <YSI_4\y_dialog>

#include <streamer>					// By Incognito, v2.7.5.2:	http://forum.sa-mp.com/showthread.php?t=102865
#include <irc>						// By Incognito, 1.4.5:		http://forum.sa-mp.com/showthread.php?t=98803
#include <dns>						// By Incognito, 2.4:		http://forum.sa-mp.com/showthread.php?t=75605
#include <sqlitei>					// By Slice, v0.9.7:		http://forum.sa-mp.com/showthread.php?t=303682
#include <formatex>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=313488
#include <strlib>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=362764
#include <md-sort>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=343172
#include <geolocation>				// By Whitetiger:			https://github.com/Whitetigerswt/SAMP-geoip

#define time ctime_time
#include <CTime>					// By RyDeR:				http://forum.sa-mp.com/showthread.php?t=294054
#undef time

#include <progress2>				// By Toribio/Southclaws:	https://github.com/Southclaws/PlayerProgressBar
#include <FileManager>				// By JaTochNietDan, 1.5:	http://forum.sa-mp.com/showthread.php?t=92246
#include <mapandreas>

#include <SimpleINI>				// By Southclaws:			https://github.com/Southclaws/SimpleINI
#include <modio>					// By Southclaws:			https://github.com/Southclaws/modio
//#include <SIF_YSI_4>				// By Southclaws, HEAD:		https://github.com/Southclaws/SIF
#include <SIF_YSI_4\Core.pwn>
#include <SIF_YSI_4\Button.pwn>
#include <SIF_YSI_4\Door.pwn>
#include <SIF_YSI_4\Item.pwn>
#include <SIF_YSI_4\Inventory.pwn>
#include <SIF_YSI_4\Container.pwn>
#include <SIF_YSI_4\extensions\ItemArrayData>
#include <SIF_YSI_4\extensions\ItemList>
#include <SIF_YSI_4\extensions\InventoryDialog>
#include <SIF_YSI_4\extensions\InventoryKeys>
#include <SIF_YSI_4\extensions\ContainerDialog>
#include <SIF_YSI_4\extensions\Craft>
#include <SIF_YSI_4\extensions\DebugLabels>
#include <WeaponData>				// By Southclaws:			https://github.com/Southclaws/AdvancedWeaponData
#include <Line>						// By Southclaws:			https://github.com/Southclaws/Line
#include <Zipline>					// By Southclaws:			https://github.com/Southclaws/Zipline
#include <Ladder>					// By Southclaws:			https://github.com/Southclaws/Ladder

public OnFilterScriptInit()
{
	printf("return 1;:  %d", CallLocalFunction("func0", "d", 8));
	printf("return 0;:  %d", CallLocalFunction("func1", "d", 8));
	printf("return -1;: %d", CallLocalFunction("func2", "d", 8));
	printf("return -2;: %d", CallLocalFunction("func3", "d", 8));

	return 1;
}

#define Y_HOOKS_CONTINUE_RETURN_1	(1)
#define Y_HOOKS_CONTINUE_RETURN_0	(0)
#define Y_HOOKS_BREAK_RETURN_0		(-1)
#define Y_HOOKS_BREAK_RETURN_1		(-2)

hook func0(var)
{
	print("func0");

	return 1;
}
#include <YSI_4\y_hooks>
hook func0(var)
{
	print("func0 call 2");

	return 1;
}

hook func1(var)
{
	print("func1");

	return 0;
}
#include <YSI_4\y_hooks>
hook func1(var)
{
	print("func1 call2");

	return 0;
}

hook func2(var)
{
	print("func2");

	return -1;
}
#include <YSI_4\y_hooks>
hook func2(var)
{
	print("func2 call 2");

	return -1;
}

hook func3(var)
{
	print("func3");

	return -2;
}
#include <YSI_4\y_hooks>
hook func3(var)
{
	print("func3 call 2");

	return -2;
}

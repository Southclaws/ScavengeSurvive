/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

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
#include <sscanf2>					// By Y_Less:				https://github.com/Southclaw/sscanf2
#include <YSI_4\y_utils>			// By Y_Less, 3.1:			https://github.com/Southclaw/YSI-3.1
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

#include <progress2>				// By Toribio/Southclaw:	https://github.com/Southclaw/PlayerProgressBar
#include <FileManager>				// By JaTochNietDan, 1.5:	http://forum.sa-mp.com/showthread.php?t=92246
#include <mapandreas>

#include <SimpleINI>				// By Southclaw:			https://github.com/Southclaw/SimpleINI
#include <modio>					// By Southclaw:			https://github.com/Southclaw/modio
//#include <SIF_YSI_4>				// By Southclaw, HEAD:		https://github.com/Southclaw/SIF
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
#include <WeaponData>				// By Southclaw:			https://github.com/Southclaw/AdvancedWeaponData
#include <Line>						// By Southclaw:			https://github.com/Southclaw/Line
#include <Zipline>					// By Southclaw:			https://github.com/Southclaw/Zipline
#include <Ladder>					// By Southclaw:			https://github.com/Southclaw/Ladder

public OnFilterScriptInit()
{
	return 1;
}

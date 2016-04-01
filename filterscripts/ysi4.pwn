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

#include <YSI_4\y_utils>
#include <YSI_4\y_va>
#include <YSI_4\y_timers>
#include <YSI_4\y_hooks>
#include <YSI_4\y_iterate>
#include <YSI_4\y_ini>
#include <YSI_4\y_dialog>

#include <streamer>

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

public OnFilterScriptInit()
{
	return 1;
}

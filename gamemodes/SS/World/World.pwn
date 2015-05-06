#include "ss/World/Spawn.pwn"

#include "ss/World/Zones/LS.pwn"
#include "ss/World/Zones/SF.pwn"
#include "ss/World/Zones/LV.pwn"
#include "ss/World/Zones/RC.pwn"
#include "ss/World/Zones/FC.pwn"
#include "ss/World/Zones/BC.pwn"
#include "ss/World/Zones/TR.pwn"
#include "ss/World/Puzzles/Area69.pwn"
#include "ss/World/Puzzles/Ranch.pwn"
#include "ss/World/Puzzles/MtChill.pwn"
#include "ss/World/Puzzles/CodeHunt.pwn"
#include "ss/World/HouseLoot.pwn"

#include "ss/World/Xmas.pwn"

new gMapName[17] = 	"San Androcalypse";

#include <YSI\y_hooks>


hook OnGameModeInit()
{
	defer LoadWorld();
}

timer LoadWorld[100]()
{
	new
		itemtypename[ITM_MAX_NAME],
		itemcounts[ITM_MAX_TYPES];

	// store this to a list and compare after
	for(new ItemType:i; i < ITM_MAX_TYPES; i++)
	{
		if(!IsValidItemType(i))
			break;

		if(GetItemTypeCount(i) == 0)
			continue;

		itemcounts[i] = GetItemTypeCount(i);
	}


	Load_LS();
	Load_SF();
	Load_LV();
	Load_RC();
	Load_FC();
	Load_BC();
	Load_TR();

	// compare with previous list and print differences
	for(new ItemType:i; i < ITM_MAX_TYPES; i++)
	{
		if(!IsValidItemType(i))
			break;

		if(GetItemTypeCount(i) == 0)
			continue;

		GetItemTypeUniqueName(i, itemtypename);

		printf("[%03d] Loaded:%04d, Spawned:%04d, Total:%04d, '%s'", _:i, itemcounts[i], GetItemTypeCount(i) - itemcounts[i], GetItemTypeCount(i), itemtypename);
	}
}

/*
	This is a utility script for converting between file structures for the 
	Player/Inventory data files.

	This code is for converting from the November format to the brand new modio
	binary tag format.
*/


#include <YSI\y_hooks>

#define DIRECTORY_PLAYER_ORIGINAL		"SSS/Player/"
#define DIRECTORY_INVENTORY_ORIGINAL	"SSS/Inventory/"
#define DIRECTORY_PLAYER_BACKUP			"SSS/Player/BACKUP/"
#define DIRECTORY_INVENTORY_BACKUP		"SSS/Inventory/BACKUP/"

// The old file structure

enum
{
	PLY_CELL_OLD_FILE_VERSION,
	PLY_CELL_OLD_HEALTH,
	PLY_CELL_OLD_ARMOUR,
	PLY_CELL_OLD_FOOD,
	PLY_CELL_OLD_SKIN,
	PLY_CELL_OLD_HAT,
	PLY_CELL_OLD_HOLST,
	PLY_CELL_OLD_HOLSTEX,
	PLY_CELL_OLD_HELD,
	PLY_CELL_OLD_HELDEX,
	PLY_CELL_OLD_STANCE,
	PLY_CELL_OLD_BLEEDING,
	PLY_CELL_OLD_CUFFED,
	PLY_CELL_OLD_WARNS,
	PLY_CELL_OLD_FREQ,
	PLY_CELL_OLD_CHATMODE,
	PLY_CELL_OLD_INFECTED,
	PLY_CELL_OLD_TOOLTIPS,
	PLY_CELL_OLD_SPAWN_X,
	PLY_CELL_OLD_SPAWN_Y,
	PLY_CELL_OLD_SPAWN_Z,
	PLY_CELL_OLD_SPAWN_R,
	PLY_CELL_OLD_MASK,
	PLY_CELL_OLD_MUTE_TIME,
	PLY_CELL_OLD_KNOCKOUT,
	PLY_CELL_OLD_BAGTYPE,
	PLY_CELL_OLD_END
}

enum
{
	INV_CELL_OLD_ITEMS[4 * 3],
	INV_CELL_OLD_BAGITEMS[9 * 3],
	INV_CELL_OLD_END
}


static
	filecheck_ItemList[ITM_LST_OF_ITEMS(9)],
	conversions,
	deletions;


PerformGlobalPlayerFileCheck()
{
	print("\n\n\nPERFORMING PLAYER DATA AND INVENTORY FILE STRUCTURE CHECK\n\n\n");
	new
		dir:direc,
		item[MAX_PLAYER_NAME + 5],
		type;

	// Player char files

	direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_PLAYER_ORIGINAL);

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			CheckPlayerFile(item);
		}
	}

	dir_close(direc);
	printf("\n\n\nFILE CHECK COMPLETE. %d FILES CHANGED, %d FILES REMOVED\n\n\n", conversions, deletions);
}

CheckPlayerFile(item[])
{
	new
		filename_ply[64],
		filename_inv[64],

		File:file_ply,
		File:file_inv,

		ply_data[PLY_CELL_OLD_END],
		inv_data[INV_CELL_OLD_END];

	format(filename_ply, sizeof(filename_ply), DIRECTORY_PLAYER_ORIGINAL"%s", item);
	format(filename_inv, sizeof(filename_inv), DIRECTORY_INVENTORY_ORIGINAL"%s", item);

	if(!fexist(filename_ply))
	{
		printf("ERROR: Player file '%s' not found. Removing corresponding INV file if exists.", filename_ply);
		fremove(filename_inv);
		deletions++;
		return 0;
	}

	if(!fexist(filename_inv))
	{
		printf("ERROR: Inventory file '%s' not found. Removing corresponding PLY file if exists.", filename_inv);
		fremove(filename_ply);
		deletions++;
		return -1;
	}

	// Now, check if the file should even be there by running a check on the
	// file extension and account database.

	new
		len,
		name[MAX_PLAYER_NAME];

	len = strlen(item);

	if(item[len - 4] == '.')
	{
		strmid(name, item, 0, len - 4);
	}
	else
	{
		fremove(filename_ply);
		fremove(filename_inv);
		printf("[INFO] Removed files '%s', '%s' because they don't match the correct name structure.", filename_ply, filename_inv);
		deletions += 2;
		return 1;
	}

	if(!AccountExists(name))
	{
		fremove(filename_ply);
		fremove(filename_inv);
		printf("[INFO] Removed files '%s', '%s' because they do not exist in the player database.", filename_ply, filename_inv);
		deletions += 2;
		return 1;
	}

	// Now, on to the actual conversion process. Open up the files for reading:

	file_ply = fopen(filename_ply, io_read);

	if(!file_ply)
		return -2;

	file_inv = fopen(filename_inv, io_read);

	if(!file_inv)
		return -3;

	// get the file data and store it into tables:

	fblockread(file_ply, ply_data, sizeof(ply_data));
	fblockread(file_inv, inv_data, sizeof(inv_data));

	fclose(file_ply);
	fclose(file_inv);

	// File version matches modio, no conversion required.
	if(ply_data[0] == MODIO_FILE_STRUCTURE_VERSION)
	{
		printf("ERROR: Attempted conversion on a modio format file. Please disable 'file-check' in settings.json.");
		return 0;
	}


/*
	Player data
*/


	// First, dump the original data into a backup in case anything fails
	// (Also, can't forget to create a directory for the backups!)

	if(!dir_exists(DIRECTORY_SCRIPTFILES DIRECTORY_PLAYER_BACKUP))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES DIRECTORY_PLAYER_BACKUP"' not found. Creating directory.");
		dir_create(DIRECTORY_SCRIPTFILES DIRECTORY_PLAYER_BACKUP);
	}

	new backup_ply[64];
	format(backup_ply, sizeof(backup_ply), DIRECTORY_PLAYER_BACKUP"%s", item);

	file_ply = fopen(backup_ply, io_write);
	fblockwrite(file_ply, ply_data);
	fclose(file_ply);

	/*
		push the same data using modio
	*/
	modio_push(filename_ply, _T<C,H,A,R>, PLY_CELL_OLD_END, ply_data, false, false, false);


/*
	Inventory
*/


	new backup_inv[64];
	if(!dir_exists(DIRECTORY_SCRIPTFILES DIRECTORY_INVENTORY_BACKUP))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES DIRECTORY_INVENTORY_BACKUP"' not found. Creating directory.");
		dir_create(DIRECTORY_SCRIPTFILES DIRECTORY_INVENTORY_BACKUP);
	}

	format(backup_inv, sizeof(backup_inv), DIRECTORY_INVENTORY_BACKUP"%s", item);

	file_inv = fopen(backup_inv, io_write);
	fblockwrite(file_ply, ply_data);
	fclose(file_ply);

	// Now populate the new array with the old data.
	
	new
		items[9],
		itemcount,
		itemlist;

	for(new i = INV_CELL_OLD_ITEMS; i < INV_CELL_OLD_BAGITEMS; i += 3)
	{
		items[itemcount] = CreateItem(ItemType:inv_data[i]);

		if(!IsValidItem(items[itemcount]))
			break;

		SetItemExtraData(items[itemcount], inv_data[i+2]);

		itemcount++;
	}

	itemlist = CreateItemList(items, itemcount);
	GetItemList(itemlist, filecheck_ItemList);
	/*
		push the itemlist data using modio
	*/
	modio_push(filename_ply, _T<I,N,V,0>, GetItemListSize(itemlist), filecheck_ItemList, false, false, false);
	DestroyItemList(itemlist);

	for(new i; i < itemcount; i++)
		DestroyItem(items[i]);


/*
	Bag
*/

	itemcount = 0;

	for(new i = INV_CELL_OLD_BAGITEMS; i < INV_CELL_OLD_END; i += 3)
	{
		items[itemcount] = CreateItem(ItemType:inv_data[i]);

		if(!IsValidItem(items[itemcount]))
			break;

		SetItemExtraData(items[itemcount], inv_data[i+2]);

		itemcount++;
	}

	itemlist = CreateItemList(items, itemcount);
	GetItemList(itemlist, filecheck_ItemList);
	/*
		push the itemlist data using modio
	*/
	modio_push(filename_ply, _T<B,A,G,0>, GetItemListSize(itemlist), filecheck_ItemList, true, true, true);
	DestroyItemList(itemlist);

	for(new i; i < itemcount; i++)
		DestroyItem(items[i]);

	conversions++;

	return 1;
}

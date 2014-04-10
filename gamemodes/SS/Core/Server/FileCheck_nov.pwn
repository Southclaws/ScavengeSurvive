/*
	This is a utility script for converting between file structures for the 
	Player/Inventory data files. Hopefully you will only ever have to use this
	script once for the November file structure update.

	If it is ever needed again, it will be updated to match whatever formats it
	will be converting between.

	~

	Old file sizes (pre-november update)
		chr: 96 bytes (24 cells)
		inv: 108 bytes (27 cells) or ((4 * 2) + 1 + (9 * 2))

	New file sizes
		chr: 104 bytes (26 cells)
		inv: 156 bytes (39 cells) or ((4 * 3) + (9 * 3))

	~

	That '1' in the middle of the old structure was the bag type, this was moved
	to the character data file instead.

	Each item uses 3 cells (12B) instead of 2 (8B) now since an extra-data size
	was added for a future addition to allow more complex item extra-data.

	~

	Note: The addition of the "PLY_CELL_FILE_VERSION" will allow easier
	conversion in the future which will be done completely by SaveLoad at
	runtime instead of initiation.
*/


#include <YSI\y_hooks>

#define DIRECTORY_PLAYER_BACKUP		"SSS/Player/BACKUP/"
#define DIRECTORY_INVENTORY_BACKUP	"SSS/Inventory/BACKUP/"

// The old file structure

enum
{
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
	PLY_CELL_OLD_END
}

enum
{
	INV_CELL_OLD_ITEMS[4 * 2],
	INV_CELL_OLD_BAGTYPE,
	INV_CELL_OLD_BAGITEMS[9 * 2],
	INV_CELL_OLD_END
}

// The new file structure

enum
{
	PLY_CELL_NEW_FILE_VERSION,
	PLY_CELL_NEW_HEALTH,
	PLY_CELL_NEW_ARMOUR,
	PLY_CELL_NEW_FOOD,
	PLY_CELL_NEW_SKIN,
	PLY_CELL_NEW_HAT,
	PLY_CELL_NEW_HOLST,
	PLY_CELL_NEW_HOLSTEX,
	PLY_CELL_NEW_HELD,
	PLY_CELL_NEW_HELDEX,
	PLY_CELL_NEW_STANCE,
	PLY_CELL_NEW_BLEEDING,
	PLY_CELL_NEW_CUFFED,
	PLY_CELL_NEW_WARNS,
	PLY_CELL_NEW_FREQ,
	PLY_CELL_NEW_CHATMODE,
	PLY_CELL_NEW_INFECTED,
	PLY_CELL_NEW_TOOLTIPS,
	PLY_CELL_NEW_SPAWN_X,
	PLY_CELL_NEW_SPAWN_Y,
	PLY_CELL_NEW_SPAWN_Z,
	PLY_CELL_NEW_SPAWN_R,
	PLY_CELL_NEW_MASK,
	PLY_CELL_NEW_MUTE_TIME,
	PLY_CELL_NEW_KNOCKOUT,
	PLY_CELL_NEW_BAGTYPE,
	PLY_CELL_NEW_END
}

enum
{
	INV_CELL_NEW_ITEMS[4 * 3],
	INV_CELL_NEW_BAGITEMS[9 * 3],
	INV_CELL_NEW_END
}


static
	conversions,
	deletions;


PerformGlobalPlayerFileCheck()
{
	print("\n\n\nPERFORMING PLAYER DATA AND INVENTORY FILE STRUCTURE CHECK\n\n\n");
	new
		dir:direc,
		item[MAX_PLAYER_NAME + 5],
		type;

	// Player inv files

	direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_INVENTORY);

	new
		oldpath[64],
		newpath[64];

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			if(strfind(item, ".inv", false, strlen(item) - 5) != -1)
			{
				printf("[INFO] Converting '%s' file extension to .dat", item);

				format(oldpath, sizeof(oldpath), DIRECTORY_SCRIPTFILES DIRECTORY_INVENTORY"%s", item);
				strreplace(item, ".inv", ".dat");
				format(newpath, sizeof(newpath), DIRECTORY_SCRIPTFILES DIRECTORY_INVENTORY"%s", item);

				file_move(oldpath, newpath);
				file_delete(oldpath); 
			}
		}
	}

	dir_close(direc);

	// Player char files

	direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_PLAYER);

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
		old_filename_ply[64],
		old_filename_inv[64],
		new_filename_ply[64],
		new_filename_inv[64],

		File:old_file_ply,
		File:old_file_inv,
		File:new_file_ply,
		File:new_file_inv,

		tmp_ply[PLY_CELL_OLD_END],
		tmp_inv[INV_CELL_OLD_END],

		old_data_ply[PLY_CELL_OLD_END],
		old_data_inv[INV_CELL_OLD_END],
		new_data_ply[PLY_CELL_NEW_END],
		new_data_inv[INV_CELL_NEW_END];

	format(old_filename_ply, sizeof(old_filename_ply), DIRECTORY_PLAYER"%s", item);
	format(old_filename_inv, sizeof(old_filename_inv), DIRECTORY_INVENTORY"%s", item);

	if(!fexist(old_filename_ply))
	{
		printf("ERROR: Player file '%s' not found. Removing corresponding INV file if exists.", old_filename_ply);
		fremove(old_filename_inv);
		deletions++;
		return 0;
	}

	if(!fexist(old_filename_inv))
	{
		printf("ERROR: Inventory file '%s' not found. Removing corresponding PLY file if exists.", old_filename_inv);
		fremove(old_filename_ply);
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
		fremove(old_filename_ply);
		fremove(old_filename_inv);
		printf("[INFO] Removed files '%s', '%s' because they don't match the correct name structure.", old_filename_ply, old_filename_inv);
		deletions += 2;
		return 1;
	}

	if(!AccountExists(name))
	{
		fremove(old_filename_ply);
		fremove(old_filename_inv);
		printf("[INFO] Removed files '%s', '%s' because they do not exist in the player database.", old_filename_ply, old_filename_inv);
		deletions += 2;
		return 1;
	}

	// Now, on to the actual conversion process. Open up the files for reading:

	old_file_ply = fopen(old_filename_ply, io_read);

	if(!old_file_ply)
		return -2;

	old_file_inv = fopen(old_filename_inv, io_read);

	if(!old_file_inv)
		return -3;

	// Declare some memory to store the return values of the read checks in:

	new
		ret_ply,
		ret_inv;

	// Actual reads: get the file data and store it into tables:

	fblockread(old_file_ply, old_data_ply, sizeof(old_data_ply));
	fblockread(old_file_inv, old_data_inv, sizeof(old_data_inv));

	// Perform dummy reads, if they return 0 it means the end of the file was
	// reached and the file is way too small to be the new version. Convert!

	ret_ply = fblockread(old_file_ply, tmp_ply, sizeof(tmp_ply));
	ret_inv = fblockread(old_file_inv, tmp_inv, sizeof(tmp_inv));

	fclose(old_file_ply);
	fclose(old_file_inv);

	if(ret_ply == 0)
	{
		// First, dump the original data into a backup in case anything fails
		// (Also, can't forget to create a directory for the backups!)

		if(!dir_exists(DIRECTORY_SCRIPTFILES DIRECTORY_PLAYER_BACKUP))
		{
			print("ERROR: Directory '"DIRECTORY_SCRIPTFILES DIRECTORY_PLAYER_BACKUP"' not found. Creating directory.");
			dir_create(DIRECTORY_SCRIPTFILES DIRECTORY_PLAYER_BACKUP);
		}

		format(new_filename_ply, sizeof(new_filename_ply), DIRECTORY_PLAYER_BACKUP"%s", item);

		old_file_ply = fopen(new_filename_ply, io_write);
		fblockwrite(old_file_ply, old_data_ply);
		fclose(old_file_ply);

		// Now populate the new array with the old data.

		new_data_ply[PLY_CELL_NEW_FILE_VERSION]	= 10; // CHARACTER_DATA_FILE_VERSION from SaveLoad.pwn
		new_data_ply[PLY_CELL_NEW_HEALTH]		= old_data_ply[PLY_CELL_OLD_HEALTH];
		new_data_ply[PLY_CELL_NEW_ARMOUR]		= old_data_ply[PLY_CELL_OLD_ARMOUR];
		new_data_ply[PLY_CELL_NEW_FOOD]			= old_data_ply[PLY_CELL_OLD_FOOD];
		new_data_ply[PLY_CELL_NEW_SKIN]			= old_data_ply[PLY_CELL_OLD_SKIN];
		new_data_ply[PLY_CELL_NEW_HAT]			= old_data_ply[PLY_CELL_OLD_HAT];
		new_data_ply[PLY_CELL_NEW_HOLST]		= old_data_ply[PLY_CELL_OLD_HOLST];
		new_data_ply[PLY_CELL_NEW_HOLSTEX]		= old_data_ply[PLY_CELL_OLD_HOLSTEX];
		new_data_ply[PLY_CELL_NEW_HELD]			= old_data_ply[PLY_CELL_OLD_HELD];
		new_data_ply[PLY_CELL_NEW_HELDEX]		= old_data_ply[PLY_CELL_OLD_HELDEX];
		new_data_ply[PLY_CELL_NEW_STANCE]		= old_data_ply[PLY_CELL_OLD_STANCE];
		new_data_ply[PLY_CELL_NEW_BLEEDING]		= old_data_ply[PLY_CELL_OLD_BLEEDING];
		new_data_ply[PLY_CELL_NEW_CUFFED]		= old_data_ply[PLY_CELL_OLD_CUFFED];
		new_data_ply[PLY_CELL_NEW_WARNS]		= old_data_ply[PLY_CELL_OLD_WARNS];
		new_data_ply[PLY_CELL_NEW_FREQ]			= old_data_ply[PLY_CELL_OLD_FREQ];
		new_data_ply[PLY_CELL_NEW_CHATMODE]		= old_data_ply[PLY_CELL_OLD_CHATMODE];
		new_data_ply[PLY_CELL_NEW_INFECTED]		= old_data_ply[PLY_CELL_OLD_INFECTED];
		new_data_ply[PLY_CELL_NEW_TOOLTIPS]		= old_data_ply[PLY_CELL_OLD_TOOLTIPS];
		new_data_ply[PLY_CELL_NEW_SPAWN_X]		= old_data_ply[PLY_CELL_OLD_SPAWN_X];
		new_data_ply[PLY_CELL_NEW_SPAWN_Y]		= old_data_ply[PLY_CELL_OLD_SPAWN_Y];
		new_data_ply[PLY_CELL_NEW_SPAWN_Z]		= old_data_ply[PLY_CELL_OLD_SPAWN_Z];
		new_data_ply[PLY_CELL_NEW_SPAWN_R]		= old_data_ply[PLY_CELL_OLD_SPAWN_R];
		new_data_ply[PLY_CELL_NEW_MASK]			= old_data_ply[PLY_CELL_OLD_MASK];
		new_data_ply[PLY_CELL_NEW_MUTE_TIME]	= old_data_ply[PLY_CELL_OLD_MUTE_TIME];
		new_data_ply[PLY_CELL_NEW_KNOCKOUT]		= old_data_ply[PLY_CELL_OLD_KNOCKOUT];
		new_data_ply[PLY_CELL_NEW_BAGTYPE]		= old_data_inv[INV_CELL_OLD_BAGTYPE];

		// Format the new filename and write the new data to the file.
		// The files should now be 104 bytes.

		new_file_ply = fopen(old_filename_ply, io_write);
		fblockwrite(new_file_ply, new_data_ply);
		fclose(new_file_ply);

		conversions++;
	}

	if(ret_inv == 0)
	{
		if(!dir_exists(DIRECTORY_SCRIPTFILES DIRECTORY_INVENTORY_BACKUP))
		{
			print("ERROR: Directory '"DIRECTORY_SCRIPTFILES DIRECTORY_INVENTORY_BACKUP"' not found. Creating directory.");
			dir_create(DIRECTORY_SCRIPTFILES DIRECTORY_INVENTORY_BACKUP);
		}

		format(new_filename_inv, sizeof(new_filename_inv), DIRECTORY_INVENTORY_BACKUP"%s", item);

		old_file_inv = fopen(new_filename_inv, io_write);
		fblockwrite(old_file_ply, old_data_ply);
		fclose(old_file_ply);

		// Now populate the new array with the old data.
		
		for(new i = INV_CELL_NEW_ITEMS, j = INV_CELL_OLD_ITEMS; j < (4 * 2); i += 3, j += 2)
		{
			new_data_inv[i] = old_data_inv[j];
			new_data_inv[i + 1] = 1;
			new_data_inv[i + 2] = old_data_inv[j + 1];
		}

		for(new i = INV_CELL_NEW_BAGITEMS, j = INV_CELL_OLD_BAGITEMS; j < (9 * 2); i += 3, j += 2)
		{
			new_data_inv[i] = old_data_inv[j];
			new_data_inv[i + 1] = 1;
			new_data_inv[i + 2] = old_data_inv[j + 1];
		}

		// Format the new filename (inventory will now use .dat instead of the
		// silly .inv extension.)
		// The new files should be 156 bytes.

		new_file_inv = fopen(old_filename_inv, io_write);
		fblockwrite(new_file_inv, new_data_inv);
		fclose(new_file_inv);

		conversions++;
	}

	return 1;
}

This is where player character data files are stored. They are stored
in binary non-encoded format (unlike "ini" files) to minimise
the ease of tampering with player's inventory data.
This also makes saving and loading data faster than encoded files
because, for instance, the value 256 only requires 1 32 bit cell
(4 bytes) rather than 3 32 bit cells (12 bytes) because encoded
files save characters, binary files just save pure data to cells.

This also speeds up the reading/writing process, as an integer
variable will not need to be converted to a string and vice versa.

The files in this folder contain player character data (not inventory/bag data)
This includes values such as health, armour, food, stance or held/holstered weapons.

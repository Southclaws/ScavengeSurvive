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


forward remote_func(arr[]);


#define SIZE 6


main()
{
	new
		arr[SIZE],
		byte_array[SIZE * 4];

	arr = {54, 45, 67, 32, 74, 55};

	shrink_array(arr, byte_array, SIZE);

	for(new i; i < SIZE; i++)
		printf("\t[%d] :: %d", i, arr[i]);

	CallRemoteFunction("remote_func", "s", byte_array);
}


public remote_func(arr[])
{
	for(new i; i < SIZE; i++)
		printf("%02d = %d", i, arr[i]);

	new
		arr_shrunk[SIZE * 4],
		arr_expanded[SIZE];

	for(new i; i < SIZE; i++)
	{
		printf("%02d = %d", i, arr[i]);
		arr_shrunk[i] = arr[i];
	}

	expand_array(arr_shrunk, arr_expanded, SIZE);

	for(new i; i < SIZE; i++)
	{
		printf("\t[%d] :: %f", i, arr_expanded[i]);
	}

	print("\nend\n");
}

stock shrink_array(input[], output[], size)
{
	for(new i, j; i < size * 4; i += 4, j += 1)
	{
		byte_explode(input[j], output[i + 0], output[i + 1], output[i + 2], output[i + 3]);
	}
}

stock expand_array(input[], output[], size)
{
	for(new i, j; i < size * 4; i += 4, j += 1)
	{
		output[j] = byte_rebuild(input[i + 0], input[i + 1], input[i + 2], input[i + 3]);
	}
}

stock byte_rebuild(b1, b2, b3, b4)
{
	return (b1<<24 | b2<<16 | b3<<8 | b4);
}

stock byte_explode(cell, &b1, &b2, &b3, &b4)
{
	b1 = (cell >> 24) & 0xFF;
	b2 = (cell >> 16) & 0xFF;
	b3 = (cell >> 8) & 0xFF;
	b4 = cell & 0xFF;
}

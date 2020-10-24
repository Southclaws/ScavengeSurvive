/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


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

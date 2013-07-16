#include <a_samp>


main()
{
	#define TESTS		1000000

	#define TOTAL		6
	#define MAX			256

	new
		output[TOTAL],
		tick = tickcount();

	for(new iter; iter < TESTS; iter++)
	{


		PickFromList(MAX, TOTAL, output);

/*
		for(new i; i < TOTAL; i++)
		{
			for(new j; j < TOTAL; j++)
			{
				if(output[i] == output[j] && i != j)
					printf("ERROR: Matching output cells %d and %d", i, j);
			}
		}
*/

	}

	printf("%dms to do "#TESTS" iterations", tickcount() - tick);
	printf("%fms per iteration", (float(tickcount() - tick) / float(TESTS)));
}


stock PickFromList(max, count, output[])
{
	new
		idx,
		picked[256];

	if(max > 256)
		print("ERROR: PickFromList function variable 'picked' is too small to match parameter 'max'.");

	while(idx < count)
	{
		output[idx] = random(max);

		if(picked[output[idx]] == 0)
		{
			picked[output[idx]] = 1;
			idx++;
		}
	}
}

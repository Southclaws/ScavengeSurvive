#include <a_samp>


main()
{
	new
		r1 = 0,
		r2 = 1;

	new
		var = (r1 | (r2 << 3));


	printf("Var: %04b %d, - type %d flag %d", var, var, r1, r2);

	new
		b1 = var & 0b111,
		b2 = var & 0b1000;

	printf("First 3: %d, %04b", b1, b1);
	printf("4th bit: %d, %04b", b2, b2);

}

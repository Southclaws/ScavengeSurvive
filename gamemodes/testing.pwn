#include <a_samp>

main()
{
	new
		timestamp1,
		timestamp2,
		days;

	timestamp1 = 1375351503;
	timestamp2 = 1375956305;
	days = (timestamp2 - timestamp1) / 86400;

	printf("Days between %d-%d = %d", timestamp1, timestamp2, days);
}

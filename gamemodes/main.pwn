#include <a_samp>


new gString[32];


main()
{
	new tmp[32];

	tmp = "hello";

	func(tmp);
}


func(string[32])
{
	gString = string;
}

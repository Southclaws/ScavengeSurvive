"return CallLocalFunction\("([A-Za-z_][A-Za-z_0-9]*)", ""\);"
"#if defined $1
		$1();
	#elseif
		return 0;
	#endif"


public OnSomething()
{
	return CallLocalFunction("lib_OnSomething", "");
}
#if defined _ALS_OnSomething
	#undef OnSomething
#else
	#define _ALS_OnSomething
#endif
#define OnSomething lib_OnSomething
#if defined lib_OnSomething
	forward lib_OnSomething();
#endif


"return CallLocalFunction\("([A-Za-z_][A-Za-z_0-9]*)", "[a-z]*", ([A-Za-z_0-9\, ]*)\);"
"#if defined $1
		return $1($2);
	#elseif
		return 0;
	#endif"


"#define (On[A-Za-z_][A-Za-z_0-9]*) ([A-Za-z_]*_On[A-Za-z_0-9]*)
forward [A-Za-z_][A-Za-z_0-9]*\(([A-Za-z_0-9\, ]*)\);"
"#define $1 $2
#if defined $2
	forward $2($3);
#endif"

public OnSomething()
{
	#if defined lib_OnSomething
		return CallLocalFunction("lib_OnSomething", "dd", playerid, vehicleid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnSomething
	#undef OnSomething
#else
	#define _ALS_OnSomething
#endif
#define OnSomething lib_OnSomething
#if defined lib_OnSomething
	forward lib_OnSomething(playerid, vehicleid);
#endif

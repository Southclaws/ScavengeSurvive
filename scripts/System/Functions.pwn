stock returnOrdinal(number)
{
    new
        ordinal[4][3] = { "st", "nd", "rd", "th" };
    number = number < 0 ? -number : number;
    return (((10 < (number % 100) < 14)) ? ordinal[3] : (0 < (number % 10) < 4) ? ordinal[((number % 10) - 1)] : ordinal[3]);
}

//==============================================================================String Functions

stock BoolToString(input, type=0, capital=1)
{
	new tmpStr[9];
	if(input>0)
	{
		if(type==0)tmpStr="true";
		if(type==1)tmpStr="yes";
		if(type==2)tmpStr="on";
		if(type==3)tmpStr="in";
		if(type==4)tmpStr="positive";
		if(type==5)tmpStr="female";
	}
	else
	{
		if(type==0)tmpStr="false";
		if(type==1)tmpStr="no";
		if(type==2)tmpStr="off";
		if(type==3)tmpStr="out";
		if(type==4)tmpStr="negative";
		if(type==5)tmpStr="male";
	}

	if(capital)toupper(tmpStr[0]);
	return tmpStr;
}
stock StringToBool(string[])
{
	new
	TrueBools[]=
	{"true",	"yes",	"on",	"in",	"positive"},
	FalseBools[]=
	{"false",	"no",	"off",	"out",	"negetive"},
	bool:result;
	for(new i;i<sizeof(TrueBools);i++)
	{
		if(!strcmp(string,TrueBools[i],true))
		{result=true;break;}
		if(!strcmp(string,FalseBools[i],true))
		{result=false;break;}
	}
	return result;
}
stock IsNumeric(const string[])
{
	for(new i,j=strlen(string);i<j;i++)if (string[i] > '9' || string[i] < '0') return 0;
	return 1;
}
stock IsCharNumeric(c)
{
	if(c>='0'&&c<='9')return 1;
	return 0;
}
stock IsCharAlphabetic(c)
{
	if((c>='a'&&c<='z')||(c>='A'&&c<='Z'))return 1;
	return 0;
}
#define chrtolower(%1) \
		(((%1) > 0x40 && (%1) <= 0x5A) ? ((%1) | 0x20) : (%1))
stock strtolower(string[])
{
	new retStr[128],i,j;
	while ((j = string[i])) retStr[i++] = chrtolower(j);
	retStr[i] = '\0';
	return retStr;
}

stock UnderscoreToSpace(name[])
{
	new pos = strfind(name,"_", true);
	if( pos != -1 )name[pos] = ' ';
}

stock MsToString(ms, mode = 0)
{
	new
		tmpStr[20],
		h,
		m,
		s;

	h=(ms/(1000*60*60));
	m=(ms%(1000*60*60))/(1000*60);
	s=((ms%(1000*60*60))%(1000*60))/1000;
	ms=ms-(h*60*60*1000)-(m*60*1000)-(s*1000);

	if(mode == 0)format(tmpStr, 20, "%d:%02d:%02d.%03d", h, m, s, ms);	// HMS
	if(mode == 1)format(tmpStr, 20, "%02d:%02d.%03d", m, s, ms);		// MS
	if(mode == 2)format(tmpStr, 20, "%02d.%03d", s, ms);				// S
	return tmpStr;
}
stock catstr(pointer[][], delimiter, ...)
{
    new
        arg
    ;
    #emit load.s.pri    8
    #emit stor.s.pri    arg

    if(8 < arg) {
        if(12 < arg) { // alt = arg
            new
                first
            ;
            #emit addr.pri      8
            #emit add
            #emit stor.s.pri    arg

            #emit addr.pri      20
            #emit stor.s.pri    first

            while(arg != first) {
                #emit lref.s.pri    arg
                #emit add.c         0xFFFFFFFC // -4
                #emit move.alt
                #emit load.s.pri    delimiter
                #emit stor.i

                arg -= 4;
            }
        }
        // @ PointerByAddress by Slice
        #emit load.s.alt    pointer
        #emit load.s.pri    20
        #emit sub
        #emit stor.i
    }
}


stock IsKeyJustDown(key, newkeys, oldkeys)
{
	if((newkeys & key) && !(oldkeys & key)) return 1;
	return 0;
}
stock IsDateReached(day,month,year)
{
	new myday,mymonth,myyear;
	getdate(myyear,mymonth,myday);
	if(myday   >=	day) 	return 1;
	if(mymonth >	month) 	return 1;
	if(myyear  >	year) 	return 1;
	return 0;
}
stock DB_Escape(text[])
{
    new
        ret[MAX_INI_ENTRY_TEXT * 2],
        ch,
        i,
        j;

    while ((ch = text[i++]) && j < sizeof (ret))
    {
        if (ch == '\'')
        {
            if (j < sizeof (ret) - 2)
            {
                ret[j++] = '\'';
                ret[j++] = '\'';
            }
        }
        else if (j < sizeof (ret))
        {
            ret[j++] = ch;
        }
        else
        {
            j++;
        }
    }
    ret[sizeof (ret) - 1] = '\0';
    return ret;
}

stock RGBAToHex(r, g, b, a)
{
	return (r<<24 | g<<16 | b<<8 | a);
}

stock HexToRGBA(colour, &r, &g, &b, &a)
{
	r = (colour >> 24) & 0xFF;
	g = (colour >> 16) & 0xFF;
	b = (colour >> 8) & 0xFF;
	a = colour & 0xFF;
}

stock IpIntToStr(ip)
{
	new str[17];
	format(str, 17, "%d.%d.%d.%d", ((ip>>24) & 0xFF), ((ip>>16) & 0xFF), ((ip>>8) & 0xFF), (ip & 0xFF) );
	return str;
}


stock filterColorTags(string[], bool: gxtTags, bool: sampColors)
{
    if(gxtTags)
    {
        new textPos = -1;
        while((textPos = strfind(string, "~", false, (textPos + 1))) != -1)
        {
            switch((string[textPos + 1] = tolower(string[textPos + 1])))
            {
                case 'r', 'g', 'b', 'w', 'y', 'p', 'l', 'n', 'h', '<', '>':
                {
                    if(string[textPos + 2] == '~')
                    {
                        strdel(string, textPos, (textPos + 3));
                    }
                }
                default: continue;
            }
        }
    }
    if(sampColors)
    {
        new
            textPos = -1,
            i;
        while((textPos = strfind(string, "{", false, (textPos + 1))) != -1)
        {
            for(i = textPos; i != (textPos + 7); ++i)
            {
                switch(string[i])
                {
                    case 'a'..'f', 'A'..'F', '0'..'9':
                    {
                        if(i == (textPos + 6))
                        {
                            if(string[(i + 1)] == '}')
                            {
                                strdel(string, textPos, (i + 2));
                            }
                        }
                    }
                    default: continue;
                }
            }
        }
    }
    return ;
}


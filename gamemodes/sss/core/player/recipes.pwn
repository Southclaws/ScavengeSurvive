/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

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

		This file was originally written by Adam Kadar:
		<https://github.com/kadaradam>


==============================================================================*/


CMD:recipes(playerid, params[])
{
	Dialog_ShowCraftTypes(playerid);
	return 1;
}

Dialog_ShowCraftTypes(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused pid, dialogid, listitem, inputtext
        
        if(response)
        {
        	switch(listitem)
        	{
        		case 0:
        			Dialog_ShowCraftList(playerid, 1);
        		case 1:
        			Dialog_ShowCraftList(playerid, 2);
        		case 2:
        			Dialog_ShowCraftList(playerid, 3);
        	}
        }
    }
    Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Recipes", "Combine recipes\nGround combine recipes\nWorkbench recipes", "Select", "Close");
}

Dialog_ShowCraftList(playerid, type)
{
	// 0 All
	// 1 Combine
	// 2 Consset
	// 3 Workbench

	new
		f_str[512],
		itemname[ITM_MAX_NAME];

	for(new i; i < GetCraftSetTotal(); i++)
	{
		if(IsValidCraftSet(i))
		{
			if(type == 1)
			{
				if(GetCraftSetConstructSet(i) != -1)
					continue;
			}
			if(type == 2)
			{
				new 
					consset = GetCraftSetConstructSet(i);

				if(consset == -1)
					continue;

				if(IsValidWorkbenchConstructionSet(consset))
					continue;
			}
			if(type == 3)
			{
				new 
					consset = GetCraftSetConstructSet(i);

				if(consset == -1)
					continue;

				if(!IsValidWorkbenchConstructionSet(consset))
					continue;
			}
			GetItemTypeName(GetCraftSetResult(i), itemname);
		}
		else
		{
			itemname = "INVALID CRAFT SET";
		}

		format(f_str, sizeof(f_str), "%s%i. %s\n", f_str, i, itemname);
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused pid, dialogid, listitem
        
        if(response)
        {
        	new 
        		consset;

        	sscanf(inputtext, "p<.>i{s[96]}", consset);

        	Dialog_ShowIngredients(playerid, consset);
        }
        else
        {
        	Dialog_ShowCraftTypes(playerid);
        }
    }
    Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Craftsets", f_str, "View", "Close");
}

Dialog_ShowIngredients(playerid, craftset)
{
	if(!IsValidCraftSet(craftset))
		return 1;

    new 
        ItemType:itemType,
        f_str[256],
		itemname[ITM_MAX_NAME],
		toolname[ITM_MAX_NAME],
		consset = GetCraftSetConstructSet(craftset);

    for(new i; i < GetCraftSetItemCount(craftset); i++)
	{
		itemType = GetCraftSetItemType(craftset, i);
		GetItemTypeName(itemType, itemname);
		format(f_str, sizeof(f_str), "%s\t\t\t%s\n", f_str, itemname);
	}

	GetItemTypeName(GetCraftSetResult(craftset), itemname);

	if(consset != -1)
	{
		GetItemTypeName(GetConstructionSetTool(consset), toolname);
		format(f_str, sizeof(f_str), "\
			"C_WHITE"Itemname:		"C_YELLOW"%s\n\
			"C_WHITE"Tool: 			"C_YELLOW"%s\n\
			"C_WHITE"Ingredients:	"C_YELLOW"\n%s", itemname, toolname, f_str);
	}
	else
	{
		format(f_str, sizeof(f_str), "\
			"C_WHITE"Itemname: 		"C_YELLOW"%s\n\
			"C_WHITE"Ingredients:	"C_YELLOW"\n%s", itemname, f_str);
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext
		if(!response)
		{
			Dialog_ShowCraftTypes(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, itemname, f_str, "Close", "Back");

	return 1;
}

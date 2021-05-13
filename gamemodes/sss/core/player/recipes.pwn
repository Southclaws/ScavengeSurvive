/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
				case 3:
					Dialog_ShowCraftHelp(playerid);
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Recipes", "Combination Recipes\nConstruction Recipes\nWorkbench Recipes\n"C_GREEN"Help", "Select", "Close");
}

Dialog_ShowCraftList(playerid, type)
{
	// 0 All
	// 1 Combine
	// 2 Consset
	// 3 Workbench

	new
		f_str[700],
		itemname[MAX_ITEM_NAME];

	for(new CraftSet:i; i < CraftSet:GetCraftSetTotal(); i++)
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
			new ItemType:resulttype;
			GetCraftSetResult(i, resulttype);
			GetItemTypeName(resulttype, itemname);
		}
		else
		{
			itemname = "INVALID CRAFT SET";
		}

		format(f_str, sizeof(f_str), "%s%i. %s\n", f_str, _:i, itemname);
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem
		
		if(response)
		{
			new craftset;

			sscanf(inputtext, "p<.>i{s[96]}", craftset);

			Dialog_ShowIngredients(playerid, CraftSet:craftset);
		}
		else
		{
			Dialog_ShowCraftTypes(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Craftsets", f_str, "View", "Close");
}

Dialog_ShowIngredients(playerid, CraftSet:craftset)
{
	if(!IsValidCraftSet(craftset))
		return 1;

	gBigString[playerid][0] = EOS;

	new
		itemcount,
		ItemType:itemType,
		itemname[MAX_ITEM_NAME],
		toolname[MAX_ITEM_NAME],
		consset = GetCraftSetConstructSet(craftset),
		ItemType:resulttype;
	GetCraftSetItemCount(craftset, itemcount);
	GetCraftSetResult(craftset, resulttype);

	for(new i; i < itemcount; i++)
	{
		GetCraftSetItemType(craftset, i, itemType);
		GetItemTypeName(itemType, itemname);
		format(gBigString[playerid], sizeof(gBigString[]), "%s\t\t\t%s\n", gBigString[playerid], itemname);
	}

	if(consset != -1)
	{
		GetItemTypeName(GetConstructionSetTool(consset), toolname);
		format(gBigString[playerid], sizeof(gBigString[]), "\
			"C_WHITE"Tool: 			"C_YELLOW"%s\n\
			"C_WHITE"Ingredients:	"C_YELLOW"\n%s", toolname, gBigString[playerid]);
	}
	else
	{
		format(gBigString[playerid], sizeof(gBigString[]), "\
			"C_WHITE"Ingredients:	"C_YELLOW"\n%s", gBigString[playerid]);
	}

	GetItemTypeName(resulttype, itemname);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext
		if(!response)
		{
			Dialog_ShowCraftTypes(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, itemname, gBigString[playerid], "Close", "Back");

	return 1;
}

Dialog_ShowCraftHelp(playerid)
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid], "Crafting is a way to create new items from existing items.\n");
	strcat(gBigString[playerid], "There are three ways to combine items in Scavenge and Survive:\n\n");

	strcat(gBigString[playerid], C_YELLOW"In Inventory Screens (Aka: Crafting or Combining):\n\n");
	strcat(gBigString[playerid], C_WHITE"While viewing your inventory or a container (vehicle trunk, box, bag, etc)\n");
	strcat(gBigString[playerid], C_WHITE"Select 'Combine' from the item options\n");
	strcat(gBigString[playerid], C_WHITE"Go back and open the options for another item\n");
	strcat(gBigString[playerid], C_WHITE"Select 'Combine with ...' to combine the items together\n");
	strcat(gBigString[playerid], C_WHITE"If a recipe requires more than two items, just repeat.\n\n");

	strcat(gBigString[playerid], C_GREEN"On The Ground (Aka: Constructing):\n\n");
	strcat(gBigString[playerid], C_WHITE"Place all the ingredient items on the ground\n");
	strcat(gBigString[playerid], C_WHITE"Equip the 'Tool' item specified in the recipe page\n");
	strcat(gBigString[playerid], C_WHITE"Hold the Interact key while close to the ingredients\n\n");

	strcat(gBigString[playerid], C_BLUE"At a Workbench:\n\n");
	strcat(gBigString[playerid], C_WHITE"Place the all ingredient items in the workbench (The workbench acts like a box)\n");
	strcat(gBigString[playerid], C_WHITE"Equip the 'Tool' item specified in the recipe page\n");
	strcat(gBigString[playerid], C_WHITE"Hold the Interact key while standing at the workbench");

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext
		if(response)
		{
			Dialog_ShowCraftTypes(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Crafting Help", gBigString[playerid], "Back", "Cancel");
}

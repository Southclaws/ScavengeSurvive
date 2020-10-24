/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


// Start Of File
/*
Zamaroht's TextDraw Editor Version 1.0RC2.
Designed for SA-MP 0.3.

Author: Zamaroht (Nicol�s Laurito)

Start of Development: 25 December 2009, 22:16 (GMT-3)
End of Development: 01 January 2010, 23:31 (GMT-3)

Disclaimer:
You can re-distribute this file as you wish, but ALWAYS keeping the name of the
author and a link back to http://forum.sa-mp.com/index.php?topic=143025.0
attached to the mean of distrubution.
For example, the link with the author's name in a public forum topic, or a
separate README file in a .zip file, etc.
If you modify this file, the same terms apply. You have to include the original
author (Zamaroht) and the link back to the mentioned webpage.

***

	20th May 2012 - Edited by Southclaws to include support for Player Textdraws (Added in SA:MP 0.3e)

***

*/

#include <a_samp>
#include <Dini>

// =============================================================================
// Internal Declarations.
// =============================================================================

#define MAX_TEXTDRAWS       90			// Max textdraws shown on client screen is 92. Using 90 to be on the safe side.
#define MSG_COLOR           0xFAF0CEFF	// Color to be shown in the messages.
#define PREVIEW_CHARS       35			// Amount of characters that show on the textdraw's preview.


// Used with P_Aux
#define DELETING 0
#define LOADING 1

// Used with P_KeyEdition
#define EDIT_NONE       0
#define EDIT_POSITION   1
#define EDIT_SIZE       2
#define EDIT_BOX        3

// Used with P_ColorEdition
#define COLOR_TEXT      0
#define COLOR_OUTLINE   1
#define COLOR_BOX       2

enum enum_tData // Textdraw data.
{
	bool:T_Created,			// Wheter the textdraw ID is created or not.
	Text:T_Handler,         // Where the TD id is saved itself.
	T_Text[1536],           // The textdraw's string.
	Float:T_X,
	Float:T_Y,
	T_Alignment,
	T_BackColor,
	T_BoxColor,
	T_Color,
	T_Font,
	Float:T_XSize,
	Float:T_YSize,
	T_Outline,
	T_Proportional,
	T_Shadow,
	Float:T_TextSizeX,
	Float:T_TextSizeY,
	T_UseBox
};

enum enum_pData // Player data.
{
	bool:P_Editing,         // Wheter the player is editing or not at the moment (allow /menu).
	P_DialogPage,           // Page of the textdraw selection dialog they are at.
	P_CurrentTextdraw,      // Textdraw ID being currently edited.
	P_CurrentMenu,          // Just used at the start, to know if the player is LOADING or DELETING.
	P_KeyEdition,           // Used to know which editions is being performed with keyboard. Check defines.
	P_Aux,      		    // Auxiliar variable, used as a temporal variable in various cases.
	P_ColorEdition,         // Used to know WHAT the player is changing the color of. Check defines.
	P_Color[4],             // Holds RGBA when using color combinator.
	P_ExpCommand[128],      // Holds temporaly the command which will be used for a command fscript export.
	P_Aux2                  // Just used in special export cases.
};

new tData[MAX_TEXTDRAWS][enum_tData],
	pData[MAX_PLAYERS][enum_pData];
	
new CurrentProject[128];  // String containing the location of the current opened project file.

// =============================================================================
// Callbacks.
// =============================================================================

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Text Draw Editor 1.0RC2 by Zamaroht for SA-MP 0.3 Loaded.\n Edited by Southclaws for 0.3e Per Player Text Draw and Font 4 sprites support!");
	print("--------------------------------------\n");
	for(new i; i < MAX_PLAYERS; i ++) if(IsPlayerConnected(i)) ResetPlayerVars(i);
	for(new i; i < MAX_TEXTDRAWS; i ++)
	{
	    tData[i][T_Handler] = TextDrawCreate(0.0, 0.0, " ");
	}
	return 1;
}

public OnFilterScriptExit()
{
    for(new i; i < MAX_TEXTDRAWS; i ++)
	{
	    TextDrawHideForAll(tData[i][T_Handler]);
	    TextDrawDestroy(tData[i][T_Handler]);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	for(new i; i < MAX_TEXTDRAWS; i ++)
	{
	    if(tData[i][T_Created])
	        TextDrawShowForPlayer(playerid, tData[i][T_Handler]);
	}
}

public OnPlayerSpawn(playerid)
{
	SendClientMessage(playerid, MSG_COLOR, "Use /text to show the Edition Menu");
	
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    ResetPlayerVars(playerid);
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp("/text", cmdtext))
	{
	    
		if(pData[playerid][P_Editing]) return SendClientMessage(playerid, MSG_COLOR, "[ERROR] Finish the current edition before using /text!");
		else if(!strlen(CurrentProject) || !strcmp(CurrentProject, " "))
		{
		    if(IsPlayerMinID(playerid))
		    {
			    ShowTextDrawDialog(playerid, 0);
			    pData[playerid][P_Editing] = true;
		    }
		    else
		        SendClientMessage(playerid, MSG_COLOR, "Just the smaller player ID can manage projects. Ask him to open one.");
		    return 1;
		}
		else
		{
		    ShowTextDrawDialog(playerid, 4, 0);
		    pData[playerid][P_Editing] = true;
		    return 1;
		}
	}
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(response == 1) 	PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0); // Confirmation sound
    else 				PlayerPlaySound(playerid, 1084, 0.0, 0.0, 0.0); // Cancelation sound
    
    switch(dialogid)
    {
        case 1574: // First dialog.
        {
            if(response) // If he pressed accept.
            {
                strmid(CurrentProject, "", 0, 1, 128);
                
                if(listitem == 0) // He pressed new project.
                    ShowTextDrawDialog(playerid, 1);
                else if(listitem == 1) // He pressed load project.
                    ShowTextDrawDialog(playerid, 2, 1);
                else if(listitem == 2) // He pressed delete project.
                    ShowTextDrawDialog(playerid, 2, 2);
            }
            else pData[playerid][P_Editing] = false;
        }
        
        case 1575: // New Project
        {
            if(response)
            {
                if(strlen(inputtext) > 120) ShowTextDrawDialog(playerid, 1, 1); // Too long.
                
                else if(
					strfind(inputtext, "/") != -1 || strfind(inputtext, "\\") != -1 ||
					strfind(inputtext, ":") != -1 || strfind(inputtext, "*") != -1 ||
					strfind(inputtext, "?") != -1 || strfind(inputtext, "\"") != -1 ||
					strfind(inputtext, "<") != -1 || strfind(inputtext, ">") != -1 ||
					strfind(inputtext, "|") != -1 || !strlen(inputtext) ||
					inputtext[0] == ' ' )
						ShowTextDrawDialog(playerid, 1, 3); // Ilegal characters.
						
                else // It's ok, create the new file.
                {
                    new filename[128];
                    format(filename, sizeof(filename), "%s.tde", inputtext);
                    if(fexist(filename)) ShowTextDrawDialog(playerid, 1, 2); // Already exists.
                    else
                    {
	                    CreateNewProject(filename);
	                    strmid(CurrentProject, filename, 0, strlen(inputtext), 128);
	                    
	                    new tmpstr[128];
	                    format(tmpstr, sizeof(tmpstr), "You are now working on the '%s' project.", filename);
	                    SendClientMessage(playerid, MSG_COLOR, tmpstr);
	                    
	                    ShowTextDrawDialog(playerid, 4); // Show the main edition menu.
			 		}
                }
            }
            else
                ShowTextDrawDialog(playerid, 0);
        }
        
        case 1576: // Load/Delete project
        {
            if(response)
            {
                if(listitem == 0) // Custom filename
                {
                    if(pData[playerid][P_CurrentMenu] == LOADING)		ShowTextDrawDialog(playerid, 3);
                    else if(pData[playerid][P_CurrentMenu] == DELETING)	ShowTextDrawDialog(playerid, 0);
				}
				else
				{
				    if(pData[playerid][P_CurrentMenu] == DELETING)
				    {
				        pData[playerid][P_Aux] = listitem - 1;
				        ShowTextDrawDialog(playerid, 6);
					}
					else if(pData[playerid][P_CurrentMenu] == LOADING)
					{
					    new filename[135];
					    format(filename, sizeof(filename), "%s", GetFileNameFromLst("tdlist.lst", listitem - 1));
					    LoadProject(playerid, filename);
					}
                }
            }
            else
                ShowTextDrawDialog(playerid, 0);
        }
        
        case 1577: // Load custom project
        {
			if(response)
			{
				new ending[5];
				strmid(ending, inputtext, strlen(inputtext) - 4, strlen(inputtext));
				if(strcmp(ending, ".tde") != 0)
				{
				    new filename[128];
				    format(filename, sizeof(filename), "%s.tde", inputtext);
				    LoadProject(playerid, filename);
				}
				else LoadProject(playerid, inputtext);
			}
			else
			{
			    if(pData[playerid][P_CurrentMenu] == DELETING)		ShowTextDrawDialog(playerid, 2, 2);
			    else if(pData[playerid][P_CurrentMenu] == LOADING)	ShowTextDrawDialog(playerid, 2);
			}
        }
        
        case 1578: // Textdraw selection
        {
            if(response)
            {
                if(listitem == 0) // They selected new textdraw
                {
                    pData[playerid][P_CurrentTextdraw] = -1;
                    for(new i; i < MAX_TEXTDRAWS; i++)
                    {
                        if(!tData[i][T_Created]) // If it isn't created yet, use it.
                        {
                            ClearTextdraw(i);
                            CreateDefaultTextdraw(i);
                            pData[playerid][P_CurrentTextdraw] = i;
                            ShowTextDrawDialog(playerid, 4, pData[playerid][P_DialogPage]);
                            break;
                        }
					}
					if(pData[playerid][P_CurrentTextdraw] == -1)
					{
					    SendClientMessage(playerid, MSG_COLOR, "You can't create any more textdraws!");
					    ShowTextDrawDialog(playerid, 4, pData[playerid][P_DialogPage]);
					}
					else
					{
						new string[128];
	                    format(string, sizeof(string), "Textdraw #%d successfuly created.", pData[playerid][P_CurrentTextdraw]);
	                    SendClientMessage(playerid, MSG_COLOR, string);
					}
                }
                else if(listitem == 1) // They selected export
                {
                    ShowTextDrawDialog(playerid, 25);
                }
                else if(listitem == 2) // They selected close project
                {
                    if(IsPlayerMinID(playerid))
                    {
	                    for(new i; i < MAX_TEXTDRAWS; i ++)
	                    {
	                        ClearTextdraw(i);
	                    }

	                    new string[128];
	                    format(string, sizeof(string), "Project '%s' closed.", CurrentProject);
	                    SendClientMessage(playerid, MSG_COLOR, string);

	                    strmid(CurrentProject, " ", 128, 128);
	                    ShowTextDrawDialog(playerid, 0);
					}
					else
					{
					    SendClientMessage(playerid, MSG_COLOR, "Just the smaller player ID can manage projects. Ask him to open one.");
					    ShowTextDrawDialog(playerid, 4);
					}
                }
                else if(listitem <= 10) // They selected a TD
                {
                    new id = 3;
                    for(new i = pData[playerid][P_DialogPage]; i < MAX_TEXTDRAWS; i ++)
                    {
                        if(tData[i][T_Created])
                        {
							if(id == listitem)
							{
							    // We found it
							    pData[playerid][P_CurrentTextdraw] = i;
							    ShowTextDrawDialog(playerid, 5);
								break;
							}
							id ++;
						}
                    }
                    new string[128];
                    format(string, sizeof(string), "You are now editing textdraw #%d", pData[playerid][P_CurrentTextdraw]);
                    SendClientMessage(playerid, MSG_COLOR, string);
                }
                else
                {
                    new BiggestID, itemcount;
                    for(new i = pData[playerid][P_DialogPage]; i < MAX_TEXTDRAWS; i ++)
                    {
                        if(tData[i][T_Created])
                        {
							itemcount ++;
							BiggestID = i;
							if(itemcount == 9) break;
						}
                    }
                    ShowTextDrawDialog(playerid, 4, BiggestID);
				}
            }
            else
            {
                pData[playerid][P_Editing] = false;
                pData[playerid][P_DialogPage] = 0;
            }
        }
        
        case 1579: // Main edition menu
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Change text
	                {
                        ShowTextDrawDialog(playerid, 8);
	                }
	                case 1: // Change position
	                {
	                    ShowTextDrawDialog(playerid, 9);
	                }
	                case 2: // Change alignment
	                {
	                    ShowTextDrawDialog(playerid, 11);
	                }
	                case 3: // Change font color
	                {
	                    pData[playerid][P_ColorEdition] = COLOR_TEXT;
	                    ShowTextDrawDialog(playerid, 13);
	                }
	                case 4: // Change font
	                {
	                    ShowTextDrawDialog(playerid, 17);
	                }
	                case 5: // Change proportionality
	                {
	                    ShowTextDrawDialog(playerid, 12);
	                }
	                case 6: // Change letter size
	                {
	                    ShowTextDrawDialog(playerid, 18);
	                }
	                case 7: // Edit outline
	                {
	                    ShowTextDrawDialog(playerid, 20);
	                }
	                case 8: // Edit box
	                {
	                    if(tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] == 0)		ShowTextDrawDialog(playerid, 23);
	                    else if(tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] == 1)	ShowTextDrawDialog(playerid, 24);
	                }
	                case 9: // Duplicate textdraw
	                {
	                    new from, to;
	                    for(new i; i < MAX_TEXTDRAWS; i++)
	                    {
	                        if(!tData[i][T_Created]) // If it isn't created yet, use it.
	                        {
	                            ClearTextdraw(i);
	                            CreateDefaultTextdraw(i);
	                            from = pData[playerid][P_CurrentTextdraw];
	                            to = i;
	                            DuplicateTextdraw(pData[playerid][P_CurrentTextdraw], i);
	                            pData[playerid][P_CurrentTextdraw] = -1;
	                            ShowTextDrawDialog(playerid, 4);
	                            break;
	                        }
						}
						if(pData[playerid][P_CurrentTextdraw] != -1)
						{
						    SendClientMessage(playerid, MSG_COLOR, "You can't create any more textdraws!");
						    ShowTextDrawDialog(playerid, 5);
						}
						else
						{
							new string[128];
		                    format(string, sizeof(string), "Textdraw #%d successfuly copied to Textdraw #%d.", from, to);
		                    SendClientMessage(playerid, MSG_COLOR, string);
						}
	                }
	                case 10: // Delete textdraw
	                {
                        ShowTextDrawDialog(playerid, 7);
	                }
				}
            }
            else
			{
			    ShowTextDrawDialog(playerid, 4, 0);
			}
        }
        
        case 1580: // Delete project confirmation dialog
        {
            if(response)
            {
                new filename[128];
                format(filename, sizeof(filename), "%s", GetFileNameFromLst("tdlist.lst", pData[playerid][P_Aux]));
	            fremove(filename);
				DeleteLineFromFile("tdlist.lst", pData[playerid][P_Aux]);
				
				format(filename, sizeof(filename), "The project saved as '%s' was successfuly deleted.", filename);
				SendClientMessage(playerid, MSG_COLOR, filename);
				
				ShowTextDrawDialog(playerid, 0);
			}
			else
			{
			    ShowTextDrawDialog(playerid, 0);
			}
        }
        
        case 1581: // Delete TD confirmation
        {
            if(response)
            {
                DeleteTDFromFile(pData[playerid][P_CurrentTextdraw]);
				ClearTextdraw(pData[playerid][P_CurrentTextdraw]);
                
                new string[128];
                format(string, sizeof(string), "You have deleted textdraw #%d", pData[playerid][P_CurrentTextdraw]);
                SendClientMessage(playerid, MSG_COLOR, string);
                
                pData[playerid][P_CurrentTextdraw] = 0;
                ShowTextDrawDialog(playerid, 4);
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 1582: // Change textdraw's text
        {
            if(response)
            {
                if(!strlen(inputtext)) ShowTextDrawDialog(playerid, 8);
                else
                {
	                format(tData[pData[playerid][P_CurrentTextdraw]][T_Text], 1024, "%s", inputtext);
	                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
	                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Text");
	                ShowTextDrawDialog(playerid, 5);
				}
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 1583: // Change textdraw's position: exact or move
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Exact position
                    {
                        pData[playerid][P_Aux] = 0;
                        ShowTextDrawDialog(playerid, 10, 0, 0);
                    }
                    case 1: // Move it
                    {
                        new string[512];
                        string = "~n~~n~~n~~n~~n~~n~~n~~n~~w~";
                        if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~, ~k~~GO_RIGHT~~n~", string);
						else								format(string, sizeof(string), "%s~k~~VEHICLE_STEERUP~, ~k~~VEHICLE_STEERDOWN~, ~k~~VEHICLE_STEERLEFT~, ~k~~VEHICLE_STEERRIGHT~~n~", string);
						format(string, sizeof(string), "%sand ~k~~PED_SPRINT~ to move. ", string);
						if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~VEHICLE_ENTER_EXIT~", string);
						else								format(string, sizeof(string), "%s~k~~VEHICLE_FIREWEAPON_ALT~", string);
						format(string, sizeof(string), "%s to finish.~n~", string);
						
						GameTextForPlayer(playerid, string, 9999999, 3);
						SendClientMessage(playerid, MSG_COLOR, "Use [up], [down], [left] and [right] keys to move the textdraw. [sprint] to boost and [enter car] to finish.");
						
						TogglePlayerControllable(playerid, 0);
						pData[playerid][P_KeyEdition] = EDIT_POSITION;
						SetTimerEx("KeyEdit", 200, 0, "i", playerid);
                    }
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 1584: // Set position manually
        {
            if(response)
            {
                if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 10, pData[playerid][P_Aux], 1);
                else
                {
                    if(pData[playerid][P_Aux] == 0) // If he edited X
                    {
                        tData[pData[playerid][P_CurrentTextdraw]][T_X] = floatstr(inputtext);
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_X");
                        ShowTextDrawDialog(playerid, 10, 1, 0);
                    }
                    else if(pData[playerid][P_Aux] == 1) // If he edited Y
                    {
                        tData[pData[playerid][P_CurrentTextdraw]][T_Y] = floatstr(inputtext);
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Y");
                        ShowTextDrawDialog(playerid, 5);
                        
						SendClientMessage(playerid, MSG_COLOR, "Textdraw successfuly moved.");
                    }
                }
            }
            else
            {
                if(pData[playerid][P_Aux] == 1) // If he is editing Y, move him to X.
                {
                    pData[playerid][P_Aux] = 0;
                    ShowTextDrawDialog(playerid, 10, 0, 0);
                }
                else // If he was editing X, move him back to select menu
                {
                    ShowTextDrawDialog(playerid, 9);
                }
            }
        }
        
        case 1585: // Change textdraw's alignment
        {
            if(response)
            {
                tData[pData[playerid][P_CurrentTextdraw]][T_Alignment] = listitem+1;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Alignment");
                
                new string[128];
                format(string, sizeof(string), "Textdraw #%d's alignment changed to %d.", pData[playerid][P_CurrentTextdraw], listitem+1);
                SendClientMessage(playerid, MSG_COLOR, string);
                
                ShowTextDrawDialog(playerid, 5);
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 1586: // Change textdraw's proportionality
        {
            if(response)
            {
                tData[pData[playerid][P_CurrentTextdraw]][T_Proportional] = listitem;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Proportional");

                new string[128];
                format(string, sizeof(string), "Textdraw #%d's proportionality changed to %d.", pData[playerid][P_CurrentTextdraw], listitem);
                SendClientMessage(playerid, MSG_COLOR, string);

                ShowTextDrawDialog(playerid, 5);
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 1587: // Change color
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Write hex
                    {
                        ShowTextDrawDialog(playerid, 14);
                    }
                    case 1: // Color combinator
                    {
                        ShowTextDrawDialog(playerid, 15, 0, 0);
                    }
                    case 2: // Premade color
                    {
                        ShowTextDrawDialog(playerid, 16);
                    }
                }
            }
            else
            {
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT)			ShowTextDrawDialog(playerid, 5);
                else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)   ShowTextDrawDialog(playerid, 20);
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)		ShowTextDrawDialog(playerid, 24);
            }
        }
        
        case 1588: // Textdraw's color: custom hex
        {
        	if(response)
            {
                new red[3], green[3], blue[3], alpha[3];
                
                if(inputtext[0] == '0' && inputtext[1] == 'x') // He's using 0xFFFFFF format
                {
                    if(strlen(inputtext) != 8 && strlen(inputtext) != 10) return ShowTextDrawDialog(playerid, 14, 1);
                    else
                    {
	                    format(red, sizeof(red), "%c%c", inputtext[2], inputtext[3]);
	                    format(green, sizeof(green), "%c%c", inputtext[4], inputtext[5]);
	                    format(blue, sizeof(blue), "%c%c", inputtext[6], inputtext[7]);
	                    if(inputtext[8] != '\0')
	                        format(alpha, sizeof(alpha), "%c%c", inputtext[8], inputtext[9]);
						else
						    alpha = "FF";
					}
                }
                else if(inputtext[0] == '#') // He's using #FFFFFF format
                {
                    if(strlen(inputtext) != 7 && strlen(inputtext) != 9) return ShowTextDrawDialog(playerid, 14, 1);
                    else
                    {
	                    format(red, sizeof(red), "%c%c", inputtext[1], inputtext[2]);
	                    format(green, sizeof(green), "%c%c", inputtext[3], inputtext[4]);
	                    format(blue, sizeof(blue), "%c%c", inputtext[5], inputtext[6]);
	                    if(inputtext[7] != '\0')
	                        format(alpha, sizeof(alpha), "%c%c", inputtext[7], inputtext[8]);
						else
						    alpha = "FF";
					}
                }
                else // He's using FFFFFF format
                {
                    if(strlen(inputtext) != 6 && strlen(inputtext) != 8) return ShowTextDrawDialog(playerid, 14, 1);
                    else
                    {
	                    format(red, sizeof(red), "%c%c", inputtext[0], inputtext[1]);
	                    format(green, sizeof(green), "%c%c", inputtext[2], inputtext[3]);
	                    format(blue, sizeof(blue), "%c%c", inputtext[4], inputtext[5]);
	                    if(inputtext[6] != '\0')
	                        format(alpha, sizeof(alpha), "%c%c", inputtext[6], inputtext[7]);
						else
						    alpha = "FF";
					}
                }
                // We got the color
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT)
                	tData[pData[playerid][P_CurrentTextdraw]][T_Color] = RGB(HexToInt(red), HexToInt(green), HexToInt(blue), HexToInt(alpha));
				else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)
				    tData[pData[playerid][P_CurrentTextdraw]][T_BackColor] = RGB(HexToInt(red), HexToInt(green), HexToInt(blue), HexToInt(alpha));
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)
				    tData[pData[playerid][P_CurrentTextdraw]][T_BoxColor] = RGB(HexToInt(red), HexToInt(green), HexToInt(blue), HexToInt(alpha));
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Color");
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BackColor");
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BoxColor");
                
                new string[128];
                format(string, sizeof(string), "Textdraw #%d's color has been changed.", pData[playerid][P_CurrentTextdraw]);
                SendClientMessage(playerid, MSG_COLOR, string);

                if(pData[playerid][P_ColorEdition] == COLOR_TEXT) 			ShowTextDrawDialog(playerid, 5);
                else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)   ShowTextDrawDialog(playerid, 20);
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)		ShowTextDrawDialog(playerid, 24);
            }
            else
            {
                ShowTextDrawDialog(playerid, 13);
            }
		}
		
		case 1589: // Textdraw's color: Color combinator
        {
            if(response)
            {
                if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 15, pData[playerid][P_Aux], 2);
                else if(strval(inputtext) < 0 || strval(inputtext) > 255) ShowTextDrawDialog(playerid, 15, pData[playerid][P_Aux], 1);
                else
                {
                    pData[playerid][P_Color][pData[playerid][P_Aux]] = strval(inputtext);
             	    
                    if(pData[playerid][P_Aux] == 3) // He finished editing alpha, he has the rest.
                    {
                        // We got the color
                        if(pData[playerid][P_ColorEdition] == COLOR_TEXT)
		                	tData[pData[playerid][P_CurrentTextdraw]][T_Color] = RGB(pData[playerid][P_Color][0], pData[playerid][P_Color][1], \
																				 pData[playerid][P_Color][2], pData[playerid][P_Color][3] );
						else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)
						    tData[pData[playerid][P_CurrentTextdraw]][T_BackColor] = RGB(pData[playerid][P_Color][0], pData[playerid][P_Color][1], \
																				 pData[playerid][P_Color][2], pData[playerid][P_Color][3] );
		                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)
						    tData[pData[playerid][P_CurrentTextdraw]][T_BoxColor] = RGB(pData[playerid][P_Color][0], pData[playerid][P_Color][1], \
																				 pData[playerid][P_Color][2], pData[playerid][P_Color][3] );
		                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
		                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Color");
		                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BackColor");
		                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BoxColor");

		                new string[128];
		                format(string, sizeof(string), "Textdraw #%d's color has been changed.", pData[playerid][P_CurrentTextdraw]);
		                SendClientMessage(playerid, MSG_COLOR, string);

		                if(pData[playerid][P_ColorEdition] == COLOR_TEXT) 			ShowTextDrawDialog(playerid, 5);
               			else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)   ShowTextDrawDialog(playerid, 20);
               			else if(pData[playerid][P_ColorEdition] == COLOR_BOX)		ShowTextDrawDialog(playerid, 24);
                    }
                    else
                    {
                        pData[playerid][P_Aux] += 1;
	                    ShowTextDrawDialog(playerid, 15, pData[playerid][P_Aux], 0);
					}
                }
            }
            else
            {
                if(pData[playerid][P_Aux] >= 1) // If he is editing alpha, blue, etc.
                {
                    pData[playerid][P_Aux] -= 1;
                    ShowTextDrawDialog(playerid, 15, pData[playerid][P_Aux], 0);
                }
                else // If he was editing red, move him back to select color menu.
                {
                    ShowTextDrawDialog(playerid, 13);
                }
            }
        }
        
        case 1590: // Textdraw's color: premade colors
        {
            if(response)
            {
                new col;
                switch(listitem)
                {
                    case 0: col = 0xff0000ff;
                    case 1: col = 0x00ff00ff;
                    case 2: col = 0x0000ffff;
                    case 3: col = 0xffff00ff;
                    case 4: col = 0xff00ffff;
                    case 5: col = 0x00ffffff;
                    case 6: col = 0xffffffff;
                    case 7: col = 0x000000ff;
                }
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT)
                	tData[pData[playerid][P_CurrentTextdraw]][T_Color] = col;
				else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)
				    tData[pData[playerid][P_CurrentTextdraw]][T_BackColor] = col;
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)
				    tData[pData[playerid][P_CurrentTextdraw]][T_BoxColor] = col;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Color");
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BackColor");
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BoxColor");

                new string[128];
                format(string, sizeof(string), "Textdraw #%d's color has been changed.", pData[playerid][P_CurrentTextdraw]);
                SendClientMessage(playerid, MSG_COLOR, string);
                
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT) 			ShowTextDrawDialog(playerid, 5);
                else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)   ShowTextDrawDialog(playerid, 20);
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)		ShowTextDrawDialog(playerid, 24);
            }
            else
            {
                ShowTextDrawDialog(playerid, 13);
            }
        }
        
        case 1591: // Change textdraw's font
        {
            if(response)
            {
                tData[pData[playerid][P_CurrentTextdraw]][T_Font] = listitem;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Font");

                new string[128];
                format(string, sizeof(string), "Textdraw #%d's font changed to %d.", pData[playerid][P_CurrentTextdraw], listitem);
                SendClientMessage(playerid, MSG_COLOR, string);

                ShowTextDrawDialog(playerid, 5);
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 1592: // Change textdraw's letter size: exact or move
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Exact size
                    {
                        pData[playerid][P_Aux] = 0;
                        ShowTextDrawDialog(playerid, 19, 0, 0);
                    }
                    case 1: // Resize it
                    {
                        new string[512];
                        string = "~n~~n~~n~~n~~n~~n~~n~~n~~w~";
                        if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~, ~k~~GO_RIGHT~~n~", string);
						else								format(string, sizeof(string), "%s~k~~VEHICLE_STEERUP~, ~k~~VEHICLE_STEERDOWN~, ~k~~VEHICLE_STEERLEFT~, ~k~~VEHICLE_STEERRIGHT~~n~", string);
						format(string, sizeof(string), "%sand ~k~~PED_SPRINT~ to resize. ", string);
						if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~VEHICLE_ENTER_EXIT~", string);
						else								format(string, sizeof(string), "%s~k~~VEHICLE_FIREWEAPON_ALT~", string);
						format(string, sizeof(string), "%s to finish.~n~", string);

						GameTextForPlayer(playerid, string, 9999999, 3);
						SendClientMessage(playerid, MSG_COLOR, "Use [up], [down], [left] and [right] keys to resize the textdraw. [sprint] to boost and [enter car] to finish.");

						TogglePlayerControllable(playerid, 0);
						pData[playerid][P_KeyEdition] = EDIT_SIZE;
						SetTimerEx("KeyEdit", 200, 0, "i", playerid);
                    }
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 1593: // Change letter size manually
        {
            if(response)
            {
                if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 19, pData[playerid][P_Aux], 1);
                else
                {
                    if(pData[playerid][P_Aux] == 0) // If he edited X
                    {
                        tData[pData[playerid][P_CurrentTextdraw]][T_XSize] = floatstr(inputtext);
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_XSize");
                        ShowTextDrawDialog(playerid, 19, 1, 0);
                    }
                    else if(pData[playerid][P_Aux] == 1) // If he edited Y
                    {
                        tData[pData[playerid][P_CurrentTextdraw]][T_YSize] = floatstr(inputtext);
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_YSize");
                        ShowTextDrawDialog(playerid, 5);

						SendClientMessage(playerid, MSG_COLOR, "Textdraw successfuly resized.");
                    }
                }
            }
            else
            {
                if(pData[playerid][P_Aux] == 1) // If he is editing Y, move him to X.
                {
                    pData[playerid][P_Aux] = 0;
                    ShowTextDrawDialog(playerid, 19, 0, 0);
                }
                else // If he was editing X, move him back to select menu
                {
                    ShowTextDrawDialog(playerid, 18);
                }
            }
        }
        
        case 1594: // main outline menu
        {
            if(response)
            {
				switch(listitem)
				{
				    case 0: // Toggle outline
				    {
				        if(tData[pData[playerid][P_CurrentTextdraw]][T_Outline])	tData[pData[playerid][P_CurrentTextdraw]][T_Outline] = 0;
				        else                                                        tData[pData[playerid][P_CurrentTextdraw]][T_Outline] = 1;
				        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
				        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Outline");
				        ShowTextDrawDialog(playerid, 20);
				        
				        SendClientMessage(playerid, MSG_COLOR, "Textdraw's outline toggled.");
				    }
					case 1: // Change shadow
					{
                        ShowTextDrawDialog(playerid, 21);
					}
					case 2: // Change color
					{
		                pData[playerid][P_ColorEdition] = COLOR_OUTLINE;
                        ShowTextDrawDialog(playerid, 13);
					}
					case 3: // Finish
	                {
	                    SendClientMessage(playerid, MSG_COLOR, "Finished outline customization.");
	                    ShowTextDrawDialog(playerid, 5);
	                }
				}
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 1595: // Outline shadow
        {
            if(response)
            {
                if(listitem == 6) // selected custom
                {
                    ShowTextDrawDialog(playerid, 22);
                }
                else
                {
                    tData[pData[playerid][P_CurrentTextdraw]][T_Shadow] = listitem;
                    UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                    SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Shadow");
                    ShowTextDrawDialog(playerid, 20);

					new string[128];
	                format(string, sizeof(string), "Textdraw #%d's outline shadow changed to %d.", pData[playerid][P_CurrentTextdraw], listitem);
	                SendClientMessage(playerid, MSG_COLOR, string);
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 20);
            }
        }
        
        case 1596: // outline shaow customized
        {
            if(response)
            {
                if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 22, 1);
                else
                {
                    tData[pData[playerid][P_CurrentTextdraw]][T_Shadow] = strval(inputtext);
                    UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                    SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Shadow");
                    ShowTextDrawDialog(playerid, 20);

					new string[128];
	                format(string, sizeof(string), "Textdraw #%d's outline shadow changed to %d.", pData[playerid][P_CurrentTextdraw], strval(inputtext));
	                SendClientMessage(playerid, MSG_COLOR, string);
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 21);
            }
        }
        
        case 1597: // Box on - off
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Turned box on
                    {
                        tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] = 1;
						UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
						SaveTDData(pData[playerid][P_CurrentTextdraw], "T_UseBox");

						SendClientMessage(playerid, MSG_COLOR, "Textdraw box enabled. Proceeding with edition...");

						ShowTextDrawDialog(playerid, 24);
                    }
                    case 1: // He disabled it, nothing more to edit.
                    {
						tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] = 0;
						UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
						SaveTDData(pData[playerid][P_CurrentTextdraw], "T_UseBox");
						
						SendClientMessage(playerid, MSG_COLOR, "Textdraw box disabled.");
						
						ShowTextDrawDialog(playerid, 5);
                    }
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 1598: // Box main menu
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Turned box off
                    {
                        tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] = 0;
						UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
						SaveTDData(pData[playerid][P_CurrentTextdraw], "T_UseBox");

						SendClientMessage(playerid, MSG_COLOR, "Textdraw box disabled.");

						ShowTextDrawDialog(playerid, 23);
                    }
                    case 1: // box size
                    {
						new string[512];
                        string = "~n~~n~~n~~n~~n~~n~~n~~n~~w~";
                        if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~, ~k~~GO_RIGHT~~n~", string);
						else								format(string, sizeof(string), "%s~k~~VEHICLE_STEERUP~, ~k~~VEHICLE_STEERDOWN~, ~k~~VEHICLE_STEERLEFT~, ~k~~VEHICLE_STEERRIGHT~~n~", string);
						format(string, sizeof(string), "%sand ~k~~PED_SPRINT~ to resize. ", string);
						if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~VEHICLE_ENTER_EXIT~", string);
						else								format(string, sizeof(string), "%s~k~~VEHICLE_FIREWEAPON_ALT~", string);
						format(string, sizeof(string), "%s to finish.~n~", string);

						GameTextForPlayer(playerid, string, 9999999, 3);
						SendClientMessage(playerid, MSG_COLOR, "Use [up], [down], [left] and [right] keys to resize the box. [sprint] to boost and [enter car] to finish.");

						TogglePlayerControllable(playerid, 0);
						pData[playerid][P_KeyEdition] = EDIT_BOX;
						SetTimerEx("KeyEdit", 200, 0, "i", playerid);
                    }
                    case 2: // box color
                    {
                        pData[playerid][P_ColorEdition] = COLOR_BOX;
                        ShowTextDrawDialog(playerid, 13);
                    }
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 1599: // Export menu
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // classic mode
                    {
                        ExportProject(playerid, 0);
                    }
                    case 1: // classic mode PlayerTextDraws
                    {
                        ExportProject(playerid, 7);
                    }
                    case 2: // self-working fs
                    {
						ShowTextDrawDialog(playerid, 26);
                    }
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 4);
            }
        }
        
        case 1600: // Export to self working filterscript
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Show all the time.
                    {
                        ExportProject(playerid, 1);
                    }
                    case 1: // Show on class selection.
                    {
                        ExportProject(playerid, 2);
                    }
                    case 2: // Show while in vehicle
                    {
                        ExportProject(playerid, 3);
                    }
                    case 3: // Show with command
                    {
                        ShowTextDrawDialog(playerid, 27);
                    }
                    case 4: // Show automatly repeteadly after some time
                    {
                        ShowTextDrawDialog(playerid, 29);
                    }
                    case 5: // Show after player killed someone
                    {
                        ShowTextDrawDialog(playerid, 31);
                    }
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 25);
            }
        }

		case 1601: // Write command for export
		{
		    if(response)
		    {
		        if(!strlen(inputtext)) ShowTextDrawDialog(playerid, 27);
		        else
		        {
		            if(inputtext[0] != '/')
		                format(pData[playerid][P_ExpCommand], 128, "/%s", inputtext);
		            else
		                format(pData[playerid][P_ExpCommand], 128, "%s", inputtext);
		                
					ShowTextDrawDialog(playerid, 28);
		        }
		    }
		    else
		    {
		        ShowTextDrawDialog(playerid, 26);
		    }
		}
		
		case 1602: // Time after command for export
		{
		    if(response)
		    {
				if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 28);
				else if(strval(inputtext) < 0) ShowTextDrawDialog(playerid, 28);
				else
				{
				    pData[playerid][P_Aux] = strval(inputtext);
				    ExportProject(playerid, 4);
				}
		    }
		    else
		    {
		        ShowTextDrawDialog(playerid, 27);
		    }
		}
		
		case 1603: // Write time in secs to appear for export
		{
		    if(response)
		    {
		        if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 29);
				else if(strval(inputtext) < 0) ShowTextDrawDialog(playerid, 29);
				else
				{
				    pData[playerid][P_Aux] = strval(inputtext);
				    ShowTextDrawDialog(playerid, 30);
				}
		    }
		    else
		    {
		        ShowTextDrawDialog(playerid, 26);
		    }
		}

		case 1604: // Time after appeared to dissapear for export
		{
		    if(response)
		    {
				if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 30);
				else if(strval(inputtext) < 0) ShowTextDrawDialog(playerid, 30);
				else
				{
				    pData[playerid][P_Aux2] = strval(inputtext);
				    ExportProject(playerid, 5);
				}
		    }
		    else
		    {
		        ShowTextDrawDialog(playerid, 29);
		    }
		}
		
		case 1605: // Time after appeared to dissapear when kill for export
		{
		    if(response)
		    {
				if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 31);
				else if(strval(inputtext) < 0) ShowTextDrawDialog(playerid, 31);
				else
				{
				    pData[playerid][P_Aux] = strval(inputtext);
				    ExportProject(playerid, 6);
				}
		    }
		    else
		    {
		        ShowTextDrawDialog(playerid, 26);
		    }
		}
    }
    
	return 1;
}

// =============================================================================
// Functions.
// =============================================================================

forward ShowTextDrawDialogEx( playerid, dialogid );
public ShowTextDrawDialogEx( playerid, dialogid ) ShowTextDrawDialog( playerid, dialogid );

stock ShowTextDrawDialog( playerid, dialogid, aux=0, aux2=0 )
{
    /*	Shows a specific dialog for a specific player
	    @playerid:      ID of the player to show the dialog to.
	    @dialogid:      ID of the dialog to show.
	    @aux:           Auxiliary variable. Works to make variations of certain dialogs.
	    @aux2:          Auxiliary variable. Works to make variations of certain dialogs.

	    -Returns:
	    true on success, false on fail.
	*/

	switch(dialogid)
	{
	    case 0: // Select project.
	    {
            new info[256];
		    format(info, sizeof(info), "%sNew Project\n", info);
		    format(info, sizeof(info), "%sLoad Project\n", info);
		    format(info, sizeof(info), "%sDelete Project", info);
		    ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Startup"), info, "Accept", "Cancel");
		    return true;
	    }
	    
	    case 1:
	    {
	        new info[256];
	        if(!aux) 			info = "Write the name of the new project file.\n";
	        else if(aux == 1)   info = "ERROR: The name is too long, please try again.\n";
	        else if(aux == 2)   info = "ERROR: That filename already exists, try again.\n";
	        else if(aux == 3)   info = "ERROR: That file name contains ilegal characters. You aren't allowed to\ncreate subdirectories. Please try again.";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "New project"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 2:
	    {
	        // Store in a var if he's deleting or loading.
	        if(aux == 2) 	pData[playerid][P_CurrentMenu] = DELETING;
	        else            pData[playerid][P_CurrentMenu] = LOADING;
	        
			new info[1024];
			if(fexist("tdlist.lst"))
	        {
				if(aux != 2)	info = "Custom filename...";
				else    		info = "<< Go back";
		        new File:tdlist = fopen("tdlist.lst", io_read),
					line[128];
                while(fread(tdlist, line))
                {
		            format(info, sizeof(info), "%s\n%s", info, line);
		        }
		        
		        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Load project"), info, "Accept", "Go back");
		        fclose(tdlist);
	        }
	        else
	        {
	            if(aux) format(info, sizeof(info), "%sCan't find tdlist.lst.\n", info);
			    format(info, sizeof(info), "%sWrite manually the name of the project file you want\n", info);
			    if(aux != 2) 	format(info, sizeof(info), "%sto open:\n", info);
			    else            format(info, sizeof(info), "%sto delete:\n", info);
			    
			    if(aux != 2)	ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Load project"), info, "Accept", "Go back");
			    else            ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Delete project"), info, "Accept", "Go back");
		    }
	        return true;
	    }
	    
	    case 3:
	    {
			ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Load project"), \
		 		"Write manually the name of the project file\n you want to load:\n", "Accept", "Go back");
			return true;
	    }
	    
	    case 4: // Main edition menu (shows all the textdraws and lets you create a new one).
	    {
	        new info[1024],
				shown;
	        format(info, sizeof(info), "%sCreate new Textdraw...", info);
	        shown ++;
	        format(info, sizeof(info), "%s\nExport project...", info);
	        shown ++;
	        format(info, sizeof(info), "%s\nClose project...", info);
	        shown ++;
	        // Aux here is used to indicate from which TD show the list from.
	        pData[playerid][P_DialogPage] = aux;
	        for(new i=aux; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
	            {
	                shown ++;
					if(shown == 12)
					{
						format(info, sizeof(info), "%s\nMore >>", info);
						break;
					}
					
	                new PieceOfText[PREVIEW_CHARS];
	                if(strlen(tData[i][T_Text]) > sizeof(PieceOfText))
	                {
	                    strmid(PieceOfText, tData[i][T_Text], 0, PREVIEW_CHARS, PREVIEW_CHARS);
	                    format(info, sizeof(info), "%s\nTDraw %d: '%s [...]'", info, i, PieceOfText);
	                }
					else
					{
					    format(info, sizeof(info), "%s\nTDraw %d: '%s'", info, i, tData[i][T_Text]);
					}
	            }
	        }
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw selection"), info, "Accept", "Cancel");
	        return true;
	    }
	    
	    case 5:
	    {
	        new info[1024];
	        format(info, sizeof(info), "%sChange text string\n", info);
	        format(info, sizeof(info), "%sChange position\n", info);
	        format(info, sizeof(info), "%sChange alignment\n", info);
	        format(info, sizeof(info), "%sChange text color\n", info);
	        format(info, sizeof(info), "%sChange font\n", info);
	        format(info, sizeof(info), "%sChange proportionality\n", info);
	        format(info, sizeof(info), "%sChange font size\n", info);
	        format(info, sizeof(info), "%sEdit outline\n", info);
	        format(info, sizeof(info), "%sEdit box\n", info);
	        format(info, sizeof(info), "%sDuplicate Textdraw...\n", info);
	        format(info, sizeof(info), "%sDelete Textdraw...", info);
	        
	        new title[40];
	        format(title, sizeof(title), "Textdraw %d", pData[playerid][P_CurrentTextdraw]);
	        
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, title), info, "Accept", "Cancel");
	        return true;
	    }
	    
	    case 6:
	    {
	        new info[256];
	        format(info, sizeof(info), "%sAre you sure you want to delete the\n", info);
	        format(info, sizeof(info), "%s%s project?\n\n", info, GetFileNameFromLst("tdlist.lst", pData[playerid][P_Aux]));
	        format(info, sizeof(info), "%sWARNING: There is no way to undo this operation.", info);
	        
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_MSGBOX, CreateDialogTitle(playerid, "Confirm deletion"), info, "Yes", "No");
	        return true;
	    }
	    
	    case 7:
	    {
	        new info[256];
	        format(info, sizeof(info), "%sAre you sure you want to delete the\n", info);
	        format(info, sizeof(info), "%sTextdraw number %d?\n\n", info, pData[playerid][P_CurrentTextdraw]);
	        format(info, sizeof(info), "%sWARNING: There is no way to undo this operation.", info);
	        
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_MSGBOX, CreateDialogTitle(playerid, "Confirm deletion"), info, "Yes", "No");
	        return true;
	    }
	    
	    case 8:
	    {
	        new info[1024];
	        info = "Write the new textdraw's text. The current text is:\n\n";
	        format(info, sizeof(info), "%s%s\n\n", info, tData[pData[playerid][P_CurrentTextdraw]][T_Text]);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's string"), info, "Accept", "Go back");
	        /* TODO:
	            Make a list of all available sprite images for font type 4
	        */
	        return true;
	    }
	    
	    case 9:
	    {
	        new info[256];
	        info = "Write exact position\n";
	        format(info, sizeof(info), "%sMove the Textdraw", info);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's position"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 10:
	    {
	        // aux is 0 for X, 1 for Y.
	        // aux2 is the type of error message. 0 for no error.
	        new info[256];
	        if(aux2 == 1) info = "ERROR: You have to write a number.\n\n";
	        
	        format(info, sizeof(info), "%sWrite in numbers the new exact ", info);
	        if(aux == 0) 		format(info, sizeof(info), "%sX", info);
	        else if(aux == 1)   format(info, sizeof(info), "%sY", info);
         	format(info, sizeof(info), "%s position of the Textdraw\n", info);
         	
        	pData[playerid][P_Aux] = aux; // To know if he's editing X or Y.
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's position"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 11:
	    {
	        new info[256];
	        info = "Left (type 1)\nCentered (type 2)\nRight (type 3)";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's alignment"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 12:
	    {
	        new info[256];
	        info = "Proportionality On\nProportionality Off";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's proportionality"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 13:
	    {
	        new info[256];
	        info = "Write an hexadecimal number\nUse color combinator\nSelect a premade color";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's color"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 14:
	    {
	        new info[256];
	        if(aux) info = "ERROR: You have written an invalid hex number.\n\n";
	        format(info, sizeof(info), "%sWrite the hexadecimal number you want:\n", info);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's color"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 15:
	    {
	        // aux is 0 for red, 1 for green, 2 for blue, and 3 for alpha.
	        // aux2 is the type of error message. 0 for no error.
	        new info[256];
	        if(aux2 == 1) 		info = "ERROR: The number range has to be between 0 and 255.\n\n";
	        else if(aux2 == 2) 	info = "ERROR: You have to write a number.\n\n";

	        format(info, sizeof(info), "%sWrite the amount of ", info);
	        if(aux == 0) 		format(info, sizeof(info), "%sRED", info);
	        else if(aux == 1)   format(info, sizeof(info), "%sGREEN", info);
	        else if(aux == 2)   format(info, sizeof(info), "%sBLUE", info);
	        else if(aux == 3)   format(info, sizeof(info), "%sOPACITY", info);
         	format(info, sizeof(info), "%s you want.\n", info);
         	format(info, sizeof(info), "%sThe number has to be in a range between 0 and 255.", info);

        	pData[playerid][P_Aux] = aux; // To know what color he's editing.
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's color"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 16:
	    {
	        new info[256];
	        info = "Red\nGreen\nBlue\nYellow\nPink\nLight Blue\nWhite\nBlack";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's color"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 17:
	    {
	        new info[256];
	        info = "Font type 0\nFont type 1\nFont type 2\nFont type 3\nFont type 4 (Sprites)";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's font"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 18:
	    {
	        new info[256];
	        info = "Write exact size\n";
	        format(info, sizeof(info), "%sResize the Textdraw", info);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's font size"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 19:
	    {
	        // aux is 0 for X, 1 for Y.
	        // aux2 is the type of error message. 0 for no error.
	        new info[256];
	        if(aux2 == 1) info = "ERROR: You have to write a number.\n\n";

	        format(info, sizeof(info), "%sWrite in numbers the new exact ", info);
	        if(aux == 0) 		format(info, sizeof(info), "%sX", info);
	        else if(aux == 1)   format(info, sizeof(info), "%sY", info);
         	format(info, sizeof(info), "%s lenght of the font letters.\n", info);

        	pData[playerid][P_Aux] = aux; // To know if he's editing X or Y.
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's size"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 20:
	    {
	        new info[256];
	        if(tData[pData[playerid][P_CurrentTextdraw]][T_Outline] == 1)	info = "Outline Off";
	        else                                                            info = "Outline On";
	        format(info, sizeof(info), "%s\nShadow size\nOutline/Shadow color\nFinish outline edition...", info);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's outline"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 21:
	    {
	        new info[256];
	        info = "Outline shadow 0\nOutline shadow 1\nOutline shadow 2\nOutline shadow 3\nOutline shadow 4\nOutline shadow 5\nCustom...";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's outline shadow"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 22:
	    {
	        new info[256];
	        if(aux) info = "ERROR: You have written an invalid number.\n\n";
	        format(info, sizeof(info), "%sWrite a number indicating the size of the shadow:\n", info);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's outline shadow"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 23:
	    {
	        new info[256];
	        info = "Box On\nBox Off";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's box"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 24:
	    {
	        new info[256];
	        info = "Box Off\nBox size\nBox color";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's box"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 25:
	    {
	        new info[256];
	        info = "Classic export mode\nClassic export (Per-Player)\nSelf-working filterscript";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 26:
	    {
	        new info[512];
	        info = "FScript: Show textdraw all the time\nFScript: Show textdraw on class selection\nFScript: Show textdraw while in vehicle\n\
					FScript: Show textdraw with command\nFScript: Show every X amount of time\nFScript: Show after killing someone";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 27:
	    {
	        new info[128];
	        info = "Write the command you want to show the textdraw.\n";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 28:
	    {
	        new info[128];
	        info = "How long (IN SECONDS) will it remain in the screen?\n";
	        format(info, sizeof(info), "%sWrite 0 if you want to hide it by typing the command again.\n", info);
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 29:
	    {
	        new info[128];
	        info = "Every how long do you want that the textdraws appear?\nWrite a time in SECONDS:\n";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }

	    case 30:
	    {
	        new info[128];
	        info = "Once it appeared, how long will it remain on the screen?\nWrite a time in SECONDS:\n";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }
	    
	    case 31:
	    {
	        new info[128];
	        info = "Once it appeared, how long will it remain on the screen?\nWrite a time in SECONDS:\n";
	        ShowPlayerDialog(playerid, dialogid+1574, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Textdraw's export"), info, "Accept", "Go back");
	        return true;
	    }
	}
	return false;
}

stock CreateDialogTitle( playerid, text[] )
{
    /*	Creates a default title for the dialogs.
        @playerid:      ID of the player getting his dialog title generated.
	    @text[]:	    Text to be attached to the title.
	*/
	#pragma unused playerid
	
	new string[128];
	if(!strlen(CurrentProject) || !strcmp(CurrentProject, " "))
		format(string, sizeof(string), "Zamaroht's Textdraw Editor: %s", text);
	else
	    format(string, sizeof(string), "%s - Zamaroht's Textdraw Editor: %s", CurrentProject, text);
	return string;
}

stock ResetPlayerVars( playerid )
{
	/*	Resets a specific player's pData info.
	    @playerid:      ID of the player to reset the data of.
	*/
	
	pData[playerid][P_Editing] = false;
	strmid(CurrentProject, "", 0, 1, 128);
}

forward KeyEdit( playerid );
public KeyEdit( playerid )
{
	/*  Handles the edition by keyboard.
		@playerid:          	Player editing.
	*/
	if(pData[playerid][P_KeyEdition] == EDIT_NONE) return 0;
	
	new string[256]; // Buffer for all gametexts and other messages.
	new keys, updown, leftright;
	GetPlayerKeys(playerid, keys, updown, leftright);

	if(updown < 0) // He's pressing up
	{
	    switch(pData[playerid][P_KeyEdition])
	    {
	        case EDIT_POSITION:
	        {
				if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_Y] -= 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_Y] -= 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Position: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_X], tData[pData[playerid][P_CurrentTextdraw]][T_Y]);
	        }
	        
	        case EDIT_SIZE:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_YSize] -= 1.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_YSize] -= 0.1;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_XSize], tData[pData[playerid][P_CurrentTextdraw]][T_YSize]);
	        }
	        
	        case EDIT_BOX:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY] -= 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY] -= 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX], tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY]);
	        }
	    }
	}
	else if(updown > 0) // He's pressing down
	{
	    switch(pData[playerid][P_KeyEdition])
	    {
	        case EDIT_POSITION:
	        {
                if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_Y] += 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_Y] += 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Position: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_X], tData[pData[playerid][P_CurrentTextdraw]][T_Y]);
	        }
	        
	        case EDIT_SIZE:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_YSize] += 1.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_YSize] += 0.1;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_XSize], tData[pData[playerid][P_CurrentTextdraw]][T_YSize]);
	        }
	        
	        case EDIT_BOX:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY] += 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY] += 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX], tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY]);
	        }
	    }
	}

	if(leftright < 0) // He's pressing left
	{
        switch(pData[playerid][P_KeyEdition])
	    {
	        case EDIT_POSITION:
	        {
                if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_X] -= 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_X] -= 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Position: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_X], tData[pData[playerid][P_CurrentTextdraw]][T_Y]);
	        }
	        
	        case EDIT_SIZE:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_XSize] -= 0.1;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_XSize] -= 0.01;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_XSize], tData[pData[playerid][P_CurrentTextdraw]][T_YSize]);
	        }
	        
	        case EDIT_BOX:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX] -= 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX] -= 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX], tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY]);
	        }
	    }
	}
	else if(leftright > 0) // He's pressing right
	{
        switch(pData[playerid][P_KeyEdition])
	    {
	        case EDIT_POSITION:
	        {
                if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_X] += 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_X] += 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Position: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_X], tData[pData[playerid][P_CurrentTextdraw]][T_Y]);
	        }
	        
	        case EDIT_SIZE:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_XSize] += 0.1;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_XSize] += 0.01;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_XSize], tData[pData[playerid][P_CurrentTextdraw]][T_YSize]);
	        }
	        
	        case EDIT_BOX:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX] += 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX] += 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Size: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX], tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY]);
	        }
	    }
	}

	GameTextForPlayer(playerid, string, 999999999, 3);
	UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
	if(pData[playerid][P_KeyEdition] == EDIT_POSITION)
	{
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_X");
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Y");
	}
	else if(pData[playerid][P_KeyEdition] == EDIT_SIZE)
	{
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_XSize");
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_YSize");
	}
	else if(pData[playerid][P_KeyEdition] == EDIT_BOX)
	{
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_TextSizeX");
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_TextSizeY");
	}
    SetTimerEx("KeyEdit", 200, 0, "i", playerid);
    return 1;
}

public OnPlayerKeyStateChange( playerid, newkeys, oldkeys )
{
    if(pData[playerid][P_KeyEdition] != EDIT_NONE && newkeys == KEY_SECONDARY_ATTACK)
	{
	    GameTextForPlayer(playerid, " ", 100, 3);
	    TogglePlayerControllable(playerid, 1);

        new string[128];
	    switch(pData[playerid][P_KeyEdition])
	    {
	        case EDIT_POSITION:
	        {
				format(string, sizeof(string), "Textdraw #%d successfuly moved.", pData[playerid][P_CurrentTextdraw]);
	        }
	        case EDIT_SIZE:
	        {
				format(string, sizeof(string), "Textdraw #%d successfuly resized.", pData[playerid][P_CurrentTextdraw]);
	        }
	        case EDIT_BOX:
	        {
				format(string, sizeof(string), "Textdraw #%d's box successfuly resized.", pData[playerid][P_CurrentTextdraw]);
	        }
	    }

        if(pData[playerid][P_KeyEdition] == EDIT_BOX)   SetTimerEx("ShowTextDrawDialogEx", 500, 0, "ii", playerid, 24);
		else 											SetTimerEx("ShowTextDrawDialogEx", 500, 0, "ii", playerid, 5);
	    SendClientMessage(playerid, MSG_COLOR, string);
	    pData[playerid][P_KeyEdition] = EDIT_NONE;
	}
	return 1;
}

stock CreateNewProject( name[] )
{
    /*	Creates a new .tde project file.
	    @name[]:		Name to be used in the filename.
	*/

	new string[128], File:File;

	// Add it to the list.
	format(string, sizeof(string), "%s\r\n", name);
	File = fopen("tdlist.lst", io_append);
	fwrite(File, string);
	fclose(File);

	// Create the default file.
	File = fopen(name, io_write);
	fwrite(File, "TDFile=yes");
	fclose(File);
}

stock ClearTextdraw( tdid )
{
	/*	Resets a textdraw's variables and destroys it.
	    @tdid:          Textdraw ID
	*/
	TextDrawHideForAll(tData[tdid][T_Handler]);
	tData[tdid][T_Created] = false;
	strmid(tData[tdid][T_Text], "", 0, 1, 2);
    tData[tdid][T_X] = 0.0;
    tData[tdid][T_Y] = 0.0;
    tData[tdid][T_Alignment] = 0;
    tData[tdid][T_BackColor] = 0;
    tData[tdid][T_UseBox] = 0;
    tData[tdid][T_BoxColor] = 0;
    tData[tdid][T_TextSizeX] = 0.0;
    tData[tdid][T_TextSizeY] = 0.0;
    tData[tdid][T_Color] = 0;
    tData[tdid][T_Font] = 0;
    tData[tdid][T_XSize] = 0.0;
    tData[tdid][T_YSize] = 0.0;
    tData[tdid][T_Outline] = 0;
    tData[tdid][T_Proportional] = 0;
    tData[tdid][T_Shadow] = 0;
}

stock CreateDefaultTextdraw( tdid, save = 1 )
{
	/*  Creates a new textdraw with default settings.
		@tdid:          Textdraw ID
	*/
	tData[tdid][T_Created] = true;
	format(tData[tdid][T_Text], 1024, "New Textdraw", 1);
    tData[tdid][T_X] = 250.0;
    tData[tdid][T_Y] = 10.0;
    tData[tdid][T_Alignment] = 0;
    tData[tdid][T_BackColor] = RGB(0, 0, 0, 255);
    tData[tdid][T_UseBox] = 0;
    tData[tdid][T_BoxColor] = RGB(0, 0, 0, 255);
    tData[tdid][T_TextSizeX] = 0.0;
    tData[tdid][T_TextSizeY] = 0.0;
    tData[tdid][T_Color] = RGB(255, 255, 255, 255);
    tData[tdid][T_Font] = 1;
    tData[tdid][T_XSize] = 0.5;
    tData[tdid][T_YSize] = 1.0;
    tData[tdid][T_Outline] = 0;
    tData[tdid][T_Proportional] = 1;
    tData[tdid][T_Shadow] = 1;

    UpdateTextdraw(tdid);
    if(save) SaveTDData(tdid, "T_Created");
}

stock DuplicateTextdraw( source, to )
{
	/*  Duplicates a textdraw from another one. Updates the new one.
	    @source:            Where to copy the textdraw from.
	    @to:                Where to copy the textdraw to.
	*/
	tData[to][T_Created] = tData[source][T_Created];
	format(tData[to][T_Text], 1024, "%s", tData[source][T_Text]);
    tData[to][T_X] = tData[source][T_X];
    tData[to][T_Y] = tData[source][T_Y];
    tData[to][T_Alignment] = tData[source][T_Alignment];
    tData[to][T_BackColor] = tData[source][T_BackColor];
    tData[to][T_UseBox] = tData[source][T_UseBox];
    tData[to][T_BoxColor] = tData[source][T_BoxColor];
    tData[to][T_TextSizeX] = tData[source][T_TextSizeX];
    tData[to][T_TextSizeY] = tData[source][T_TextSizeY];
    tData[to][T_Color] = tData[source][T_Color];
    tData[to][T_Font] = tData[source][T_Font];
    tData[to][T_XSize] = tData[source][T_XSize];
    tData[to][T_YSize] = tData[source][T_YSize];
    tData[to][T_Outline] = tData[source][T_Outline];
    tData[to][T_Proportional] = tData[source][T_Proportional];
    tData[to][T_Shadow] = tData[source][T_Shadow];
	
	UpdateTextdraw(to);
	SaveTDData(to, "T_Created");
	SaveTDData(to, "T_Text");
	SaveTDData(to, "T_X");
	SaveTDData(to, "T_Y");
	SaveTDData(to, "T_Alignment");
	SaveTDData(to, "T_BackColor");
	SaveTDData(to, "T_UseBox");
	SaveTDData(to, "T_BoxColor");
    SaveTDData(to, "T_TextSizeX");
    SaveTDData(to, "T_TextSizeY");
    SaveTDData(to, "T_Color");
    SaveTDData(to, "T_Font");
    SaveTDData(to, "T_XSize");
    SaveTDData(to, "T_YSize");
    SaveTDData(to, "T_Outline");
    SaveTDData(to, "T_Proportional");
    SaveTDData(to, "T_Shadow");
}

stock UpdateTextdraw( tdid )
{
	/*  Updates a Textdraw which is being shown on the screen with its respective values.
	    @tdid:          Textdraw ID
	*/
	if(!tData[tdid][T_Created]) return false;
	TextDrawHideForAll(tData[tdid][T_Handler]);
	TextDrawDestroy(tData[tdid][T_Handler]);
	
	// Recreate it
	tData[tdid][T_Handler] = TextDrawCreate(tData[tdid][T_X], tData[tdid][T_Y], tData[tdid][T_Text]);
	TextDrawAlignment(tData[tdid][T_Handler], tData[tdid][T_Alignment]);
	TextDrawBackgroundColor(tData[tdid][T_Handler], tData[tdid][T_BackColor]);
	TextDrawColor(tData[tdid][T_Handler], tData[tdid][T_Color]);
	TextDrawFont(tData[tdid][T_Handler], tData[tdid][T_Font]);
	TextDrawLetterSize(tData[tdid][T_Handler], tData[tdid][T_XSize], tData[tdid][T_YSize]);
	TextDrawSetOutline(tData[tdid][T_Handler], tData[tdid][T_Outline]);
	TextDrawSetProportional(tData[tdid][T_Handler], tData[tdid][T_Proportional]);
	TextDrawSetShadow(tData[tdid][T_Handler], tData[tdid][T_Shadow]);
	if(tData[tdid][T_UseBox])
	{
		TextDrawUseBox(tData[tdid][T_Handler], tData[tdid][T_UseBox]);
		TextDrawBoxColor(tData[tdid][T_Handler], tData[tdid][T_BoxColor]);
		TextDrawTextSize(tData[tdid][T_Handler], tData[tdid][T_TextSizeX], tData[tdid][T_TextSizeY]);
	}

	TextDrawShowForAll(tData[tdid][T_Handler]);

	return true;
}

stock DeleteTDFromFile( tdid )
{
    /*  Deletes a specific textdraw from its .tde file
	    @tdid:              Textdraw ID.
	*/
	new string[128], filename[135];
	format(filename, sizeof(filename), "%s.tde", CurrentProject);
	
	format(string, sizeof(string), "%dT_Created", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Text", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_X", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Y", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Alignment", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_BackColor", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_UseBox", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_BoxColor", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_TextSizeX", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_TextSizeY", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Color", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Font", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_XSize", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_YSize", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Outline", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Proportional", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Shadow", tdid);
	dini_Unset(filename, string);
}

stock SaveTDData( tdid, data[] )
{
	/*  Saves a specific data from a specific textdraw to project file.
	    @tdid:              Textdraw ID.
	    @data[]:            Data to be saved.
	*/
	new string[128], filename[135];
	format(string, sizeof(string), "%d%s", tdid, data);
	format(filename, sizeof(filename), "%s.tde", CurrentProject);
	
	if(!strcmp("T_Created", data))
        dini_IntSet(filename, string, 1);
	else if(!strcmp("T_Text", data))
		dini_Set(filename, string, tData[tdid][T_Text]);
	else if(!strcmp("T_X", data))
		dini_FloatSet(filename, string, tData[tdid][T_X]);
	else if(!strcmp("T_Y", data))
		dini_FloatSet(filename, string, tData[tdid][T_Y]);
	else if(!strcmp("T_Alignment", data))
		dini_IntSet(filename, string, tData[tdid][T_Alignment]);
	else if(!strcmp("T_BackColor", data))
		dini_IntSet(filename, string, tData[tdid][T_BackColor]);
	else if(!strcmp("T_UseBox", data))
		dini_IntSet(filename, string, tData[tdid][T_UseBox]);
	else if(!strcmp("T_BoxColor", data))
		dini_IntSet(filename, string, tData[tdid][T_BoxColor]);
    else if(!strcmp("T_TextSizeX", data))
		dini_FloatSet(filename, string, tData[tdid][T_TextSizeX]);
    else if(!strcmp("T_TextSizeY", data))
		dini_FloatSet(filename, string, tData[tdid][T_TextSizeY]);
    else if(!strcmp("T_Color", data))
		dini_IntSet(filename, string, tData[tdid][T_Color]);
    else if(!strcmp("T_Font", data))
		dini_IntSet(filename, string, tData[tdid][T_Font]);
    else if(!strcmp("T_XSize", data))
		dini_FloatSet(filename, string, tData[tdid][T_XSize]);
    else if(!strcmp("T_YSize", data))
		dini_FloatSet(filename, string, tData[tdid][T_YSize]);
    else if(!strcmp("T_Outline", data))
		dini_IntSet(filename, string, tData[tdid][T_Outline]);
    else if(!strcmp("T_Proportional", data))
		dini_IntSet(filename, string, tData[tdid][T_Proportional]);
    else if(!strcmp("T_Shadow", data))
		dini_IntSet(filename, string, tData[tdid][T_Shadow]);
	else
	    SendClientMessageToAll(MSG_COLOR, "Incorrect data parsed, textdraw autosave failed");
}

stock LoadProject( playerid, filename[] )
{
	/*  Loads a project for edition.
	    @filename[]:            Filename where the project is currently saved.
	*/
	new string[128];
	if(!dini_Isset(filename, "TDFile"))
	{
	    SendClientMessage(playerid, MSG_COLOR, "Invalid textdraw file.");
	    ShowTextDrawDialog(playerid, 0);
	}
	else
	{
		for(new i; i < MAX_TEXTDRAWS; i ++)
		{
		    format(string, sizeof(string), "%dT_Created", i);
		    if(dini_Isset(filename, string))
		    {
		        CreateDefaultTextdraw(i, 0); // Create but don't save.

		        format(string, sizeof(string), "%dT_Text", i);
		        if(dini_Isset(filename, string))
					format(tData[i][T_Text], 1536, "%s", dini_Get(filename, string));

	            format(string, sizeof(string), "%dT_X", i);
				if(dini_Isset(filename, string))
					tData[i][T_X] = dini_Float(filename, string);

	            format(string, sizeof(string), "%dT_Y", i);
				if(dini_Isset(filename, string))
					tData[i][T_Y] = dini_Float(filename, string);

	            format(string, sizeof(string), "%dT_Alignment", i);
				if(dini_Isset(filename, string))
					tData[i][T_Alignment] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_BackColor", i);
				if(dini_Isset(filename, string))
					tData[i][T_BackColor] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_UseBox", i);
				if(dini_Isset(filename, string))
					tData[i][T_UseBox] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_BoxColor", i);
				if(dini_Isset(filename, string))
					tData[i][T_BoxColor] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_TextSizeX", i);
			    if(dini_Isset(filename, string))
					tData[i][T_TextSizeX] = dini_Float(filename, string);

	            format(string, sizeof(string), "%dT_TextSizeY", i);
			    if(dini_Isset(filename, string))
					tData[i][T_TextSizeY] = dini_Float(filename, string);

	            format(string, sizeof(string), "%dT_Color", i);
			    if(dini_Isset(filename, string))
					tData[i][T_Color] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_Font", i);
			    if(dini_Isset(filename, string))
					tData[i][T_Font] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_XSize", i);
				if(dini_Isset(filename, string))
					tData[i][T_XSize] = dini_Float(filename, string);

	            format(string, sizeof(string), "%dT_YSize", i);
				if(dini_Isset(filename, string))
					tData[i][T_YSize] = dini_Float(filename, string);

	            format(string, sizeof(string), "%dT_Outline", i);
			    if(dini_Isset(filename, string))
					tData[i][T_Outline] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_Proportional", i);
			    if(dini_Isset(filename, string))
					tData[i][T_Proportional] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_Shadow", i);
			    if(dini_Isset(filename, string))
					tData[i][T_Shadow] = dini_Int(filename, string);

		        UpdateTextdraw(i);
		    }
		}
		strmid(CurrentProject, filename, 0, strlen(filename) - 4, 128);
		ShowTextDrawDialog(playerid, 4);
	}
}

stock ExportProject( playerid, type )
{
	/*  Exports a project.
	    @playerid:          ID of the player exporting the project.
	    @type:              Type of export requested:
	        - Type 0:       Classic export type
	        - Type 7:       Classic export type for Player Textdraws (Edited in by Southclaws)
	        (Fixed so this type saves in .txt format, not .pwn)
 	*/
 	SendClientMessage(playerid, MSG_COLOR, "The project is now being exported, please wait...");
 	
 	new filename[135], tmpstring[1152];
 	if(type == 0 || type == 7)	format(filename, sizeof(filename), "%s.txt", CurrentProject);
 	else		  				format(filename, sizeof(filename), "%s.pwn", CurrentProject);
 	new File:File = fopen(filename, io_write);
	switch(type)
	{
	    case 0: // Classic export.
	    {
	        fwrite(File, "// TextDraw developed using Zamaroht's Textdraw Editor 1.0\r\n\r\n");
	        fwrite(File, "// On top of script:\r\n");
	        for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
	        fwrite(File, "\r\n// In OnGameModeInit prefferably, we procced to create our textdraws:\r\n");
	        for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "Textdraw%d\t\t\t\t\t=TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "TextDrawAlignment\t\t\t(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "TextDrawBackgroundColor\t\t(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawFont\t\t\t\t(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawLetterSize\t\t\t(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawColor\t\t\t\t(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawSetOutline\t\t\t(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawSetProportional\t\t(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "TextDrawSetShadow\t\t\t(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "TextDrawUseBox\t\t\t\t(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "TextDrawBoxColor\t\t\t(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "TextDrawTextSize\t\t\t(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "// You can now use TextDrawShowForPlayer(-ForAll), TextDrawHideForPlayer(-ForAll) and\r\n");
	        fwrite(File, "// TextDrawDestroy functions to show, hide, and destroy the textdraw.");

			format(tmpstring, sizeof(tmpstring), "Project exported to %s.txt in scriptfiles directory.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    
	    case 1: // Show all the time
	    {
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generated using Zamaroht's TextDraw Editor Version 1.0.\r\n");
	        fwrite(File, "Designed for SA-MP 0.3a.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Time and Date: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instructions:\r\n");
			fwrite(File, "1- Compile this file using the compiler provided with the sa-mp server package.\r\n");
			fwrite(File, "2- Copy the .amx file to the filterscripts directory.\r\n");
			fwrite(File, "3- Add the filterscripts in the server.cfg file (more info here:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Run the server!\r\n\r\n");
			fwrite(File, "Disclaimer:\r\n");
			fwrite(File, "You have full rights over this file. You can distribute it, modify it, and\r\n");
			fwrite(File, "change it as much as you want, without having to give any special credits.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
            for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
			fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Textdraw file generated by\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor was loaded.\");\r\n\r\n");
			fwrite(File, "	// Create the textdraws:\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	for(new i; i < MAX_PLAYERS; i ++)\r\n");
	        fwrite(File, "	{\r\n");
	        fwrite(File, "		if(IsPlayerConnected(i))\r\n");
	        fwrite(File, "		{\r\n");
	        for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "			TextDrawShowForPlayer(i, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "		}\r\n");
			fwrite(File, "	}\r\n");
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            for(new i; i < MAX_TEXTDRAWS; i ++)
            {
                if(tData[i][T_Created])
                {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerConnect(playerid)\r\n");
			fwrite(File, "{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawShowForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n");
			
			format(tmpstring, sizeof(tmpstring), "Project exported to %s.pwn in scriptfiles directory as a filterscript.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    
	    case 2: // Show on class selection
	    {
            fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generated using Zamaroht's TextDraw Editor Version 1.0.\r\n");
	        fwrite(File, "Designed for SA-MP 0.3a.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Time and Date: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instructions:\r\n");
			fwrite(File, "1- Compile this file using the compiler provided with the sa-mp server package.\r\n");
			fwrite(File, "2- Copy the .amx file to the filterscripts directory.\r\n");
			fwrite(File, "3- Add the filterscripts in the server.cfg file (more info here:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Run the server!\r\n\r\n");
			fwrite(File, "Disclaimer:\r\n");
			fwrite(File, "You have full rights over this file. You can distribute it, modify it, and\r\n");
			fwrite(File, "change it as much as you want, without having to give any special credits.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
            for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
			fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Textdraw file generated by\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor was loaded.\");\r\n\r\n");
			fwrite(File, "	// Create the textdraws:\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            for(new i; i < MAX_TEXTDRAWS; i ++)
            {
                if(tData[i][T_Created])
                {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerRequestClass(playerid, classid)\r\n");
			fwrite(File, "{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawShowForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerSpawn(playerid)\r\n");
			fwrite(File, "{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			
			format(tmpstring, sizeof(tmpstring), "Project exported to %s.pwn in scriptfiles directory as a filterscript.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    
	    case 3: // Show while in vehicle
	    {
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generated using Zamaroht's TextDraw Editor Version 1.0.\r\n");
	        fwrite(File, "Designed for SA-MP 0.3a.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Time and Date: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instructions:\r\n");
			fwrite(File, "1- Compile this file using the compiler provided with the sa-mp server package.\r\n");
			fwrite(File, "2- Copy the .amx file to the filterscripts directory.\r\n");
			fwrite(File, "3- Add the filterscripts in the server.cfg file (more info here:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Run the server!\r\n\r\n");
			fwrite(File, "Disclaimer:\r\n");
			fwrite(File, "You have full rights over this file. You can distribute it, modify it, and\r\n");
			fwrite(File, "change it as much as you want, without having to give any special credits.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
            for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
			fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Textdraw file generated by\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor was loaded.\");\r\n\r\n");
			fwrite(File, "	// Create the textdraws:\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            for(new i; i < MAX_TEXTDRAWS; i ++)
            {
                if(tData[i][T_Created])
                {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerStateChange(playerid, newstate, oldstate)\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)\r\n");
			fwrite(File, "	{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "		TextDrawShowForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	}\r\n");
			fwrite(File, "	else if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)\r\n");
			fwrite(File, "	{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "		TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	}\r\n");
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n");
			
			format(tmpstring, sizeof(tmpstring), "Project exported to %s.pwn in scriptfiles directory as a filterscript.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    
	    case 4: // Use command
	    {
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generated using Zamaroht's TextDraw Editor Version 1.0.\r\n");
	        fwrite(File, "Designed for SA-MP 0.3a.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Time and Date: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instructions:\r\n");
			fwrite(File, "1- Compile this file using the compiler provided with the sa-mp server package.\r\n");
			fwrite(File, "2- Copy the .amx file to the filterscripts directory.\r\n");
			fwrite(File, "3- Add the filterscripts in the server.cfg file (more info here:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Run the server!\r\n\r\n");
			fwrite(File, "Disclaimer:\r\n");
			fwrite(File, "You have full rights over this file. You can distribute it, modify it, and\r\n");
			fwrite(File, "change it as much as you want, without having to give any special credits.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
			fwrite(File, "new Showing[MAX_PLAYERS];\r\n\r\n");
            for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
	        fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Textdraw file generated by\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor was loaded.\");\r\n\r\n");
			fwrite(File, "	// Create the textdraws:\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            for(new i; i < MAX_TEXTDRAWS; i ++)
            {
                if(tData[i][T_Created])
                {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerConnect(playerid)\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	Showing[playerid] = 0;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerCommandText(playerid, cmdtext[])\r\n");
			fwrite(File, "{\r\n");
			if(pData[playerid][P_Aux] != 0)
			{
			    format(tmpstring, sizeof(tmpstring), "	if(!strcmp(cmdtext, \"%s\") && Showing[playerid] == 0)\r\n", pData[playerid][P_ExpCommand]);
			    fwrite(File, tmpstring);
			}
			else
			{
			    format(tmpstring, sizeof(tmpstring), "	if(!strcmp(cmdtext, \"%s\"))\r\n", pData[playerid][P_ExpCommand]);
			    fwrite(File, tmpstring);
			}
			fwrite(File, "	{\r\n");
			fwrite(File, "		if(Showing[playerid] == 1)\r\n");
			fwrite(File, "		{\r\n");
			fwrite(File, "			Showing[playerid] = 0;\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "			TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "		}\r\n");
			fwrite(File, "		else\r\n");
			fwrite(File, "		{\r\n");
			fwrite(File, "			Showing[playerid] = 1;\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "			TextDrawShowForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			if(pData[playerid][P_Aux] != 0)
			{
			    format(tmpstring, sizeof(tmpstring), "			SetTimerEx(\"HideTextdraws\", %d, 0, \"i\", playerid);\r\n", pData[playerid][P_Aux]*1000);
				fwrite(File, tmpstring);
			}
			fwrite(File, "		}\r\n");
			fwrite(File, "	}\r\n");
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n");
            if(pData[playerid][P_Aux] != 0)
			{
			    fwrite(File, "\r\n");
			    fwrite(File, "forward HideTextdraws(playerid);\r\n");
			    fwrite(File, "public HideTextdraws(playerid)\r\n");
			    fwrite(File, "{\r\n");
			    fwrite(File, "	Showing[playerid] = 0;\r\n");
			    for(new i; i < MAX_TEXTDRAWS; i ++)
				{
				    if(tData[i][T_Created])
				    {
				        format(tmpstring, sizeof(tmpstring), "	TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
						fwrite(File, tmpstring);
				    }
				}
				fwrite(File, "}\r\n");
			}
			
			format(tmpstring, sizeof(tmpstring), "Project exported to %s.pwn in scriptfiles directory as a filterscript.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    
	    case 5: // Every X time
	    {
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generated using Zamaroht's TextDraw Editor Version 1.0.\r\n");
	        fwrite(File, "Designed for SA-MP 0.3a.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Time and Date: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instructions:\r\n");
			fwrite(File, "1- Compile this file using the compiler provided with the sa-mp server package.\r\n");
			fwrite(File, "2- Copy the .amx file to the filterscripts directory.\r\n");
			fwrite(File, "3- Add the filterscripts in the server.cfg file (more info here:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Run the server!\r\n\r\n");
			fwrite(File, "Disclaimer:\r\n");
			fwrite(File, "You have full rights over this file. You can distribute it, modify it, and\r\n");
			fwrite(File, "change it as much as you want, without having to give any special credits.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
			fwrite(File, "new Timer;\r\n\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
	        fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Textdraw file generated by\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor was loaded.\");\r\n\r\n");
			fwrite(File, "	// Create the textdraws:\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        format(tmpstring, sizeof(tmpstring), "	Timer = SetTimer(\"ShowMessage\", %d, 1);\r\n", pData[playerid][P_Aux]*1000);
	        fwrite(File, tmpstring);
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            for(new i; i < MAX_TEXTDRAWS; i ++)
            {
                if(tData[i][T_Created])
                {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
            fwrite(File, "	KillTimer(Timer);\r\n");
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
	        fwrite(File, "forward ShowMessage( );\r\n");
	        fwrite(File, "public ShowMessage( )\r\n");
	        fwrite(File, "{\r\n");
	        for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawShowForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			format(tmpstring, sizeof(tmpstring), "	SetTimer(\"HideMessage\", %d, 1);\r\n", pData[playerid][P_Aux2]*1000);
			fwrite(File, tmpstring);
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "forward HideMessage( );\r\n");
	        fwrite(File, "public HideMessage( )\r\n");
	        fwrite(File, "{\r\n");
	        for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
	        fwrite(File, "}");
	        
	        format(tmpstring, sizeof(tmpstring), "Project exported to %s.pwn in scriptfiles directory as a filterscript.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    
	    case 6: // After kill
	    {
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generated using Zamaroht's TextDraw Editor Version 1.0.\r\n");
	        fwrite(File, "Designed for SA-MP 0.3a.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Time and Date: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instructions:\r\n");
			fwrite(File, "1- Compile this file using the compiler provided with the sa-mp server package.\r\n");
			fwrite(File, "2- Copy the .amx file to the filterscripts directory.\r\n");
			fwrite(File, "3- Add the filterscripts in the server.cfg file (more info here:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Run the server!\r\n\r\n");
			fwrite(File, "Disclaimer:\r\n");
			fwrite(File, "You have full rights over this file. You can distribute it, modify it, and\r\n");
			fwrite(File, "change it as much as you want, without having to give any special credits.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
            for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
			fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Textdraw file generated by\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor was loaded.\");\r\n\r\n");
			fwrite(File, "	// Create the textdraws:\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            for(new i; i < MAX_TEXTDRAWS; i ++)
            {
                if(tData[i][T_Created])
                {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerDeath(playerid, killerid, reason)\r\n");
			fwrite(File, "{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawShowForPlayer(killerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			format(tmpstring, sizeof(tmpstring), "	SetTimerEx(\"HideMessage\", %d, 0, \"i\", killerid);\r\n", pData[playerid][P_Aux]*1000);
			fwrite(File, tmpstring);
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "forward HideMessage(playerid);\r\n");
			fwrite(File, "public HideMessage(playerid)\r\n");
			fwrite(File, "{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "}");
			
		    format(tmpstring, sizeof(tmpstring), "Project exported to %s.pwn in scriptfiles directory as a filterscript.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    case 7: // Classic mode + PlayerTextDraw
	    {
	        fwrite(File, "// TextDraw developed using Zamaroht's Textdraw Editor 1.0\r\n");
			fwrite(File, "Edited by Southclaws to include support for Player Textdraws\r\n");
	        fwrite(File, "// On top of script:\r\n");
	        for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new PlayerText:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
	        fwrite(File, "\r\n// In OnGameModeInit or OnPlayerConnect prefferably, we procced to create our textdraws:\r\n");
	        for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "Textdraw%d\t\t\t\t\t\t=CreatePlayerTextDraw(playerid, %f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "PlayerTextDrawAlignment\t(playerid, Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawBackgroundColor\t(playerid, Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawFont\t\t\t\t(playerid, Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawLetterSize\t\t(playerid, Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawColor\t\t\t\t(playerid, Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetOutline\t\t(playerid, Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetProportional\t(playerid, Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawSetShadow\t\t\t(playerid, Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "PlayerTextDrawUseBox\t\t\t(playerid, Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "PlayerTextDrawBoxColor\t\t\t(playerid, Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "PlayerTextDrawTextSize\t\t\t(playerid, Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "// You can now use PlayerextDrawShow, PlayerTextDrawHide and\r\n");
	        fwrite(File, "// PlayerTextDrawDestroy functions to show, hide, and destroy the textdraw.");

			format(tmpstring, sizeof(tmpstring), "Project exported to %s.txt in scriptfiles directory.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	}
	fclose(File);
	
	ShowTextDrawDialog(playerid, 4);
}

// ================================================================================================================================
// -------------------------------------------------------- AUXILIAR FUNCTIONS ----------------------------------------------------
// ================================================================================================================================


stock GetFileNameFromLst( file[], line )
{
	/*  Returns the line in the specified line of the specified file.
	    @file[]:            File to return the line from.
	    @line:              Line number to return.
	*/
	new string[150];

	new CurrLine,
		File:Handler = fopen(file, io_read);

	if(line >= 0 && CurrLine != line)
	{
        while(CurrLine != line)
        {
			fread(Handler, string);
            CurrLine ++;
        }
	}

	// Read the next line, which is the asked one.
	fread(Handler, string);
	fclose(Handler);

	// Cut the last two characters (\n)
	strmid(string, string, 0, strlen(string) - 2, 150);

	return string;
}

stock DeleteLineFromFile( file[], line )
{
	/*  Deletes a specific line from a specific file.
	    @file[]:        File to delete the line from.
	    @line:          Line number to delete.
	*/

	if(line < 0) return false;

	new tmpfile[140];
	format(tmpfile, sizeof(tmpfile), "%s.tmp", file);
	fcopytextfile(file, tmpfile);
	// Copied to a temp file, now parse it back.

	new CurrLine,
		File:FileFrom 	= fopen(tmpfile, io_read),
		File:FileTo		= fopen(file, io_write);

	new tmpstring[200];
	if(CurrLine != line)
	{
		while(CurrLine != line)
		{
		    fread(FileFrom, tmpstring);
			fwrite(FileTo, tmpstring);
			CurrLine ++;
		}
	}

	// Skip a line
	fread(FileFrom, tmpstring);

	// Write the rest
	while(fread(FileFrom, tmpstring))
	{
	    fwrite(FileTo, tmpstring);
	}

	fclose(FileTo);
	fclose(FileFrom);
	// Remove tmp file.
	fremove(tmpfile);
	return true;
}

/** BY DRACOBLUE
 *  Strips Newline from the end of a string.
 *  Idea: Y_Less, Bugfixing (when length=1) by DracoBlue
 *  @param   string
 */
stock StripNewLine(string[])
{
	new len = strlen(string);
	if (string[0]==0) return ;
	if ((string[len - 1] == '\n') || (string[len - 1] == '\r')) {
		string[len - 1] = 0;
		if (string[0]==0) return ;
		if ((string[len - 2] == '\n') || (string[len - 2] == '\r')) string[len - 2] = 0;
	}
}

/** BY DRACOBLUE
 *  Copies a textfile (Source file won't be deleted!)
 *  @param   oldname
 *           newname
 */
stock fcopytextfile(oldname[],newname[]) {
	new File:ohnd,File:nhnd;
	if (!fexist(oldname)) return false;
	ohnd=fopen(oldname,io_read);
	nhnd=fopen(newname,io_write);
	new tmpres[256];
	while (fread(ohnd,tmpres)) {
		StripNewLine(tmpres);
		format(tmpres,sizeof(tmpres),"%s\r\n",tmpres);
		fwrite(nhnd,tmpres);
	}
	fclose(ohnd);
	fclose(nhnd);
	return true;
}

stock RGB( red, green, blue, alpha )
{
	/*  Combines a color and returns it, so it can be used in functions.
	    @red:           Amount of red color.
	    @green:         Amount of green color.
	    @blue:          Amount of blue color.
	    @alpha:         Amount of alpha transparency.

		-Returns:
		A integer with the combined color.
	*/
	return (red * 16777216) + (green * 65536) + (blue * 256) + alpha;
}

IsNumeric2(const string[])
{
    // Is Numeric Check 2
	// ------------------
	// By DracoBlue... handles negative numbers

	new length=strlen(string);
	if (length==0) return false;
	for (new i = 0; i < length; i++)
	{
	  if((string[i] > '9' || string[i] < '0' && string[i]!='-' && string[i]!='+' && string[i]!='.') // Not a number,'+' or '-' or '.'
	         || (string[i]=='-' && i!=0)                                             // A '-' but not first char.
	         || (string[i]=='+' && i!=0)                                             // A '+' but not first char.
	     ) return false;
	}
	if (length==1 && (string[0]=='-' || string[0]=='+' || string[0]=='.')) return false;
	return true;
}

/** BY DRACOBLUE
 *  Return the value of an hex-string
 *  @param string
 */
stock HexToInt(string[]) {
  if (string[0]==0) return 0;
  new i;
  new cur=1;
  new res=0;
  for (i=strlen(string);i>0;i--) {
    if (string[i-1]<58) res=res+cur*(string[i-1]-48); else res=res+cur*(string[i-1]-65+10);
    cur=cur*16;
  }
  return res;
}

stock IsPlayerMinID(playerid)
{
	/*  Checks if the player is the minumum ID in the server.
	    @playerid:              ID to check.
	    
	    -Returns:
	    true if he is, false if he isn't.
	*/
	for(new i; i < playerid; i ++)
	{
	    if(IsPlayerConnected(i))
	    {
		    if(IsPlayerNPC(i)) continue;
		    else return false;
		}
	}
	return true;
}
// ================================================================================================================================
// ----------------------------------------------------- END OF AUXULIAR FUNCTIONS ------------------------------------------------
// ================================================================================================================================

// EOF

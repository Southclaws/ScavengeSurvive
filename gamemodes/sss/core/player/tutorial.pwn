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


==============================================================================*/


#include <YSI\y_hooks>


static
PlayerText:	TutUI_Keys				[MAX_PLAYERS],
PlayerText:	TutUI_Watch				[MAX_PLAYERS],
PlayerText:	TutUI_Stats				[MAX_PLAYERS],
PlayerText:	TutUI_Exit				[MAX_PLAYERS],
PlayerText:	ClassButtonTutorial		[MAX_PLAYERS],
bool:		PlayerInTutorial		[MAX_PLAYERS],
			PlayerTutorialWorld		[MAX_PLAYERS],
			PlayerTutorialVehicle	[MAX_PLAYERS],
			TutorialWorld = 90;


static
			HANDLER = -1;


forward OnPlayerWearBag(playerid, itemid);
forward OnPlayerHolsteredItem(playerid, itemid);


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Tutorial'...");

	HANDLER = debug_register_handler("tutorial", 0);
}

hook OnPlayerLoadAccount(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerLoadAccount] in /gamemodes/sss/core/player/tutorial.pwn");

	d:1:HANDLER("[OnPlayerLoadAccount]");

	ClassButtonTutorial[playerid]	=CreatePlayerTextDraw(playerid, 320.000000, 300.000000, "~n~Want to try the game first?~n~~n~~y~Click here to play the tutorial!~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonTutorial[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonTutorial[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonTutorial[playerid], 0.25, 1.000000);
	PlayerTextDrawColor				(playerid, ClassButtonTutorial[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonTutorial[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonTutorial[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonTutorial[playerid], 34.000000, 150.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonTutorial[playerid], true);
}

hook OnPlayerSpawnChar(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerSpawnChar] in /gamemodes/sss/core/player/tutorial.pwn");

	PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);
}

hook OnPlayerSpawnNewChar(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerSpawnNewChar] in /gamemodes/sss/core/player/tutorial.pwn");

	PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);
}

hook OnPlayerCreateChar(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerCreateChar] in /gamemodes/sss/core/player/tutorial.pwn");

	d:1:HANDLER("[OnPlayerCreateChar]");

	PlayerTextDrawShow(playerid, ClassButtonTutorial[playerid]);
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerClickPlayerTD] in /gamemodes/sss/core/player/tutorial.pwn");

	d:1:HANDLER("[OnPlayerClickPlayerTD]");
	if(playertextid == ClassButtonTutorial[playerid])
	{
		PlayerTutorialWorld[playerid] = TutorialWorld;
		TutorialWorld++;

		TutUI_Keys[playerid]			=CreatePlayerTextDraw(playerid, 390.000000, 140.000000, "This tells you ~>~ what keys to press");
		PlayerTextDrawBackgroundColor	(playerid, TutUI_Keys[playerid], 255);
		PlayerTextDrawFont				(playerid, TutUI_Keys[playerid], 1);
		PlayerTextDrawLetterSize		(playerid, TutUI_Keys[playerid], 0.300000, 1.500000);
		PlayerTextDrawColor				(playerid, TutUI_Keys[playerid], -1);
		PlayerTextDrawSetOutline		(playerid, TutUI_Keys[playerid], 0);
		PlayerTextDrawSetProportional	(playerid, TutUI_Keys[playerid], 1);
		PlayerTextDrawSetShadow			(playerid, TutUI_Keys[playerid], 1);
		PlayerTextDrawUseBox			(playerid, TutUI_Keys[playerid], 1);
		PlayerTextDrawBoxColor			(playerid, TutUI_Keys[playerid], 100);
		PlayerTextDrawTextSize			(playerid, TutUI_Keys[playerid], 480.000000, 0.000000);

		TutUI_Watch[playerid]			=CreatePlayerTextDraw(playerid, 83.000000, 250.000000, "This is your watch.~n~It shows your facing angle,~n~current time of day,~n~and chat radio frequency.~n~~d~");
		PlayerTextDrawAlignment			(playerid, TutUI_Watch[playerid], 2);
		PlayerTextDrawBackgroundColor	(playerid, TutUI_Watch[playerid], 255);
		PlayerTextDrawFont				(playerid, TutUI_Watch[playerid], 1);
		PlayerTextDrawLetterSize		(playerid, TutUI_Watch[playerid], 0.300000, 1.500000);
		PlayerTextDrawColor				(playerid, TutUI_Watch[playerid], -1);
		PlayerTextDrawSetOutline		(playerid, TutUI_Watch[playerid], 0);
		PlayerTextDrawSetProportional	(playerid, TutUI_Watch[playerid], 1);
		PlayerTextDrawSetShadow			(playerid, TutUI_Watch[playerid], 1);
		PlayerTextDrawUseBox			(playerid, TutUI_Watch[playerid], 1);
		PlayerTextDrawBoxColor			(playerid, TutUI_Watch[playerid], 100);
		PlayerTextDrawTextSize			(playerid, TutUI_Watch[playerid], 0.000000, 150.000000);

		TutUI_Stats[playerid]			=CreatePlayerTextDraw(playerid, 390.000000, 20.000000, "This shows your ~>~ health, armour, ammo and energy");
		PlayerTextDrawBackgroundColor	(playerid, TutUI_Stats[playerid], 255);
		PlayerTextDrawFont				(playerid, TutUI_Stats[playerid], 1);
		PlayerTextDrawLetterSize		(playerid, TutUI_Stats[playerid], 0.300000, 1.500000);
		PlayerTextDrawColor				(playerid, TutUI_Stats[playerid], -1);
		PlayerTextDrawSetOutline		(playerid, TutUI_Stats[playerid], 0);
		PlayerTextDrawSetProportional	(playerid, TutUI_Stats[playerid], 1);
		PlayerTextDrawSetShadow			(playerid, TutUI_Stats[playerid], 1);
		PlayerTextDrawUseBox			(playerid, TutUI_Stats[playerid], 1);
		PlayerTextDrawBoxColor			(playerid, TutUI_Stats[playerid], 100);
		PlayerTextDrawTextSize			(playerid, TutUI_Stats[playerid], 480.000000, 0.000000);

		TutUI_Exit[playerid]			=CreatePlayerTextDraw(playerid, 484.000000, 280.000000, "To exit the tutorial, type /exit. If you can only see the tutorial button:~n~~n~This server uses an anti-cheat program. To play, you must download this from ~y~ac.scavengesurvive.com then you can play unrestricted.");
		PlayerTextDrawBackgroundColor	(playerid, TutUI_Exit[playerid], 255);
		PlayerTextDrawFont				(playerid, TutUI_Exit[playerid], 1);
		PlayerTextDrawLetterSize		(playerid, TutUI_Exit[playerid], 0.300000, 1.500000);
		PlayerTextDrawColor				(playerid, TutUI_Exit[playerid], -1);
		PlayerTextDrawSetOutline		(playerid, TutUI_Exit[playerid], 0);
		PlayerTextDrawSetProportional	(playerid, TutUI_Exit[playerid], 1);
		PlayerTextDrawSetShadow			(playerid, TutUI_Exit[playerid], 1);
		PlayerTextDrawUseBox			(playerid, TutUI_Exit[playerid], 1);
		PlayerTextDrawBoxColor			(playerid, TutUI_Exit[playerid], 100);
		PlayerTextDrawTextSize			(playerid, TutUI_Exit[playerid], 630.000000, 0.000000);

		SetPlayerPos(playerid, 1078.36194, 2139.40771, 10.64758);
		SetPlayerFacingAngle(playerid, 180.0);
		SetPlayerVirtualWorld(playerid, PlayerTutorialWorld[playerid]);

		switch(random(14))
		{
			case 0: SetPlayerClothesID(playerid, skin_MainM);
			case 1: SetPlayerClothesID(playerid, skin_Civ1M);
			case 2: SetPlayerClothesID(playerid, skin_Civ2M);
			case 3: SetPlayerClothesID(playerid, skin_Civ3M);
			case 4: SetPlayerClothesID(playerid, skin_Civ4M);
			case 5: SetPlayerClothesID(playerid, skin_MechM);
			case 6: SetPlayerClothesID(playerid, skin_BikeM);
			case 7: SetPlayerClothesID(playerid, skin_MainF);
			case 8: SetPlayerClothesID(playerid, skin_Civ1F);
			case 9: SetPlayerClothesID(playerid, skin_Civ2F);
			case 10: SetPlayerClothesID(playerid, skin_Civ3F);
			case 11: SetPlayerClothesID(playerid, skin_Civ4F);
			case 12: SetPlayerClothesID(playerid, skin_ArmyF);
			case 13: SetPlayerClothesID(playerid, skin_IndiF);
		}

		SetPlayerHP(playerid, 100.0);
		SetPlayerAP(playerid, 0.0);
		SetPlayerFP(playerid, 80.0);
		SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
		SetPlayerGender(playerid, GetClothesGender(GetPlayerClothesID(playerid)));
		SetPlayerBleedRate(playerid, 0.0);

		SetPlayerBitFlag(playerid, Alive, false);
		SetPlayerBitFlag(playerid, Spawned, false);

		FreezePlayer(playerid, gLoginFreezeTime * 1000);
		PrepareForSpawn(playerid);

		PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
		PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);
		PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);

		SetPlayerBrightness(playerid, 255);

		ShowHelpTip(playerid, "Welcome to the tutorial! Look around and try things. Help messages will appear here! Type /exit to leave the tutorial.");
		PlayerInTutorial[playerid] = true;

		ToggleTutorialUI(playerid, true);

		new itemid;

		CreateItem(item_Satchel, 1078.70325, 2132.96069, 9.85179, .world = PlayerTutorialWorld[playerid]);

		PlayerTutorialVehicle[playerid] = CreateWorldVehicle(veht_Bobcat, 1075.4344, 2121.3606, 10.7901, 355.6799, -1, -1, .world = PlayerTutorialWorld[playerid]);
		SetVehicleHealth(PlayerTutorialVehicle[playerid], 321.9);
		SetVehicleFuel(PlayerTutorialVehicle[playerid], frandom(1.0));
		FillContainerWithLoot(GetVehicleContainer(PlayerTutorialVehicle[playerid]), 5, loot_Civilian);
		SetVehicleDamageData(PlayerTutorialVehicle[playerid],
			encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4)),
			encode_doors(random(5), random(5), random(5), random(5)),
			encode_lights(random(2), random(2), random(2), random(2)),
			encode_tires(0, 1, 1, 0) );

		CreateItem(item_Wrench, 1077.57263, 2125.35938, 9.85153, .rz = frandom(360.0), .world = PlayerTutorialWorld[playerid]);
		CreateItem(item_Screwdriver, 1076.52942, 2125.82959, 9.85156, .rz = frandom(360.0), .world = PlayerTutorialWorld[playerid]);
		CreateItem(item_Hammer, 1074.94214, 2126.51489, 9.85160, .rz = frandom(360.0), .world = PlayerTutorialWorld[playerid]);

		CreateItem(item_Wheel, 1073.59448, 2127.05786, 9.85164, .rz = frandom(360.0), .world = PlayerTutorialWorld[playerid]);
		CreateItem(item_Wheel, 1073.4965, 2125.6582, 9.8516, .rz = frandom(360.0), .world = PlayerTutorialWorld[playerid]);
		itemid = CreateItem(item_GasCan, 0.63107, 10.54177, -20.03327, .rz = frandom(360.0), .world = PlayerTutorialWorld[playerid]);
		SetItemExtraData(itemid, 10);
	}
}

hook OnPlayerDeath(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerDeath] in /gamemodes/sss/core/player/tutorial.pwn");

	ExitTutorial(playerid);
}

hook OnPlayerDisconnect(playerid, reason)
{
	d:3:GLOBAL_DEBUG("[OnPlayerDisconnect] in /gamemodes/sss/core/player/tutorial.pwn");

	ExitTutorial(playerid);
}

ExitTutorial(playerid)
{
	if(!PlayerInTutorial[playerid])
		return 0;

	for(new i = INV_MAX_SLOTS - 1; i >= 0; i--)
	{
		RemoveItemFromInventory(playerid, i);
	}
	
	PlayerInTutorial[playerid] = false;
	HideHelpTip(playerid);
	SetPlayerBitFlag(playerid, Spawned, false);
	SetPlayerBitFlag(playerid, Alive, false);
	SetPlayerVirtualWorld(playerid, 0);
	PlayerCreateNewCharacter(playerid);
	SetPlayerBrightness(playerid, 0);

	DestroyWorldVehicle(PlayerTutorialVehicle[playerid], true);
	PlayerTutorialVehicle[playerid] = INVALID_VEHICLE_ID;

	ToggleTutorialUI(playerid, false);

	return 1;
}

ToggleTutorialUI(playerid, toggle)
{
	if(toggle)
	{
		PlayerTextDrawShow(playerid, TutUI_Keys[playerid]);
		PlayerTextDrawShow(playerid, TutUI_Watch[playerid]);
		PlayerTextDrawShow(playerid, TutUI_Stats[playerid]);
		PlayerTextDrawShow(playerid, TutUI_Exit[playerid]);
	}
	else
	{
		PlayerTextDrawHide(playerid, TutUI_Keys[playerid]);
		PlayerTextDrawHide(playerid, TutUI_Watch[playerid]);
		PlayerTextDrawHide(playerid, TutUI_Stats[playerid]);
		PlayerTextDrawHide(playerid, TutUI_Exit[playerid]);
	}
}


hook OnPlayerPickUpItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerPickUpItem] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		// ShowHelpTip(playerid, "This is an item. There are many different items in the game with different purposes. Some are common and some are rare.");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


hook OnPlayerWearBag(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerWearBag] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "You can access your bag by pressing "KEYTEXT_INVENTORY" and clicking the Bag icon at the bottom right.");
	}

	return 0;
}


hook OnPlayerOpenInventory(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerOpenInventory] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		ToggleTutorialUI(playerid, false);

		ShowHelpTip(playerid, "This is your character inventory also known as your pockets. This is not your bag.");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


hook OnPlayerOpenContainer(playerid, containerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerOpenContainer] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		ToggleTutorialUI(playerid, false);

		if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
		{
			ShowHelpTip(playerid, "This is your bag. Bags are extra storage. There are many different types of bags with different sizes.");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseInventory(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerCloseInventory] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
		ToggleTutorialUI(playerid, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerCloseContainer] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
		ToggleTutorialUI(playerid, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewCntOpt(playerid, containerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerViewCntOpt] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		if(GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))) == item_Wrench)
		{
			ShowHelpTip(playerid, "These are your options for the selected item. Equip puts it in your hand. Combine can be selected on multiple items to attempt to combine them.");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerDroppedItem] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "When you drop an item, other players can pick it up. Most item types ");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddToInventory(playerid, itemid, slot)
{
	d:3:GLOBAL_DEBUG("[OnItemAddToInventory] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "You added an item to your inventory. If your inventory is full, the item will be put in your bag.");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewInvOpt(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerViewInvOpt] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "These are your options for the selected item. Equip puts it in your hand. Combine can be selected on multiple items to attempt to combine them.");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddToContainer(containerid, itemid, playerid)
{
	d:3:GLOBAL_DEBUG("[OnItemAddToContainer] in /gamemodes/sss/core/player/tutorial.pwn");

	if(IsPlayerConnected(playerid))
	{
		if(PlayerInTutorial[playerid])
		{
			if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
			{
				ShowHelpTip(playerid, "You added an item to your bag. You can access your bag by pressing "KEYTEXT_INVENTORY" and clicking the Bag icon at the bottom right.");
			}
			else
			{
				ShowHelpTip(playerid, "You added an item to a container. Containers are places to store items ");
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerHolsteredItem(playerid, itemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerHolsteredItem] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "You have holstered an item. Holstered items can be quickly accessed by pressing "KEYTEXT_PUT_AWAY" again.");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItemWithItem] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		ShowHelpTip(playerid, "You tried to use an item with another item because you're holding one already. This can be used sometimes, for example use a lighter with a campfire to light it or use a weapon with ammo to load it.");
	}
}

CMD:exit(playerid, params[])
{
	ExitTutorial(playerid);

	return 1;
}

stock IsPlayerInTutorial(playerid)
{
	if(PlayerInTutorial[playerid])
		return 1;

	return 0;
}

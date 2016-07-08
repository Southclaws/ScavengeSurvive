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


#define MAX_DEFENCE_ITEM		(10)
#define MAX_DEFENCE				(6000)
#define INVALID_DEFENCE_ID		(-1)
#define INVALID_DEFENCE_TYPE	(-1)


enum
{
	DEFENCE_POSE_HORIZONTAL,
	DEFENCE_POSE_VERTICAL,
	DEFENCE_POSE_SUPPORTED,
}

enum E_DEFENCE_ITEM_DATA
{
ItemType:	def_itemtype,
Float:		def_verticalRotX,
Float:		def_verticalRotY,
Float:		def_verticalRotZ,
Float:		def_horizontalRotX,
Float:		def_horizontalRotY,
Float:		def_horizontalRotZ,
Float:		def_placeOffsetZ,
			def_maxHitPoints
}

enum e_DEFENCE_DATA
{
bool:		def_active,
			def_pose,
			def_motor,
			def_keypad,
			def_pass,
			def_moveState,
			def_hitPoints
}


static
			def_TypeData[MAX_DEFENCE_ITEM][E_DEFENCE_ITEM_DATA],
			def_TypeTotal,
			def_ItemTypeDefenceType[ITM_MAX_TYPES] = {INVALID_DEFENCE_TYPE};

static
			def_CurrentDefenceItem[MAX_PLAYERS],
			def_CurrentDefenceEdit[MAX_PLAYERS],
			def_CurrentDefenceMove[MAX_PLAYERS],
			def_CurrentDefenceOpen[MAX_PLAYERS],
			def_LastPassEntry[MAX_PLAYERS],
			def_Cooldown[MAX_PLAYERS],
			def_PassFails[MAX_PLAYERS];


forward OnDefenceCreate(defenceid);
forward OnDefenceModified(defenceid);
forward OnDefenceMove(defenceid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Defences'...");
}

hook OnPlayerConnect(playerid)
{
	def_CurrentDefenceItem[playerid] = INVALID_ITEM_ID;
	def_CurrentDefenceEdit[playerid] = -1;
	def_CurrentDefenceMove[playerid] = -1;
	def_CurrentDefenceOpen[playerid] = -1;
	def_LastPassEntry[playerid] = 0;
	def_Cooldown[playerid] = 2000;
	def_PassFails[playerid] = 0;
}


/*==============================================================================

	Core

==============================================================================*/


stock DefineDefenceItem(ItemType:itemtype, Float:v_rx, Float:v_ry, Float:v_rz, Float:h_rx, Float:h_ry, Float:h_rz, Float:zoffset, maxhitpoints)
{
	SetItemTypeMaxArrayData(itemtype, 1);

	def_TypeData[def_TypeTotal][def_itemtype] = itemtype;
	def_TypeData[def_TypeTotal][def_verticalRotX] = v_rx;
	def_TypeData[def_TypeTotal][def_verticalRotY] = v_ry;
	def_TypeData[def_TypeTotal][def_verticalRotZ] = v_rz;
	def_TypeData[def_TypeTotal][def_horizontalRotX] = h_rx;
	def_TypeData[def_TypeTotal][def_horizontalRotY] = h_ry;
	def_TypeData[def_TypeTotal][def_horizontalRotZ] = h_rz;
	def_TypeData[def_TypeTotal][def_placeOffsetZ] = zoffset;
	def_TypeData[def_TypeTotal][def_maxHitPoints] = maxhitpoints;
	def_ItemTypeDefenceType[itemtype] = def_TypeTotal;

	return def_TypeTotal++;
}

CreateDefence(itemid, pose, motor = 0, keypad = 0, pass = 0, movestate = -1, hitpoints = -1, worldid = 0, interiorid = 0)
{
	new itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
	{
		printf("ERROR: Attempted to create defence from item with invalid type (%d)", _:itemtype);
		return INVALID_ITEM_ID;
	}

	new defencetype = def_ItemTypeDefenceType[];

	if(defencetype == INVALID_DEFENCE_TYPE)
	{
		printf("ERROR: Attempted to create defence from item that is not a defence type (%d)", _:itemtype);
		return INVALID_ITEM_ID;
	}

	new
		itemtypename[ITM_MAX_NAME],
		itemdata[e_DEFENCE_DATA],
		objectid;

	GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);
	objectid = GetItemObjectID(itemid);

	itemdata[def_active]	= true;
	itemdata[def_pose]		= pose;
	itemdata[def_motor]		= motor;
	itemdata[def_keypad]	= keypad;
	itemdata[def_pass]		= pass;
	itemdata[def_moveState]	= movestate;
	itemdata[def_hitPoints]	= ((hitpoints == -1) ? (def_TypeData[defencetype][def_maxHitPoints]) : (hitpoints));

	SetItemArrayData(itemid, itemdata, _:e_DEFENCE_DATA);

	if(motor)
	{
		if(movestate == DEFENCE_POSE_HORIZONTAL)
		{
			SetDynamicObjectRot(objectid,
				def_TypeData[defencetype][def_horizontalRotX],
				def_TypeData[defencetype][def_horizontalRotY],
				def_TypeData[defencetype][def_horizontalRotZ] + rz);

			// UITXT: sprintf(""KEYTEXT_INTERACT" to open %s", itemtypename)
			// LABEL: sprintf("%d/%d", hitpoints, def_TypeData[defencetype][def_maxHitPoints])
		}
		else
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(itemid, x, y, z);

			SetDynamicObjectPos(objectid, x, y, z + def_TypeData[defencetype][def_placeOffsetZ]);
			SetDynamicObjectRot(objectid,
				def_TypeData[defencetype][def_verticalRotX],
				def_TypeData[defencetype][def_verticalRotY],
				def_TypeData[defencetype][def_verticalRotZ] + rz);

			// UITXT: sprintf(""KEYTEXT_INTERACT" to open %s", itemtypename)
			// LABEL: sprintf("%d/%d", hitpoints, def_TypeData[defencetype][def_maxHitPoints])
		}
	}
	else
	{
		if(pose == DEFENCE_POSE_HORIZONTAL)
		{
			SetDynamicObjectRot(objectid,
				def_TypeData[defencetype][def_horizontalRotX],
				def_TypeData[defencetype][def_horizontalRotY],
				def_TypeData[defencetype][def_horizontalRotZ] + rz);

			// UITXT: sprintf(""KEYTEXT_INTERACT" to modify %s", itemtypename)
			// LABEL: sprintf("%d/%d", hitpoints, def_TypeData[defencetype][def_maxHitPoints])
		}
		else
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetItemPos(itemid, x, y, z);

			SetDynamicObjectPos(objectid, x, y, z + def_TypeData[defencetype][def_placeOffsetZ]);
			SetDynamicObjectRot(objectid,
				def_TypeData[defencetype][def_verticalRotX],
				def_TypeData[defencetype][def_verticalRotY],
				def_TypeData[defencetype][def_verticalRotZ] + rz);

			// UITXT: sprintf(""KEYTEXT_INTERACT" to modify %s", itemtypename)
			// LABEL: sprintf("%d/%d", hitpoints, def_TypeData[defencetype][def_maxHitPoints])
		}
	}

	return itemid;
}

DeconstructDefence(itemid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);
	SetItemPos(itemid, x, y, z, FLOOR_OFFSET);

	SetItemArrayDataAtCell(itemid, 0, 0);
	SetItemArrayDataLength(itemid, 0);
}


/*==============================================================================

	Internal

==============================================================================*/


hook OnPlayerPickUpItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != INVALID_DEFENCE_TYPE)
	{
		if(GetItemArrayDataAtCell(itemid, 0))
		{
			_InteractDefence(playerid, itemid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return 1;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{

	new ItemType:withitemtype = GetItemType(withitemid);

	if(def_ItemTypeDefenceType[withitemtype] != INVALID_DEFENCE_TYPE)
	{
		if(GetItemArrayDataAtCell(itemid, 0))
		{
			_InteractDefenceWithItem(playerid, withitemid, itemid);
		}
		else
		{
			new ItemType:itemtype = GetItemType(itemid);

			if(itemtype == item_Hammer || itemtype == item_Screwdriver)
				StartBuildingDefence(playerid, withitemid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		StopBuildingDefence(playerid);
	}
}

StartBuildingDefence(playerid, itemid)
{
	new itemtypename[ITM_MAX_NAME];

	GetItemTypeName(GetItemType(itemid), itemtypename);

	def_CurrentDefenceItem[playerid] = itemid;
	StartHoldAction(playerid, 10000);
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, sprintf(ls(playerid, "DEFBUILDING"), itemtypename));

	return 1;
}

StopBuildingDefence(playerid)
{
	if(!IsValidItem(GetPlayerItem(playerid)))
		return;

	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		def_CurrentDefenceItem[playerid] = INVALID_ITEM_ID;
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		HideActionText(playerid);

		return;
	}

	if(def_CurrentDefenceEdit[playerid] != -1)
	{
		def_CurrentDefenceEdit[playerid] = -1;
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		HideActionText(playerid);
		
		return;
	}

	return;
}

_InteractDefence(playerid, itemid)
{
	new data[e_DEFENCE_DATA];

	GetItemArrayData(itemid, data);

	if(data[def_motor])
	{
		if(data[def_keypad] == 1)
		{
			if(data[def_pass] == 0)
			{
				if(def_CurrentDefenceEdit[playerid] != -1)
				{
					HideKeypad(playerid);
					Dialog_Hide(playerid);
				}

				def_CurrentDefenceEdit[playerid] = itemid;
				ShowSetPassDialog_Keypad(playerid);
			}
			else
			{
				if(def_CurrentDefenceOpen[playerid] != -1)
				{
					HideKeypad(playerid);
					Dialog_Hide(playerid);
				}

				def_CurrentDefenceOpen[playerid] = itemid;

				ShowEnterPassDialog_Keypad(playerid);
				CancelPlayerMovement(playerid);
			}
		}
		else if(data[def_keypad] == 2)
		{
			if(data[def_pass] == 0)
			{
				if(def_CurrentDefenceEdit[playerid] != -1)
				{
					HideKeypad(playerid);
					Dialog_Hide(playerid);
				}

				def_CurrentDefenceEdit[playerid] = itemid;
				ShowSetPassDialog_KeypadAdv(playerid);
			}
			else
			{
				if(def_CurrentDefenceOpen[playerid] != -1)
				{
					HideKeypad(playerid);
					Dialog_Hide(playerid);
				}

				def_CurrentDefenceOpen[playerid] = itemid;

				ShowEnterPassDialog_KeypadAdv(playerid);
				CancelPlayerMovement(playerid);
			}
		}
		else
		{
			ShowActionText(playerid, ls(playerid, "DEFMOVINGIT"), 3000);
			defer MoveDefence(itemid, playerid);
		}
	}
}

_InteractDefenceWithItem(playerid, itemid, tool)
{
	new
		defencetype,
		ItemType:tooltype,
		Float:angle;

	defencetype = def_ItemTypeDefenceType[GetItemType(itemid)];
	tooltype =  = GetItemType(tool);
	GetItemRot(itemid, angle, angle, angle);

	// ensures the player can only perform these actions on the back-side.
	if(!(90.0 < absoluteangle(angle - GetButtonAngleToPlayer(playerid, GetItemButtonID(itemid))) < 270.0))
		return 0;

	if(tooltype == item_Crowbar)
	{
		new itemtypename[ITM_MAX_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, 10000);
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
		ShowActionText(playerid, sprintf(ls(playerid, "DEFREMOVING"), itemtypename));

		return 1;
	}

	if(tooltype == item_Motor)
	{
		new itemtypename[ITM_MAX_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, 6000);
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "DEFMODIFYIN"), itemtypename));

		return 1;
	}

	if(tooltype == item_Keypad)
	{
		if(!GetItemArrayDataAtCell(itemid, _:def_motor))
		{
			ShowActionText(playerid, ls(playerid, "DEFNEEDMOTO"));
			return 1;
		}

		new itemtypename[ITM_MAX_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, 6000);
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "DEFMODIFYIN"), itemtypename));

		return 1;
	}

	if(tooltype == item_AdvancedKeypad)
	{
		if(!GetItemArrayDataAtCell(itemid, _:def_motor))
		{
			ShowActionText(playerid, ls(playerid, "DEFNEEDMOTO"));
			return 0;
		}

		new itemtypename[ITM_MAX_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, 6000);
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "DEFMODIFYIN"), itemtypename));

		return 1;
	}

	return 0;
}

hook OnHoldActionUpdate(playerid, progress)
{
	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]))
			StopHoldAction(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]))
			return Y_HOOKS_BREAK_RETURN_0;

		new
			worldid,
			interiorid,
			ItemType:itemtype = GetItemType(GetPlayerItem(playerid)),
			pose,
			itemid;

		GetItemPos(def_CurrentDefenceItem[playerid], x, y, z);
		GetItemRot(def_CurrentDefenceItem[playerid], angle, angle, angle);
		worldid = GetItemWorld(def_CurrentDefenceItem[playerid]);
		interiorid = GetItemInterior(def_CurrentDefenceItem[playerid]);

		if(itemtype == item_Screwdriver)
			pose = DEFENCE_POSE_VERTICAL;

		if(itemtype == item_Hammer)
			pose = DEFENCE_POSE_HORIZONTAL;

		itemid = CreateDefence(def_CurrentDefenceItem[playerid], DEFENCE_POSE_VERTICAL, .worldid = worldid, .interiorid = interiorid);

		if(!IsValidItem(itemid))
		{
			ChatMsgLang(playerid, RED, "DEFLIMITREA");
			return Y_HOOKS_BREAK_RETURN_0;
		}

		new
			geid[GEID_LEN],
			Float:x,
			Float:y,
			Float:z,
			Float:angle;

		GetItemGEID(itemid, geid);
		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, angle, angle, angle);

		logf("[CONSTRUCT] %p Built defence %d (GEID: %d) (%d, %f, %f, %f, %f, %f, %f)",
			playerid, itemid, geid,
			GetItemTypeModel(GetItemType(itemid)),
			x, y, z + def_TypeData[type][def_placeOffsetZ],
			def_TypeData[type][def_verticalRotX],
			def_TypeData[type][def_verticalRotY],
			def_TypeData[type][def_verticalRotZ] + angle);

		CallLocalFunction("OnDefenceCreate", "d", id);
		StopBuildingDefence(playerid);
		//EditDefence(playerid, id);

		return Y_HOOKS_BREAK_RETURN_0;
	}

	if(def_CurrentDefenceEdit[playerid] != -1)
	{
		new
			itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		if(itemtype == item_Motor)
		{
			ShowActionText(playerid, ls(playerid, "DEFINSTMOTO"));
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], true, def_motor);
			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(itemtype == item_Keypad)
		{
			ShowActionText(playerid, ls(playerid, "DEFINSTKEYP"));
			ShowSetPassDialog_Keypad(playerid);
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], 1, def_keypad);
			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(itemtype == item_AdvancedKeypad)
		{
			ShowActionText(playerid, ls(playerid, "DEFINSTADKP"));
			ShowSetPassDialog_KeypadAdv(playerid);
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], 2, def_keypad);
			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(itemtype == item_Crowbar)
		{
			new
				geid[GEID_LEN],
				Float:x,
				Float:y,
				Float:z,
				Float:rx,
				Float:ry,
				Float:rz;

			GetItemGEID(def_CurrentDefenceEdit[playerid], geid);
			GetItemPos(itemid, x, y, z);
			GetItemRot(itemid, rz, rz, rz);
			ShowActionText(playerid, ls(playerid, "DEFDISMANTL"));

			DeconstructDefence(def_CurrentDefenceEdit[playerid]);

			logf("[CROWBAR] %p broke defence %d (%s) (%d, %f, %f, %f, %f, %f, %f)",
				playerid, def_CurrentDefenceEdit[playerid], geid,
				GetItemTypeModel(GetItemType(itemid)), x, y, z, rx, ry, rz);

			/*
				Note:
				This log entry is designed to help with reconstructing bases
				in the case that they are wrongfully deconstructed. The
				section in parentheses mimics the structure of the arguments
				for CreateObject so it can easily be plugged into a map
				editor to view the original base.
			*/

			DestroyDefence(def_CurrentDefenceEdit[playerid]);
			ClearAnimations(playerid);
			def_CurrentDefenceEdit[playerid] = -1;
		}

		return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeypadEnter(playerid, keypadid, code, match)
{
	if(keypadid == 100)
	{
		if(def_CurrentDefenceEdit[playerid] != -1)
		{
			def_Data[def_CurrentDefenceEdit[playerid]][def_pass] = code;
			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);
			HideKeypad(playerid);

			def_CurrentDefenceEdit[playerid] = -1;

			if(code == 0)
				ChatMsgLang(playerid, YELLOW, "DEFCODEZERO");

			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(def_CurrentDefenceOpen[playerid] != -1)
		{
			if(code == match)
			{
				ShowActionText(playerid, ls(playerid, "DEFMOVINGIT"), 3000);
				defer MoveDefence(def_CurrentDefenceOpen[playerid], playerid);
				def_CurrentDefenceOpen[playerid] = -1;
			}
			else
			{
				if(GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]) < def_Cooldown[playerid])
				{
					ShowEnterPassDialog_Keypad(playerid, 2);
					return Y_HOOKS_BREAK_RETURN_0;
				}

				if(def_PassFails[playerid] == 5)
				{
					def_Cooldown[playerid] += 4000;
					def_PassFails[playerid] = 0;
					return Y_HOOKS_BREAK_RETURN_0;
				}

				logf("[DEFFAIL] Player %p failed defence %d (GEID: %d) keypad code %d", playerid, def_CurrentDefenceOpen[playerid], def_GEID[def_CurrentDefenceOpen[playerid]], code);
				ShowEnterPassDialog_Keypad(playerid, 1);
				def_LastPassEntry[playerid] = GetTickCount();
				def_Cooldown[playerid] = 2000;
				def_PassFails[playerid]++;

				return Y_HOOKS_BREAK_RETURN_0;
			}

			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeypadCancel(playerid, keypadid)
{
	if(keypadid == 100)
	{
		if(def_CurrentDefenceEdit[playerid] != -1)
		{
			ShowSetPassDialog_Keypad(playerid);
			def_CurrentDefenceEdit[playerid] = -1;

			return 1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

ShowSetPassDialog_Keypad(playerid)
{
	ChatMsgLang(playerid, YELLOW, "DEFSETPASSC");

	ShowKeypad(playerid, 100);
}

ShowEnterPassDialog_Keypad(playerid, msg = 0)
{
	if(msg == 0)
		ChatMsgLang(playerid, YELLOW, "DEFENTERPAS");

	if(msg == 1)
		ChatMsgLang(playerid, YELLOW, "DEFINCORREC");

	if(msg == 2)
		ChatMsgLang(playerid, YELLOW, "DEFTOOFASTE", MsToString(def_Cooldown[playerid] - GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]), "%m:%s"));

	ShowKeypad(playerid, 100, def_Data[def_CurrentDefenceOpen[playerid]][def_pass]);
}

ShowSetPassDialog_KeypadAdv(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			new pass;

			if(!sscanf(inputtext, "x", pass) && strlen(inputtext) >= 4)
			{
				def_Data[def_CurrentDefenceEdit[playerid]][def_pass] = pass;
				CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);
				def_CurrentDefenceEdit[playerid] = -1;
			}
			else
			{
				ShowSetPassDialog_KeypadAdv(playerid);
			}
		}
		else
		{
			ShowSetPassDialog_KeypadAdv(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Set passcode", "Enter a passcode between 4 and 8 characters long using characers 0-9, a-f.", "Enter", "");

	return 1;
}

ShowEnterPassDialog_KeypadAdv(playerid, msg = 0)
{
	if(msg == 2)
		ChatMsgLang(playerid, YELLOW, "DEFTOOFASTE", MsToString(def_Cooldown[playerid] - GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]), "%m:%s"));

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			new pass;

			sscanf(inputtext, "x", pass);

			if(pass == def_Data[def_CurrentDefenceOpen[playerid]][def_pass] && strlen(inputtext) >= 4)
			{
				ShowActionText(playerid, ls(playerid, "DEFMOVINGIT"), 3000);
				defer MoveDefence(def_CurrentDefenceOpen[playerid], playerid);
				def_CurrentDefenceOpen[playerid] = -1;
			}
			else
			{
				if(GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]) < def_Cooldown[playerid])
				{
					ShowEnterPassDialog_KeypadAdv(playerid, 2);
					return 1;
				}

				if(def_PassFails[playerid] == 5)
				{
					def_Cooldown[playerid] += 4000;
					def_PassFails[playerid] = 0;
					return 1;
				}

				logf("[DEFFAIL] Player %p failed defence %d (GEID: %d) keypad code %d", playerid, def_CurrentDefenceOpen[playerid], def_GEID[def_CurrentDefenceOpen[playerid]], pass);
				ShowEnterPassDialog_KeypadAdv(playerid, 1);
				def_LastPassEntry[playerid] = GetTickCount();
				def_Cooldown[playerid] = 2000;
				def_PassFails[playerid]++;
			}
		}
		else
		{
			return 0;
		}

		return 1;
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Enter passcode", (msg == 1) ? ("Incorrect passcode!") : ("Enter the 4-8 character hexadecimal passcode to open."), "Enter", "Cancel");

	return 1;
}

timer MoveDefence[1500](defenceid, playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	foreach(new i : Player)
	{
		GetPlayerPos(i, x, y, z);

		if(Distance(x, y, z, def_Data[defenceid][def_posX], def_Data[defenceid][def_posY], def_Data[defenceid][def_posZ]) < 3.0)
		{
			defer MoveDefence(defenceid, playerid);

			return;
		}
	}

	if(def_Data[defenceid][def_moveState] == DEFENCE_POSE_HORIZONTAL)
	{
		MoveDynamicObject(def_Data[defenceid][def_objectId],
			def_Data[defenceid][def_posX],
			def_Data[defenceid][def_posY],
			def_Data[defenceid][def_posZ] + def_TypeData[def_Data[defenceid][def_type]][def_placeOffsetZ], 0.5,
			def_TypeData[def_Data[defenceid][def_type]][def_verticalRotX],
			def_TypeData[def_Data[defenceid][def_type]][def_verticalRotY],
			def_TypeData[def_Data[defenceid][def_type]][def_verticalRotZ] + def_Data[defenceid][def_rotZ]);

		def_Data[defenceid][def_moveState] = DEFENCE_POSE_VERTICAL;

		logf("[DEFMOVE] Player %p moved defence %d (GEID: %d) into CLOSED position at %.1f, %.1f, %.1f", playerid, defenceid, def_GEID[defenceid], def_Data[defenceid][def_posX], def_Data[defenceid][def_posY], def_Data[defenceid][def_posZ]);
		CallLocalFunction("OnDefenceMove", "d", defenceid);
	}
	else
	{
		MoveDynamicObject(def_Data[defenceid][def_objectId],
			def_Data[defenceid][def_posX],
			def_Data[defenceid][def_posY],
			def_Data[defenceid][def_posZ], 0.5,
			def_TypeData[def_Data[defenceid][def_type]][def_horizontalRotX],
			def_TypeData[def_Data[defenceid][def_type]][def_horizontalRotY],
			def_TypeData[def_Data[defenceid][def_type]][def_horizontalRotZ] + def_Data[defenceid][def_rotZ]);

		def_Data[defenceid][def_moveState] = DEFENCE_POSE_HORIZONTAL;

		logf("[DEFMOVE] Player %p moved defence %d (GEID: %d) into OPEN position at %.1f, %.1f, %.1f", playerid, defenceid, def_GEID[defenceid], def_Data[defenceid][def_posX], def_Data[defenceid][def_posY], def_Data[defenceid][def_posZ]);
		CallLocalFunction("OnDefenceMove", "d", defenceid);
	}

	return;
}


/*==============================================================================

	Interface functions

==============================================================================*/


stock IsValidDefenceType(type)
{
	if(0 <= type < def_TypeTotal)
		return 1;

	return 0;
}

stock GetItemTypeDefenceType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return INVALID_DEFENCE_TYPE;

	return def_ItemTypeDefenceType[itemtype];
}

stock IsValidDefence(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	return 1;
}

// def_itemtype
forward ItemType:GetDefenceTypeItemType(defencetype);
stock ItemType:GetDefenceTypeItemType(defencetype)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return INVALID_ITEM_TYPE;

	return def_TypeData[defencetype][def_itemtype];
}

// def_verticalRotX
// def_verticalRotY
// def_verticalRotZ
stock GetDefenceTypeVerticalRot(defencetype, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return 0;

	x = def_TypeData[defencetype][def_verticalRotX];
	y = def_TypeData[defencetype][def_verticalRotY];
	z = def_TypeData[defencetype][def_verticalRotZ];

	return 1;
}

// def_horizontalRotX
// def_horizontalRotY
// def_horizontalRotZ
stock GetDefenceTypeHorizontalRot(defencetype, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return 0;

	x = def_TypeData[defencetype][def_horizontalRotX];
	y = def_TypeData[defencetype][def_horizontalRotY];
	z = def_TypeData[defencetype][def_horizontalRotZ];

	return 1;
}

// def_placeOffsetZ
forward Float:GetDefenceTypeOffsetZ(defencetype);
stock Float:GetDefenceTypeOffsetZ(defencetype)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return 0.0;

	return def_TypeData[defencetype][def_placeOffsetZ];
}

// def_maxHitPoints
stock GetDefenceTypeMaxHitpoints(defencetype)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return 0;

	return def_TypeData[defencetype][def_maxHitPoints];
}


// def_type
stock GetDefenceType(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	return def_Data[defenceid][def_type];
}

// def_objectId
stock GetDefenceObjectID(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	return def_Data[defenceid][def_objectId];
}

// def_buttonId
stock GetDefenceButtonID(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	return def_Data[defenceid][def_buttonId];
}

// def_pose
stock GetDefencePose(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	return def_Data[defenceid][def_pose];
}

// def_motor
stock GetDefenceMotor(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	return def_Data[defenceid][def_motor];
}

// def_keypad
stock GetDefenceKeypad(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	return def_Data[defenceid][def_keypad];
}

// def_pass
stock GetDefencePass(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	return def_Data[defenceid][def_pass];
}

// def_moveState
stock GetDefenceMoveState(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	return def_Data[defenceid][def_moveState];
}

// def_hitPoints
stock GetDefenceHitPoints(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	return def_Data[defenceid][def_hitPoints];
}

stock SetDefenceHitPoints(defenceid, hitpoints)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	def_Data[defenceid][def_hitPoints] = hitpoints;

	return 1;
}

// def_posX
// def_posY
// def_posZ
stock GetDefencePos(defenceid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	x = def_Data[defenceid][def_posX];
	y = def_Data[defenceid][def_posY];
	z = def_Data[defenceid][def_posZ];

	return 1;
}

// def_rotZ
forward Float:GetDefenceRot(defenceid);
stock Float:GetDefenceRot(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0.0;

	return def_Data[defenceid][def_rotZ];
}

stock GetClosestDefence(Float:x, Float:y, Float:z, Float:size)
{
	new
		Float:defposx,
		Float:defposy,
		Float:defposz,
		Float:smallestdistance = 9999999.9,
		Float:tempdistance,
		closestid;

	foreach(new i : def_Index)
	{
		GetDefencePos(i, defposx, defposy, defposz);

		tempdistance = Distance(x, y, z, defposx, defposy, defposz);

		if(tempdistance < smallestdistance)
		{
			smallestdistance = tempdistance;
			closestid = i;
		}
	}

	if(smallestdistance < size)
		return closestid;

	else
		return -1;
}

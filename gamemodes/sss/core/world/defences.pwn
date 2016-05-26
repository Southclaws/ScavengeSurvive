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


#define DIRECTORY_DEFENCES	DIRECTORY_MAIN"defences/"
#define MAX_DEFENCE_ITEM	(10)
#define MAX_DEFENCE			(6000)


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

enum E_DEFENCE_DATA
{
			def_type,
			def_objectId,
			def_buttonId,
			def_pose,
			def_motor,
			def_keypad,
			def_pass,
			def_moveState,
			def_hitPoints,
Float:		def_posX,
Float:		def_posY,
Float:		def_posZ,
Float:		def_rotZ,
			def_worldid,
			def_interiorid
}

enum
{
	DEFENCE_CELL_TYPE,
	DEFENCE_CELL_POSE,
	DEFENCE_CELL_MOTOR,
	DEFENCE_CELL_KEYPAD,
	DEFENCE_CELL_PASS,
	DEFENCE_CELL_MOVESTATE,
	DEFENCE_CELL_HITPOINTS
}


static
			def_GEID_Index,
			def_GEID[MAX_DEFENCE],
			def_SkipGEID,
#if defined SIF_USE_DEBUG_LABELS
			def_DebugLabelType,
			def_DebugLabelID[MAX_DEFENCE],
#endif
			def_TypeData[MAX_DEFENCE_ITEM][E_DEFENCE_ITEM_DATA],
			def_TypeIndex,
			def_ItemTypeBounds[2] = {65535, 0};

new
			def_Data[MAX_DEFENCE][E_DEFENCE_DATA],
   Iterator:def_Index<MAX_DEFENCE>,
			def_ButtonDefence[BTN_MAX];

static
			def_CurrentDefenceItem[MAX_PLAYERS],
			def_CurrentDefenceEdit[MAX_PLAYERS],
			def_CurrentDefenceMove[MAX_PLAYERS],
			def_CurrentDefenceOpen[MAX_PLAYERS],
			def_LastPassEntry[MAX_PLAYERS],
			def_Cooldown[MAX_PLAYERS],
			def_PassFails[MAX_PLAYERS];

// Settings: Prefixed camel case here and dashed in settings.json
static
bool:		def_PrintEachLoad,
bool:		def_PrintTotalLoad,
bool:		def_PrintEachSave,
bool:		def_PrintTotalSave,
bool:		def_PrintRemoves;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Defences'...");

	if(def_GEID_Index > 0)
	{
		printf("ERROR: def_GEID_Index has been modified prior to loading defences.");
		for(;;){}
	}

	#if defined SIF_USE_DEBUG_LABELS
		def_DebugLabelType = DefineDebugLabelType("DEFENCE", GREEN);
	#endif

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_DEFENCES);

	for(new i; i < BTN_MAX; i++)
		def_ButtonDefence[i] = -1;

	GetSettingInt("defence/print-each-load", false, def_PrintEachLoad);
	GetSettingInt("defence/print-total-load", true, def_PrintTotalLoad);
	GetSettingInt("defence/print-each-save", false, def_PrintEachSave);
	GetSettingInt("defence/print-total-save", true, def_PrintTotalSave);
	GetSettingInt("defence/print-removes", false, def_PrintRemoves);
}

hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Defences'...");

	LoadDefences();
}

hook OnPlayerConnect(playerid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerConnect] in /gamemodes/sss/core/world/defences.pwn");

	def_CurrentDefenceItem[playerid] = INVALID_ITEM_ID;
	def_CurrentDefenceEdit[playerid] = -1;
	def_CurrentDefenceMove[playerid] = -1;
	def_CurrentDefenceOpen[playerid] = -1;
	def_LastPassEntry[playerid] = 0;
	def_Cooldown[playerid] = 2000;
	def_PassFails[playerid] = 0;
}


stock DefineDefenceItem(ItemType:itemtype, Float:v_rx, Float:v_ry, Float:v_rz, Float:h_rx, Float:h_ry, Float:h_rz, Float:zoffset, maxhitpoints)
{
	new id = def_TypeIndex;

	def_TypeData[id][def_itemtype] = itemtype;
	def_TypeData[id][def_verticalRotX] = v_rx;
	def_TypeData[id][def_verticalRotY] = v_ry;
	def_TypeData[id][def_verticalRotZ] = v_rz;
	def_TypeData[id][def_horizontalRotX] = h_rx;
	def_TypeData[id][def_horizontalRotY] = h_ry;
	def_TypeData[id][def_horizontalRotZ] = h_rz;
	def_TypeData[id][def_placeOffsetZ] = zoffset;
	def_TypeData[id][def_maxHitPoints] = maxhitpoints;

	if(_:itemtype < def_ItemTypeBounds[0])
		def_ItemTypeBounds[0] = _:itemtype;

	if(_:itemtype > def_ItemTypeBounds[1])
		def_ItemTypeBounds[1] = _:itemtype;

	return def_TypeIndex++;
}

stock IsValidDefenceType(type)
{
	if(0 <= type < def_TypeIndex)
		return 1;

	return 0;
}

stock IsItemTypeDefenceItem(ItemType:itemtype)
{
	for(new i; i < def_TypeIndex; i++)
	{
		if(itemtype == def_TypeData[i][def_itemtype])
		{
			return true;
		}
	}
	return false;
}

CreateDefence(type, Float:x, Float:y, Float:z, Float:rz, pose, motor = 0, keypad = 0, pass = 0, movestate = -1, hitpoints = -1, worldid = 0, interiorid = 0)
{
	new id = Iter_Free(def_Index);

	if(id == -1)
		return -1;

	new	itemtypename[ITM_MAX_NAME];

	def_Data[id][def_type] = type;

	GetItemTypeName(def_TypeData[type][def_itemtype], itemtypename);

	def_Data[id][def_pose] = pose;
	def_Data[id][def_motor] = motor;
	def_Data[id][def_keypad] = keypad;
	def_Data[id][def_pass] = pass;
	def_Data[id][def_moveState] = movestate;
	def_Data[id][def_hitPoints] = ((hitpoints == -1) ? (def_TypeData[type][def_maxHitPoints]) : (hitpoints));

	def_Data[id][def_posX] = x;
	def_Data[id][def_posY] = y;
	def_Data[id][def_posZ] = z;
	def_Data[id][def_rotZ] = rz;
	def_Data[id][def_worldid] = worldid;
	def_Data[id][def_interiorid] = interiorid;

	if(motor)
	{
		if(movestate == DEFENCE_POSE_HORIZONTAL)
		{
			def_Data[id][def_objectId] = CreateDynamicObject(GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z,
				def_TypeData[type][def_horizontalRotX],
				def_TypeData[type][def_horizontalRotY],
				def_TypeData[type][def_horizontalRotZ] + rz, worldid, interiorid);

			def_Data[id][def_buttonId] = CreateButton(x, y, z, sprintf(""KEYTEXT_INTERACT" to open %s", itemtypename), worldid, interiorid, 1.5, 1, sprintf("%d/%d", def_Data[id][def_hitPoints], def_TypeData[type][def_maxHitPoints]), _, 1.5);
		}
		else
		{
			def_Data[id][def_objectId] = CreateDynamicObject(GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z + def_TypeData[type][def_placeOffsetZ],
				def_TypeData[type][def_verticalRotX],
				def_TypeData[type][def_verticalRotY],
				def_TypeData[type][def_verticalRotZ] + rz, worldid, interiorid);

			def_Data[id][def_buttonId] = CreateButton(x, y, z + def_TypeData[type][def_placeOffsetZ], sprintf(""KEYTEXT_INTERACT" to open %s", itemtypename), worldid, interiorid, 1.5, 1, sprintf("%d/%d", def_Data[id][def_hitPoints], def_TypeData[type][def_maxHitPoints]), _, 1.5);
		}
	}
	else
	{
		if(pose == DEFENCE_POSE_HORIZONTAL)
		{
			def_Data[id][def_objectId] = CreateDynamicObject(GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z,
				def_TypeData[type][def_horizontalRotX],
				def_TypeData[type][def_horizontalRotY],
				def_TypeData[type][def_horizontalRotZ] + rz, worldid, interiorid);

			def_Data[id][def_buttonId] = CreateButton(x, y, z, sprintf(""KEYTEXT_INTERACT" to modify %s", itemtypename), worldid, interiorid, 1.5, 1, sprintf("%d/%d", def_Data[id][def_hitPoints], def_TypeData[type][def_maxHitPoints]), _, 1.5);
		}
		else
		{
			def_Data[id][def_objectId] = CreateDynamicObject(GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z + def_TypeData[type][def_placeOffsetZ],
				def_TypeData[type][def_verticalRotX],
				def_TypeData[type][def_verticalRotY],
				def_TypeData[type][def_verticalRotZ] + rz, worldid, interiorid);

			def_Data[id][def_buttonId] = CreateButton(x, y, z + def_TypeData[type][def_placeOffsetZ], sprintf(""KEYTEXT_INTERACT" to modify %s", itemtypename), worldid, interiorid, 1.5, 1, sprintf("%d/%d", def_Data[id][def_hitPoints], def_TypeData[type][def_maxHitPoints]), _, 1.5);
		}
	}

	def_ButtonDefence[def_Data[id][def_buttonId]] = id;

	Iter_Add(def_Index, id);

	if(!def_SkipGEID)
	{
		def_GEID[id] = def_GEID_Index;
		def_GEID_Index++;
		// printf("Defence GEID Index: %d", def_GEID_Index);
	}

	#if defined SIF_USE_DEBUG_LABELS
		def_DebugLabelID[id] = CreateDebugLabel(def_DebugLabelType, id, x, y, z);
		def_UpdateDebugLabel(id);
	#endif

	return id;
}

stock DestroyDefence(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	new
		filename[64],
		next;

	format(filename, sizeof(filename), ""DIRECTORY_DEFENCES"def_%010d.dat", def_GEID[defenceid]);

	fremove(filename);

	DestroyDynamicObject(def_Data[defenceid][def_objectId]);
	DestroyButton(def_Data[defenceid][def_buttonId]);

	if(IsValidButton(def_Data[defenceid][def_buttonId]))
		def_ButtonDefence[def_Data[defenceid][def_buttonId]] = INVALID_ITEM_ID;

	def_Data[defenceid][def_objectId] = INVALID_OBJECT_ID;
	def_Data[defenceid][def_buttonId] = INVALID_BUTTON_ID;

	def_Data[defenceid][def_pose]		= 0;
	def_Data[defenceid][def_motor]		= 0;
	def_Data[defenceid][def_keypad]		= 0;
	def_Data[defenceid][def_pass]		= 0;
	def_Data[defenceid][def_moveState]	= 0;
	def_Data[defenceid][def_hitPoints]	= 0;
	def_Data[defenceid][def_posX]		= 0.0;
	def_Data[defenceid][def_posY]		= 0.0;
	def_Data[defenceid][def_posZ]		= 0.0;
	def_Data[defenceid][def_rotZ]		= 0.0;

	Iter_SafeRemove(def_Index, defenceid, next);

	#if defined SIF_USE_DEBUG_LABELS
		DestroyDebugLabel(def_DebugLabelID[defenceid]);
	#endif

	return next;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerUseItemWithItem] in /gamemodes/sss/core/world/defences.pwn");

	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Hammer || itemtype == item_Screwdriver)
	{
		new ItemType:withitemtype = GetItemType(withitemid);

		if(def_ItemTypeBounds[0] <= _:withitemtype <= def_ItemTypeBounds[1])
		{
			StartBuildingDefence(playerid, withitemid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeyStateChange] in /gamemodes/sss/core/world/defences.pwn");

	if(oldkeys & 16)
	{
		StopBuildingDefence(playerid);
	}
}

StartBuildingDefence(playerid, itemid)
{
	new type = -1;

	for(new i; i < def_TypeIndex; i++)
	{
		if(GetItemType(itemid) == def_TypeData[i][def_itemtype])
		{
			type = i;
			break;
		}
	}

	if(type == -1)
		return 0;

	new itemtypename[ITM_MAX_NAME];

	GetItemTypeName(def_TypeData[type][def_itemtype], itemtypename);

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

hook OnButtonPress(playerid, buttonid)
{
	d:3:GLOBAL_DEBUG("[OnButtonPress] in /gamemodes/sss/core/world/defences.pwn");

	if(def_ButtonDefence[buttonid] != -1)
	{
		new id = def_ButtonDefence[buttonid];

		if(buttonid == def_Data[id][def_buttonId])
		{
			new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

			if(!IsValidItemType(itemtype))
			{
				if(def_Data[id][def_motor])
				{
					if(def_Data[id][def_keypad] == 1)
					{
						if(def_Data[id][def_pass] == 0)
						{
							if(def_CurrentDefenceEdit[playerid] != -1)
							{
								HideKeypad(playerid);
								Dialog_Hide(playerid);
							}

							def_CurrentDefenceEdit[playerid] = id;
							ShowSetPassDialog_Keypad(playerid);
						}
						else
						{
							if(def_CurrentDefenceOpen[playerid] != -1)
							{
								HideKeypad(playerid);
								Dialog_Hide(playerid);
							}

							def_CurrentDefenceOpen[playerid] = id;

							ShowEnterPassDialog_Keypad(playerid);
							CancelPlayerMovement(playerid);
						}
					}
					else if(def_Data[id][def_keypad] == 2)
					{
						if(def_Data[id][def_pass] == 0)
						{
							if(def_CurrentDefenceEdit[playerid] != -1)
							{
								HideKeypad(playerid);
								Dialog_Hide(playerid);
							}

							def_CurrentDefenceEdit[playerid] = id;
							ShowSetPassDialog_KeypadAdv(playerid);
						}
						else
						{
							if(def_CurrentDefenceOpen[playerid] != -1)
							{
								HideKeypad(playerid);
								Dialog_Hide(playerid);
							}

							def_CurrentDefenceOpen[playerid] = id;

							ShowEnterPassDialog_KeypadAdv(playerid);
							CancelPlayerMovement(playerid);
						}
					}
					else
					{
						ShowActionText(playerid, ls(playerid, "DEFMOVINGIT"), 3000);
						defer MoveDefence(id, playerid);
					}

					return Y_HOOKS_BREAK_RETURN_1;
				}
			}

			if(itemtype == item_Crowbar)
			{
				new Float:angle = absoluteangle(def_Data[id][def_rotZ] - GetButtonAngleToPlayer(playerid, buttonid));

				if(90.0 < angle < 270.0)
				{
					new itemtypename[ITM_MAX_NAME];

					GetItemTypeName(def_TypeData[def_Data[id][def_type]][def_itemtype], itemtypename);

					def_CurrentDefenceEdit[playerid] = id;
					StartHoldAction(playerid, 10000);
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
					ShowActionText(playerid, sprintf(ls(playerid, "DEFREMOVING"), itemtypename));

					return Y_HOOKS_BREAK_RETURN_1;
				}
			}

			if(itemtype == item_Motor)
			{
				new Float:angle = absoluteangle(def_Data[id][def_rotZ] - GetButtonAngleToPlayer(playerid, buttonid));

				if(90.0 < angle < 270.0)
				{	
					new itemtypename[ITM_MAX_NAME];

					GetItemTypeName(def_TypeData[def_Data[id][def_type]][def_itemtype], itemtypename);

					def_CurrentDefenceEdit[playerid] = id;
					StartHoldAction(playerid, 6000);
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

					ShowActionText(playerid, sprintf(ls(playerid, "DEFMODIFYIN"), itemtypename));

					return Y_HOOKS_BREAK_RETURN_1;
				}
			}

			if(itemtype == item_Keypad)
			{
				new Float:angle = absoluteangle(def_Data[id][def_rotZ] - GetButtonAngleToPlayer(playerid, buttonid));

				if(90.0 < angle < 270.0)
				{
					if(!def_Data[id][def_motor])
					{
						ShowActionText(playerid, ls(playerid, "DEFNEEDMOTO"));
						return Y_HOOKS_BREAK_RETURN_1;
					}

					new itemtypename[ITM_MAX_NAME];

					GetItemTypeName(def_TypeData[def_Data[id][def_type]][def_itemtype], itemtypename);

					def_CurrentDefenceEdit[playerid] = id;
					StartHoldAction(playerid, 6000);
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

					ShowActionText(playerid, sprintf(ls(playerid, "DEFMODIFYIN"), itemtypename));

					return Y_HOOKS_BREAK_RETURN_1;
				}
			}

			if(itemtype == item_AdvancedKeypad)
			{
				new Float:angle = absoluteangle(def_Data[id][def_rotZ] - GetButtonAngleToPlayer(playerid, buttonid));

				if(90.0 < angle < 270.0)
				{
					if(!def_Data[id][def_motor])
					{
						ShowActionText(playerid, ls(playerid, "DEFNEEDMOTO"));
						return Y_HOOKS_BREAK_RETURN_1;
					}

					new itemtypename[ITM_MAX_NAME];

					GetItemTypeName(def_TypeData[def_Data[id][def_type]][def_itemtype], itemtypename);

					def_CurrentDefenceEdit[playerid] = id;
					StartHoldAction(playerid, 6000);
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

					ShowActionText(playerid, sprintf(ls(playerid, "DEFMODIFYIN"), itemtypename));

					return Y_HOOKS_BREAK_RETURN_1;
				}
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionUpdate(playerid, progress)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionUpdate] in /gamemodes/sss/core/world/defences.pwn");

	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]))
			StopHoldAction(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	d:3:GLOBAL_DEBUG("[OnHoldActionFinish] in /gamemodes/sss/core/world/defences.pwn");

	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]))
			return Y_HOOKS_BREAK_RETURN_0;

		new
			Float:x,
			Float:y,
			Float:z,
			Float:angle,
			worldid,
			interiorid,
			ItemType:itemtype = GetItemType(GetPlayerItem(playerid)),
			type,
			id;

		GetItemPos(def_CurrentDefenceItem[playerid], x, y, z);
		GetItemRot(def_CurrentDefenceItem[playerid], angle, angle, angle);
		worldid = GetItemWorld(def_CurrentDefenceItem[playerid]);
		interiorid = GetItemInterior(def_CurrentDefenceItem[playerid]);

		for(new i; i < def_TypeIndex; i++)
		{
			if(GetItemType(def_CurrentDefenceItem[playerid]) == def_TypeData[i][def_itemtype])
			{
				type = i;
				break;
			}
		}

		if(itemtype == item_Screwdriver)
		{
			id = CreateDefence(type, x, y, z, angle, DEFENCE_POSE_VERTICAL, .worldid = worldid, .interiorid = interiorid);

			if(!IsValidDefence(id))
			{
				ChatMsgLang(playerid, RED, "DEFLIMITREA");
				return Y_HOOKS_BREAK_RETURN_0;
			}

			logf("[CONSTRUCT] %p Built defence %d (GEID: %d) type %d (%d, %f, %f, %f, %f, %f, %f)", playerid, id, def_GEID[id], type,
				GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z + def_TypeData[type][def_placeOffsetZ],
				def_TypeData[type][def_verticalRotX],
				def_TypeData[type][def_verticalRotY],
				def_TypeData[type][def_verticalRotZ] + angle);
		}

		if(itemtype == item_Hammer)
		{
			id = CreateDefence(type, x, y, z, angle, DEFENCE_POSE_HORIZONTAL, .worldid = worldid, .interiorid = interiorid);

			if(!IsValidDefence(id))
			{
				ChatMsgLang(playerid, RED, "DEFLIMITREA");
				return Y_HOOKS_BREAK_RETURN_0;
			}

			logf("[CONSTRUCT] %p Built defence %d (GEID: %d)  type %d (%d, %f, %f, %f, %f, %f, %f)", playerid, id, def_GEID[id], type,
				GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z,
				def_TypeData[type][def_horizontalRotX],
				def_TypeData[type][def_horizontalRotY],
				def_TypeData[type][def_horizontalRotZ] + angle);
		}

		DestroyItem(def_CurrentDefenceItem[playerid]);

		SaveDefenceItem(id);
		StopBuildingDefence(playerid);
		//EditDefence(playerid, id);

		return Y_HOOKS_BREAK_RETURN_0;
	}

	if(def_CurrentDefenceEdit[playerid] != -1)
	{
		new itemid = GetPlayerItem(playerid);

		if(GetItemType(itemid) == item_Motor)
		{
			ShowActionText(playerid, ls(playerid, "DEFINSTMOTO"));
			def_Data[def_CurrentDefenceEdit[playerid]][def_motor] = true;
			SaveDefenceItem(def_CurrentDefenceEdit[playerid]);
			DestroyItem(itemid);
			ClearAnimations(playerid);
			def_UpdateDebugLabel(def_CurrentDefenceEdit[playerid]);
		}

		if(GetItemType(itemid) == item_Keypad)
		{
			ShowActionText(playerid, ls(playerid, "DEFINSTKEYP"));
			ShowSetPassDialog_Keypad(playerid);
			def_Data[def_CurrentDefenceEdit[playerid]][def_keypad] = 1;
			SaveDefenceItem(def_CurrentDefenceEdit[playerid]);
			DestroyItem(itemid);
			ClearAnimations(playerid);
			def_UpdateDebugLabel(def_CurrentDefenceEdit[playerid]);
		}

		if(GetItemType(itemid) == item_AdvancedKeypad)
		{
			ShowActionText(playerid, ls(playerid, "DEFINSTADKP"));
			ShowSetPassDialog_KeypadAdv(playerid);
			def_Data[def_CurrentDefenceEdit[playerid]][def_keypad] = 2;
			SaveDefenceItem(def_CurrentDefenceEdit[playerid]);
			DestroyItem(itemid);
			ClearAnimations(playerid);
			def_UpdateDebugLabel(def_CurrentDefenceEdit[playerid]);
		}

		if(GetItemType(itemid) == item_Crowbar)
		{
			ShowActionText(playerid, ls(playerid, "DEFDISMANTL"));

			CreateItem(def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_itemtype],
				def_Data[def_CurrentDefenceEdit[playerid]][def_posX],
				def_Data[def_CurrentDefenceEdit[playerid]][def_posY],
				def_Data[def_CurrentDefenceEdit[playerid]][def_posZ],
				.rz = def_Data[def_CurrentDefenceEdit[playerid]][def_rotZ],
				.world = def_Data[def_CurrentDefenceEdit[playerid]][def_worldid],
				.interior = def_Data[def_CurrentDefenceEdit[playerid]][def_interiorid],
				.zoffset = ITEM_BUTTON_OFFSET);

			switch(def_Data[def_CurrentDefenceEdit[playerid]][def_pose])
			{
				case DEFENCE_POSE_HORIZONTAL:
				{
					logf("[CROWBAR] %p broke defence %d (GEID: %d)  type %d (%d, %f, %f, %f, %f, %f, %f)",
						playerid,
						def_CurrentDefenceEdit[playerid],
						def_GEID[def_CurrentDefenceEdit[playerid]],
						_:def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_itemtype],
						GetItemTypeModel(def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_itemtype]),
						def_Data[def_CurrentDefenceEdit[playerid]][def_posX],
						def_Data[def_CurrentDefenceEdit[playerid]][def_posY],
						def_Data[def_CurrentDefenceEdit[playerid]][def_posZ],
						def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_horizontalRotX],
						def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_horizontalRotY],
						def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_horizontalRotZ] + def_Data[def_CurrentDefenceEdit[playerid]][def_rotZ]);
				}
				case DEFENCE_POSE_VERTICAL:
				{
					logf("[CROWBAR] %p broke defence %d (GEID: %d)  type %d (%d, %f, %f, %f, %f, %f, %f)",
						playerid,
						def_CurrentDefenceEdit[playerid],
						def_GEID[def_CurrentDefenceEdit[playerid]],
						_:def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_itemtype],
						GetItemTypeModel(def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_itemtype]),
						def_Data[def_CurrentDefenceEdit[playerid]][def_posX],
						def_Data[def_CurrentDefenceEdit[playerid]][def_posY],
						def_Data[def_CurrentDefenceEdit[playerid]][def_posZ] + def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_placeOffsetZ],
						def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_verticalRotX],
						def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_verticalRotY],
						def_TypeData[def_Data[def_CurrentDefenceEdit[playerid]][def_type]][def_verticalRotZ] + def_Data[def_CurrentDefenceEdit[playerid]][def_rotZ]);
				}
				case DEFENCE_POSE_SUPPORTED:
				{
					// not implemented
				}
			}

			DestroyDefence(def_CurrentDefenceEdit[playerid]);
			ClearAnimations(playerid);
			def_CurrentDefenceEdit[playerid] = -1;
		}

		return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

/* y_inline
ShowSetPassDialog_Keypad(playerid)
{
	inline Response(pid, keypadid, code, match)
	{
		#pragma unused pid, keypadid, match

		def_Data[def_CurrentDefenceEdit[playerid]][def_pass] = code;
		SaveDefenceItem(def_CurrentDefenceEdit[playerid]);
		HideKeypad(playerid);

		return 1;
	}
	inline Cancel(pid, keypadid)
	{
		#pragma unused pid, keypadid

		ShowSetPassDialog_Keypad(playerid);
	}
	ShowKeypad_Callback(playerid, using inline Response, using inline Cancel, -1);

	return 1;
}

ShowEnterPassDialog_Keypad(playerid)
{
	inline Response(pid, keypadid, code, match)
	{
		#pragma unused pid, keypadid, match

		if(code == match)
		{
			defer MoveDefence(def_CurrentDefenceOpen[playerid], playerid);
		}
		else
		{
			if(GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]) < 1000)
			{
				ShowEnterPassDialog_Keypad(playerid, 2);
				return 1;
			}

			if(def_PassFails[playerid] == 5)
			{
				def_PassFails[playerid] = 0;
				return 1;
			}

			logf("[DEFFAIL] Player %p failed defence %d (GEID: %d) keypad code %d", playerid, def_CurrentDefenceOpen[playerid], def_GEID[def_CurrentDefenceOpen[playerid]], code);
			ShowEnterPassDialog_Keypad(playerid, 1);
			def_LastPassEntry[playerid] = GetTickCount();
			def_PassFails[playerid]++;
		}

		return 1;
	}
	inline Cancel(pid, keypadid)
	{
		#pragma unused pid, keypadid

		HideKeypad(playerid);
	}
	ShowKeypad_Callback(playerid, using inline Response, using inline Cancel, def_Data[def_CurrentDefenceEdit[playerid]][def_pass]);

	return 1;
}
*/

hook OnPlayerKeypadEnter(playerid, keypadid, code, match)
{
	d:3:GLOBAL_DEBUG("[OnPlayerKeypadEnter] in /gamemodes/sss/core/world/defences.pwn");

	if(keypadid == 100)
	{
		if(def_CurrentDefenceEdit[playerid] != -1)
		{
			def_Data[def_CurrentDefenceEdit[playerid]][def_pass] = code;
			SaveDefenceItem(def_CurrentDefenceEdit[playerid]);
			HideKeypad(playerid);

			def_UpdateDebugLabel(def_CurrentDefenceEdit[playerid]);

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
	d:3:GLOBAL_DEBUG("[OnPlayerKeypadCancel] in /gamemodes/sss/core/world/defences.pwn");

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
				SaveDefenceItem(def_CurrentDefenceEdit[playerid]);
				def_UpdateDebugLabel(def_CurrentDefenceEdit[playerid]);
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
		def_UpdateDebugLabel(defenceid);
		SaveDefenceItem(defenceid);
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
		def_UpdateDebugLabel(defenceid);
		SaveDefenceItem(defenceid);
	}

	return;
}

def_UpdateDebugLabel(defenceid)
{
	#if defined SIF_USE_DEBUG_LABELS
		UpdateDebugLabelString(def_DebugLabelID[defenceid], sprintf("pose:%d motor:%d keypad:%d pass:%d movestate:%d hitpoints:%d",
			def_Data[defenceid][def_pose],
			def_Data[defenceid][def_motor],
			def_Data[defenceid][def_keypad],
			def_Data[defenceid][def_pass],
			def_Data[defenceid][def_moveState],
			def_Data[defenceid][def_hitPoints]));
	#endif
}


/*==============================================================================

	Experimental hack detector

==============================================================================*/

/*
static
		def_CurrentCheckDefence[MAX_PLAYERS],
Timer:	def_AngleCheckTimer[MAX_PLAYERS];

hook OnPlayerEnterButtonArea(playerid, buttonid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerEnterButtonArea] in /gamemodes/sss/core/world/defences.pwn");

	if(!IsPlayerOnAdminDuty(playerid))
	{
		new defenceid = def_ButtonDefence[buttonid];

		if(Iter_Contains(def_Index, defenceid))
		{
			if(
				(!def_Data[defenceid][def_motor] && def_Data[defenceid][def_pose] == DEFENCE_POSE_VERTICAL) ||
				(def_Data[defenceid][def_motor] && def_Data[defenceid][def_moveState] == DEFENCE_POSE_VERTICAL) )
			{
				new Float:angle = absoluteangle(def_Data[defenceid][def_rotZ] - GetButtonAngleToPlayer(playerid, buttonid));

				if(angle < 90.0 || angle > 270.0)
				{
					stop def_AngleCheckTimer[playerid];

					def_CurrentCheckDefence[playerid] = defenceid;
					def_AngleCheckTimer[playerid] = repeat DefenceAngleCheck(playerid, defenceid);
				}
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerLeaveButtonArea(playerid, buttonid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerLeaveButtonArea] in /gamemodes/sss/core/world/defences.pwn");

	new defenceid = def_ButtonDefence[buttonid];

	if(Iter_Contains(def_Index, defenceid))
	{
		if(def_CurrentCheckDefence[playerid] == defenceid)
			stop def_AngleCheckTimer[playerid];
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

timer DefenceAngleCheck[100](playerid, defenceid)
{
	new Float:angle = absoluteangle(def_Data[defenceid][def_rotZ] - GetButtonAngleToPlayer(playerid, def_Data[defenceid][def_buttonId]));

	//MsgF(playerid, YELLOW, " >  Angle to defence: %f", angle);

	if(120.0 < angle < 250.0)
	{
		MsgAdminsF(3, YELLOW, " >  [TEST] Player %p moved through defence %d at %.1f, %.1f, %.1f", playerid, defenceid,
			def_Data[defenceid][def_posX], def_Data[defenceid][def_posY], def_Data[defenceid][def_posZ]);

		logf("[THRUDEF] Player %p moved through defence %d (GEID: %d) at %.1f, %.1f, %.1f", playerid, defenceid, def_GEID[defenceid], def_Data[defenceid][def_posX], def_Data[defenceid][def_posY], def_Data[defenceid][def_posZ]);

		stop def_AngleCheckTimer[playerid];
	}
}
*/

/*==============================================================================

	Load All

==============================================================================*/


LoadDefences()
{
	new
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_DEFENCES),
		item[46],
		type,
		filename[64],
		count;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			filename = DIRECTORY_DEFENCES;
			strcat(filename, item);

			count += LoadDefenceItem(filename);
		}
	}

	dir_close(direc);

	if(def_PrintTotalLoad)
		printf("Loaded %d Defences", count);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveDefenceItem(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	if(def_Data[defenceid][def_hitPoints] <= 0)
		return 0;

	if(def_PrintEachSave)
		printf("\t[SAVE] Defence type %d at %f, %f, %f (p:%d m:%d k:%d p:%d ms:%d h:%d)", def_Data[defenceid][def_type], def_Data[defenceid][def_posX], def_Data[defenceid][def_posY], def_Data[defenceid][def_posZ], def_Data[defenceid][def_pose], def_Data[defenceid][def_motor], def_Data[defenceid][def_keypad], def_Data[defenceid][def_pass], def_Data[defenceid][def_moveState], def_Data[defenceid][def_hitPoints]);

	new
		filename[64],
		data[7];

	format(filename, sizeof(filename), ""DIRECTORY_DEFENCES"def_%010d.dat", def_GEID[defenceid]);

	data[0] = _:def_Data[defenceid][def_posX];
	data[1] = _:def_Data[defenceid][def_posY];
	data[2] = _:def_Data[defenceid][def_posZ];
	data[3] = _:def_Data[defenceid][def_rotZ];
	data[4] = _:def_Data[defenceid][def_worldid];
	data[5] = _:def_Data[defenceid][def_interiorid];

	modio_push(filename, _T<W,P,O,S>, 6, data, false, false, false);

	data[DEFENCE_CELL_TYPE] = def_Data[defenceid][def_type];
	data[DEFENCE_CELL_POSE] = def_Data[defenceid][def_pose];
	data[DEFENCE_CELL_MOTOR] = def_Data[defenceid][def_motor];
	data[DEFENCE_CELL_KEYPAD] = def_Data[defenceid][def_keypad];
	data[DEFENCE_CELL_PASS] = def_Data[defenceid][def_pass];
	data[DEFENCE_CELL_MOVESTATE] = def_Data[defenceid][def_moveState];
	data[DEFENCE_CELL_HITPOINTS] = def_Data[defenceid][def_hitPoints];

	modio_push(filename, _T<D,A,T,A>, 7, data, true, true, true);

	return 1;
}

LoadDefenceItem(filename[])
{
	new
		length,
		searchpos,
		defenceid,
		pos[6],
		data[7];

	length = modio_read(filename, _T<W,P,O,S>, sizeof(pos), _:pos, false, false);

	if(length < 0)
	{
		printf("[LoadDefenceItem] ERROR: modio error %d in '%s'.", length, filename);
		modio_finalise_read(modio_getsession_read(filename));
		return 0;
	}

	if(length == 0)
	{
		print("[LoadDefenceItem] ERROR: modio_read returned length of 0.");
		modio_finalise_read(modio_getsession_read(filename));
		return 0;
	}

	if(Float:pos[0] == 0.0 && Float:pos[1] == 0.0 && Float:pos[2] == 0.0)
	{
		print("[LoadDefenceItem] ERROR: null position.");
		modio_finalise_read(modio_getsession_read(filename));
		return 0;
	}

	// final 'true' param is to force close read session
	// Because these files are read in a loop, sessions can stack up so this
	// ensures that a new session isn't registered for each Defence.
	length = modio_read(filename, _T<D,A,T,A>, sizeof(data), _:data, true);

	if(data[DEFENCE_CELL_HITPOINTS] <= 0)
	{
		printf("[LoadDefenceItem] ERROR: none or negative hitpoints (%d).", data[DEFENCE_CELL_HITPOINTS]);
		return 0;
	}

	def_SkipGEID = true;

	defenceid = CreateDefence(data[DEFENCE_CELL_TYPE], Float:pos[0], Float:pos[1], Float:pos[2], Float:pos[3],
		data[DEFENCE_CELL_POSE],
		data[DEFENCE_CELL_MOTOR],
		data[DEFENCE_CELL_KEYPAD],
		data[DEFENCE_CELL_PASS],
		data[DEFENCE_CELL_MOVESTATE],
		data[DEFENCE_CELL_HITPOINTS],
		pos[4], pos[5]);

	def_SkipGEID = false;

	searchpos = strlen(DIRECTORY_DEFENCES) + 5;

	sscanf(filename[searchpos], "p<.>d{s[5]}", def_GEID[defenceid]);

	if(def_GEID[defenceid] > def_GEID_Index)
		def_GEID_Index = def_GEID[defenceid] + 1;

	if(def_PrintEachLoad)
		printf("\t[LOAD] Defence type %d at %f, %f, %f (p:%d m:%d k:%d p:%d ms:%d h:%d)", data[DEFENCE_CELL_TYPE], Float:pos[0], Float:pos[1], Float:pos[2], data[DEFENCE_CELL_POSE], data[DEFENCE_CELL_MOTOR], data[DEFENCE_CELL_KEYPAD], data[DEFENCE_CELL_PASS], data[DEFENCE_CELL_MOVESTATE], data[DEFENCE_CELL_HITPOINTS]);

	return 1;
}


/*==============================================================================

	Interface functions

==============================================================================*/


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
	if(!(0 <= defencetype < def_TypeIndex))
		return INVALID_ITEM_TYPE;

	return def_TypeData[defencetype][def_itemtype];
}

// def_verticalRotX
// def_verticalRotY
// def_verticalRotZ
stock GetDefenceTypeVerticalRot(defencetype, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= defencetype < def_TypeIndex))
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
	if(!(0 <= defencetype < def_TypeIndex))
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
	if(!(0 <= defencetype < def_TypeIndex))
		return 0.0;

	return def_TypeData[defencetype][def_placeOffsetZ];
}

// def_maxHitPoints
stock GetDefenceTypeMaxHitpoints(defencetype)
{
	if(!(0 <= defencetype < def_TypeIndex))
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
	SetButtonLabel(def_Data[defenceid][def_buttonId], sprintf("%d/%d", def_Data[defenceid][def_hitPoints], def_TypeData[def_Data[defenceid][def_type]][def_maxHitPoints]), .range = 1.5);
	def_UpdateDebugLabel(defenceid);

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

// def_GEID
stock GetDefenceGEID(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return -1;

	return def_GEID[defenceid];
}

stock GetDefenceIDFromGEID(geid)
{
	foreach(new i : def_Index)
	{
		if(def_GEID[i] == geid)
			return i;
	}

	return 1;
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

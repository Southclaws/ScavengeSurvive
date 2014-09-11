#include <YSI\y_hooks>


#define DIRECTORY_DEFENCES	DIRECTORY_MAIN"Defences/"
#define MAX_DEFENCE_ITEM	(10)
#define MAX_DEFENCE			(2048)


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
Iterator:	def_Index<MAX_DEFENCE>,
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
bool:		def_PrintEachRuntimeSave,
bool:		def_PrintTotalSave,
bool:		def_PrintRemoves;


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'Defences'...");

	if(def_GEID_Index > 0)
	{
		printf("ERROR: def_GEID_Index has been modified prior to loading from "GEID_FILE". This variable can NOT be modified before being assigned a value from this file.");
		for(;;){}
	}

	new arr[1];

	modio_read(GEID_FILE, _T<D,F,N,C>, arr);

	def_GEID_Index = arr[0];
	// printf("Loaded defence GEID: %d", def_GEID_Index);

	#if defined SIF_USE_DEBUG_LABELS
		def_DebugLabelType = DefineDebugLabelType("DEFENCE", GREEN);
	#endif

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_DEFENCES);

	for(new i; i < BTN_MAX; i++)
		def_ButtonDefence[i] = -1;

	GetSettingInt("defence/print-each-load", false, def_PrintEachLoad);
	GetSettingInt("defence/print-total-load", true, def_PrintTotalLoad);
	GetSettingInt("defence/print-each-save", false, def_PrintEachSave);
	GetSettingInt("defence/print-each-runtime-save", false, def_PrintEachRuntimeSave);
	GetSettingInt("defence/print-total-save", true, def_PrintTotalSave);
	GetSettingInt("defence/print-removes", false, def_PrintRemoves);
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

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Hammer || itemtype == item_Screwdriver)
	{
		new ItemType:withitemtype = GetItemType(withitemid);

		if(def_ItemTypeBounds[0] <= _:withitemtype <= def_ItemTypeBounds[1])
		{
			StartBuildingDefence(playerid, withitemid);
		}
	}

	#if defined def_OnPlayerUseItemWithItem
		return def_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif
#define OnPlayerUseItemWithItem def_OnPlayerUseItemWithItem
#if defined def_OnPlayerUseItemWithItem
	forward def_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
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
	ShowActionText(playerid, sprintf("Building %s...", itemtypename));

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

public OnButtonPress(playerid, buttonid)
{
	if(def_ButtonDefence[buttonid] != -1)
	{
		new id = def_ButtonDefence[buttonid];

		if(buttonid == def_Data[id][def_buttonId])
		{
			new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

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
					ShowActionText(playerid, sprintf("Removing %s", itemtypename));

					return 1;
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

					ShowActionText(playerid, sprintf("Modifying %s", itemtypename));

					return 1;
				}
			}

			if(itemtype == item_Keypad)
			{
				new Float:angle = absoluteangle(def_Data[id][def_rotZ] - GetButtonAngleToPlayer(playerid, buttonid));

				if(90.0 < angle < 270.0)
				{
					if(!def_Data[id][def_motor])
					{
						ShowActionText(playerid, "You must install a motor before installing a keypad!");
						return 1;
					}

					new itemtypename[ITM_MAX_NAME];

					GetItemTypeName(def_TypeData[def_Data[id][def_type]][def_itemtype], itemtypename);

					def_CurrentDefenceEdit[playerid] = id;
					StartHoldAction(playerid, 6000);
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

					ShowActionText(playerid, sprintf("Modifying %s", itemtypename));

					return 1;
				}
			}

			if(itemtype == item_AdvancedKeypad)
			{
				new Float:angle = absoluteangle(def_Data[id][def_rotZ] - GetButtonAngleToPlayer(playerid, buttonid));

				if(90.0 < angle < 270.0)
				{
					if(!def_Data[id][def_motor])
					{
						ShowActionText(playerid, "You must install a motor before installing a keypad!");
						return 1;
					}

					new itemtypename[ITM_MAX_NAME];

					GetItemTypeName(def_TypeData[def_Data[id][def_type]][def_itemtype], itemtypename);

					def_CurrentDefenceEdit[playerid] = id;
					StartHoldAction(playerid, 6000);
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

					ShowActionText(playerid, sprintf("Modifying %s", itemtypename));

					return 1;
				}
			}

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
					ShowActionText(playerid, "Moving defence, please stand back.", 3000);
					defer MoveDefence(id, playerid);
				}

				return 1;
			}
		}
	}

	#if defined def_OnButtonPress
		return def_OnButtonPress(playerid, buttonid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnButtonPress
	#undef OnButtonPress
#else
	#define _ALS_OnButtonPress
#endif
#define OnButtonPress def_OnButtonPress
#if defined def_OnButtonPress
	forward def_OnButtonPress(playerid, buttonid);
#endif

public OnHoldActionUpdate(playerid, progress)
{
	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]))
			StopHoldAction(playerid);
	}
	#if defined def_OnHoldActionUpdate
		return def_OnHoldActionUpdate(playerid, progress);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnHoldActionUpdate
	#undef OnHoldActionUpdate
#else
	#define _ALS_OnHoldActionUpdate
#endif
#define OnHoldActionUpdate def_OnHoldActionUpdate
#if defined def_OnHoldActionUpdate
	forward def_OnHoldActionUpdate(playerid, progress);
#endif

public OnHoldActionFinish(playerid)
{
	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]))
			return 1;

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

		DestroyItem(def_CurrentDefenceItem[playerid]);

		if(itemtype == item_Screwdriver)
		{
			id = CreateDefence(type, x, y, z, angle, DEFENCE_POSE_VERTICAL, .worldid = worldid, .interiorid = interiorid);

			logf("[CONSTRUCT] %p Built defence %d (GEID: %d) type %d (%d, %f, %f, %f, %f, %f, %f)", playerid, id, def_GEID[id], type,
				GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z + def_TypeData[type][def_placeOffsetZ],
				def_TypeData[type][def_verticalRotX],
				def_TypeData[type][def_verticalRotY],
				def_TypeData[type][def_verticalRotZ] + angle);
		}

		if(itemtype == item_Hammer)
		{
			id = CreateDefence(type, x, y, z, angle, DEFENCE_POSE_HORIZONTAL, .worldid = worldid, .interiorid = interiorid);

			logf("[CONSTRUCT] %p Built defence %d (GEID: %d)  type %d (%d, %f, %f, %f, %f, %f, %f)", playerid, id, def_GEID[id], type,
				GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z,
				def_TypeData[type][def_horizontalRotX],
				def_TypeData[type][def_horizontalRotY],
				def_TypeData[type][def_horizontalRotZ] + angle);
		}


		SaveDefenceItem(id, def_PrintEachRuntimeSave);
		StopBuildingDefence(playerid);
		//EditDefence(playerid, id);

		return 1;
	}

	if(def_CurrentDefenceEdit[playerid] != -1)
	{
		new itemid = GetPlayerItem(playerid);

		if(GetItemType(itemid) == item_Motor)
		{
			ShowActionText(playerid, "Motor installed to defence");
			def_Data[def_CurrentDefenceEdit[playerid]][def_motor] = true;
			SaveDefenceItem(def_CurrentDefenceEdit[playerid], def_PrintEachRuntimeSave);
			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(GetItemType(itemid) == item_Keypad)
		{
			ShowActionText(playerid, "Keypad installed to defence");
			ShowSetPassDialog_Keypad(playerid);
			def_Data[def_CurrentDefenceEdit[playerid]][def_keypad] = 1;
			SaveDefenceItem(def_CurrentDefenceEdit[playerid], def_PrintEachRuntimeSave);
			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(GetItemType(itemid) == item_AdvancedKeypad)
		{
			ShowActionText(playerid, "Advanced Keypad installed to defence");
			ShowSetPassDialog_KeypadAdv(playerid);
			def_Data[def_CurrentDefenceEdit[playerid]][def_keypad] = 2;
			SaveDefenceItem(def_CurrentDefenceEdit[playerid], def_PrintEachRuntimeSave);
			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(GetItemType(itemid) == item_Crowbar)
		{
			ShowActionText(playerid, "Defence disassembled");

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

		return 1;
	}

	#if defined def_OnHoldActionFinish
		return def_OnHoldActionFinish(playerid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish def_OnHoldActionFinish
#if defined def_OnHoldActionFinish
	forward def_OnHoldActionFinish(playerid);
#endif

/* y_inline
ShowSetPassDialog_Keypad(playerid)
{
	inline Response(pid, keypadid, code, match)
	{
		#pragma unused pid, keypadid, match

		def_Data[def_CurrentDefenceEdit[playerid]][def_pass] = code;
		SaveDefenceItem(def_CurrentDefenceEdit[playerid], def_PrintEachRuntimeSave);
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

public OnPlayerKeypadEnter(playerid, keypadid, code, match)
{
	if(keypadid == 100)
	{
		if(def_CurrentDefenceEdit[playerid] != -1)
		{
			def_Data[def_CurrentDefenceEdit[playerid]][def_pass] = code;
			SaveDefenceItem(def_CurrentDefenceEdit[playerid], def_PrintEachRuntimeSave);
			HideKeypad(playerid);

			def_CurrentDefenceEdit[playerid] = -1;

			if(code == 0)
				Msg(playerid, YELLOW, " >  Leaving the code at 0 will allow the code to be set again.");

			return 1;
		}

		if(def_CurrentDefenceOpen[playerid] != -1)
		{
			if(code == match)
			{
				ShowActionText(playerid, "Moving defence, please stand back.", 3000);
				defer MoveDefence(def_CurrentDefenceOpen[playerid], playerid);
				def_CurrentDefenceOpen[playerid] = -1;
			}
			else
			{
				if(GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]) < def_Cooldown[playerid])
				{
					ShowEnterPassDialog_Keypad(playerid, 2);
					return 0;
				}

				if(def_PassFails[playerid] == 5)
				{
					def_Cooldown[playerid] += 4000;
					def_PassFails[playerid] = 0;
					return 0;
				}

				logf("[DEFFAIL] Player %p failed defence %d (GEID: %d) keypad code %d", playerid, def_CurrentDefenceOpen[playerid], def_GEID[def_CurrentDefenceOpen[playerid]], code);
				ShowEnterPassDialog_Keypad(playerid, 1);
				def_LastPassEntry[playerid] = GetTickCount();
				def_Cooldown[playerid] = 2000;
				def_PassFails[playerid]++;

				return 0;
			}

			return 1;
		}
	}

	#if defined kp_OnPlayerKeypadEnter
		return kp_OnPlayerKeypadEnter(playerid, keypadid, code, match);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeypadEnter
	#undef OnPlayerKeypadEnter
#else
	#define _ALS_OnPlayerKeypadEnter
#endif
 
#define OnPlayerKeypadEnter kp_OnPlayerKeypadEnter
#if defined kp_OnPlayerKeypadEnter
	forward kp_OnPlayerKeypadEnter(playerid, keypadid, code, match);
#endif

public OnPlayerKeypadCancel(playerid, keypadid)
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

	#if defined kp_OnPlayerKeypadCancel
		return kp_OnPlayerKeypadCancel(playerid, keypadid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerKeypadCancel
	#undef OnPlayerKeypadCancel
#else
	#define _ALS_OnPlayerKeypadCancel
#endif
 
#define OnPlayerKeypadCancel kp_OnPlayerKeypadCancel
#if defined kp_OnPlayerKeypadCancel
	forward kp_OnPlayerKeypadCancel(playerid, keypadid);
#endif

ShowSetPassDialog_Keypad(playerid)
{
	MsgF(playerid, YELLOW, " >  Set a 4 digit passcode for this defence.");

	ShowKeypad(playerid, 100);
}

ShowEnterPassDialog_Keypad(playerid, msg = 0)
{
	if(msg == 0)
		MsgF(playerid, YELLOW, " >  Enter the 4 digit passcode to open this defence.");

	if(msg == 1)
		MsgF(playerid, YELLOW, " >  Incorrect passcode!");

	if(msg == 2)
		MsgF(playerid, YELLOW, " >  You are entering codes too fast, please wait %s.", MsToString(def_Cooldown[playerid] - GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]), "%m:%s"));

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
				SaveDefenceItem(def_CurrentDefenceEdit[playerid], def_PrintEachRuntimeSave);
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
		MsgF(playerid, YELLOW, " >  You are entering codes too fast, please wait %s.", MsToString(def_Cooldown[playerid] - GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]), "%m:%s"));

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			new pass;

			sscanf(inputtext, "x", pass);

			if(pass == def_Data[def_CurrentDefenceOpen[playerid]][def_pass] && strlen(inputtext) >= 4)
			{
				ShowActionText(playerid, "Moving defence, please stand back.", 3000);
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
	}

	return;
}


/*==============================================================================

	Experimental hack detector

==============================================================================*/


static
		def_CurrentCheckDefence[MAX_PLAYERS],
Timer:	def_AngleCheckTimer[MAX_PLAYERS];

public OnPlayerEnterButtonArea(playerid, buttonid)
{
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

	#if defined def_OnPlayerEnterButtonArea
		return def_OnPlayerEnterButtonArea(playerid, buttonid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerEnterButtonArea
	#undef OnPlayerEnterButtonArea
#else
	#define _ALS_OnPlayerEnterButtonArea
#endif
 
#define OnPlayerEnterButtonArea def_OnPlayerEnterButtonArea
#if defined def_OnPlayerEnterButtonArea
	forward def_OnPlayerEnterButtonArea(playerid, buttonid);
#endif

public OnPlayerLeaveButtonArea(playerid, buttonid)
{
	new defenceid = def_ButtonDefence[buttonid];

	if(Iter_Contains(def_Index, defenceid))
	{
		if(def_CurrentCheckDefence[playerid] == defenceid)
			stop def_AngleCheckTimer[playerid];
	}

	#if defined def_OnPlayerLeaveButtonArea
		return def_OnPlayerLeaveButtonArea(playerid, buttonid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerLeaveButtonArea
	#undef OnPlayerLeaveButtonArea
#else
	#define _ALS_OnPlayerLeaveButtonArea
#endif
 
#define OnPlayerLeaveButtonArea def_OnPlayerLeaveButtonArea
#if defined def_OnPlayerLeaveButtonArea
	forward def_OnPlayerLeaveButtonArea(playerid, buttonid);
#endif

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


/*==============================================================================

	Save and Load All

==============================================================================*/


SaveDefences()
{
	new count;

	foreach(new i : def_Index)
	{
		if(SaveDefenceItem(i, def_PrintEachSave))
			count++;
	}

	if(def_PrintTotalSave)
		printf("Saved %d Defences", count);

	new arr[1];

	arr[0] = def_GEID_Index;

	modio_push(GEID_FILE, _T<D,F,N,C>, 1, arr);//, true, false, false);
	printf("Storing defence GEID: %d", def_GEID_Index);
}

hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'Defences'...");

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

	// If no defences were loaded, load the old format
	// This should only ever happen once (upon transition to this new version)
	if(count == 0)
		OLD_LoadDefences();

	if(def_PrintTotalLoad)
		printf("Loaded %d Defences", count);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveDefenceItem(defenceid, prints)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0;

	if(def_Data[defenceid][def_hitPoints] <= 0)
		return 0;

	if(prints)
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

	length = modio_read(filename, _T<W,P,O,S>, _:pos, false, false);

	if(length == 0)
		return 0;

	if(Float:pos[0] == 0.0 && Float:pos[1] == 0.0 && Float:pos[2] == 0.0)
		return 0;

	// final 'true' param is to force close read session
	// Because these files are read in a loop, sessions can stack up so this
	// ensures that a new session isn't registered for each Defence.
	length = modio_read(filename, _T<D,A,T,A>, _:data, true);

	if(data[DEFENCE_CELL_HITPOINTS] <= 0)
		return 0;

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
	{
		printf("WARNING: Defence %d GEID (%d) is greater than GEID index (%d). Updating to %d to avoid GEID collision.", defenceid, def_GEID[defenceid], def_GEID_Index, def_GEID[defenceid] + 1);
		def_GEID_Index = def_GEID[defenceid] + 1;
	}

	if(def_PrintEachLoad)
		printf("\t[LOAD] Defence type %d at %f, %f, %f (p:%d m:%d k:%d p:%d ms:%d h:%d)", data[DEFENCE_CELL_TYPE], Float:pos[0], Float:pos[1], Float:pos[2], data[DEFENCE_CELL_POSE], data[DEFENCE_CELL_MOTOR], data[DEFENCE_CELL_KEYPAD], data[DEFENCE_CELL_PASS], data[DEFENCE_CELL_MOVESTATE], data[DEFENCE_CELL_HITPOINTS]);

	return 1;
}


/*==============================================================================

	Legacy format (Load only)

==============================================================================*/


OLD_LoadDefences()
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

			count += OLD_LoadDefenceItem(filename);
		}
	}

	dir_close(direc);

	SaveDefences();

	if(def_PrintTotalLoad)
		printf("Loaded %d Defences using old format", Iter_Count(def_Index));
}

OLD_LoadDefenceItem(filename[])
{
	new
		File:file,
		data[4],
		pose,
		motor,
		keypad,
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	file = fopen(filename);

	if(!file)
		return 0;

	fblockread(file, data, sizeof(data));
	fclose(file);
	fremove(filename);

	sscanf(filename, "'"DIRECTORY_DEFENCES"'p<_>dddd", _:x, _:y, _:z, _:r);

	pose = data[1];

	if(pose == 2)
	{
		pose = DEFENCE_POSE_VERTICAL;
		motor = 1;
		keypad = 1;
	}

	new ret = CreateDefence(data[0], Float:x, Float:y, Float:z, Float:r, pose, motor, keypad, data[3], pose, data[2]);

	if(ret > -1)
	{
		if(def_PrintEachLoad)
			printf("\t[LOAD] [OLD] Defence type %d at %f, %f, %f (p:%d m:%d k:%d p:%d m:%d h:%d)", data[0], x, y, z, pose, motor, keypad, data[3], pose, data[2]);
	}
	else
	{
		printf("ERROR: Creating loaded defence type %d at %f, %f, %f, Code: %d", data[0], x, y, z, ret);
	}

	return 1;
}


/*==============================================================================

	(I have no idea where to put this, for now it will live right here.)
	(Custom explosion code needs to be written that also does custom damage.)

==============================================================================*/


stock CreateStructuralExplosion(Float:x, Float:y, Float:z, type, Float:size, hitpoints = 1)
{
	CreateExplosion(x, y, z, type, size);

	new
		Float:smallestdistance = 9999999.9,
		Float:tempdistance,
		closestid;

	foreach(new i : def_Index)
	{
		tempdistance = Distance(x, y, z, def_Data[i][def_posX], def_Data[i][def_posY], def_Data[i][def_posZ]);

		if(tempdistance < smallestdistance)
		{
			smallestdistance = tempdistance;
			closestid = i;
		}
	}

	if(smallestdistance < size)
	{
		def_Data[closestid][def_hitPoints] -= hitpoints;

		if(def_Data[closestid][def_hitPoints] <= 0)
		{
			logf("[DESTRUCTION] Defence %d From %.1f, %.1f, %.1f (GEID: %d) type %d (%d, %f, %f, %f, %f, %f, %f)",
				closestid, x, y, z,
				def_GEID[closestid],
				_:def_TypeData[def_Data[closestid][def_type]][def_itemtype],
				GetItemTypeModel(def_TypeData[type][def_itemtype]), x, y, z + def_TypeData[type][def_placeOffsetZ],
				def_TypeData[type][def_verticalRotX],
				def_TypeData[type][def_verticalRotY],
				def_TypeData[type][def_verticalRotZ] + def_Data[closestid][def_rotZ]);

			DestroyDefence(closestid);
		}
		else
		{
			SetButtonLabel(def_Data[closestid][def_buttonId], sprintf("%d/%d", def_Data[closestid][def_hitPoints], def_TypeData[def_Data[closestid][def_type]][def_maxHitPoints]), .range = 1.5);
		}
	}
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
stock Float:GetDefenceRot(defenceid)
{
	if(!Iter_Contains(def_Index, defenceid))
		return 0.0;

	return def_Data[defenceid][def_rotZ];
}

// def_GEID
stock GetDefenceIDFromGEID(geid)
{
	foreach(new i : def_Index)
	{
		if(def_GEID[i] == geid)
			return i;
	}

	return 1;
}

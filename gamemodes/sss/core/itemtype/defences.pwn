/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_DEFENCE_ITEM		(11)
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
bool:		def_movable
}

enum e_DEFENCE_DATA
{
bool:		def_active,
			def_pose,
			def_motor,
			def_keypad,
			def_pass,
			def_mod,
}


static
			def_TypeData[MAX_DEFENCE_ITEM][E_DEFENCE_ITEM_DATA],
			def_TypeTotal,
			def_ItemTypeDefenceType[MAX_ITEM_TYPE] = {INVALID_DEFENCE_TYPE, ...};

static
			def_TweakArrow[MAX_PLAYERS] = {INVALID_OBJECT_ID, ...},
Item:		def_CurrentDefenceItem[MAX_PLAYERS],
Item:		def_CurrentDefenceEdit[MAX_PLAYERS],
Item:		def_CurrentDefenceOpen[MAX_PLAYERS],
			def_LastPassEntry[MAX_PLAYERS],
			def_Cooldown[MAX_PLAYERS],
			def_PassFails[MAX_PLAYERS];


forward OnDefenceCreate(Item:itemid);
forward OnDefenceDestroy(Item:itemid);
forward OnDefenceModified(Item:itemid);
forward OnDefenceMove(Item:itemid);
forward OnPlayerInteractDefence(playerid, Item:itemid);


/*==============================================================================

	Zeroing

==============================================================================*/

public OnPlayerShootDynamicObject(playerid, weaponid, STREAMER_TAG_OBJECT:objectid, Float:x, Float:y, Float:z)
{
	return 1;
}

hook OnPlayerConnect(playerid)
{
	def_CurrentDefenceItem[playerid] = INVALID_ITEM_ID;
	def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;
	def_CurrentDefenceOpen[playerid] = INVALID_ITEM_ID;
	def_LastPassEntry[playerid] = 0;
	def_Cooldown[playerid] = 2000;
	def_PassFails[playerid] = 0;
}


/*==============================================================================

	Core

==============================================================================*/


stock DefineDefenceItem(ItemType:itemtype, Float:v_rx, Float:v_ry, Float:v_rz, Float:h_rx, Float:h_ry, Float:h_rz, Float:zoffset, bool:movable)
{
	SetItemTypeMaxArrayData(itemtype, e_DEFENCE_DATA);

	def_TypeData[def_TypeTotal][def_itemtype] = itemtype;
	def_TypeData[def_TypeTotal][def_verticalRotX] = v_rx;
	def_TypeData[def_TypeTotal][def_verticalRotY] = v_ry;
	def_TypeData[def_TypeTotal][def_verticalRotZ] = v_rz;
	def_TypeData[def_TypeTotal][def_horizontalRotX] = h_rx;
	def_TypeData[def_TypeTotal][def_horizontalRotY] = h_ry;
	def_TypeData[def_TypeTotal][def_horizontalRotZ] = h_rz;
	def_TypeData[def_TypeTotal][def_placeOffsetZ] = zoffset;
	def_TypeData[def_TypeTotal][def_movable] = movable;
	def_ItemTypeDefenceType[itemtype] = def_TypeTotal;

	return def_TypeTotal++;
}

ActivateDefenceItem(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
	{
		err("Attempted to create defence from item with invalid type (%d)", _:itemtype);
		return 1;
	}

	new defencetype = def_ItemTypeDefenceType[itemtype];

	if(defencetype == INVALID_DEFENCE_TYPE)
	{
		err("Attempted to create defence from item that is not a defence type (%d)", _:itemtype);
		return 2;
	}

	new
		itemtypename[MAX_ITEM_NAME],
		itemdata[e_DEFENCE_DATA],
		Button:buttonid;

	GetItemButtonID(itemid, buttonid);
	GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);
	GetItemArrayData(itemid, itemdata);

	itemdata[def_active] = true;

	SetItemArrayData(itemid, itemdata, e_DEFENCE_DATA);

	if(itemdata[def_motor])
	{
		SetButtonText(buttonid, sprintf(""KEYTEXT_INTERACT" to open %s", itemtypename));
		SetItemLabel(itemid, sprintf("%d/%d", GetItemHitPoints(itemid), GetItemTypeMaxHitPoints(itemtype)));
	}
	else
	{
		SetButtonText(buttonid, sprintf(""KEYTEXT_INTERACT" to modify %s", itemtypename));
		SetItemLabel(itemid, sprintf("%d/%d", GetItemHitPoints(itemid), GetItemTypeMaxHitPoints(itemtype)));
	}

	return 0;
}

DeconstructDefence(Item:itemid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		ItemType:itemtype,
		itemdata[e_DEFENCE_DATA];

	GetItemPos(itemid, x, y, z);
	itemtype = GetItemType(itemid);
	GetItemArrayData(itemid, itemdata);

	if(itemdata[def_motor])
	{
		if(itemdata[def_pose] == DEFENCE_POSE_VERTICAL)
			z -= def_TypeData[def_ItemTypeDefenceType[itemtype]][def_placeOffsetZ];
	}
	else
	{
		if(itemdata[def_pose] == DEFENCE_POSE_VERTICAL)
			z -= def_TypeData[def_ItemTypeDefenceType[itemtype]][def_placeOffsetZ];
	}

	SetItemPos(itemid, x, y, z);
	SetItemRot(itemid, 0.0, 0.0, 0.0, true);

	SetItemArrayDataAtCell(itemid, 0, 0);
	CallLocalFunction("OnDefenceDestroy", "d", _:itemid);
}


/*==============================================================================

	Internal

==============================================================================*/


hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != INVALID_DEFENCE_TYPE)
	{
		new active;
		GetItemArrayDataAtCell(itemid, active, def_active);
		if(active)
		{
			_InteractDefence(playerid, itemid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return 1;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{

	new ItemType:withitemtype = GetItemType(withitemid);

	if(def_ItemTypeDefenceType[withitemtype] != INVALID_DEFENCE_TYPE)
	{
		new active;
		GetItemArrayDataAtCell(withitemid, active, def_active);
		if(active)
		{
			if(!_InteractDefenceWithItem(playerid, withitemid, itemid))
				_InteractDefence(playerid, withitemid);
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

StartBuildingDefence(playerid, Item:itemid)
{
	new itemtypename[MAX_ITEM_NAME];

	GetItemTypeName(GetItemType(itemid), itemtypename);

	def_CurrentDefenceItem[playerid] = itemid;
	StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, 10000, "Construction"));
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

	if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID)
	{
		def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		HideActionText(playerid);
		
		return;
	}

	return;
}

_InteractDefence(playerid, Item:itemid)
{
	new data[e_DEFENCE_DATA];

	GetItemArrayData(itemid, data);

	if(data[def_motor])
	{
		if(data[def_keypad] == 1)
		{
			if(data[def_pass] == 0)
			{
				if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID)
				{
					HideKeypad(playerid);
					Dialog_Hide(playerid);
				}

				def_CurrentDefenceEdit[playerid] = itemid;
				ShowSetPassDialog_Keypad(playerid);
			}
			else
			{
				if(def_CurrentDefenceOpen[playerid] != INVALID_ITEM_ID)
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
				if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID)
				{
					HideKeypad(playerid);
					Dialog_Hide(playerid);
				}

				def_CurrentDefenceEdit[playerid] = itemid;
				ShowSetPassDialog_KeypadAdv(playerid);
			}
			else
			{
				if(def_CurrentDefenceOpen[playerid] != INVALID_ITEM_ID)
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
			defer MoveDefence(_:itemid, playerid);
		}
	}

	CallLocalFunction("OnPlayerInteractDefence", "dd", playerid, _:itemid);
}

_InteractDefenceWithItem(playerid, Item:itemid, Item:tool)
{
	new
		defencetype,
		ItemType:tooltype,
		Float:angle,
		Float:angletoplayer,
		Button:buttonid;

	defencetype = def_ItemTypeDefenceType[GetItemType(itemid)];
	tooltype = GetItemType(tool);
	GetItemRot(itemid, angle, angle, angle);
	GetItemButtonID(itemid, buttonid);
	GetButtonAngleToPlayer(playerid, buttonid, angletoplayer);

	angle = absoluteangle((angle - def_TypeData[defencetype][def_verticalRotZ]) - angletoplayer);

	// ensures the player can only perform these actions on the back-side.
	if(!(90.0 < angle < 270.0))
		return 0;

	if(tooltype == item_Crowbar)
	{
		new itemtypename[MAX_ITEM_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, 10000, "Construction"));
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
		ShowActionText(playerid, sprintf(ls(playerid, "DEFREMOVING"), itemtypename));

		return 1;
	}

	if(tooltype == item_Motor)
	{
		if(!def_TypeData[defencetype][def_movable])
		{
			ShowActionText(playerid, ls(playerid, "DEFNOTMOVAB"));
			return 1;
		}

		new itemtypename[MAX_ITEM_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, 6000, "Construction"));
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "DEFMODIFYIN"), itemtypename));

		return 1;
	}

	if(tooltype == item_Keypad)
	{
		new hasmotor;
		GetItemArrayDataAtCell(itemid, hasmotor, _:def_motor);
		if(!hasmotor)
		{
			ShowActionText(playerid, ls(playerid, "DEFNEEDMOTO"));
			return 1;
		}

		new itemtypename[MAX_ITEM_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, 6000, "Construction"));
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "DEFMODIFYIN"), itemtypename));

		return 1;
	}

	if(tooltype == item_AdvancedKeypad)
	{
		new hasmotor;
		GetItemArrayDataAtCell(itemid, hasmotor, _:def_motor);
		if(!hasmotor)
		{
			ShowActionText(playerid, ls(playerid, "DEFNEEDMOTO"));
			return 0;
		}

		new itemtypename[MAX_ITEM_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, 6000, "Construction"));
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
			Item:itemid = def_CurrentDefenceItem[playerid],
			ItemType:itemtype,
			pose;

		itemtype = GetItemType(GetPlayerItem(playerid));

		if(itemtype == item_Screwdriver)
			pose = DEFENCE_POSE_VERTICAL;

		if(itemtype == item_Hammer)
			pose = DEFENCE_POSE_HORIZONTAL;

		ConvertItemToDefenceItem(itemid, pose);

		if(!IsValidItem(itemid))
		{
			ChatMsgLang(playerid, RED, "DEFLIMITREA");
			return Y_HOOKS_BREAK_RETURN_0;
		}

		new
			uuid[UUID_LEN],
			Float:x,
			Float:y,
			Float:z,
			Float:rx,
			Float:ry,
			Float:rz,
			model;

		GetItemUUID(itemid, uuid);
		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rx, ry, rz);
		GetItemTypeModel(GetItemType(itemid), model);

		log("[CONSTRUCT] %p Built defence %d (%s) (%d, %f, %f, %f, %f, %f, %f)",
			playerid, _:itemid, uuid, model, x, y, z, rx, ry, rz);

		StopBuildingDefence(playerid);
		TweakItem(playerid, itemid);
		_UpdateDefenceTweakArrow(playerid, itemid);
		PlayerGainSkillExperience(playerid, "Construction");

		ShowHelpTip(playerid, ls(playerid, "TIPTWEAKDEF"));

		return Y_HOOKS_BREAK_RETURN_0;
	}

	if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID)
	{
		new
			Item:itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		if(itemtype == item_Motor)
		{
			ShowActionText(playerid, ls(playerid, "DEFINSTMOTO"));
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], true, def_motor);
			CallLocalFunction("OnDefenceModified", "d", _:def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(itemtype == item_Keypad)
		{
			ShowActionText(playerid, ls(playerid, "DEFINSTKEYP"));
			ShowSetPassDialog_Keypad(playerid);
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], 1, def_keypad);
			CallLocalFunction("OnDefenceModified", "d", _:def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(itemtype == item_AdvancedKeypad)
		{
			ShowActionText(playerid, ls(playerid, "DEFINSTADKP"));
			ShowSetPassDialog_KeypadAdv(playerid);
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], 2, def_keypad);
			CallLocalFunction("OnDefenceModified", "d", _:def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(itemtype == item_Crowbar)
		{
			new
				uuid[UUID_LEN],
				Float:x,
				Float:y,
				Float:z,
				Float:rx,
				Float:ry,
				Float:rz,
				model;

			GetItemUUID(def_CurrentDefenceEdit[playerid], uuid);
			GetItemPos(def_CurrentDefenceEdit[playerid], x, y, z);
			GetItemRot(def_CurrentDefenceEdit[playerid], rz, rz, rz);
			ShowActionText(playerid, ls(playerid, "DEFDISMANTL"));
			GetItemTypeModel(GetItemType(def_CurrentDefenceEdit[playerid]), model);

			DeconstructDefence(def_CurrentDefenceEdit[playerid]);

			log("[CROWBAR] %p broke defence %d (%s) (%d, %f, %f, %f, %f, %f, %f)",
				playerid, _:def_CurrentDefenceEdit[playerid], uuid,
				model, x, y, z, rx, ry, rz);

			/*
				Note:
				This log entry is designed to help with reconstructing bases
				in the case that they are wrongfully deconstructed. The
				section in parentheses mimics the structure of the arguments
				for CreateObject so it can easily be plugged into a map
				editor to view the original base.
			*/

			ClearAnimations(playerid);
			def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;
		}

		return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeypadEnter(playerid, keypadid, code, match)
{
	if(keypadid == 100)
	{
		if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID)
		{
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], code, def_pass);
			CallLocalFunction("OnDefenceModified", "d", _:def_CurrentDefenceEdit[playerid]);
			HideKeypad(playerid);

			def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;

			if(code == 0)
				ChatMsgLang(playerid, YELLOW, "DEFCODEZERO");

			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(def_CurrentDefenceOpen[playerid] != INVALID_ITEM_ID)
		{
			if(code == match)
			{
				ShowActionText(playerid, ls(playerid, "DEFMOVINGIT"), 3000);
				defer MoveDefence(_:def_CurrentDefenceOpen[playerid], playerid);
				def_CurrentDefenceOpen[playerid] = INVALID_ITEM_ID;
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

				new uuid[UUID_LEN];

				GetItemUUID(def_CurrentDefenceOpen[playerid], uuid);

				log("[DEFFAIL] Player %p failed defence %d (%s) keypad code %d", playerid, _:def_CurrentDefenceOpen[playerid], uuid, code);
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

ConvertItemToDefenceItem(Item:itemid, pose)
{
	new ret = ActivateDefenceItem(itemid);
	if(ret)
		return ret;

	SetItemArrayDataAtCell(itemid, pose, def_pose);

	new
		ItemType:itemtype = GetItemType(itemid),
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz;

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rx, ry, rz);

	if(pose == DEFENCE_POSE_HORIZONTAL)
	{
		rx = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotX];
		ry = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotY];
		rz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotZ];
	}
	else if(pose == DEFENCE_POSE_VERTICAL)
	{
		z += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_placeOffsetZ];
		rx = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_verticalRotX];
		ry = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_verticalRotY];
		rz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_verticalRotZ];
	}

	SetItemPos(itemid, x, y, z);
	SetItemRot(itemid, rx, ry, rz);
	return CallLocalFunction("OnDefenceCreate", "d", _:itemid);
}

_UpdateDefenceTweakArrow(playerid, Item:itemid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz,
		world,
		interior;

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rx, ry, rz);
	GetItemWorld(itemid, world);
	GetItemInterior(itemid, interior);

	if(!IsValidDynamicObject(def_TweakArrow[playerid]))
		def_TweakArrow[playerid] = CreateDynamicObject(19132, x, y, z, 0.0, 0.0, 0.0, world, interior);

	else
		SetDynamicObjectPos(def_TweakArrow[playerid], x, y, z);

	new pose;
	GetItemArrayDataAtCell(itemid, pose, def_pose);
	if(pose == DEFENCE_POSE_VERTICAL)
	{
		SetDynamicObjectRot(def_TweakArrow[playerid],
			rx - def_TypeData[def_ItemTypeDefenceType[GetItemType(itemid)]][def_verticalRotX] + 90,
			ry - def_TypeData[def_ItemTypeDefenceType[GetItemType(itemid)]][def_verticalRotY],
			rz - def_TypeData[def_ItemTypeDefenceType[GetItemType(itemid)]][def_verticalRotZ]);
	}
	else
	{
		SetDynamicObjectRot(def_TweakArrow[playerid],
			rx - def_TypeData[def_ItemTypeDefenceType[GetItemType(itemid)]][def_horizontalRotX],
			ry - def_TypeData[def_ItemTypeDefenceType[GetItemType(itemid)]][def_horizontalRotY],
			rz - def_TypeData[def_ItemTypeDefenceType[GetItemType(itemid)]][def_horizontalRotZ]);
	}
}

hook OnItemTweakUpdate(playerid, Item:itemid)
{
	if(def_TweakArrow[playerid] != INVALID_OBJECT_ID)
	{
		_UpdateDefenceTweakArrow(playerid, itemid);
	}
}

hook OnItemTweakFinish(playerid, Item:itemid)
{
	if(def_TweakArrow[playerid] != INVALID_OBJECT_ID)
	{
		DestroyDynamicObject(def_TweakArrow[playerid]);
		def_TweakArrow[playerid] = INVALID_OBJECT_ID;
		CallLocalFunction("OnDefenceModified", "d", _:itemid);
	}
}

hook OnPlayerKeypadCancel(playerid, keypadid)
{
	if(keypadid == 100)
	{
		if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID)
		{
			ShowSetPassDialog_Keypad(playerid);
			def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;

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

	new pass;
	GetItemArrayDataAtCell(def_CurrentDefenceOpen[playerid], pass, def_pass);
	ShowKeypad(playerid, 100, pass);
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
				SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], pass, def_pass);
				CallLocalFunction("OnDefenceModified", "d", _:def_CurrentDefenceEdit[playerid]);
				def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;
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
			new pass, defpass;

			sscanf(inputtext, "x", pass);
			GetItemArrayDataAtCell(def_CurrentDefenceOpen[playerid], defpass, def_pass);

			if(pass == defpass && strlen(inputtext) >= 4)
			{
				ShowActionText(playerid, ls(playerid, "DEFMOVINGIT"), 3000);
				defer MoveDefence(_:def_CurrentDefenceOpen[playerid], playerid);
				def_CurrentDefenceOpen[playerid] = INVALID_ITEM_ID;
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

				new uuid[UUID_LEN];

				GetItemUUID(def_CurrentDefenceOpen[playerid], uuid);

				log("[DEFFAIL] Player %p failed defence %d (%s) keypad code %d", playerid, _:def_CurrentDefenceOpen[playerid], uuid, pass);
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

timer MoveDefence[1500](itemid, playerid)
{
	new
		Float:px,
		Float:py,
		Float:pz,
		Float:ix,
		Float:iy,
		Float:iz;

	GetItemPos(Item:itemid, ix, iy, iz);

	foreach(new i : Player)
	{
		GetPlayerPos(i, px, py, pz);

		if(Distance(px, py, pz, ix, iy, iz) < 4.0)
		{
			defer MoveDefence(itemid, playerid);

			return;
		}
	}

	new
		ItemType:itemtype = GetItemType(Item:itemid),
		Float:rx,
		Float:ry,
		Float:rz,
		uuid[UUID_LEN],
		pose;

	GetItemRot(Item:itemid, rx, ry, rz);
	GetItemUUID(Item:itemid, uuid);
	GetItemArrayDataAtCell(Item:itemid, pose, def_pose);

	if(pose == DEFENCE_POSE_HORIZONTAL)
	{
		rx = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_verticalRotX];
		ry = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_verticalRotY];
		rz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_verticalRotZ];
		iz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_placeOffsetZ];

		SetItemPos(Item:itemid, ix, iy, iz);
		SetItemRot(Item:itemid, rx, ry, rz);

		SetItemArrayDataAtCell(Item:itemid, DEFENCE_POSE_VERTICAL, def_pose);

		log("[DEFMOVE] Player %p moved defence %d (%s) into CLOSED position at %.1f, %.1f, %.1f", playerid, itemid, uuid, ix, iy, iz);
		CallLocalFunction("OnDefenceMove", "d", itemid);
	}
	else
	{
		rx = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotX];
		ry = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotY];
		rz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotZ];
		iz -= def_TypeData[def_ItemTypeDefenceType[itemtype]][def_placeOffsetZ];

		SetItemPos(Item:itemid, ix, iy, iz);
		SetItemRot(Item:itemid, rx, ry, rz);

		SetItemArrayDataAtCell(Item:itemid, DEFENCE_POSE_HORIZONTAL, def_pose);

		log("[DEFMOVE] Player %p moved defence %d (%s) into OPEN position at %.1f, %.1f, %.1f", playerid, itemid, uuid, ix, iy, iz);
		CallLocalFunction("OnDefenceMove", "d", itemid);
	}

	return;
}

hook OnItemHitPointsUpdate(Item:itemid, oldvalue, newvalue)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != -1){
		SetItemLabel(itemid, sprintf("%d/%d", GetItemHitPoints(itemid), GetItemTypeMaxHitPoints(itemtype)));
		CallLocalFunction("OnDefenceModified", "d", _:itemid);
	}
}

hook OnItemDestroy(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != -1)
	{
		if(GetItemHitPoints(itemid) <= 0)
		{
			new
				Float:x,
				Float:y,
				Float:z,
				Float:rx,
				Float:ry,
				Float:rz,
				model;

			GetItemPos(itemid, x, y, z);
			GetItemRot(itemid, rx, ry, rz);
			GetItemTypeModel(itemtype, model);

			log("[DESTRUCTION] Defence %d (%d) Object: (%d, %f, %f, %f, %f, %f, %f)", _:itemid, _:itemtype, model, x, y, z, rx, ry, rz);
		}
	}
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

stock IsItemTypeDefence(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return false;

	if(def_ItemTypeDefenceType[itemtype] != -1)
		return true;

	return false;
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

// def_type
stock GetDefenceType(Item:itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	return def_ItemTypeDefenceType[GetItemType(itemid)];
}

// def_pose
stock GetDefencePose(Item:itemid)
{
	return GetItemArrayDataAtCell(itemid, def_pose);
}

// def_motor
stock GetDefenceMotor(Item:itemid)
{
	return GetItemArrayDataAtCell(itemid, def_motor);
}

// def_keypad
stock GetDefenceKeypad(Item:itemid)
{
	return GetItemArrayDataAtCell(itemid, def_keypad);
}

// def_pass
stock GetDefencePass(Item:itemid)
{
	return GetItemArrayDataAtCell(itemid, def_pass);
}

#define MAX_TOOLTIP_TEXT (256)


static
	ItemToolTips[ITM_MAX][MAX_TOOLTIP_TEXT];


DefineItemToolTip(ItemType:itemtype, tooltip[MAX_TOOLTIP_TEXT])
{
	ItemToolTips[_:itemtype] = tooltip;

	return 1;
}

ShowItemToolTip(playerid, ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(isnull(ItemToolTips[_:itemtype]))
		return 0;

	new str[MAX_TOOLTIP_TEXT + 32];
	
	format(str, sizeof(str), "%s~n~~n~~b~Type /tooltips to toggle these messages", ItemToolTips[_:itemtype]);

	ShowHelpTip(playerid, str, 20000);

	return 1;
}

public OnPlayerPickUpItem(playerid, itemid)
{
	if(!IsPlayerInTutorial(playerid))
	{
		if(IsPlayerToolTipsOn(playerid))
			ShowItemToolTip(playerid, GetItemType(itemid));
	}

	return CallLocalFunction("tip_OnPlayerPickUpItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem tip_OnPlayerPickUpItem
forward tip_OnPlayerPickUpItem(playerid, itemid);

public OnPlayerDropItem(playerid, itemid)
{
	if(!IsPlayerInTutorial(playerid))
	{
		if(IsPlayerToolTipsOn(playerid))
			HideHelpTip(playerid);
	}

	return CallLocalFunction("tip_OnPlayerDropItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerDropItem
	#undef OnPlayerDropItem
#else
	#define _ALS_OnPlayerDropItem
#endif
#define OnPlayerDropItem tip_OnPlayerDropItem
forward tip_OnPlayerDropItem(playerid, itemid);

public OnLoad()
{
	DefineItemToolTip(item_Parachute,		"Press "KEYTEXT_PUT_AWAY" to equip, you can't wear this while you are wearing a bag");
	DefineItemToolTip(item_Medkit,			"You can heal yourself or others with this");
	DefineItemToolTip(item_HardDrive,		"Used for crafting and some puzzles");
	DefineItemToolTip(item_Key,				"Used in a puzzle");
	DefineItemToolTip(item_FireworkBox,		"Use a lighter with this to see some fireworks! Or craft explosives with it");
	DefineItemToolTip(item_FireLighter,		"Light BBQs, campfires and fireworks with this");
	DefineItemToolTip(item_Timer,			"Used for crafting");
	DefineItemToolTip(item_Explosive,		"Craft with various mechanical items for different types of bombs");
	DefineItemToolTip(item_TntTimebomb,		"An explosive with a timed detonation of 5 seconds, press "KEYTEXT_INTERACT" to arm");
	DefineItemToolTip(item_Battery,			"Used for crafting and some puzzles");
	DefineItemToolTip(item_Fusebox,			"Used for crafting and some puzzles");
	DefineItemToolTip(item_Bottle,			"Can be drunk for food value");
	DefineItemToolTip(item_Sign,			"Press "KEYTEXT_INTERACT" to place and write on");
	DefineItemToolTip(item_Armour,			"Press "KEYTEXT_INTERACT" to wear for protection");
	DefineItemToolTip(item_Bandage,			"You can heal yourself or others with this");
	DefineItemToolTip(item_FishRod,			"This has no use yet");
	DefineItemToolTip(item_Wrench,			"Use this to repair vehicles by standing at the front and holding "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_Crowbar,			"Use this to break defences and tents or open locked car doors and trunks");
	DefineItemToolTip(item_Hammer,			"Use this to repair vehicles by standing at the front and holding "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_Shield,			"This protects you from gunfire when pointed towards the shooter");
	DefineItemToolTip(item_Flashlight,		"Press "KEYTEXT_INTERACT" to toggle light, other than that it does nothing");
	DefineItemToolTip(item_Taser,			"Attack players with this to disable them for 1 minute");
	DefineItemToolTip(item_LaserPoint,		"This has no use yet");
	DefineItemToolTip(item_Screwdriver,		"Use this to repair vehicles by standing at the front and holding "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_MobilePhone,		"Used for crafting");
	DefineItemToolTip(item_Pager,			"This has no use yet");
	DefineItemToolTip(item_Rake,			"This has no use yet");
	DefineItemToolTip(item_HotDog,			"Cook and eat this for food value");
	DefineItemToolTip(item_EasterEgg,		"This has no use yet");
	DefineItemToolTip(item_Cane,			"This has no use yet");
	DefineItemToolTip(item_HandCuffs,		"Hold "KEYTEXT_INTERACT" at a player to handcuff them");
	DefineItemToolTip(item_Bucket,			"This has no use yet");
	DefineItemToolTip(item_GasMask,			"This has no use yet");
	DefineItemToolTip(item_Flag,			"This has no use yet");
	DefineItemToolTip(item_DoctorBag,		"You can heal yourself or others with this");
	DefineItemToolTip(item_Backpack,		"Press "KEYTEXT_PUT_AWAY" to wear a bag, press "KEYTEXT_DROP_ITEM" while holding nothing to remove a bag");
	DefineItemToolTip(item_Satchel,			"Press "KEYTEXT_PUT_AWAY" to wear a bag, press "KEYTEXT_DROP_ITEM" while holding nothing to remove a bag");
	DefineItemToolTip(item_Wheel,			"Use this to repair vehicle wheels by standing at the front and pressing "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_MotionSense,		"Used for crafting");
	DefineItemToolTip(item_Accelerometer,	"used for crafting");
	DefineItemToolTip(item_TntTripMine,		"Arm on the floor by pressing "KEYTEXT_INTERACT" arm inside containers by opening options and clicking 'Arm' will explode when interacted with");
	DefineItemToolTip(item_IedBomb,			"Craft with various mechanical items for different types of bombs");
	DefineItemToolTip(item_Pizza,			"Cook and eat this for food value");
	DefineItemToolTip(item_Burger,			"Cook and eat this for food value");
	DefineItemToolTip(item_BurgerBox,		"Cook and eat this for food value");
	DefineItemToolTip(item_Taco,			"Cook and eat this for food value");
	DefineItemToolTip(item_GasCan,			"Use this to refuel vehicles by standing at the front and holding "KEYTEXT_INTERACT" refuel petrol can at fuel pumps by holding "KEYTEXT_INTERACT" at one");
	DefineItemToolTip(item_Clothes,			"Wear these by holding "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_HelmArmy,		"Wear this by pressing "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_MediumBox,		"Store items inside this to save them over restarts, read more: /restartinfo");
	DefineItemToolTip(item_SmallBox,		"Store items inside this to save them over restarts, read more: /restartinfo");
	DefineItemToolTip(item_LargeBox,		"Store items inside this to save them over restarts, read more: /restartinfo");
	DefineItemToolTip(item_AmmoTin,			"Old item type, this shouldn't even spawn anymore");
	DefineItemToolTip(item_Meat,			"Cook and eat this for food value");
	DefineItemToolTip(item_DeadLeg,			"Tasty human leg...");
	DefineItemToolTip(item_Torso,			"Tasty human torso... the original owner might not be happy");
	DefineItemToolTip(item_LongPlank,		"This item has no use yet");
	DefineItemToolTip(item_GreenGloop,		"This item has no use yet");
	DefineItemToolTip(item_Capsule,			"This item has no use yet");
	DefineItemToolTip(item_RadioPole,		"Used for crafting");
	DefineItemToolTip(item_SignShot,		"Use this to scare people (it doesn't save over restarts)");
	DefineItemToolTip(item_Mailbox,			"This item has no use yet");
	DefineItemToolTip(item_Pumpkin,			"This item has no use yet");
	DefineItemToolTip(item_Nailbat,			"This item has no use yet");
	DefineItemToolTip(item_ZorroMask,		"Wear this by pressing "KEYTEXT_INTERACT" and pretend you are Zorro");
	DefineItemToolTip(item_Barbecue,		"Used to cook food, stand near with food and press "KEYTEXT_INTERACT" to place, use fuel and a lighter to cook");
	DefineItemToolTip(item_Headlight,		"Use this to repair vehicle headlights by standing at the front and pressing "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_Pills,			"Different pill types have different effects, some are good some are bad, be careful!");
	DefineItemToolTip(item_AutoInjec,		"Different injector types have different effects, some are good some are bad, be careful!");
	DefineItemToolTip(item_BurgerBag,		"Cook and eat this for food value");
	DefineItemToolTip(item_CanDrink,		"Can be drunk for food value");
	DefineItemToolTip(item_Detergent,		"This item has no use yet");
	DefineItemToolTip(item_Dice,			"Drop the dice to roll it!");
	DefineItemToolTip(item_Dynamite,		"This item has no use yet");
	DefineItemToolTip(item_Door,			"Use screwdriver with this to construct a permanent wall, or a hammer to construct a permanent floor, hold "KEYTEXT_INTERACT" to build");
	DefineItemToolTip(item_MetPanel,		"Use screwdriver with this to construct a permanent wall, or a hammer to construct a permanent floor, hold "KEYTEXT_INTERACT" to build");
	DefineItemToolTip(item_SurfBoard,		"Use screwdriver with this to construct a permanent wall, or a hammer to construct a permanent floor, hold "KEYTEXT_INTERACT" to build");
	DefineItemToolTip(item_CrateDoor,		"Use screwdriver with this to construct a permanent wall, or a hammer to construct a permanent floor, hold "KEYTEXT_INTERACT" to build");
	DefineItemToolTip(item_CorPanel,		"Use screwdriver with this to construct a permanent wall, or a hammer to construct a permanent floor, hold "KEYTEXT_INTERACT" to build");
	DefineItemToolTip(item_ShipDoor,		"Use screwdriver with this to construct a permanent wall, or a hammer to construct a permanent floor, hold "KEYTEXT_INTERACT" to build");
	DefineItemToolTip(item_MetalPlate,		"Use screwdriver with this to construct a permanent wall, or a hammer to construct a permanent floor, hold "KEYTEXT_INTERACT" to build");
	DefineItemToolTip(item_MetalStand,		"Use screwdriver with this to construct a permanent wall, or a hammer to construct a permanent floor, hold "KEYTEXT_INTERACT" to build");
	DefineItemToolTip(item_WoodDoor,		"Use screwdriver with this to construct a permanent wall, or a hammer to construct a permanent floor, hold "KEYTEXT_INTERACT" to build");
	DefineItemToolTip(item_WoodPanel,		"Use screwdriver with this to construct a permanent wall, or a hammer to construct a permanent floor, hold "KEYTEXT_INTERACT" to build");
	DefineItemToolTip(item_Flare,			"This item has no use yet");
	DefineItemToolTip(item_TntPhoneBomb,	"Use a phone with this by pressing "#KEYTEXT_INTERACT" to sync the phones, then use the phone to detonate with "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_ParaBag,			"Press "KEYTEXT_PUT_AWAY" to wear a bag, press "KEYTEXT_DROP_ITEM" while holding nothing to remove a bag");
	DefineItemToolTip(item_Keypad,			"Hold "#KEYTEXT_INTERACT" with this while at a constructed defence to turn it into a key-code protected door");
	DefineItemToolTip(item_TentPack,		"Use a hammer with this to build a tent");
	DefineItemToolTip(item_Campfire,		"Light with petrol and a lighter, then put food on by holding the food and pressing "KEYTEXT_INTERACT" to cook it");
	DefineItemToolTip(item_CowboyHat,		"Wear this by pressing "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_TruckCap,		"Wear this by pressing "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_BoaterHat,		"Wear this by pressing "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_BowlerHat,		"Wear this by pressing "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_PoliceCap,		"Wear this by pressing "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_TopHat,			"Wear this by pressing "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_Ammo9mm,			"Put in a container and click 'Transfer Ammo' in the options menu to load ammo into guns or other ammo tins");
	DefineItemToolTip(item_Ammo50,			"Put in a container and click 'Transfer Ammo' in the options menu to load ammo into guns or other ammo tins");
	DefineItemToolTip(item_AmmoBuck,		"Put in a container and click 'Transfer Ammo' in the options menu to load ammo into guns or other ammo tins");
	DefineItemToolTip(item_Ammo556,			"Put in a container and click 'Transfer Ammo' in the options menu to load ammo into guns or other ammo tins");
	DefineItemToolTip(item_Ammo357,			"Put in a container and click 'Transfer Ammo' in the options menu to load ammo into guns or other ammo tins");
	DefineItemToolTip(item_AmmoRocket,		"Put in a container and click 'Transfer Ammo' in the options menu to load ammo into guns or other ammo tins");
	DefineItemToolTip(item_MolotovEmpty,	"Pour petrol into this to make a throwable fire bomb");
	DefineItemToolTip(item_Money,			"This item has no use yet");
	DefineItemToolTip(item_PowerSupply,		"Used for crafting");
	DefineItemToolTip(item_StorageUnit,		"Used for crafting");
	DefineItemToolTip(item_Fluctuator,		"Used for crafting");
	DefineItemToolTip(item_IoUnit,			"Used for crafting");
	DefineItemToolTip(item_FluxCap,			"Used for crafting");
	DefineItemToolTip(item_DataInterface,	"Used for crafting");
	DefineItemToolTip(item_HackDevice,		"Used for hacking keypads and accessing doors (not player-built doors)");
	DefineItemToolTip(item_PlantPot,		"This item has no use yet");
	DefineItemToolTip(item_HerpDerp,		"Press "KEYTEXT_INTERACT" to derp");
	DefineItemToolTip(item_Parrot,			"This is a parrot called Sebastian");
	DefineItemToolTip(item_TntProxMine,		"This item has no use yet");
	DefineItemToolTip(item_IedTimebomb,		"An explosive with a timed detonation of 5 seconds, press "KEYTEXT_INTERACT" to arm");
	DefineItemToolTip(item_IedTripMine,		"Arm on the floor by pressing "KEYTEXT_INTERACT" arm inside containers by opening options and clicking 'Arm' will explode when interacted with");
	DefineItemToolTip(item_IedProxMine,		"This item has no use yet");
	DefineItemToolTip(item_IedPhoneBomb,	"Use a phone with this by pressing "#KEYTEXT_INTERACT" to sync the phones, then use the phone to detonate with "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_EmpTimebomb,		"A proximity taser with a timed detonation of 5 seconds, press "KEYTEXT_INTERACT" to arm");
	DefineItemToolTip(item_EmpTripMine,		"Arm on the floor by pressing "KEYTEXT_INTERACT" arm inside containers by opening options and clicking 'Arm' will explode when interacted with");
	DefineItemToolTip(item_EmpProxMine,		"This item has no use yet");
	DefineItemToolTip(item_EmpPhoneBomb,	"Use a phone with this by pressing "#KEYTEXT_INTERACT" to sync the phones, then use the phone to detonate with "KEYTEXT_INTERACT"");
	DefineItemToolTip(item_Gyroscope,		"This item has no use yet");
	DefineItemToolTip(item_Motor,			"This item has no use yet");
	DefineItemToolTip(item_StarterMotor,	"This item has no use yet");
	DefineItemToolTip(item_FlareGun,		"This item has no use yet");
	DefineItemToolTip(item_PetrolBomb,		"This item has no use yet");
	DefineItemToolTip(item_CodePart,		"A puzzle item, the number displayed next to the item name is part of a 4 digit code used to open a door somewhere");

	return CallLocalFunction("tip_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad tip_OnLoad
forward tip_OnLoad();

public OnLoad()
{
	for(new i; i < loot_Survivor + 1; i++)
	{
		// Weapons
		AddItemToLootIndex(i, ItemType:WEAPON_COLT45, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_DEAGLE, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_SHOTGUN, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_SAWEDOFF, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_UZI, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_TEC9, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_GRENADE, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_TEARGAS, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_SILENCED, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_SHOTGSPA, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_MP5, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_AK47, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_M4, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_RIFLE, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_SNIPER, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_ROCKETLAUNCHER, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_FLAMETHROWER, 1.0);
		AddItemToLootIndex(i, ItemType:WEAPON_MINIGUN, 1.0);

		// Military
		AddItemToLootIndex(i, item_Armour, 1.0);
		AddItemToLootIndex(i, item_Shield, 1.0);
		AddItemToLootIndex(i, item_Backpack, 1.0);
		AddItemToLootIndex(i, item_Ammo9mm, 1.0);
		AddItemToLootIndex(i, item_Ammo50, 1.0);
		AddItemToLootIndex(i, item_AmmoBuck, 1.0);
		AddItemToLootIndex(i, item_Ammo556, 1.0);
		AddItemToLootIndex(i, item_Ammo357, 1.0);
		AddItemToLootIndex(i, item_AmmoRocket, 1.0);

		// Medical
		AddItemToLootIndex(i, item_Bandage, 1.0);
		AddItemToLootIndex(i, item_Medkit, 1.0);
		AddItemToLootIndex(i, item_DoctorBag, 1.0);
		AddItemToLootIndex(i, item_Pills, 1.0);
		AddItemToLootIndex(i, item_AutoInjec, 1.0);

		// Vehicle
		AddItemToLootIndex(i, item_Wrench, 1.0);
		AddItemToLootIndex(i, item_Crowbar, 1.0);
		AddItemToLootIndex(i, item_Hammer, 1.0);
		AddItemToLootIndex(i, item_Screwdriver, 1.0);
		AddItemToLootIndex(i, item_Wheel, 1.0);
		AddItemToLootIndex(i, item_GasCan, 1.0);

		// Customisation
		AddItemToLootIndex(i, item_Clothes, 1.0);
		AddItemToLootIndex(i, item_CowboyHat, 1.0);
		AddItemToLootIndex(i, item_TruckCap, 1.0);
		AddItemToLootIndex(i, item_BoaterHat, 1.0);
		AddItemToLootIndex(i, item_BowlerHat, 1.0);
		AddItemToLootIndex(i, item_TopHat, 1.0);
		AddItemToLootIndex(i, item_GasMask, 1.0);
		AddItemToLootIndex(i, item_HockeyMask, 1.0);
		AddItemToLootIndex(i, item_ZorroMask, 1.0);

		// Misc
		AddItemToLootIndex(i, item_MobilePhone, 1.0);
		AddItemToLootIndex(i, item_Taco, 1.0);
		AddItemToLootIndex(i, item_Barbecue, 1.0);
		AddItemToLootIndex(i, item_Explosive, 1.0);
		AddItemToLootIndex(i, item_FireLighter, 1.0);
		AddItemToLootIndex(i, item_Timer, 1.0);
		AddItemToLootIndex(i, item_MotionSense, 1.0);
		AddItemToLootIndex(i, item_Accelerometer, 1.0);
	}

	return CallLocalFunction("loot_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad loot_OnLoad
forward loot_OnLoad();


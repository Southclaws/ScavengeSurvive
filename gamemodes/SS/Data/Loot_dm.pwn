public OnLoad()
{
	for(new i; i < loot_Survivor + 1; i++)
	{
		// Weapons
		AddItemToLootIndex(i, ItemType:WEAPON_COLT45, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_DEAGLE, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_SHOTGUN, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_SAWEDOFF, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_UZI, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_TEC9, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_GRENADE, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_TEARGAS, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_SILENCED, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_SHOTGSPA, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_MP5, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_AK47, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_M4, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_RIFLE, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_SNIPER, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_ROCKETLAUNCHER, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_FLAMETHROWER, 50);
		AddItemToLootIndex(i, ItemType:WEAPON_MINIGUN, 50);

		// Military
		AddItemToLootIndex(i, item_Armour, 50);
		AddItemToLootIndex(i, item_Shield, 50);
		AddItemToLootIndex(i, item_Backpack, 50);
		AddItemToLootIndex(i, item_Ammo9mm, 50);
		AddItemToLootIndex(i, item_Ammo50, 50);
		AddItemToLootIndex(i, item_AmmoBuck, 50);
		AddItemToLootIndex(i, item_Ammo556, 50);
		AddItemToLootIndex(i, item_Ammo357, 50);
		AddItemToLootIndex(i, item_AmmoRocket, 50);

		// Medical
		AddItemToLootIndex(i, item_Bandage, 50);
		AddItemToLootIndex(i, item_Medkit, 50);
		AddItemToLootIndex(i, item_DoctorBag, 50);
		AddItemToLootIndex(i, item_Pills, 50);
		AddItemToLootIndex(i, item_AutoInjec, 50);

		// Vehicle
		AddItemToLootIndex(i, item_Wrench, 50);
		AddItemToLootIndex(i, item_Crowbar, 50);
		AddItemToLootIndex(i, item_Hammer, 50);
		AddItemToLootIndex(i, item_Screwdriver, 50);
		AddItemToLootIndex(i, item_Wheel, 50);
		AddItemToLootIndex(i, item_GasCan, 50);

		// Customisation
		AddItemToLootIndex(i, item_Clothes, 50);
		AddItemToLootIndex(i, item_CowboyHat, 50);
		AddItemToLootIndex(i, item_TruckCap, 50);
		AddItemToLootIndex(i, item_BoaterHat, 50);
		AddItemToLootIndex(i, item_BowlerHat, 50);
		AddItemToLootIndex(i, item_TopHat, 50);
		AddItemToLootIndex(i, item_GasMask, 50);
		AddItemToLootIndex(i, item_HockeyMask, 50);
		AddItemToLootIndex(i, item_ZorroMask, 50);

		// Misc
		AddItemToLootIndex(i, item_MobilePhone, 50);
		AddItemToLootIndex(i, item_Taco, 50);
		AddItemToLootIndex(i, item_Barbecue, 50);
		AddItemToLootIndex(i, item_Explosive, 50);
		AddItemToLootIndex(i, item_FireLighter, 50);
		AddItemToLootIndex(i, item_Timer, 50);
		AddItemToLootIndex(i, item_MotionSense, 50);
		AddItemToLootIndex(i, item_Accelerometer, 50);
	}

	#if defined loot_OnLoad
        loot_OnLoad();
    #elseif
        return 0;
    #endif
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad loot_OnLoad
#if defined loot_OnLoad
    forward loot_OnLoad();
#endif


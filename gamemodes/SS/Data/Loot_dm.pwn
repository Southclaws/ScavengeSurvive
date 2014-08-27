#include <YSI\y_hooks>


hook OnGameModeInit()
{
	for(new i; i < loot_Survivor + 1; i++)
	{
		// Firearms
		AddItemToLootIndex(i, item_M9Pistol, 50);
		AddItemToLootIndex(i, item_M9PistolSD, 50);
		AddItemToLootIndex(i, item_DesertEagle, 50);
		AddItemToLootIndex(i, item_PumpShotgun, 50);
		AddItemToLootIndex(i, item_Sawnoff, 50);
		AddItemToLootIndex(i, item_Spas12, 50);
		AddItemToLootIndex(i, item_Mac10, 50);
		AddItemToLootIndex(i, item_MP5, 50);
		AddItemToLootIndex(i, item_AK47Rifle, 50);
		AddItemToLootIndex(i, item_M16Rifle, 50);
		AddItemToLootIndex(i, item_Tec9, 50);
		AddItemToLootIndex(i, item_SemiAutoRifle, 50);
		AddItemToLootIndex(i, item_SniperRifle, 50);
		AddItemToLootIndex(i, item_RocketLauncher, 10);
		AddItemToLootIndex(i, item_Heatseeker, 10);
		AddItemToLootIndex(i, item_Flamer, 10);
		AddItemToLootIndex(i, item_Minigun, 10);

		// Melee
		AddItemToLootIndex(i, item_Knuckles, 50);
		AddItemToLootIndex(i, item_GolfClub, 50);
		AddItemToLootIndex(i, item_Baton, 50);
		AddItemToLootIndex(i, item_Knife, 50);
		AddItemToLootIndex(i, item_Bat, 50);
		AddItemToLootIndex(i, item_Spade, 50);
		AddItemToLootIndex(i, item_PoolCue, 50);
		AddItemToLootIndex(i, item_Sword, 50);
		AddItemToLootIndex(i, item_Chainsaw, 50);
		AddItemToLootIndex(i, item_Dildo1, 50);
		AddItemToLootIndex(i, item_Dildo2, 50);
		AddItemToLootIndex(i, item_Dildo3, 50);
		AddItemToLootIndex(i, item_Dildo4, 50);
		AddItemToLootIndex(i, item_Flowers, 50);
		AddItemToLootIndex(i, item_WalkingCane, 50);

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
		AddItemToLootIndex(i, item_Explosive, 100);
		AddItemToLootIndex(i, item_FireLighter, 50);
		AddItemToLootIndex(i, item_Timer, 50);
		AddItemToLootIndex(i, item_MotionSense, 50);
		AddItemToLootIndex(i, item_Accelerometer, 50);
	}
}

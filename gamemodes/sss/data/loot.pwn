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


hook OnGameModeInit()
{
	// loot_Civilian
	AddItemToLootIndex(loot_Civilian,		item_GolfClub,						50.0);
	AddItemToLootIndex(loot_Civilian,		item_Baton,							40.0);
	AddItemToLootIndex(loot_Civilian,		item_Knife,							80.0);
	AddItemToLootIndex(loot_Civilian,		item_Bat,							70.0);
	AddItemToLootIndex(loot_Civilian,		item_Spade,							70.0);
	AddItemToLootIndex(loot_Civilian,		item_Flowers,						40.0);
	AddItemToLootIndex(loot_Civilian,		item_WalkingCane,					70.0);
	AddItemToLootIndex(loot_Civilian,		item_M9Pistol,						50.0);
	AddItemToLootIndex(loot_Civilian,		item_DesertEagle,					10.0);
	AddItemToLootIndex(loot_Civilian,		item_PumpShotgun,					30.0);
	AddItemToLootIndex(loot_Civilian,		item_Sawnoff,						20.0);
	AddItemToLootIndex(loot_Civilian,		item_Mac10,							5.0);
	AddItemToLootIndex(loot_Civilian,		item_Tec9,							4.0);
	AddItemToLootIndex(loot_Civilian,		item_M77RMRifle,					21.4);
	AddItemToLootIndex(loot_Civilian,		item_Model70Rifle,					21.4);
	AddItemToLootIndex(loot_Civilian,		item_SprayPaint,					40.0);
	AddItemToLootIndex(loot_Civilian,		item_Extinguisher,					60.0);
	AddItemToLootIndex(loot_Civilian,		item_Camera,						60.0);
	AddItemToLootIndex(loot_Civilian,		item_Key,							50.0);
	AddItemToLootIndex(loot_Civilian,		item_Medkit,						10.0);
	AddItemToLootIndex(loot_Civilian,		item_FireworkBox,					10.0);
	AddItemToLootIndex(loot_Civilian,		item_FireLighter,					100.0);
	AddItemToLootIndex(loot_Civilian,		item_Bottle,						100.0);
	AddItemToLootIndex(loot_Civilian,		item_Sign,							40.0);
	AddItemToLootIndex(loot_Civilian,		item_Bandage,						20.0);
	AddItemToLootIndex(loot_Civilian,		item_AntiSepBandage,				10.0);
//	AddItemToLootIndex(loot_Civilian,		item_FishRod,						100.0);
	AddItemToLootIndex(loot_Civilian,		item_Wrench,						100.0);
	AddItemToLootIndex(loot_Civilian,		item_Crowbar,						100.0);
	AddItemToLootIndex(loot_Civilian,		item_Hammer,						100.0);
//	AddItemToLootIndex(loot_Civilian,		item_Flashlight,					100.0);
//	AddItemToLootIndex(loot_Civilian,		item_LaserPoint,					100.0);
	AddItemToLootIndex(loot_Civilian,		item_Screwdriver,					100.0);
	AddItemToLootIndex(loot_Civilian,		item_MobilePhone,					40.0);
	AddItemToLootIndex(loot_Civilian,		item_Rake,							90.0);
	AddItemToLootIndex(loot_Civilian,		item_HotDog,						100.0);
	AddItemToLootIndex(loot_Civilian,		item_EasterEgg,						1.0);
	AddItemToLootIndex(loot_Civilian,		item_Cane,							80.0);
//	AddItemToLootIndex(loot_Civilian,		item_Bucket,						100.0);
	AddItemToLootIndex(loot_Civilian,		item_Flag,							100.0);
	AddItemToLootIndex(loot_Civilian,		item_Satchel,						100.0);
	AddItemToLootIndex(loot_Civilian,		item_Pizza,							10.0);
	AddItemToLootIndex(loot_Civilian,		item_Burger,						20.0);
	AddItemToLootIndex(loot_Civilian,		item_BurgerBox,						20.0);
	AddItemToLootIndex(loot_Civilian,		item_BurgerBag,						10.0);
	AddItemToLootIndex(loot_Civilian,		item_Taco,							20.0);
	AddItemToLootIndex(loot_Civilian,		item_Clothes,						100.0);
	AddItemToLootIndex(loot_Civilian,		item_Barbecue,						1.0);
	AddItemToLootIndex(loot_Civilian,		item_Pills,							40.0);
//	AddItemToLootIndex(loot_Civilian,		item_Detergent,						50.0);
	AddItemToLootIndex(loot_Civilian,		item_Dice,							20.0);
	AddItemToLootIndex(loot_Civilian,		item_TentPack,						20.0);
	AddItemToLootIndex(loot_Civilian,		item_CowboyHat,						20.0);
	AddItemToLootIndex(loot_Civilian,		item_TruckCap,						20.0);
	AddItemToLootIndex(loot_Civilian,		item_BoaterHat,						10.0);
	AddItemToLootIndex(loot_Civilian,		item_BowlerHat,						10.0);
	AddItemToLootIndex(loot_Civilian,		item_TopHat,						20.0);
	AddItemToLootIndex(loot_Civilian,		item_Ammo9mmFMJ,					10.0);
	AddItemToLootIndex(loot_Civilian,		item_AmmoBuck,						9.0);
	AddItemToLootIndex(loot_Civilian,		item_AmmoHomeBuck,					25.0);
	AddItemToLootIndex(loot_Civilian,		item_Ammo357,						5.0);
	AddItemToLootIndex(loot_Civilian,		item_Ammo308,						5.0);
	AddItemToLootIndex(loot_Civilian,		item_PlantPot,						50.0);
	AddItemToLootIndex(loot_Civilian,		item_HerpDerp,						10.0);
	AddItemToLootIndex(loot_Civilian,		item_CanDrink,						100.0);
	AddItemToLootIndex(loot_Civilian,		item_HockeyMask,					30.0);
	AddItemToLootIndex(loot_Civilian,		item_Pumpkin,						10.0);
	AddItemToLootIndex(loot_Civilian,		item_Daypack,						38.0);
	AddItemToLootIndex(loot_Civilian,		item_MediumBag,						14.0);
	AddItemToLootIndex(loot_Civilian,		item_Rucksack,						1.0);
	AddItemToLootIndex(loot_Civilian,		item_Note,							45.0);
	AddItemToLootIndex(loot_Civilian,		item_HeartShapedBox,				5.0);

	// loot_Industrial
	AddItemToLootIndex(loot_Industrial,		item_Chainsaw,						1.0);
	AddItemToLootIndex(loot_Industrial,		item_MobilePhone,					40.0);
	AddItemToLootIndex(loot_Industrial,		item_Bandage,						10.0);
	AddItemToLootIndex(loot_Industrial,		item_AntiSepBandage,				5.0);
	AddItemToLootIndex(loot_Industrial,		item_GasMask,						50.0);
	AddItemToLootIndex(loot_Industrial,		item_Timer,							20.0);
	AddItemToLootIndex(loot_Industrial,		item_Battery,						40.0);
	AddItemToLootIndex(loot_Industrial,		item_Fusebox,						30.0);
	AddItemToLootIndex(loot_Industrial,		item_Wheel,							30.0);
	AddItemToLootIndex(loot_Industrial,		item_MotionSense,					20.0);
	AddItemToLootIndex(loot_Industrial,		item_Accelerometer,					20.0);
	AddItemToLootIndex(loot_Industrial,		item_GasCan,						30.0);
	AddItemToLootIndex(loot_Industrial,		item_MediumBox,						7.0);
	AddItemToLootIndex(loot_Industrial,		item_SmallBox,						10.0);
	AddItemToLootIndex(loot_Industrial,		item_LargeBox,						3.0);
	AddItemToLootIndex(loot_Industrial,		item_Headlight,						40.0);
	AddItemToLootIndex(loot_Industrial,		item_MetPanel,						3.0);
	AddItemToLootIndex(loot_Industrial,		item_MetalGate,						4.0);
	AddItemToLootIndex(loot_Industrial,		item_CrateDoor,						4.0);
	AddItemToLootIndex(loot_Industrial,		item_CorPanel,						3.0);
	AddItemToLootIndex(loot_Industrial,		item_ShipDoor,						1.0);
	AddItemToLootIndex(loot_Industrial,		item_MetalStand,					2.0);
	AddItemToLootIndex(loot_Industrial,		item_WoodPanel,						2.0);
	AddItemToLootIndex(loot_Industrial,		item_Keypad,						5.0);
	AddItemToLootIndex(loot_Industrial,		item_AmmoBuck,						6.0);
	AddItemToLootIndex(loot_Industrial,		item_RadioPole,						6.0);
	AddItemToLootIndex(loot_Industrial,		item_Motor,							15.0);
	AddItemToLootIndex(loot_Industrial,		item_Daypack,						28.0);
	AddItemToLootIndex(loot_Industrial,		item_MediumBag,						15.0);
	AddItemToLootIndex(loot_Industrial,		item_Rucksack,						1.0);
	AddItemToLootIndex(loot_Industrial,		item_Note,							34.0);
	AddItemToLootIndex(loot_Industrial,		item_WheelLock,						34.0);

	// loot_Police
	AddItemToLootIndex(loot_Police,			item_M9Pistol,						50.0);
	AddItemToLootIndex(loot_Police,			item_PumpShotgun,					30.0);
	AddItemToLootIndex(loot_Police,			item_SemiAutoRifle,					20.0);
	AddItemToLootIndex(loot_Police,			item_M77RMRifle,					30.0);
	AddItemToLootIndex(loot_Police,			item_Medkit,						10.0);
	AddItemToLootIndex(loot_Police,			item_AntiSepBandage,				20.0);
	AddItemToLootIndex(loot_Police,			item_MobilePhone,					40.0);
	AddItemToLootIndex(loot_Police,			item_HandCuffs,						40.0);
	AddItemToLootIndex(loot_Police,			item_StunGun,						60.0);
	AddItemToLootIndex(loot_Police,			item_GasMask,						70.0);
//	AddItemToLootIndex(loot_Police,			item_Flashlight,					90.0);
	AddItemToLootIndex(loot_Police,			item_Shield,						70.0);
	AddItemToLootIndex(loot_Police,			item_Headlight,						10.0);
	AddItemToLootIndex(loot_Police,			item_CowboyHat,						10.0);
	AddItemToLootIndex(loot_Police,			item_PoliceCap,						80.0);
	AddItemToLootIndex(loot_Police,			item_Ammo9mm,						30.0);
	AddItemToLootIndex(loot_Police,			item_AmmoBuck,						20.0);
	AddItemToLootIndex(loot_Police,			item_Ammo357Tracer,					15.0);
	AddItemToLootIndex(loot_Police,			item_MediumBag,						15.0);
	AddItemToLootIndex(loot_Police,			item_Note,							21.0);

	// loot_Military
	//AddItemToLootIndex(loot_Military,		item_Grenade,						20.0);
	AddItemToLootIndex(loot_Military,		item_M9PistolSD,					20.0);
	AddItemToLootIndex(loot_Military,		item_Spas12,						2.0);
	AddItemToLootIndex(loot_Military,		item_MP5,							5.0);
	AddItemToLootIndex(loot_Military,		item_WASR3Rifle,					4.0);
	AddItemToLootIndex(loot_Military,		item_M16Rifle,						3.0);
	AddItemToLootIndex(loot_Military,		item_SniperRifle,					2.0);
	AddItemToLootIndex(loot_Military,		item_RocketLauncher,				8.0);
	AddItemToLootIndex(loot_Military,		item_Flamer,						5.0);
	AddItemToLootIndex(loot_Military,		item_Minigun,						1.0);
	AddItemToLootIndex(loot_Military,		item_AK47Rifle,						2.0);
	AddItemToLootIndex(loot_Military,		item_M77RMRifle,					0.6);	
	AddItemToLootIndex(loot_Military,		item_Parachute,						30.0);
	AddItemToLootIndex(loot_Military,		item_AntiSepBandage,				20.0);
	AddItemToLootIndex(loot_Military,		item_Explosive,						6.0);
	AddItemToLootIndex(loot_Military,		item_Armour,						10.0);
	AddItemToLootIndex(loot_Military,		item_Shield,						30.0);
	AddItemToLootIndex(loot_Military,		item_Backpack,						10.0);
	AddItemToLootIndex(loot_Military,		item_HelmArmy,						50.0);
	AddItemToLootIndex(loot_Military,		item_Ammo556,						20.0);
	AddItemToLootIndex(loot_Military,		item_Ammo556Tracer,					20.0);
	AddItemToLootIndex(loot_Military,		item_Ammo357,						9.0);
	AddItemToLootIndex(loot_Military,		item_Ammo357Tracer,					9.0);
	AddItemToLootIndex(loot_Military,		item_AmmoRocket,					5.0);
	AddItemToLootIndex(loot_Military,		item_AmmoFlechette,					5.0);
	AddItemToLootIndex(loot_Military,		item_Ammo762,						4.0);
	AddItemToLootIndex(loot_Military,		item_LargeBackpack,					7.0);
	AddItemToLootIndex(loot_Military,		item_Ammo50BMG,						1.1);
	AddItemToLootIndex(loot_Military,		item_Ammo308,						2.2);
	AddItemToLootIndex(loot_Military,		item_Note,							11.0);

	// loot_Medical
	AddItemToLootIndex(loot_Medical,		item_AntiSepBandage,				50.0);
	AddItemToLootIndex(loot_Medical,		item_Medkit,						40.0);
	AddItemToLootIndex(loot_Medical,		item_DoctorBag,						10.0);
	AddItemToLootIndex(loot_Medical,		item_Pills,							90.0);
	AddItemToLootIndex(loot_Medical,		item_AutoInjec,						80.0);
//	AddItemToLootIndex(loot_Medical,		item_Detergent,						10.0);
	AddItemToLootIndex(loot_Medical,		item_Note,							16.0);

	// loot_CarCivilian
	AddItemToLootIndex(loot_CarCivilian,	item_M9Pistol,						50.0);
	AddItemToLootIndex(loot_CarCivilian,	item_DesertEagle,					20.0);
	AddItemToLootIndex(loot_CarCivilian,	item_PumpShotgun,					30.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Sawnoff,						10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Mac10,							10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Tec9,							12.0);
	AddItemToLootIndex(loot_CarCivilian,	item_SemiAutoRifle,					15.0);
	AddItemToLootIndex(loot_CarCivilian,	item_M77RMRifle,					18.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Model70Rifle,					18.0);
	AddItemToLootIndex(loot_CarCivilian,	item_SprayPaint,					50.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Extinguisher,					50.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Camera,						40.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Bandage,						20.0);
	AddItemToLootIndex(loot_CarCivilian,	item_AntiSepBandage,				10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Medkit,						10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_FireworkBox,					10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_FireLighter,					100.0);
//	AddItemToLootIndex(loot_CarCivilian,	item_FishRod,						100.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Wrench,						100.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Crowbar,						100.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Hammer,						90.0);
//	AddItemToLootIndex(loot_CarCivilian,	item_Flashlight,					100.0);
//	AddItemToLootIndex(loot_CarCivilian,	item_LaserPoint,					100.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Screwdriver,					80.0);
	AddItemToLootIndex(loot_CarCivilian,	item_MobilePhone,					40.0);
	AddItemToLootIndex(loot_CarCivilian,	item_HotDog,						100.0);
//	AddItemToLootIndex(loot_CarCivilian,	item_Bucket,						100.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Satchel,						100.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Backpack,						10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Fusebox,						70.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Bottle,						100.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Battery,						60.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Wheel,							20.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Pizza,							10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Burger,						20.0);
	AddItemToLootIndex(loot_CarCivilian,	item_BurgerBox,						20.0);
	AddItemToLootIndex(loot_CarCivilian,	item_BurgerBag,						10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Taco,							20.0);
	AddItemToLootIndex(loot_CarCivilian,	item_GasCan,						30.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Clothes,						90.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Barbecue,						10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Headlight,						80.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Pills,							30.0);
	AddItemToLootIndex(loot_CarCivilian,	item_TentPack,						30.0);
	AddItemToLootIndex(loot_CarCivilian,	item_CowboyHat,						30.0);
	AddItemToLootIndex(loot_CarCivilian,	item_TruckCap,						20.0);
	AddItemToLootIndex(loot_CarCivilian,	item_BoaterHat,						10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_BowlerHat,						10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_TopHat,						10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Ammo9mmFMJ,					10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_AmmoBuck,						6.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Ammo308,						3.0);
	AddItemToLootIndex(loot_CarCivilian,	item_PlantPot,						50.0);
	AddItemToLootIndex(loot_CarCivilian,	item_HerpDerp,						10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_CanDrink,						100.0);
	AddItemToLootIndex(loot_CarCivilian,	item_HockeyMask,					30.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Motor,							10.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Ammo762,						4.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Daypack,						32.0);
	AddItemToLootIndex(loot_CarCivilian,	item_MediumBag,						15.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Rucksack,						3.0);
	AddItemToLootIndex(loot_CarCivilian,	item_Note,							38.0);
	AddItemToLootIndex(loot_CarCivilian,	item_WheelLock,						28.0);

	// loot_CarIndustrial
	AddItemToLootIndex(loot_CarIndustrial,	item_Bandage,						10.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_AntiSepBandage,				5.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Battery,						80.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Fusebox,						100.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Wheel,							30.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Bottle,						100.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Wrench,						100.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Crowbar,						80.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Hammer,						90.0);
//	AddItemToLootIndex(loot_CarIndustrial,	item_Flashlight,					100.0);
//	AddItemToLootIndex(loot_CarIndustrial,	item_LaserPoint,					100.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Screwdriver,					80.0);
//	AddItemToLootIndex(loot_CarIndustrial,	item_Bucket,						100.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Satchel,						80.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_MotionSense,					20.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Accelerometer,					20.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_GasCan,						40.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_MediumBox,						6.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_SmallBox,						10.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_LargeBox,						4.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Headlight,						80.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_MetPanel,						3.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_MetalGate,						3.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_CrateDoor,						4.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_CorPanel,						4.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_ShipDoor,						1.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_RustyDoor,						5.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_MetalStand,					2.0);
//	AddItemToLootIndex(loot_CarIndustrial,	item_RustyMetal,					5.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_WoodPanel,						2.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Keypad,						10.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_TruckCap,						70.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_AmmoBuck,						5.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_CanDrink,						90.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_GasMask,						70.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Motor,							25.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Daypack,						22.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_Note,							32.0);
	AddItemToLootIndex(loot_CarIndustrial,	item_WheelLock,						30.0);

	// loot_CarPolice
	AddItemToLootIndex(loot_CarPolice,		item_M9Pistol,						40.0);
	AddItemToLootIndex(loot_CarPolice,		item_PumpShotgun,					30.0);
	AddItemToLootIndex(loot_CarPolice,		item_Spas12,						8.0);
	AddItemToLootIndex(loot_CarPolice,		item_AntiSepBandage,				20.0);
	AddItemToLootIndex(loot_CarPolice,		item_Battery,						70.0);
	AddItemToLootIndex(loot_CarPolice,		item_Wheel,							10.0);
	AddItemToLootIndex(loot_CarPolice,		item_Wrench,						60.0);
	AddItemToLootIndex(loot_CarPolice,		item_Crowbar,						60.0);
	AddItemToLootIndex(loot_CarPolice,		item_Hammer,						60.0);
	AddItemToLootIndex(loot_CarPolice,		item_Screwdriver,					80.0);
	AddItemToLootIndex(loot_CarPolice,		item_HandCuffs,						70.0);
	AddItemToLootIndex(loot_CarPolice,		item_StunGun,						70.0);
	AddItemToLootIndex(loot_CarPolice,		item_Medkit,						10.0);
//	AddItemToLootIndex(loot_CarPolice,		item_Flashlight,					100.0);
	AddItemToLootIndex(loot_CarPolice,		item_Headlight,						60.0);
	AddItemToLootIndex(loot_CarPolice,		item_PoliceCap,						50.0);
	AddItemToLootIndex(loot_CarPolice,		item_Ammo9mm,						20.0);
	AddItemToLootIndex(loot_CarPolice,		item_AmmoBuck,						10.0);
	AddItemToLootIndex(loot_CarPolice,		item_Ammo357Tracer,					5.0);
	AddItemToLootIndex(loot_CarPolice,		item_MediumBag,						10.0);
	AddItemToLootIndex(loot_CarPolice,		item_Note,							12.0);

	// loot_CarMilitary
	//AddItemToLootIndex(loot_CarMilitary,	item_Grenade,						10.0);
	AddItemToLootIndex(loot_CarMilitary,	item_M9PistolSD,					20.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Spas12,						7.0);
	AddItemToLootIndex(loot_CarMilitary,	item_MP5,							6.0);
	AddItemToLootIndex(loot_CarMilitary,	item_M16Rifle,						3.0);
	AddItemToLootIndex(loot_CarMilitary,	item_SniperRifle,					1.0);
	AddItemToLootIndex(loot_CarMilitary,	item_M77RMRifle,					0.5);	
	AddItemToLootIndex(loot_CarMilitary,	item_Medkit,						20.0);
	AddItemToLootIndex(loot_CarMilitary,	item_AntiSepBandage,				30.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Wheel,							10.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Wrench,						100.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Crowbar,						100.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Hammer,						100.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Screwdriver,					100.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Explosive,						50.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Backpack,						25.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Ammo556,						10.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Ammo556Tracer,					10.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Ammo357,						6.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Ammo357Tracer,					6.0);
	AddItemToLootIndex(loot_CarMilitary,	item_AmmoRocket,					1.0);
	AddItemToLootIndex(loot_CarMilitary,	item_LargeBackpack,					8.0);
	AddItemToLootIndex(loot_CarMilitary,	item_Ammo50BMG,						1.2);
	AddItemToLootIndex(loot_CarMilitary,	item_Ammo308,						1.8);
	AddItemToLootIndex(loot_CarMilitary,	item_Note,							14.0);

	// loot_Survivor
	AddItemToLootIndex(loot_Survivor,		item_Sword,							10.0);
	AddItemToLootIndex(loot_Survivor,		item_M9Pistol,						60.0);
	AddItemToLootIndex(loot_Survivor,		item_Sawnoff,						7.0);
	AddItemToLootIndex(loot_Survivor,		item_Mac10,							4.0);
	AddItemToLootIndex(loot_Survivor,		item_Tec9,							3.0);
	AddItemToLootIndex(loot_Survivor,		item_PumpShotgun,					9.0);
	AddItemToLootIndex(loot_Survivor,		item_SemiAutoRifle,					7.0);
	AddItemToLootIndex(loot_Survivor,		item_M77RMRifle,					9.0);
	AddItemToLootIndex(loot_Survivor,		item_WASR3Rifle,					2.0);
	AddItemToLootIndex(loot_Survivor,		item_Medkit,						40.0);
	AddItemToLootIndex(loot_Survivor,		item_Bandage,						20.0);
	AddItemToLootIndex(loot_Survivor,		item_AntiSepBandage,				15.0);
	AddItemToLootIndex(loot_Survivor,		item_Backpack,						40.0);
	AddItemToLootIndex(loot_Survivor,		item_Wheel,							30.0);
	AddItemToLootIndex(loot_Survivor,		item_Bottle,						40.0);
	AddItemToLootIndex(loot_Survivor,		item_Wrench,						40.0);
	AddItemToLootIndex(loot_Survivor,		item_Crowbar,						50.0);
	AddItemToLootIndex(loot_Survivor,		item_Hammer,						40.0);
	AddItemToLootIndex(loot_Survivor,		item_Screwdriver,					40.0);
	AddItemToLootIndex(loot_Survivor,		item_GasCan,						50.0);
	AddItemToLootIndex(loot_Survivor,		item_Pizza,							10.0);
	AddItemToLootIndex(loot_Survivor,		item_Burger,						10.0);
	AddItemToLootIndex(loot_Survivor,		item_GasMask,						30.0);
	AddItemToLootIndex(loot_Survivor,		item_FireLighter,					70.0);
	AddItemToLootIndex(loot_Survivor,		item_Meat,							9.0);
	AddItemToLootIndex(loot_Survivor,		item_Pills,							60.0);
	AddItemToLootIndex(loot_Survivor,		item_Campfire,						40.0);
	AddItemToLootIndex(loot_Survivor,		item_Ammo556HP,						10.0);
	AddItemToLootIndex(loot_Survivor,		item_Ammo357,						7.0);
	AddItemToLootIndex(loot_Survivor,		item_CanDrink,						90.0);
	AddItemToLootIndex(loot_Survivor,		item_Ammo762,						3.0);
	AddItemToLootIndex(loot_Survivor,		item_AK47Rifle,						0.1);
	AddItemToLootIndex(loot_Survivor,		item_DogsBreath,					0.05);
	AddItemToLootIndex(loot_Survivor,		item_Ammo308,						2.4);
	AddItemToLootIndex(loot_Survivor,		item_LenKnocksRifle,				0.05);
	AddItemToLootIndex(loot_Survivor,		item_Daypack,						28.0);
	AddItemToLootIndex(loot_Survivor,		item_MediumBag,						25.0);
	AddItemToLootIndex(loot_Survivor,		item_Rucksack,						10.0);
	AddItemToLootIndex(loot_Survivor,		item_Note,							1.0);

	AddItemToLootIndex(loot_FoodMedCrate,	item_Medkit,						60.0);
	AddItemToLootIndex(loot_FoodMedCrate,	item_AntiSepBandage,				70.0);
	AddItemToLootIndex(loot_FoodMedCrate,	item_DoctorBag,						40.0);
	AddItemToLootIndex(loot_FoodMedCrate,	item_Backpack,						30.0);
	AddItemToLootIndex(loot_FoodMedCrate,	item_GasCan,						50.0);
	AddItemToLootIndex(loot_FoodMedCrate,	item_FireLighter,					50.0);
	AddItemToLootIndex(loot_FoodMedCrate,	item_Meat,							10.0);
	AddItemToLootIndex(loot_FoodMedCrate,	item_Pills,							40.0);
	AddItemToLootIndex(loot_FoodMedCrate,	item_CanDrink,						80.0);
	AddItemToLootIndex(loot_FoodMedCrate,	item_Burger,						60.0);
	AddItemToLootIndex(loot_FoodMedCrate,	item_Daypack,						45.0);
	AddItemToLootIndex(loot_FoodMedCrate,	item_MediumBag,						28.0);
	AddItemToLootIndex(loot_FoodMedCrate,	item_Rucksack,						5.0);

	AddItemToLootIndex(loot_LowWepCrate,	item_Knife,							30.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_Bat,							40.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_M9Pistol,						50.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_PumpShotgun,					35.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_Sawnoff,						24.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_Mac10,							20.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_M77RMRifle,					10.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_Ammo9mm,						50.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_AmmoBuck,						30.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_Ammo357,						10.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_Ammo9mmFMJ,					40.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_AmmoFlechette,					35.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_AmmoHomeBuck,					40.0);
	AddItemToLootIndex(loot_LowWepCrate,	item_Ammo357Tracer,					15.0);

	AddItemToLootIndex(loot_MilWepCrate,	item_M9Pistol,						40.0, 2);
	AddItemToLootIndex(loot_MilWepCrate,	item_M9PistolSD,					20.0, 2);
	AddItemToLootIndex(loot_MilWepCrate,	item_Spas12,						10.0, 2);
	AddItemToLootIndex(loot_MilWepCrate,	item_MP5,							30.0, 2);
	AddItemToLootIndex(loot_MilWepCrate,	item_M16Rifle,						30.0, 1);
	AddItemToLootIndex(loot_MilWepCrate,	item_SemiAutoRifle,					25.0, 2);
	AddItemToLootIndex(loot_MilWepCrate,	item_SniperRifle,					03.0, 1);
	AddItemToLootIndex(loot_MilWepCrate,	item_RocketLauncher,				10.0, 1);
	AddItemToLootIndex(loot_MilWepCrate,	item_Flamer,						0.05, 1);
	AddItemToLootIndex(loot_MilWepCrate,	item_Minigun,						0.01, 1);
	AddItemToLootIndex(loot_MilWepCrate,	item_AK47Rifle,						10.0, 1);
	AddItemToLootIndex(loot_MilWepCrate,	item_M77RMRifle,					08.0, 1);
	AddItemToLootIndex(loot_MilWepCrate,	item_Ammo556,						24.0, 2);
	AddItemToLootIndex(loot_MilWepCrate,	item_Ammo556Tracer,					10.0, 2);
	AddItemToLootIndex(loot_MilWepCrate,	item_Ammo357,						22.0, 3);
	AddItemToLootIndex(loot_MilWepCrate,	item_Ammo357Tracer,					10.0, 2);
	AddItemToLootIndex(loot_MilWepCrate,	item_AmmoRocket,					10.0, 1);
	AddItemToLootIndex(loot_MilWepCrate,	item_AmmoFlechette,					26.0, 3);
	AddItemToLootIndex(loot_MilWepCrate,	item_Ammo762,						14.0, 2);
	AddItemToLootIndex(loot_MilWepCrate,	item_Ammo50BMG,						0.05, 2);
	AddItemToLootIndex(loot_MilWepCrate,	item_Ammo308,						12.5, 3);

	AddItemToLootIndex(loot_IndustCrate,	item_Chainsaw,						10.0);
	AddItemToLootIndex(loot_IndustCrate,	item_Battery,						30.0);
	AddItemToLootIndex(loot_IndustCrate,	item_Fusebox,						30.0);
	AddItemToLootIndex(loot_IndustCrate,	item_MotionSense,					30.0);
	AddItemToLootIndex(loot_IndustCrate,	item_Accelerometer,					40.0);
	AddItemToLootIndex(loot_IndustCrate,	item_MediumBox,						40.0);
	AddItemToLootIndex(loot_IndustCrate,	item_SmallBox,						50.0);
	AddItemToLootIndex(loot_IndustCrate,	item_LargeBox,						30.0);
	AddItemToLootIndex(loot_IndustCrate,	item_MetPanel,						30.0);
	AddItemToLootIndex(loot_IndustCrate,	item_MetalGate,						30.0);
	AddItemToLootIndex(loot_IndustCrate,	item_CrateDoor,						40.0);
	AddItemToLootIndex(loot_IndustCrate,	item_CorPanel,						20.0);
	AddItemToLootIndex(loot_IndustCrate,	item_ShipDoor,						10.0);
	AddItemToLootIndex(loot_IndustCrate,	item_RustyDoor,						35.0);
	AddItemToLootIndex(loot_IndustCrate,	item_MetalStand,					20.0);
//	AddItemToLootIndex(loot_IndustCrate,	item_RustyMetal,					10.0);
	AddItemToLootIndex(loot_IndustCrate,	item_WoodPanel,						20.0);
	AddItemToLootIndex(loot_IndustCrate,	item_Keypad,						10.0);
	AddItemToLootIndex(loot_IndustCrate,	item_Motor,							25.0);

	AddItemToLootIndex(loot_OrdnanceCrate,	item_Explosive,						10.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_TntTimebomb,					5.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_TntTripMine,					8.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_TntProxMine,					8.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_TntPhoneBomb,					5.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_IedBomb,						12.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_IedTimebomb,					4.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_IedTripMine,					11.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_IedProxMine,					11.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_IedPhoneBomb,					7.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_Fluctuator,					14.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_EmpTimebomb,					9.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_EmpTripMine,					12.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_EmpProxMine,					12.0);
	AddItemToLootIndex(loot_OrdnanceCrate,	item_EmpPhoneBomb,					9.0);
}

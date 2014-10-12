# Mock-up script to test ideas for weighted selection from list
import random


class loot:
	def __init__(self, itemid, weight):
		self.itemid = itemid
		self.weight = weight

	def __str__(self):
		return "%s (%.1f)"%(self.itemid, self.weight)

def main():
	print("start")

	# populate a mock list
	list = [
		loot("item_GolfClub",						50.0),
		loot("item_Baton",							40.0),
		loot("item_Knife",							80.0),
		loot("item_Bat",							70.0),
		loot("item_Spade",							70.0),
		loot("item_Flowers",						40.0),
		loot("item_WalkingCane",					70.0),
		loot("item_M9Pistol",						50.0),
		loot("item_DesertEagle",					10.0),
		loot("item_PumpShotgun",					30.0),
		loot("item_Sawnoff",						20.0),
		loot("item_Mac10",							5.0),
		loot("item_Tec9",							4.0),
		loot("item_M77RMRifle",					21.4),
		loot("item_Model70Rifle",					21.4),
		loot("item_SprayPaint",					40.0),
		loot("item_Extinguisher",					60.0),
		loot("item_Camera",						60.0),
		loot("item_Key",							50.0),
		loot("item_Medkit",						10.0),
		loot("item_FireworkBox",					10.0),
		loot("item_FireLighter",					100.0),
		loot("item_Bottle",						100.0),
		loot("item_Sign",							40.0),
		loot("item_Bandage",						20.0),
		loot("item_FishRod",						100.0),
		loot("item_Wrench",						100.0),
		loot("item_Crowbar",						100.0),
		loot("item_Hammer",						100.0),
		loot("item_Flashlight",					100.0),
		loot("item_LaserPoint",					100.0),
		loot("item_Screwdriver",					100.0),
		loot("item_MobilePhone",					40.0),
		loot("item_Rake",							90.0),
		loot("item_HotDog",						100.0),
		loot("item_EasterEgg",						1.0),
		loot("item_Cane",							80.0),
		loot("item_Bucket",						100.0),
		loot("item_Flag",							100.0),
		loot("item_Satchel",						100.0),
		loot("item_Pizza",							10.0),
		loot("item_Burger",						20.0),
		loot("item_BurgerBox",						20.0),
		loot("item_BurgerBag",						10.0),
		loot("item_Taco",							20.0),
		loot("item_Clothes",						100.0),
		loot("item_Barbecue",						1.0),
		loot("item_Pills",							40.0),
		loot("item_Detergent",						50.0),
		loot("item_Dice",							20.0),
		loot("item_TentPack",						20.0),
		loot("item_CowboyHat",						20.0),
		loot("item_TruckCap",						20.0),
		loot("item_BoaterHat",						10.0),
		loot("item_BowlerHat",						10.0),
		loot("item_TopHat",						20.0),
		loot("item_Ammo9mmFMJ",					10.0),
		loot("item_AmmoBuck",						9.0),
		loot("item_AmmoHomeBuck",					25.0),
		loot("item_Ammo357",						5.0),
		loot("item_Ammo308",						5.0),
		loot("item_PlantPot",						50.0),
		loot("item_HerpDerp",						10.0),
		loot("item_CanDrink",						100.0),
		loot("item_HockeyMask",					30.0),
		loot("item_Pumpkin",						10.0),
		loot("item_Daypack",						38.0),
		loot("item_MediumBag",						24.0),
		loot("item_Rucksack",						5.0)
	]

	list = sorted(list, key=lambda loot: loot.weight)
	cumw = [list[0].weight]

	print("list size ", len(list), ", top itemid: ", list[0])

	results = []

	i = 0
	while i < 20:
		results.append(selectfrom1(list))
		i+=1

	results = sorted(results, key=lambda loot: loot.weight, reverse=True)

	for i in results:
		print(i.weight,":",i.itemid);

	print("results size ", len(results), "top: ", results[0])

def selectfrom1(list):

	idx = 0
	templist = []
	cell = 0
	lootid = 0

	# Generate a sample list to pick from
	# Sample list consists of 
	for i in list:
		if random.uniform(0.0, 100.0) < i.weight:
			templist.append(i)
			idx += 1

	cell = random.randrange(idx)

	return templist[cell]

def selectfrom2(list):
	num = 0.0
	for i in list:

		num = random.uniform(0.0, 100.0)

		if num < i.weight:
			return i

def selectfrom3(list):

	i = 0
	maxindex = 0
	lootindexcell = 0

	while i < len(list):
		num = random.uniform(0.0, 100.0)

		if list[i].weight < num:
			maxindex = i
			break

		i += 1 

	if maxindex == 0:
		return 0

	return list[random.randrange(maxindex)]

main()

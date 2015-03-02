# Mock-up script to test ideas for weighted selection from list
import random


class loot:
	def __init__(self, itemid, weight, limit = 3):
		self.itemid = itemid
		self.weight = weight
		self.limit = limit

	def __str__(self):
		return "%s (%.1f)"%(self.itemid, self.weight)

def main():
	print("start")

	# populate a mock list
	list = [
		loot("item_M9Pistol",						40.0, 2),
		loot("item_M9PistolSD",						20.0, 2),
		loot("item_Spas12",							10.0, 2),
		loot("item_MP5",							30.0, 2),
		loot("item_M16Rifle",						30.0, 1),
		loot("item_SemiAutoRifle",					25.0, 2),
		loot("item_SniperRifle",					03.0, 1),
		loot("item_RocketLauncher",					10.0, 1),
		loot("item_Flamer",							0.05, 1),
		loot("item_Minigun",						0.01, 1),
		loot("item_AK47Rifle",						10.0, 1),
		loot("item_M77RMRifle",						08.0, 1),
		loot("item_Ammo556",						24.0, 2),
		loot("item_Ammo556Tracer",					10.0, 2),
		loot("item_Ammo357",						22.0, 3),
		loot("item_Ammo357Tracer",					10.0, 2),
		loot("item_AmmoRocket",						10.0, 1),
		loot("item_AmmoFlechette",					26.0, 3),
		loot("item_Ammo762",						14.0, 2),
		loot("item_Ammo50BMG",						0.05, 2),
		loot("item_Ammo308",						12.5, 3)
	]

	list = sorted(list, key=lambda loot: loot.weight)

	print("list size ", len(list), ", top itemid: ", list[0])

	results = []

	i = 0
	while i < 20:
		results.append(selectfrom(list))
		i+=1

	results = sorted(results, key=lambda loot: loot.weight, reverse=True)

	print("results size ", len(results), "top: ", results[0])

	for i in results:
		print(i.weight,":",i.itemid);

def selectfrom(list):

	cell = random.randrange(len(list))

	num = random.uniform(0.0, 100.0)

	if num < list[cell].weight:
		return list[cell]


main()

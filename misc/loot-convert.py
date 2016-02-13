import sys
import io
import re


re_object = re.compile(r'CreateObject\(([0-9]*),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+)\);')
re_lootsp = re.compile(r'[ \t]*CreateStaticLootSpawn\(([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*(loot_[a-zA-Z]*),\s*([\-\+]?[0-9]*(?:\.[0-9]+)?)(?:,\s([0-9]))?(?:,\s([0-9]))?(?:,\s([0-9]))?\);')
ltd = {
	"330":	("loot_Civilian",	30, 6),
	"341":	("loot_Industrial",	35, 5),
	"346":	("loot_Police",		40, 4),
	"356":	("loot_Military",	20, 3),
	"1240":	("loot_Medical",	35, 2),
	"1247":	("loot_Survivor",	10, 1) }

class LootSpawn():

	# CreateStaticLootSpawn(Float:x, Float:y, Float:z, lootindex, Float:weight = 100.0, size = -1, worldid = 0, interiorid = 0)

	def __init__(self, x, y, z, lootindex, weight, size, worldid, interiorid, idx):
		self.x = x
		self.y = y
		self.z = z
		self.lootindex = lootindex
		self.weight = weight
		# optionals: (technically weight is optional but is never used that way)
		self.size = (size if type(size) is int else -1)
		self.worldid = (worldid if type(worldid) is int else 0)
		self.interiorid = (interiorid if type(interiorid) is int else 0)
		self.idx = idx
		#print(self.x, self.y, self.z, self.lootindex, self.weight, self.size, self.worldid, self.interiorid)


def obj_to_loot():

	print("Converting editor objects to loot spawn data.")

	obj = []

	with io.open("input", "r") as f:
		for l in f:
			m = re_object.match(l)

			if m:
				obj.append(LootSpawn(
					float(m.group(2)),	# x
					float(m.group(3)),	# y
					float(m.group(4)),	# z
					ltd[m.group(1)][0],	# lootindex
					ltd[m.group(1)][1],	# weight
					3,					# size
					0,					# worldid
					0,					# interiorid
					ltd[m.group(1)][2]))# sort idx

	obj.sort(key=lambda x: x.idx, reverse=True)

	with io.open("output", "w") as f:
		for s in obj:
			f.write("CreateStaticLootSpawn(%f, %f, %f, %s, %f, 3);\n"%(
				s.x,
				s.y,
				s.z,
				s.lootindex,
				s.weight))


def loot_to_obj():

	print("Converting loot spawn data to objects for editing.")

	loot = []

	with io.open("input", "r") as f:
		for l in f:
			m = re_lootsp.match(l)

			if m:
				loot.append(LootSpawn(
					float(m.group(1)),	# x
					float(m.group(2)),	# y
					float(m.group(3)),	# z
					m.group(4),			# lootindex
					float(m.group(5)),	# weight
					m.group(6),			# size
					m.group(7),			# worldid
					m.group(8),			# interiorid
					0))

	with io.open("output", "w") as f:
		for s in loot:
			model = 0

			for m in ltd:
				if ltd[m][0] == s.lootindex:
					model = int(m)

			f.write("CreateObject(%d, %f, %f, %f, 0.0, 0.0, 0.0);\n"%(
				model,
				s.x,
				s.y,
				s.z))


def main():

	if sys.argv[1] == "otol":
		obj_to_loot()

	elif sys.argv[1] == "ltoo":
		loot_to_obj()

	else:
		print("arguments: 'otol': object to loot. 'ltoo' loot to object.")

if __name__ == '__main__':
	main()

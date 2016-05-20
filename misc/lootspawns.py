# returns a list of loot spawns in SS
import sys
import re
import io


regex = re.compile(r'[ \t]*CreateStaticLootSpawn\(([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*(loot_[a-zA-Z]*),\s*([\-\+]?[0-9]*(?:\.[0-9]+)?)(?:,\s([0-9]))?(?:,\s([0-9]))?(?:,\s([0-9]))?\);')


class LootSpawn():

	# CreateStaticLootSpawn(Float:x, Float:y, Float:z, lootindex, Float:weight = 100.0, size = -1, worldid = 0, interiorid = 0)

	def __init__(self, x, y, z, lootindex, weight, size, worldid, interiorid):
		self.x = x
		self.y = y
		self.z = z
		self.lootindex = lootindex
		self.weight = weight
		# optionals: (technically weight is optional but is never used that way)
		self.size = (size if type(size) is int else -1)
		self.worldid = (worldid if type(worldid) is int else 0)
		self.interiorid = (interiorid if type(interiorid) is int else 0)
		#print(self.x, self.y, self.z, self.lootindex, self.weight, self.size, self.worldid, self.interiorid)


def load(filename):

	loot = []

	with io.open(filename) as f:
		for l in f:
			r = regex.match(l)

			if r:
				loot.append(LootSpawn(
					float(r.group(1)),	# x
					float(r.group(2)),	# y
					float(r.group(3)),	# z
					r.group(4),			# lootindex
					float(r.group(5)),	# weight
					r.group(6),			# size
					r.group(7),			# worldid
					r.group(8)))		# interiorid

	return loot


if __name__ == '__main__':
	if len(sys.argv) != 2:
		print("Parameters: filename to scan for loot spawns")

	else:
		loot = load(sys.argv[1])

		for s in loot:
			print(s.x, s.y, s.z, s.lootindex, s.weight, s.size, s.worldid, s.interiorid)

import io
import re
from PIL import Image, ImageDraw, ImageColor


p = re.compile(r'[ \t]*CreateStaticLootSpawn\(([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*(loot_[a-zA-Z]*),\s*([\-\+]?[0-9]*(?:\.[0-9]+)?)(?:,\s([0-9]))?(?:,\s([0-9]))?(?:,\s([0-9]))?\);')
DOT_RADIUS = 6


colours = {
	"loot_Civilian":		(0, 100, 0),
	"loot_Industrial":		(50, 50, 50),
	"loot_Police":			(0, 20, 100),
	"loot_Military":		(255, 0, 0),
	"loot_Medical":			(100, 100, 255),
	"loot_CarCivilian":		(0, 100, 0),
	"loot_CarIndustrial":	(50, 50, 50),
	"loot_CarPolice":		(0, 20, 100),
	"loot_CarMilitary":		(255, 0, 0),
	"loot_Survivor":		(60, 0, 100)
}

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


def load_loot(filename):

	loot = []

	with io.open(filename) as f:
		for l in f:
			r = p.match(l)

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


def draw_loot(loot):

	im = Image.open("gtasa-blank-1.0.jpg")
	draw = ImageDraw.Draw(im)
	x = 0.0
	y = 0.0

	for s in loot:
		x = s.x + 3000
		y = 6000 - (s.y + 3000)
		draw.ellipse([x - DOT_RADIUS, y - DOT_RADIUS, x + DOT_RADIUS, y + DOT_RADIUS], outline=(255, 255, 255), fill=colours[s.lootindex])

	del draw

	# write to stdout
	im.save("gtasa-blank-1.0-ss-loot.jpg")


def main():

	loot = []

	loot += load_loot("../gamemodes/SS/World/Zones/LS.pwn")
	loot += load_loot("../gamemodes/SS/World/Zones/SF.pwn")
	loot += load_loot("../gamemodes/SS/World/Zones/LV.pwn")
	loot += load_loot("../gamemodes/SS/World/Zones/RC.pwn")
	loot += load_loot("../gamemodes/SS/World/Zones/FC.pwn")
	loot += load_loot("../gamemodes/SS/World/Zones/BC.pwn")
	loot += load_loot("../gamemodes/SS/World/Zones/TR.pwn")

	print(len(loot))

	draw_loot(loot)


if __name__ == '__main__':
	main()

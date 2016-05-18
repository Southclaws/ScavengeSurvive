import os
import copy
import io
import re
import itertools as IT
from PIL import Image, ImageDraw, ImageColor, ImageFont
import heatmap
from region import regions


font = ImageFont.truetype("arial.ttf", 32)
p = re.compile(r'[ \t]*CreateStaticLootSpawn\(([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*(loot_[a-zA-Z]*),\s*([\-\+]?[0-9]*(?:\.[0-9]+)?)(?:,\s([0-9]))?(?:,\s([0-9]))?(?:,\s([0-9]))?\);')
v = re.compile(r'Vehicle\(([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*.*\)')
o = re.compile(r'CreateObject\(([0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+)\);')
DOT_RADIUS = 6
BOX_RADIUS = 2


def area_of_polygon(x, y):
	"""Calculates the signed area of an arbitrary polygon given its verticies
	http://stackoverflow.com/a/4682656/190597 (Joe Kington)
	http://softsurfer.com/Archive/algorithm_0101/algorithm_0101.htm#2D%20Polygons
	"""
	area = 0.0
	for i in range(-1, len(x) - 1):
		area += x[i] * (y[i + 1] - y[i - 1])
	return area / 2.0


def centroid_of_polygon(points):
	"""
	http://stackoverflow.com/a/14115494/190597 (mgamba)
	"""
	area = area_of_polygon(*zip(*points))
	result_x = 0
	result_y = 0
	N = len(points)
	points = IT.cycle(points)
	x1, y1 = next(points)
	for i in range(N):
		x0, y0 = x1, y1
		x1, y1 = next(points)
		cross = (x0 * y1) - (x1 * y0)
		result_x += (x0 + x1) * cross
		result_y += (y0 + y1) * cross
	result_x /= (area * 6.0)
	result_y /= (area * 6.0)
	return (result_x, result_y)


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

class Vehicle():

	def __init__(self, x, y, z):
		self.x = x
		self.y = y
		self.z = z

class Object():

	def __init__(self, x, y, z):
		self.x = x
		self.y = y
		self.z = z


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


def load_vehicles(directory):

	# Vehicle(-130.138595, 2244.483398, 31.974399, 349.191802)

	vehicles = []

	for fn in os.listdir(directory):
		if os.path.isfile(directory + fn):
			with io.open(directory + fn) as f:
				for l in f:
					r = v.match(l)

					if r:
						vehicles.append(Vehicle(
							float(r.group(1)),	# x
							float(r.group(2)),	# y
							float(r.group(3))))	# z

	return vehicles


def load_obj(directory):

	objs = []

	for root, dirs, files in os.walk(directory):
		for fn in files:
			if os.path.splitext(fn)[1] == ".map" and "_TESTING" not in root:
				with io.open(os.path.join(root, fn)) as f:
					for l in f:
						r = o.match(l)

						if r:
							objs.append(Object(
								float(r.group(2)),	# x
								float(r.group(3)),	# y
								float(r.group(4))))	# z

	return objs



def draw_loot(im, draw, loot):

	print(len(loot), "loot spawns being drawn")

	x = 0.0
	y = 0.0

	for s in loot:
		x = s.x + 3000
		y = 6000 - (s.y + 3000)
		draw.ellipse([x - DOT_RADIUS, y - DOT_RADIUS, x + DOT_RADIUS, y + DOT_RADIUS], outline=(255, 255, 255), fill=colours[s.lootindex])


def draw_regions(im, draw):

	print(len(regions), "regions spawns being drawn")

	for key, value in regions.items():
		temp_region = []

		# perform the map>image translation and store temporarily
		for i in value:
			temp_region.append((i[0] + 3000, 6000 - (i[1] + 3000)))

		draw.polygon(temp_region, outline=(255, 255, 255))
		cent = centroid_of_polygon(temp_region)
		draw.text((cent[0] + 2, cent[1] + 2), key, fill=(0, 0, 0), font=font)
		draw.text(cent, key, fill=(255, 255, 255), font=font)



def draw_vehicles(im, draw, vehicles):

	print(len(vehicles), "vehicle spawns being drawn")

	x = 0.0
	y = 0.0

	for s in vehicles:
		x = s.x + 3000
		y = 6000 - (s.y + 3000)
		draw.rectangle([x - BOX_RADIUS, y - BOX_RADIUS, x + BOX_RADIUS, y + BOX_RADIUS], outline=(0, 0, 0), fill=(80, 80, 80))


def draw_obj(im, draw, objs):

	print(len(objs), "objs spawns being drawn")

	x = 0.0
	y = 0.0

	for s in objs:
		x = s.x + 3000
		y = 6000 - (s.y + 3000)
		draw.ellipse([x - DOT_RADIUS, y - DOT_RADIUS, x + DOT_RADIUS, y + DOT_RADIUS], outline=(255, 255, 255), fill=(0, 0, 0))



def generate_loot_heatmap(im, draw, loot):

	points = []

	for l in loot:
		points.append([int(l.x + 3000), int(l.y + 3000)])

	hm = heatmap.Heatmap(libpath="C:\\Python34\\Lib\\site-packages\\heatmap\\cHeatmap-x86.dll")
	hmimg = hm.heatmap(
		points,
		dotsize=150,
		size=(6000, 6000),
		scheme='classic',
		area=((0, 0), (6000, 6000)))

	im.paste(hmimg, mask=hmimg)
	im.save("gtasa-blank-1.0-ss-map-heat-loot.jpg")


def generate_vehicle_heatmap(im, draw, vehicles):

	points = []

	for l in vehicles:
		points.append([int(l.x + 3000), int(l.y + 3000)])

	hm = heatmap.Heatmap(libpath="C:\\Python34\\Lib\\site-packages\\heatmap\\cHeatmap-x86.dll")
	hmimg = hm.heatmap(
		points,
		dotsize=300,
		size=(6000, 6000),
		scheme='classic',
		area=((0, 0), (6000, 6000)))

	im.paste(hmimg, mask=hmimg)
	im.save("gtasa-blank-1.0-ss-map-heat-vehicle.jpg")


def generate_obj_heatmap(im, draw, objs):

	points = []

	for l in objs:
		points.append([int(l.x + 3000), int(l.y + 3000)])

	hm = heatmap.Heatmap(libpath="C:\\Python34\\Lib\\site-packages\\heatmap\\cHeatmap-x86.dll")
	hmimg = hm.heatmap(
		points,
		dotsize=150,
		size=(6000, 6000),
		scheme='classic',
		area=((0, 0), (6000, 6000)))

	im.paste(hmimg, mask=hmimg)
	im.save("gtasa-blank-1.0-ss-map-heat-objs.jpg")


def main():

	loot = []
	vehicles = []
	objs = []

	loot += load_loot("../gamemodes/sss/world/zones/ls.pwn")
	loot += load_loot("../gamemodes/sss/world/zones/sf.pwn")
	loot += load_loot("../gamemodes/sss/world/zones/lv.pwn")
	loot += load_loot("../gamemodes/sss/world/zones/rc.pwn")
	loot += load_loot("../gamemodes/sss/world/zones/fc.pwn")
	loot += load_loot("../gamemodes/sss/world/zones/bc.pwn")
	loot += load_loot("../gamemodes/sss/world/zones/tr.pwn")

	vehicles += load_vehicles("../scriptfiles/Vehicles/")

	objs = load_obj("../scriptfiles/Maps/")

	# Initialise PIL stuff
	mapimg = Image.open("gtasa-blank-1.0.jpg")
	draw = ImageDraw.Draw(mapimg)

	# Generate the main map with region lines, loot spawns and vehicles
	draw_loot(mapimg, draw, loot)
	draw_vehicles(mapimg, draw, vehicles)
	draw_regions(mapimg, draw)

	mapimg.save("gtasa-blank-1.0-ss-map.jpg")

	# generate heatmaps for loot and vehicles on separate images
	generate_loot_heatmap(copy.copy(mapimg), draw, loot)

	generate_vehicle_heatmap(copy.copy(mapimg), draw, vehicles)

	generate_obj_heatmap(copy.copy(mapimg), draw, objs)


if __name__ == '__main__':
	main()

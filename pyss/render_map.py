import os
import copy
import io
import re
from PIL import Image, ImageDraw, ImageColor, ImageFont
import heatmap

import region
import lootspawns
import vehiclespawns
import objects


font = ImageFont.truetype("arial.ttf", 32)
DOT_RADIUS = 6
BOX_RADIUS = 2


def draw_loot(im, draw, loot):

	print(len(loot), "loot spawns being drawn")

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

	x = 0.0
	y = 0.0

	for s in loot:
		x = s.x + 3000
		y = 6000 - (s.y + 3000)
		draw.ellipse([x - DOT_RADIUS, y - DOT_RADIUS, x + DOT_RADIUS, y + DOT_RADIUS], outline=(255, 255, 255), fill=colours[s.lootindex])


def draw_regions(im, draw):

	print(len(region.regions), "regions spawns being drawn")

	for key, value in region.regions.items():
		temp_region = []

		# perform the map>image translation and store temporarily
		for i in value:
			temp_region.append((i[0] + 3000, 6000 - (i[1] + 3000)))

		draw.polygon(temp_region, outline=(255, 255, 255))
		cent = region.center(temp_region)
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

	loot += lootspawns.load("../gamemodes/sss/world/zones/ls.pwn")
	loot += lootspawns.load("../gamemodes/sss/world/zones/sf.pwn")
	loot += lootspawns.load("../gamemodes/sss/world/zones/lv.pwn")
	loot += lootspawns.load("../gamemodes/sss/world/zones/rc.pwn")
	loot += lootspawns.load("../gamemodes/sss/world/zones/fc.pwn")
	loot += lootspawns.load("../gamemodes/sss/world/zones/bc.pwn")
	loot += lootspawns.load("../gamemodes/sss/world/zones/tr.pwn")

	vehicles += vehiclespawns.load("../scriptfiles/vspawn/")

	objs = objects.load("../scriptfiles/Maps/")

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

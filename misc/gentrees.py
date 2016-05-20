# platform imports
import os
import io
import array
from PIL import Image, ImageDraw, ImageColor, ImageFont
import random

# ss script utilities
import region
import mapandreas
import bitmapdata


SPAWN_CHANCE_PER_SQM = 0.1 # chance to spawn a tree per sq metre
SCRIPTFILES_PATH = "../scriptfiles/"
TXWORKSPACE_PATH = "txmap/"
MAPSDATA_PATH = "Maps/"

HMAP_PATH = SCRIPTFILES_PATH + "SAfull.hmap"
BMP_PATH = SCRIPTFILES_PATH + TXWORKSPACE_PATH + "tx.bmp"


obj_arr_E_ROADS = [18862, 647, 692, 759, 760, 762, 800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827]
obj_arr_E_SHRUB_S = [647, 692, 759, 760, 762, 800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827]
obj_arr_E_SHRUB_C = [654, 655, 656, 657, 658, 659, 660, 661]
obj_arr_E_SHRUB_L = [647, 692, 759, 760, 762, 800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827]
obj_arr_E_SHRUB_D = [647, 692, 759, 760, 762, 800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827]


def gen_stuff():

	print("Generating trees...")

	stuff = []
	z = 0.0

	for x in range (-3000, 3000):

		for y in range (-3000, 3000):

			if (100 * random.random()) > SPAWN_CHANCE_PER_SQM:
				continue

			c = bitmapdata.colour_at(x, y)

			if c == None:
				continue

			# darkforest	:96
			# lightforest	:128
			# desert		:160
			# grassplanes	:192

			if c == (0, 96, 0):
				z = mapandreas.get_z(x, y) - 0.5
				stuff.append(("darkforest", x, y, z))

			elif c == (0, 128, 0):
				z = mapandreas.get_z(x, y) - 0.5
				stuff.append(("lightforest", x, y, z))

			elif c == (0, 160, 0):
				z = mapandreas.get_z(x, y) - 0.5
				stuff.append(("desert", x, y, z))

			elif c == (0, 192, 0):
				z = mapandreas.get_z(x, y) - 0.5
				stuff.append(("grassplanes", x, y, z))

			# ... fill in colour codes for species here

	print("Generating completed", len(stuff), "Trees generated.")

	return stuff


def save_stuff(stuff):

	files = ["BC", "FC", "LS", "LV", "SF", "RC", "TR"]
	count = 0

	for name in files:
		count = 0
		with io.open(SCRIPTFILES_PATH + MAPSDATA_PATH + name + "/trees.tpl", "w") as f:

			for i in stuff:
				if region.is_point_in(i[1], i[2], name):
					f.write("CreateTree(%s, %f, %f, %f);\n"%(i[0], i[1], i[2], i[3]))
					count += 1

		print("Saved", count, "trees for", name)

	# clear up the leftovers and dump them in GEN, should be empty really
	with io.open(SCRIPTFILES_PATH + MAPSDATA_PATH + "GEN/trees.tpl", "w") as f:
		for i in stuff:
			region_id = 0
			for name in files:
				if region.is_point_in(i[1], i[2], name):
					region_id = 1
					break

			if region_id == 0:
				f.write("CreateTree(%s, %f, %f, %f);\n"%(i[0], i[1], i[2], i[3]))
				count += 1


def draw_stuff(stuff):

	im = Image.open("gtasa-blank-1.0.jpg")
	draw = ImageDraw.Draw(im)

	for i in stuff:
		c = (0, 0, 0)

		if i[0] == "darkforest":
			c = (0, 96, 0)

		elif i[0] == "lightforest":
			c = (0, 128, 0)

		elif i[0] == "desert":
			c = (0, 160, 0)

		elif i[0] == "grassplanes":
			c = (0, 192, 0)

		draw.ellipse([int(i[1] + 3000) - 8, int(6000 - (i[2] + 3000)) - 8, int(i[1] + 3000) + 8, int(6000 - (i[2] + 3000)) + 8], outline=(255, 255, 255), fill=c)

	im.save("gtasa-blank-1.0-ss-map-trees.jpg")


def main():
	
	mapandreas.load_heightmap(HMAP_PATH)

	bitmapdata.load_bitmap(BMP_PATH)

	stuff = gen_stuff()

	draw_stuff(stuff)

	save_stuff(stuff)


if __name__ == '__main__':
	main()

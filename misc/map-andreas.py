import os
import io
import array
from PIL import Image
import random


HMAP_PATH = "..\\scriptfiles\\SAfull.hmap"

height_data = array.array('H')
map_data = []

obj_arr_E_ROADS = [18862, 647, 692, 759, 760, 762, 800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827]
obj_arr_E_SHRUB_S = [647, 692, 759, 760, 762, 800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827]
obj_arr_E_SHRUB_C = [654, 655, 656, 657, 658, 659, 660, 661]
obj_arr_E_SHRUB_L = [647, 692, 759, 760, 762, 800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827]
obj_arr_E_SHRUB_D = [647, 692, 759, 760, 762, 800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827]



def get_z(x, y):

	# check for a co-ord outside the map
	if x < -3000.0 or x > 3000.0 or y > 3000.0 or y < -3000.0:
		return 0.0

	# get row/col on 6000x6000 grid
	iGridX = (int(x)) + 3000
	iGridY = ((int(y)) - 3000) * -1
	iDataPos = (iGridY * 6000) + iGridX # for every y, increment by the number of cols, add the col index.

	return height_data[iDataPos] / 100.0 # the data is a float stored as ushort * 100


def load_hmap():

	print("Loading heightmap...")

	with io.open(HMAP_PATH, "rb") as f:

		while True:

			try:
				height_data.fromfile(f, 1)

			except EOFError:
				print("Reached end of file")
				break

	print("Loaded heightmap.")


def load_bmap(filename):

	print("Loading bitmap...")

	global map_data

	im = Image.open(filename)

	map_data = list(im.getdata())

	print("Loaded bitmap.")


def get_c(x, y):

	# check for a co-ord outside the map
	if x < -3000.0 or x > 3000.0 or y > 3000.0 or y < -3000.0:
		return None

	# get row/col on 6000x6000 grid
	iGridX = (int(x)) + 3000
	iGridY = ((int(y)) - 3000) * -1
	iDataPos = (iGridY * 6000) + iGridX

	try:
		c = map_data[iDataPos]

	except IndexError:
		print("iDataPos:", iDataPos, "Len:", len(map_data))
		return None

	return c


def gen_stuff():

	print("Generating stuff...")

	stuff = []
	z = 0.0

	for x in range (-3000, 3000):

		for y in range (-3000, 3000):

			if random.random() > 0.05: # 5% chance to place a tree each sq metre
				continue

			c = get_c(x, y)

			if c == None:
				continue

			if c == (255, 0, 0):
				z = get_z(x, y)
				stuff.append((obj_arr_E_SHRUB_S[random.randrange(len(obj_arr_E_SHRUB_S))], x, y, z))

	print(len(stuff))

	print("Generating completed.")

	return stuff


def save_stuff(stuff):

	with io.open("output.txt", "w") as f:
		for i in stuff:
			f.write("CreateObject(%d, %f, %f, %f, 0.0, 0.0, 0.0);\n"%(i[0], i[1], i[2], i[3]))

	im = Image.new("RGB", (6000, 6000), (255, 255, 255))

	for i in stuff:
		im.putpixel((i[1] + 3000, (6000 - (i[2] + 3000))), (0, 0, 0))

	im.save("output.bmp")



def main():
	
	load_hmap()

	load_bmap("bmp/tx.bmp")

	stuff = gen_stuff()

	save_stuff(stuff)


if __name__ == '__main__':
	main()

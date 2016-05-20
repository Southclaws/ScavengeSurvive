import timeit
import os
import copy
import io
import re
import itertools as IT
from PIL import Image, ImageDraw, ImageColor, ImageFont
import heatmap


o = re.compile(r'CreateObject\(([0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+)\);')
DOT_RADIUS = 6


class Object():

	def __init__(self, x, y, z):
		self.x = x
		self.y = y
		self.z = z


def load_obj(filename):

	objs = []

	with io.open(filename) as f:
		for l in f:
			r = o.match(l)

			if r:
				objs.append(Object(
					float(r.group(2)),	# x
					float(r.group(3)),	# y
					float(r.group(4))))	# z

	return objs


def draw_obj(im, draw, objs):

	print(len(objs), "objs spawns being drawn")

	x = 0.0
	y = 0.0

	for s in objs:
		x = s.x + 3000
		y = 6000 - (s.y + 3000)
		draw.ellipse([x - DOT_RADIUS, y - DOT_RADIUS, x + DOT_RADIUS, y + DOT_RADIUS], outline=(255, 255, 255), fill=(0, 0, 0))


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
	im.save("object-heatmap.jpg")

def core():

	objs = []
	objs += load_obj("in")

	# Initialise PIL stuff
	mapimg = Image.open("gtasa-blank-1.0.jpg")
	draw = ImageDraw.Draw(mapimg)

	# Generate dots
	draw_obj(mapimg, draw, objs)

	mapimg.save("object-map.jpg")

	# generate heatmap
	generate_obj_heatmap(copy.copy(mapimg), draw, objs)


if __name__ == '__main__':
	main()

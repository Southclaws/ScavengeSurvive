import sys
import io
from PIL import Image, ImageDraw, ImageColor, ImageFont


SCRIPTFILES_PATH = "../scriptfiles/"


map_data = []


def load_bitmap(filename):
	"""
	Loads the bitmap data into memory.
	"""

	print("Loading bitmap...")

	global map_data
	im = Image.open(filename)
	map_data = list(im.getdata())

	print("Loaded bitmap.")


def colour_at(x, y):
	"""
	Returns a colour (r,g,b) value for the specified coordinates.
	"""

	if x < -3000.0 or x > 3000.0 or y > 3000.0 or y < -3000.0:
		return None

	iGridX = (int(x)) + 3000
	iGridY = ((int(y)) - 2999) * -1
	iDataPos = (iGridY * 6000) + iGridX

	try:
		c = map_data[iDataPos]

	except IndexError:
		print("IndexError: Pos: ", iGridX, iGridY, x, y, "iDataPos:", iDataPos, "Len:", len(map_data))
		return None

	return c


if __name__ == '__main__':
	if len(sys.argv) != 4:
		print("Parameters: bitmap path, x, y")

	else:
		x = float(sys.argv[2])
		y = float(sys.argv[3])

		load_bitmap(sys.argv[1])
		print("Colour at", x, y, "is", colour_at(x, y))

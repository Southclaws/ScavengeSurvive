import sys
import io
import array


SCRIPTFILES_PATH = "../scriptfiles/"


height_data = array.array('H')


def load_heightmap(filename):
	"""
	Loads the heightmap data into memory.
	"""

	print("Loading heightmap...")

	with io.open(filename, "rb") as f:

		while True:

			try:
				height_data.fromfile(f, 1)

			except EOFError:
				break

	print("Loaded heightmap.")


def get_z(x, y):
	"""
	Returns a z (height) value for the specified coordinates.
	"""

	if x < -3000.0 or x > 3000.0 or y > 3000.0 or y < -3000.0:
		return 0.0

	iGridX = (int(x)) + 3000
	iGridY = ((int(y)) - 3000) * -1

	iDataPos = (iGridY * 6000) + iGridX

	return height_data[iDataPos] / 100.0


if __name__ == '__main__':
	if len(sys.argv) != 4:
		print("Parameters: heightmap path, x, y")

	else:
		x = float(sys.argv[2])
		y = float(sys.argv[3])

		load_heightmap(sys.argv[1])
		print("Height at", x, y, "is", get_z(x, y))

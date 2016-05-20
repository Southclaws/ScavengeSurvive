# returns a list of vehicle spawns loaded from .vpl (vehicle placement) files.
import sys
import re
import os
import io


regex = re.compile(r'Vehicle\(([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*.*\)')


class Vehicle():

	def __init__(self, x, y, z):
		self.x = x
		self.y = y
		self.z = z


def load(directory):

	# Vehicle(-130.138595, 2244.483398, 31.974399, 349.191802)

	vehicles = []

	for fn in os.listdir(directory):
		if os.path.isfile(directory + fn):
			with io.open(directory + fn) as f:
				for l in f:
					r = regex.match(l)

					if r:
						vehicles.append(Vehicle(
							float(r.group(1)),	# x
							float(r.group(2)),	# y
							float(r.group(3))))	# z

	return vehicles


if __name__ == '__main__':
	if len(sys.argv) != 2:
		print("Parameters: directory to read .vpl files from")

	else:
		vehicles = load(sys.argv[1])

		for v in vehicles:
			print(v.x, v.y, v.z)

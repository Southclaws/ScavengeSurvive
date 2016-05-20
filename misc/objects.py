# returns a list of vehicle spawns loaded from .vpl (vehicle placement) files.
import sys
import re
import os
import io


regex = re.compile(r'CreateObject\(([0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+)\);')


class Object():

	def __init__(self, model, x, y, z, rx, ry, rz):
		self.model = model
		self.x = x
		self.y = y
		self.z = z
		self.rx = rx
		self.ry = ry
		self.rz = rz


def load(directory):

	objs = []

	for root, dirs, files in os.walk(directory):
		for fn in files:
			if os.path.splitext(fn)[1] == ".map" and "_TESTING" not in root:
				with io.open(os.path.join(root, fn)) as f:
					for l in f:
						r = regex.match(l)

						if r:
							objs.append(Object(
								r.group(1),			# model
								float(r.group(2)),	# x
								float(r.group(3)),	# y
								float(r.group(4)),	# z
								float(r.group(2)),	# rx
								float(r.group(3)),	# ry
								float(r.group(4))))	# rz

	return objs


if __name__ == '__main__':
	if len(sys.argv) != 2:
		print("Parameters: directory to read .map files from")

	else:
		objs = load(sys.argv[1])

		for o in objs:
			print(o.model, o.x, o.y, o.z, o.rx, o.ry, o.rz)

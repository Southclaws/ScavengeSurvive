import argparse
import io
import os
import json
import subprocess


COMPILER_PATH = "../pawno/pawncc.exe"

try:
	with io.open("build-config.json") as f:
		config = json.load(f)

	COMPILER_PATH = config["compiler_path"]

except IOError:
	print("Could not load build-config.json")


def build_project(increment=True):
	print("Building project...")
	BUILD_NUMBER = 0

	with io.open("BUILD_NUMBER", 'r') as f:
		BUILD_NUMBER = int(f.read())

	if increment:
		BUILD_NUMBER = BUILD_NUMBER + 1

		with io.open("BUILD_NUMBER", 'w') as f:
			f.write(str(BUILD_NUMBER))

	print("BUILD", BUILD_NUMBER)
	print("COMPILER", COMPILER_PATH)

	ret = subprocess.call([COMPILER_PATH, "-Dgamemodes/", "ScavengeSurvive.pwn", "-;+", "-(+", "-\\)+", "-d3", "-e../errors"])

	# fixes sublime text jump-to-error feature by adding the `gamemodes/` directory
	# to errors and warnings.

	try:
		with io.open("errors", 'r') as f:
			print("Build result:", ret)
			for l in f:
				if not os.path.isfile(l):
					print("gamemodes/" + l, end='')

				else:
					print(l, end='')

		os.remove("errors")

	except:
		print("Build successful!")


def build_file(file):
	print("Building file", file, "...")
	if not file:
		print("No file passed")
		return

	output = "-o" + os.path.splitext(file)[0]

	ret = subprocess.call([COMPILER_PATH, file, output, "-;+", "-(+", "-\\)+", "-d3", "-e../errors"])

	try:
		with io.open("errors", 'r') as f:
			print("Build result:", ret)
			for l in f:
				if not os.path.isfile(l):
					print("gamemodes/" + l, end='')

				else:
					print(l, end='')

		os.remove("errors")

	except:
		print("Build successful!")


def main():

	parser = argparse.ArgumentParser()
	parser.add_argument('mode', help="mode: project|file")
	parser.add_argument('--increment', action="store_true", help="when set, increments build number")
	parser.add_argument('--input', type=str, default='')
	args = parser.parse_args()

	if args.mode == "project":
		build_project(args.increment)

	elif args.mode == "file":
		build_file(args.input)


if __name__ == '__main__':
	main()

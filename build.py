import io
import os
import json
import subprocess

COMPILER_PATH = "../pawno/pawncc.exe"
BUILD_NUMBER = 0

with io.open("build-config.json") as f:
	config = json.load(f)

COMPILER_PATH = config["compiler_path"]

with io.open("BUILD_NUMBER", 'r') as f:
	BUILD_NUMBER = int(f.read())

BUILD_NUMBER = BUILD_NUMBER + 1

with io.open("BUILD_NUMBER", 'w') as f:
	f.write(str(BUILD_NUMBER))

print("BUILD", BUILD_NUMBER)
print("COMPILER", COMPILER_PATH)

ret = subprocess.call(["../pawno/pawncc.exe", "-Dgamemodes/", "ScavengeSurvive.pwn", "-;+", "-(+", "-\\)+", "-d3", "-e../errors"])

# fixes sublime text jump-to-error feature by adding the `gamemodes/` directory
# to errors and warnings.

try:
	with io.open("errors", 'r') as f:
		print("Build result:", ret)
		for l in f:
			print("gamemodes/" + l, end = '')

	os.remove("errors")

except:
	print("Build successful!")

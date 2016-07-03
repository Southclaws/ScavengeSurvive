import io
import json
import subprocess


COMPILER_PATH = "../pawno/pawncc.exe"

ret = 0
ret += subprocess.call(["git", "fetch"])
ret += subprocess.call(["git", "merge"])

with io.open("build-config.json") as f:
	config = json.load(f)

COMPILER_PATH = config["compiler_path"]

if ret > 0:
	print("git error")

while True:
	ret = subprocess.call([COMPILER_PATH, "-Dgamemodes/", "ScavengeSurvive.pwn", "-;+", "-(+", "-\\)+", "-d3",])
	if ret > 0:
		print("compilation error")
		break

	ret = subprocess.call(["python.exe", "misc/gentrees.py"])
	if ret > 0:
		print("tree generation error")

	ret = subprocess.call(["samp-server.exe"])

	print("samp-server runtime error")

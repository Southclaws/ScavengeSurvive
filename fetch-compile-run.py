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

if ret == 0:
	ret = subprocess.call([COMPILER_PATH, "-Dgamemodes/", "ScavengeSurvive.pwn", "-;+", "-(+", "-\\)+", "-d3",])
else:
	print("git error")


if ret == 0:
	subprocess.call(["python.exe", "misc/gentrees.py"])
else:
	print("tree generation error")


if ret == 0:
	subprocess.call(["samp-server.exe"])
else:
	print("compilation error")

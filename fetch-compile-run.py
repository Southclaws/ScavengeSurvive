import platform
import io
import json
import subprocess


config = {}


try:
	with io.open("build-config.json", 'r') as f:
		config = json.load(f)

except IOError as e:
	print(e)
	print("Creating build-config with defaults...")

	if platform.system() == "Windows":
		config["compiler_path"] = "../pawno/pawncc.exe"

	else:
		config["compiler_path"] = "../pawnc-3.10.20160702-linux/bin/pawncc"

	config["branch"] = "master"

	with io.open("build-config.json", 'w') as f:
		json.dump(config, f, indent=4)

	print(config["compiler_path"], config["branch"])


COMPILER_PATH = config["compiler_path"]
BRANCH = config["branch"]


ret = 0
ret += subprocess.call(["git", "fetch"])
ret += subprocess.call(["git", "merge"])
ret += subprocess.call(["git", "checkout", BRANCH])

if ret > 0:
	print("git error")


while True:
	ret = subprocess.call([COMPILER_PATH, "-Dgamemodes/", "ScavengeSurvive.pwn", "-;+", "-(+", "-\\)+", "-d3"])
	if ret > 0:
		print("compilation error")
		break

	ret = subprocess.call(["python.exe", "misc/gentrees.py"])
	if ret > 0:
		print("tree generation error")

	ret = subprocess.call(["samp-server.exe"])

	print("samp-server runtime error")

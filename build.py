import argparse
import io
import os
import json
import re
import subprocess


# NOTE:
#
# Scroll down to "def main():" to follow the script in chronological order.
#


# Main variables, these are defaults but they can be changed by creating a file
# named 'build-config.json' next to this script which is a standard JSON file
# example:
# {
#   "compiler_path":"C:/Pawno/pawncc.exe",
#   "branch":"dev",
#   "constants":[
#     "BUILD_EXTENSIONS"
#   ]
# }
# 'constants' is a list of labels you can pass to the compiler to #define at
# compile time, BUILD_EXTENSIONS is a label I use which triggers a line of code
# in a private file: '#if defined BUILD_EXTENSIONS' which adds some hidden
# features to my build. You can use this to control compile-time flags such as
# YSI's _DEBUG constant.
COMPILER_PATH = "../pawno/pawncc.exe"
CONSTANTS = []

try:
	with io.open("build-config.json") as f:
		config = json.load(f)

	COMPILER_PATH = config["compiler_path"]
	CONSTANTS = config['constants']

except IOError:
	print("Could not load build-config.json")


# build_project will compile the main source file (in this case,
# "./gamemodes/ScavengeSurvive.pwn") and the only argument will determine
# whether or not to increment the build number. Most of the time you'll want to
# increment your build numbers every time so this is rarely used.
# Side note: the print lines throughout this script use 'flush=True' to force
# the print functions to output immediately instead of wait for the next stdout
# flush because that usually comes *after* the build process (which can take
# over a minute to complete!)
def build_project(increment=True):
	print("Building project...", flush=True)
	BUILD_NUMBER = 0

	# open up the BUILD_NUMBER file and read the build number, this should only
	# ever be changed by this script and never by hand or another program.
	with io.open("BUILD_NUMBER", 'r') as f:
		BUILD_NUMBER = int(f.read())

	if increment:
		BUILD_NUMBER = BUILD_NUMBER + 1

		with io.open("BUILD_NUMBER", 'w') as f:
			f.write(str(BUILD_NUMBER))

	print("BUILD", BUILD_NUMBER, flush=True)
	print("COMPILER", COMPILER_PATH, flush=True)
	print("CONSTANTS", CONSTANTS, flush=True)

	# This is the part that actually runs the compiler, the compiler is called
	# pawncc NOT Pawno! Pawno is the IDE but you can compile scripts without
	# ever touching Pawno because the compilation is actually always performed
	# by pawncc which is a simple terminal application with a variety of args.
	# The arguments being passed here include:
	# '-D': tells the compiler the working directory
	# 'ScavengeSurvive.pwn': the source file we want to compile
	# '-;+': enforces the use of semicolons, just a SA:MP tradition really!
	# '-(+': enforces the use of open brackets on functions and if statements
	# '-\+': defines the escape character as '\', pretty standard
	# '-d3': sets the debug output as level 3, mostly just for crashdetect
	# '-e': tells the compiler to write all output to a file instead of stdout
	# (that ^last one^ is important!)
	ret = subprocess.call([
		COMPILER_PATH,
		"-Dgamemodes/",
		"ScavengeSurvive.pwn",
		"-;+",
		"-(+",
		"-\\+",
		"-d3",
		"-e../errors"
	] + [s + "=" for s in CONSTANTS])

	# This extra part at the end will iterate the CONSTANTS list and add them
	# to the command with a '=' after each. This is because pawncc accepts
	# definitions in the command such as "MY_CONSTANT=3" then if you have a
	# compile-time check in your source code such as "#if MY_CONSTANT == 3"
	# then this suddenly becomes very useful for passing external values and
	# flags directly into source code at compile time *without* needing to
	# modify the source code itself.

	# Remember that -e flag that's important? Here's why:
	# Sublime Text will extract file paths and line numbers from compilation
	# output so you can double-click the errors in the output console to jump
	# to the specific file and line and now it even shows inline messages in
	# the code which is super useful!
	# The problem is that because pawncc context is inside the ./gamemodes/
	# directory so all the errors and warnings are relative to that directory
	# but the Sublime Text context is in the project directory so the output
	# from the compiler will contain paths that don't start from the correct
	# directory.

	# The fix for this is to write all errors out to the file then after
	# compilation, read that file and correct the path. There is also a check
	# here that ensures the missing directory isn't added incorrectly as
	# warnings and errors from external includes will have the full directory
	# path (such as C:\Pawno\include\foreach.inc)
	try:
		with io.open("errors", 'r') as f:
			print("Build result:", ret)
			for l in f:
				if re.match("[a-zA-Z]:\\.*", l):
					print(l, end='')

				else:
					print("gamemodes/" + l, end='')
		# clean up when we're done because we're polite!
		os.remove("errors")

	except:
		print("Build successful!")


# build_file is much simpler as it just needs to call pawncc with the input
# file as a parameter followed by some standard flags. The same applies to the
# -e flag and output handling however.
def build_file(file):
	print("Building file", file, "...", flush=True)
	if not file:
		print("No file passed", flush=True)
		return

	output = "-o" + os.path.splitext(file)[0]

	ret = subprocess.call([
		COMPILER_PATH,
		file,
		output,
		"-;+",
		"-(+",
		"-\\)+",
		"-d3",
		"-e../errors"
	] + [s + "=" for s in CONSTANTS])

	try:
		with io.open("errors", 'r') as f:
			print("Build result:", ret)
			for l in f:
				if re.match("[a-zA-Z]:\\.*", l):
					print(l, end='')

				else:
					print("gamemodes/" + l, end='')

		os.remove("errors")

	except:
		print("Build successful!")


# Script entry point.
# Here, some arguments are set up:
# - mode: whether the script should compile the entire project or a single file
# - increment: should the script increment the build number?
# - input: if 'mode' is 'file' then this arg specifies the file to compile
# then the script calls either build_project or build_file.
def main():

	parser = argparse.ArgumentParser()
	parser.add_argument('mode', help="mode: project|file")
	parser.add_argument('--increment', action="store_true")
	parser.add_argument('--input', type=str, default='')
	args = parser.parse_args()

	if args.mode == "project":
		build_project(args.increment)

	elif args.mode == "file":
		build_file(args.input)


if __name__ == '__main__':
	main()

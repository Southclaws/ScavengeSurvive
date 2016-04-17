#
#	Quick utility for adding a license to source files. Ironically, this script
#	has no license and is in public domain!
#


import os
import io


LICENSE = """/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


"""


def process(filename):

	if filename == ".\\gamemodes\\ScavengeSurvive.pwn":
		return

	if filename.startswith(".\\scriptfiles"):
		return

	source = ""

	with io.open(filename, 'r') as f:
		source = f.read()

	if not source.startswith(LICENSE):

		new = LICENSE + source
	
		with io.open(filename, 'w', newline='\n') as f:
			f.write(new)
	
		print("Added a license block to", filename)


def main():

	c = 0

	for p, d, fs in os.walk("."):
		if ".git" in p:
			continue

		for f in fs:
			if os.path.splitext(f)[1] in [".inc", ".pwn"]:
				process(os.path.join(p, f))
				c += 1

	print(c, "files processed")


if __name__ == '__main__':
	main()

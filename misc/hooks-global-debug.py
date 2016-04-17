import os
import io
import re


def process(filename):

	filename = filename.replace("\\", "/")

	SEARCH = r"hook (On.*)\((.*)\)\s\{"
	REPLACE = r"""hook \1(\2)
{
	d:3:GLOBAL_DEBUG("[\1] in %s");
"""%(filename.replace("..", ""))

	if filename == "../gamemodes/ScavengeSurvive.pwn":
		return

	if filename.startswith("./scriptfiles"):
		return

	source = ""

	with io.open(filename, 'r') as f:
		source = f.read()

	source = re.sub(SEARCH, REPLACE, source)

	#print(source)

	with io.open(filename, 'w', newline='\n') as f:
		f.write(source)


def main():

	c = 0

	for p, d, fs in os.walk("../gamemodes/"):
		if ".git" in p:
			continue

		for f in fs:
			if os.path.splitext(f)[1] in [".inc", ".pwn"]:
				process(os.path.join(p, f))
				c += 1

	print(c, "files processed")


if __name__ == '__main__':
	main()

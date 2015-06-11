import io, os, glob


def count_lines(filepath):

	lines = 0
	chars = 0

	with io.open(filepath, "r") as f:
		for i in f:
			chars += len(i)
			lines += 1

	return lines, chars


def main():

	lines = 0
	chars = 0

	path = '../gamemodes/'

	for root, _, files in os.walk(path):
		for f in files:
			fullpath = os.path.join(root, f)
			if(os.path.splitext(fullpath)[1] in [".pwn", ".inc"]):
				data = count_lines(fullpath)
				lines += data[0]
				chars += data[1]
				print("%d lines, %d characters in %s"%(data[0], data[1], fullpath))

	print("%d lines, %d characters total"%(lines, chars))


if __name__ == '__main__':
	main()

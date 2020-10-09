import json
import io


def main():

	content = ""

	with io.open('settings.json', 'r') as f:
		content = json.load(f)

	for a, b in content.items():
		for i, j in b.items():
			if type(j) is dict:
				for x, y in j.items():
					#print("%s : %s/%s/%s/0=%s"%(type(y), a, b, x, y))
					print("DICT FOUND:", j)

			elif type(j) is list:
				for x, y in enumerate(j):
					print("%s/%s/%s=%s"%(a, i, x, y))
			else:
				print("%s/%s=%s"%(a, i, j))

	return


if __name__ == '__main__':
	main()

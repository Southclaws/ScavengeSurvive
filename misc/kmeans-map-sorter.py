import sys

from objects import load

from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
from sklearn.preprocessing import scale
from numpy import float


def main():
	print("k-means clustering for map objects")

	objs = load(sys.argv[1])

	print("Loaded", len(objs), "objects")

	model = KMeans(n_clusters=5)

	model = model.fit(scale(objs))

	plt.figure(figsize=(8, 6))
	plt.scatter(objs[:, 0], objs[:, 1], c=model.labels_.astype(float))
	plt.savefig('test.png', bbox_inches='tight')


if __name__ == '__main__':
	main()

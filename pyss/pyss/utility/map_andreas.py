import argparse
import logging
import io
import array


class Heightmap:
    def __init__(self, filename):
        """
        Loads the heightmap data into memory.
        """

        logging.info("Loading heightmap...")

        self.heightmap = array.array('H')

        with io.open(filename, "rb") as f:
            while True:
                try:
                    self.heightmap.fromfile(f, 1)
                except EOFError:
                    break

        logging.info("Loaded heightmap.")

    def get_z(self, x, y):
        """
        Returns a z (height) value for the specified coordinates.
        """

        if x < -3000.0 or x > 3000.0 or y > 3000.0 or y < -3000.0:
            return 0.0

        iGridX = (int(x)) + 3000
        iGridY = ((int(y)) - 3000) * -1

        iDataPos = (iGridY * 6000) + iGridX

        return self.heightmap[iDataPos] / 100.0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("file", type=str, help="Map Andreas .hmap file")
    parser.add_argument("posx", type=float, help="x coordinate")
    parser.add_argument("posy", type=float, help="y coordinate")
    args = parser.parse_args()

    b = Heightmap(args.file)

    print(
        "Height at", args.posx, args.posy,
        "is", b.get_z(args.posx, args.posy))


if __name__ == '__main__':
    main()

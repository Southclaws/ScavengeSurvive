import argparse
import logging

from PIL import Image


class BitMap:
    def __init__(self, filename):
        """
        Loads the bitmap data into memory.
        """

        logging.info("Loading bitmap...")

        im = Image.open(filename)
        self.map_data = list(im.getdata())

        logging.info("Loaded bitmap.")

    def colour_at(self, x, y):
        """
        Returns a colour (r,g,b) value for the specified coordinates.
        """

        if x < -3000.0 or x > 3000.0 or y > 3000.0 or y < -3000.0:
            return None

        iGridX = (int(x)) + 3000
        iGridY = ((int(y)) - 2999) * -1
        iDataPos = (iGridY * 6000) + iGridX

        try:
            c = self.map_data[iDataPos]

        except IndexError:
            print(
                "IndexError: Pos: ", iGridX, iGridY, x, y,
                "iDataPos:", iDataPos,
                "Len:", len(self.map_data))
            c = None

        return c


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("file", type=str, help="6k square bitmap file")
    parser.add_argument("posx", type=float, help="x coordinate")
    parser.add_argument("posy", type=float, help="y coordinate")
    args = parser.parse_args()

    b = BitMap(args.file)

    print(
        "Colour at", args.posx, args.posy,
        "is", b.colour_at(args.posx, args.posy))


if __name__ == '__main__':
    main()

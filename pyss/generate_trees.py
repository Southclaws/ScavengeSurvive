import argparse
import io
import os
import random

from pyss.utility.regions import Regions
from pyss.utility.map_andreas import Heightmap
from pyss.utility.bitmap import BitMap

from PIL import Image, ImageDraw


def generate_trees(bitmap, heightmap, spawnchance):
    print("Generating trees...")

    trees = []
    z = 0.0

    for x in range(-3000, 3000):

        for y in range(-3000, 3000):

            if (100 * random.random()) > spawnchance:
                continue

            c = bitmap.colour_at(x, y)

            if c is None:
                continue

            # darkforest    :96
            # lightforest   :128
            # desert        :160
            # grassplanes   :192

            if c == (0, 96, 0):
                z = heightmap.get_z(x, y) - 0.5
                trees.append(("darkforest", x, y, z))

            elif c == (0, 128, 0):
                z = heightmap.get_z(x, y) - 0.5
                trees.append(("lightforest", x, y, z))

            elif c == (0, 160, 0):
                z = heightmap.get_z(x, y) - 0.5
                trees.append(("desert", x, y, z))

            elif c == (0, 192, 0):
                z = heightmap.get_z(x, y) - 0.5
                trees.append(("grassplanes", x, y, z))

            # ... fill in colour codes for species here

    print("Generating completed", len(trees), "Trees generated.")

    return trees


def write_trees(trees, directory, regions, subfolders):

    region_names = ["BC", "FC", "LS", "LV", "SF", "RC", "TR"]
    count = 0

    for region_name in region_names:
        count = 0

        if subfolders:
            outfile = os.path.join(directory, region_name, "/trees.tpl")
            os.makedirs(os.path.join(directory, region_name), exist_ok=True)
        else:
            outfile = os.path.join(directory, region_name + ".tpl")

        with io.open(outfile, "w") as f:
            for i in trees:
                if regions.is_point_in(i[1], i[2], region_name):
                    f.write(
                        "CreateTree(%s, %f, %f, %f);\n" %
                        (i[0], i[1], i[2], i[3]))

                    count += 1

        print("Saved", count, "trees for", region_name)

    # clear up the leftovers and dump them in GEN, should be empty really
    if subfolders:
        outfile = os.path.join(directory, "GEN/trees.tpl")
        os.makedirs(os.path.join(directory, "GEN"), exist_ok=True)
    else:
        outfile = os.path.join(directory, "GEN.tpl")

    with io.open(outfile, "w") as f:
        for i in trees:
            region_id = 0
            for region_name in region_names:
                if regions.is_point_in(i[1], i[2], region_name):
                    region_id = 1
                    break

            if region_id == 0:
                f.write(
                    "CreateTree(%s, %f, %f, %f);\n" %
                    (i[0], i[1], i[2], i[3]))
                count += 1


def draw_tree_map(trees, original, output):
    im = Image.open(original)
    draw = ImageDraw.Draw(im)

    for i in trees:
        c = (0, 0, 0)

        if i[0] == "darkforest":
            c = (0, 96, 0)

        elif i[0] == "lightforest":
            c = (0, 128, 0)

        elif i[0] == "desert":
            c = (0, 160, 0)

        elif i[0] == "grassplanes":
            c = (0, 192, 0)

        draw.ellipse([
            int(i[1] + 3000) - 8, int(6000 - (i[2] + 3000)) - 8,
            int(i[1] + 3000) + 8, int(6000 - (i[2] + 3000)) + 8],
            outline=(255, 255, 255), fill=c)

    im.save(output)


def main():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument(
        '-b', '--bitmap',
        default='../scriptfiles/txmap/tx.bmp',
        help='bitmap path (controls tree placement)')

    parser.add_argument(
        '-a', '--heightmap',
        default='../scriptfiles/SAfull.hmap',
        help='MapAndreas .hmap path (controls tree position Z value)')

    parser.add_argument(
        '-r', '--regions',
        default='data/regions.json',
        help='regions.json path')

    parser.add_argument(
        '-d', '--directory',
        default='../scriptfiles/trees/',
        help='output directory path')

    parser.add_argument(
        '-i', '--image',
        default='data/gtasa-blank-1.0.jpg',
        help="path to Ian Albert's gtasa-blank-1.0.jpg map")

    parser.add_argument(
        '-o', '--imageout',
        default='data/gtasa-blank-1.0-ss-trees.jpg',
        help="path to output file for tree map")

    parser.add_argument(
        '-s', '--spawnchance',
        type=float,
        default=0.1,
        help='percentage chance of a tree spawning')

    parser.add_argument(
        '-f', '--subfolders',
        action="store_true",
        help='place each .tpl output file in a subfolder named after region')

    args = parser.parse_args()

    print('--bitmap =', args.bitmap)
    print('--heightmap =', args.heightmap)
    print('--regions =', args.regions)
    print('--directory =', args.directory)
    print('--image =', args.image)
    print('--imageout =', args.imageout)
    print('--spawnchance =', args.spawnchance)
    print('--subfolders =', args.subfolders)

    print("\nvalidating arguments...\n")

    # preflight checks
    if not os.path.isfile(args.bitmap):
        return print("--bitmap no such file:", args.bitmap)

    if not os.path.isfile(args.heightmap):
        return print("--heightmap no such file:", args.heightmap)

    if not os.path.isfile(args.regions):
        return print("--regions no such file:", args.regions)

    if not os.path.isdir(args.directory):
        return print("--directory no such directory:", args.directory)

    if not os.path.isdir(args.image):
        print("--image no such file:", args.image, "no image output")

    if args.spawnchance < 0.0 or args.spawnchance > 5.0:
        print("--spawnchance must be between 0.0 and 5.0")

    # begin processing
    b = BitMap(args.bitmap)
    h = Heightmap(args.heightmap)
    r = Regions(args.regions)

    trees = generate_trees(b, h, args.spawnchance)
    write_trees(trees, args.directory, r, args.subfolders)

    if os.path.isdir(args.image):
        draw_tree_map(trees, args.image, args.imageout)


if __name__ == '__main__':
    main()

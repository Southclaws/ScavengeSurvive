import argparse
import copy
import os

from pyss.utility.regions import Regions, center
from pyss.utility.loot_spawns import LootSpawns
from pyss.utility.vehicle_spawns import VehicleSpawns
from pyss.utility.object_placement import ObjectSet

from PIL import Image, ImageDraw, ImageFont
# import heatmap
# heatmap won't work, it's python 2 and I have no idea how it worked previously


def draw_loot(im, draw, loot, mark_size=4):

    colours = {
        "world_civilian":
            (0, 100, 0),

        "world_industrial":
            (50, 50, 50),

        "world_police":
            (0, 20, 100),

        "world_military":
            (255, 0, 0),

        "world_medical":
            (100, 100, 255),

        "vehicle_civilian":
            (0, 100, 0),

        "vehicle_industrial":
            (50, 50, 50),

        "vehicle_police":
            (0, 20, 100),

        "vehicle_military":
            (255, 0, 0),

        "world_survivor":
            (60, 0, 100)
    }

    x = 0.0
    y = 0.0

    for zone in loot.spawns:
        for spawn in loot.spawns[zone]:
            x = spawn.x + 3000
            y = 6000 - (spawn.y + 3000)
            draw.ellipse([
                x - mark_size, y - mark_size, x + mark_size, y + mark_size],
                outline=(255, 255, 255), fill=colours[spawn.lootindex])


def draw_regions(im, draw, regions, font):

    print(len(regions.regions), "regions spawns being drawn")

    for key, value in regions.regions.items():
        temp_region = []

        # perform the map>image translation and store temporarily
        for i in value:
            temp_region.append((i[0] + 3000, 6000 - (i[1] + 3000)))

        draw.polygon(temp_region, outline=(255, 255, 255))
        cent = center(temp_region)
        draw.text((cent[0] + 2, cent[1] + 2), key, fill=(0, 0, 0), font=font)
        draw.text(cent, key, fill=(255, 255, 255), font=font)


def draw_vehicles(im, draw, vehicles, mark_size=2):

    print(len(vehicles.vehicles), "vehicle spawns being drawn")

    x = 0.0
    y = 0.0

    for spawn in vehicles.vehicles:
        x = spawn.x + 3000
        y = 6000 - (spawn.y + 3000)
        draw.rectangle([
            x - mark_size, y - mark_size, x + mark_size, y + mark_size],
            outline=(0, 0, 0), fill=(80, 80, 80))


def draw_obj(im, draw, objs, mark_size=4):

    print(len(objs), "objs spawns being drawn")

    x = 0.0
    y = 0.0

    for file in objs.objects:
        for obj in objs.objects[file]:
            x = obj.x + 3000
            y = 6000 - (obj.y + 3000)
            draw.ellipse([
                x - mark_size, y - mark_size, x + mark_size, y + mark_size],
                outline=(255, 255, 255), fill=(0, 0, 0))


def generate_loot_heatmap(im, draw, hm, loot, out):

    points = []

    for zone in loot.spawns:
        for spawn in loot.spawns[zone]:
            points.append([int(spawn.x + 3000), int(spawn.y + 3000)])

    hmimg = hm.heatmap(
        points,
        dotsize=150,
        size=(6000, 6000),
        scheme='classic',
        area=((0, 0), (6000, 6000)))

    im.paste(hmimg, mask=hmimg)
    im.save(out)


def generate_vehicle_heatmap(im, draw, hm, vehicles, out):

    points = []

    for l in vehicles.vehicles:
        points.append([int(l.x + 3000), int(l.y + 3000)])

    hmimg = hm.heatmap(
        points,
        dotsize=300,
        size=(6000, 6000),
        scheme='classic',
        area=((0, 0), (6000, 6000)))

    im.paste(hmimg, mask=hmimg)
    im.save(out)


def generate_obj_heatmap(im, draw, hm, objs, out):

    points = []

    for file in objs.objects:
        for obj in objs.objects[file]:
            points.append([int(obj.x + 3000), int(obj.y + 3000)])

    hmimg = hm.heatmap(
        points,
        dotsize=150,
        size=(6000, 6000),
        scheme='classic',
        area=((0, 0), (6000, 6000)))

    im.paste(hmimg, mask=hmimg)
    im.save(out)


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '-i', '--image',
        default='data/gtasa-blank-1.0.jpg',
        help="path to Ian Albert's gtasa-blank-1.0.jpg map")

    parser.add_argument(
        '-o', '--imageout',
        default='data/',
        help="directory to write output images to")

    parser.add_argument(
        '-l', '--hmlibpath',
        default='C:/Anaconda3/Lib/site-packages/heatmap/cHeatmap-x64.dll',
        help="directory to write output images to")

    args = parser.parse_args()

    # Initialise PIL stuff
    font = ImageFont.truetype("arial.ttf", 32)
    mapimg = Image.open(args.image)
    draw = ImageDraw.Draw(mapimg)
    # hm = heatmap.Heatmap(libpath=args.hmlibpath)

    # Generate paths
    map_path = os.path.join(args.imageout, "gtasa-blank-1.0-ss-map.jpg")
    # hm_loot = os.path.join(args.imageout, "gtasa-blank-1.0-ss-loot.jpg")
    # hm_vehicle = os.path.join(args.imageout, "gtasa-blank-1.0-ss-vehicles.jpg")
    # hm_object = os.path.join(args.imageout, "gtasa-blank-1.0-ss-objects.jpg")

    # Load SS data
    regions = Regions("data/regions.json")
    loot = LootSpawns("../gamemodes/sss/world/zones/")
    vehicles = VehicleSpawns("../scriptfiles/vspawn/")
    objs = ObjectSet("../scriptfiles/Maps/")

    # Generate the main map with region lines, loot spawns and vehicles
    draw_loot(mapimg, draw, loot)
    draw_vehicles(mapimg, draw, vehicles)
    draw_regions(mapimg, draw, regions, font)

    mapimg.save(map_path)

    # generate heatmaps for loot and vehicles on separate images
    # generate_loot_heatmap(copy.copy(mapimg), draw, hm, loot, hm_loot)
    # generate_vehicle_heatmap(copy.copy(mapimg), draw, hm, vehicles, hm_vehicle)
    # generate_obj_heatmap(copy.copy(mapimg), draw, hm, objs, hm_object)


if __name__ == '__main__':
    main()

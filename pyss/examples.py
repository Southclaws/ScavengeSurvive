from pyss.regions import Regions
from pyss.map_andreas import Heightmap
from pyss.bitmap import BitMap
from pyss.vehicle_spawns import VehicleSpawns
from pyss.object_placement import ObjectSet
from pyss.loot_spawns import LootSpawns


def main():
    x = 300
    y = 1800
    region = "BC_Ocultado"

    print("Test variables x, y, region:", x, y, region)

    regions = Regions()
    mapandreas = Heightmap("../scriptfiles/SAfull.hmap")
    image = BitMap("../scriptfiles/txmap/tx.bmp")
    vehicle_spawns = VehicleSpawns("../scriptfiles/vspawn/")
    object_set = ObjectSet("../scriptfiles/maps/")
    loot_spawns = LootSpawns("../gamemodes/sss/world/zones")

    print(
        x, y, "in region", region, "true/false:",
        regions.is_point_in(x, y, region),
        "actual region name:",
        regions.get_point_region(x, y))

    print(
        "Height of point", x, y, "is:",
        mapandreas.get_z(x, y))

    print(
        "Colour of point", x, y, "is:",
        image.colour_at(x, y))

    print(
        "Loaded", len(vehicle_spawns.vehicles),
        "vehicles from server 'vspawn' directory")

    print(
        "Loaded", len(object_set.objects),
        "object sets from server 'maps' directory")

    print(
        "Loaded", len(loot_spawns.spawns),
        "loot spawn sets from server 'maps' directory")

    for name in loot_spawns.spawns:
        print(len(loot_spawns.spawns[name]), "loot spawns in", name)


if __name__ == '__main__':
    main()

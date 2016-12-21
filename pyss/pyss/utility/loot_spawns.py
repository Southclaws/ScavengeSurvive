import re
import os
import io


"""
Regex matches:

    CreateStaticLootSpawn(
        Float:x, Float:y, Float:z,
        lootindex, Float:weight = 100.0, size = -1,
        worldid = 0, interiorid = 0);

From server source code files.
"""
regex = re.compile(
    r'[ \t]*CreateStaticLootSpawn\(([\-\+]?[0-9]*(?:\.[0-9]+)?),'
    r'\s*([\-\+]?[0-9]*(?:\.[0-9]+)?),\s*([\-\+]?[0-9]*(?:\.[0-9]+)?),'
    r'\s*GetLootIndexFromName\(\"(\w+)\"\),\s*([\-\+]?[0-9]*(?:\.[0-9]+)?)'
    r'(?:,\s*)?([0-9])?\);')


class LootSpawns:
    def __init__(self, source):
        self.spawns = {}

        if os.path.isdir(source):
            self._from_dir(source)

        else:
            self._from_file(source)

    def _from_dir(self, path):
        for root, dirs, files in os.walk(path):
            for fn in files:
                self.spawns[os.path.splitext(fn)[0]] = self._from_file(
                    os.path.join(root, fn))

    def _from_file(self, filename):
        spawns = []
        with io.open(filename) as f:
            for l in f:
                r = regex.match(l)

                if r:
                    x = float(r.group(1))
                    y = float(r.group(2))
                    z = float(r.group(3))
                    index = r.group(4)
                    weight = float(r.group(5))
                    size = r.group(6) if 6 in r.groups() else -1
                    world = r.group(7) if 7 in r.groups() else 0
                    interior = r.group(8) if 8 in r.groups() else 0

                    spawns.append(LootSpawn(
                        x, y, z, index, weight, size, world, interior))

        return spawns


class LootSpawn:
    def __init__(self, x, y, z, lootindex, weight, size, worldid, interiorid):
        self.x = x
        self.y = y
        self.z = z
        self.lootindex = lootindex
        self.weight = weight
        # optionals: (technically weight is optional but is always present)
        self.size = (size if type(size) is int else -1)
        self.worldid = (worldid if type(worldid) is int else 0)
        self.interiorid = (interiorid if type(interiorid) is int else 0)

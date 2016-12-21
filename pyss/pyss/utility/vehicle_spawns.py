"""
returns a list of vehicle spawns loaded from .vpl (vehicle placement) files.
"""

import argparse
import re
import os
import io


regex = re.compile(
    (r'Vehicle\(([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),'  # x, y
        r'\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+)'  # z, z-rot
        r'(?:,\s*)?([A-Za-z]*)?\)')  # model name (if exists)
)


class VehicleSpawns:
    def __init__(self, directory):
        self.vehicles = []

        for file in os.listdir(directory):
            if os.path.isfile(directory + file):
                self._read(directory + file)

    def _read(self, file):
        with io.open(file) as f:
            for l in f:
                r = regex.match(l)

                if r:
                    self.vehicles.append(Vehicle(
                        float(r.group(1)),
                        float(r.group(2)),
                        float(r.group(3)),
                        float(r.group(4)),
                        r.group(5)))


class Vehicle:
    def __init__(self, x, y, z, r, model):
        self.x = x
        self.y = y
        self.z = z
        self.r = r
        self.model = model

    def __repr__(self):
        return "%d, %f, %f, %f, %f" % (
            self.model, self.x, self.y, self.z, self.r)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "file", type=str, help="path to directory containing .vpl files")

    args = parser.parse_args()

    vehicles = VehicleSpawns(args.file)

    for v in vehicles:
        print(v)

import argparse
import io
import json
import itertools


class Regions:
    def __init__(self, region_data="data/regions.json"):
        with io.open(region_data, 'r') as f:
            self.regions = json.load(f)

    def is_point_in(self, x, y, name):
        if name not in self.regions:
            return False
        return is_point_in_poly(x, y, self.regions[name])

    def get_point_region(self, x, y):
        region = None
        for r in self.regions:
            if self.is_point_in(x, y, r):
                region = r
                break
        return region


def is_point_in_poly(x, y, poly):
    """
    Calculates whether or not a point (x, y) is inside poly. From:
    http://geospatialpython.com/2011/08/point-in-polygon-2-on-line.html
    """

    # check if point is a vertex
    if (x, y) in poly:
        return True

    # check if point is on a boundary
    for i in range(len(poly)):
        p1 = None
        p2 = None
        if i == 0:
            p1 = poly[0]
            p2 = poly[1]
        else:
            p1 = poly[i - 1]
            p2 = poly[i]
        if (
            (p1[1] == p2[1]) and
            (p1[1] == y) and
            (x > min(p1[0], p2[0])) and
            (x < max(p1[0], p2[0]))
        ):
            return True

    n = len(poly)
    inside = False
    p1x, p1y = poly[0]

    for i in range(n + 1):
        p2x, p2y = poly[(i % n)]

        if y > min(p1y, p2y):
            if y <= max(p1y, p2y):
                if x <= max(p1x, p2x):

                    if p1y != p2y:
                        xinters = (y - p1y) * (p2x - p1x) / (p2y - p1y) + p1x

                    if p1x == p2x or x <= xinters:
                        inside = not inside

        p1x, p1y = p2x, p2y

    return inside


def get_area(x, y):
    """
    Calculates the signed area of an arbitrary polygon given its verticies
    http://stackoverflow.com/a/4682656/190597 (Joe Kington)
    http://softsurfer.com/Archive/algorithm_0101/algorithm_0101.htm#2D%20Polygons
    """
    area = 0.0
    for i in range(-1, len(x) - 1):
        area += x[i] * (y[i + 1] - y[i - 1])
    return area / 2.0


def center(points):
    """
    http://stackoverflow.com/a/14115494/190597 (mgamba)
    """
    area = get_area(*zip(*points))
    result_x = 0
    result_y = 0
    N = len(points)
    points = itertools.cycle(points)
    x1, y1 = next(points)
    for i in range(N):
        x0, y0 = x1, y1
        x1, y1 = next(points)
        cross = (x0 * y1) - (x1 * y0)
        result_x += (x0 + x1) * cross
        result_y += (y0 + y1) * cross
    result_x /= (area * 6.0)
    result_y /= (area * 6.0)
    return (result_x, result_y)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("posx", type=float, help="x coordinate")
    parser.add_argument("posy", type=float, help="y coordinate")
    parser.add_argument("-r", "--region", type=str, help="region to check")
    args = parser.parse_args()

    r = Regions(args.file)

    if "region" in args:
        if r.is_point_in(args.posx, args.posy, args.region):
            print("Point", args.posx, args.posy, "is in", args.region)

        else:
            print("Point", args.posx, args.posy, "is not in", args.region)


if __name__ == '__main__':
    main()

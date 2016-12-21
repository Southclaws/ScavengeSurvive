import re
import os
import io


regex_obj = re.compile(
    r'CreateObject\(([0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),'
    r'\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),'
    r'\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),'
    r'\s*([\-\+]?[0-9]*\.[0-9]+)\);')

regex_rmb = re.compile(
    r'RemoveBuildingForPlayer\(playerid,\s*([0-9]+),'
    r'\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+),'
    r'\s*([\-\+]?[0-9]*\.[0-9]+),\s*([\-\+]?[0-9]*\.[0-9]+)\);')


class ObjectSet:
    def __init__(self, source):
        self.objects = {}

        if os.path.isdir(source):
            self._from_dir(source)

        else:
            self._from_file(source)

    def _from_dir(self, path):
        for root, dirs, files in os.walk(path):
            for fn in files:
                if os.path.splitext(fn)[1] == ".map":
                    self.objects[fn] = self._from_file(os.path.join(root, fn))

    def _from_file(self, path):
        objs = []
        with io.open(path) as f:
            for l in f:
                r = regex_obj.match(l)
                if r:
                    objs.append(Object(
                        r.group(1),
                        float(r.group(2)),
                        float(r.group(3)),
                        float(r.group(4)),
                        float(r.group(5)),
                        float(r.group(6)),
                        float(r.group(7))))

                r = regex_rmb.match(l)

                if r:
                    objs.append(Removal(
                        r.group(1),
                        float(r.group(2)),
                        float(r.group(3)),
                        float(r.group(4)),
                        float(r.group(5))))
        return objs


class Object:
    def __init__(self, model, x, y, z, rx=0.0, ry=0.0, rz=0.0):
        self.model = model
        self.x = x
        self.y = y
        self.z = z
        self.rx = rx
        self.ry = ry
        self.rz = rz

    def __repr__(self):
        return "CreateObject(%d, %f, %f, %f, %f, %f, %f" % (
            self.model, self.x, self.y, self.z, self.rx, self.ry, self.rz)


class Removal:
    def __init__(self, model, x, y, z, scale):
        self.model = model
        self.x = x
        self.y = y
        self.z = z
        self.scale = scale

    def __repr__(self):
        return (
            "RemoveBuildingForPlayer(playerid, %d, %f, %f, %f, %f, %f, %f" %
            (self.model, self.x, self.y, self.z, self.scale))

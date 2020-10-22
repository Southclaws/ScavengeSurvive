import io
import re
import os

DefineItemType = r"\s+(item_\w+)\s*=\sDefineItemType\(\"(.+)\",\s*\"([\w]+)\",\s*(\d+),\s*(\d+)"
SetItemTypeScrapValue = r"\s*SetItemTypeScrapValue\((\w+),\s*([0-9]+)\);"
SetItemTypeHolsterable = r"\s*SetItemTypeHolsterable\((\w+),\s*([0-9]+)"
DefineItemTypeWeapon_custom = r"\s+DefineItemTypeWeapon\((\w+),\s*\d+,\s*-1,\s*([0-9.]+),\s*_?:?([0-9.]+),\s*0,\s*anim_(\w+)"
DefineItemTypeWeapon_melee = r"\s+DefineItemTypeWeapon\((\w+),\s*WEAPON_\w+\,\s*.*,\s*([0-9.]+),\s*([0-9.]+),\s*([0-9.]+)"
DefineItemTypeWeapon_firearm = r"\s+DefineItemTypeWeapon\((\w+),\s*WEAPON_\w+\,\s*(\w+),\s*([0-9.]+),\s*([0-9.]+),\s*([0-9.]+)"
DefineItemTypeAmmo = r"\s+DefineItemTypeAmmo\((\w+),\s*\"([\w .]+)\",\s*(\w+),\s*([0-9.]+),\s*([0-9.]+),\s*([0-9.]+),\s*([0-9.]+)\);"


class Extractor(object):
    def __init__(self, infile="../gamemodes/sss/core/server/init.pwn", outdir="../docs/docs/game"):
        self.items = {}
        with io.open(infile) as f:
            self.content = f.read()
            self.outdir = outdir

            # get item names and stuff so we can map variable names to actual names
            for _, match in enumerate(re.finditer(DefineItemType, self.content, re.MULTILINE), start=1):
                self.items[match.group(1)] = {
                    'name': match.group(2),
                    'unique': match.group(3),
                    'model': match.group(4),
                    'size': match.group(5),
                }

            # now run the matchers for various data
            with io.open(os.path.join(self.outdir, "Scrap.md"), "w") as o:
                o.write("""---
title: Item Scrap Values
---

Some items in the world can be turned into Scrap Metal using a Scrap Machine. This page lists all those items with the number of pieces of scrap metal they will yield once processed inside a Scrap Machine.

""")
                self.match_and_save(SetItemTypeScrapValue, o, [
                    ["Item", lambda x: self.itemname(x)],
                    ["Scrap Value"]
                ])

            with io.open(os.path.join(self.outdir, "Holster.md"), "w") as o:
                o.write("""---
title: Holster
---

The Holster is a place on your character to store certain types of weapon. Not all weapons can be holstered. The "Bone" indicates where on your character the item will be stored. `1` is on your back and `8` is on your belt.

""")
                self.match_and_save(SetItemTypeHolsterable, o, [
                    ["Item", lambda x: self.itemname(x)],
                    ["Bone"],
                ])

            with io.open(os.path.join(self.outdir, "Weapons.md"), "w") as o:
                o.write("""---
title: Weapons
---

There are many weapons in the game, more than the original game. This page lists all melee, custom melee and firearms.

""")
                o.write("""

# Firearms

""")
                self.match_and_save(DefineItemTypeWeapon_firearm, o, [
                    ["Item", lambda x: self.itemname(x)],
                    ["Ammo Calibre"],
                    ["Muzzle Velocity"],
                    ["Magazine Size"],
                    ["Maximum Magazines"],
                ], ignore="item_Chainsaw")
                o.write("""

# Ammunition

""")
                self.match_and_save(DefineItemTypeAmmo, o, [
                    ["Item", lambda x: self.itemname(x)],
                    ["Ammo Name"],
                    ["Calibre"],
                    ["Bleed Rate"],
                    ["K/O Multiplier"],
                    ["Penetration"],
                    ["Size"],
                ])
                o.write("""

# Melee Weapons

""")

                self.match_and_save(DefineItemTypeWeapon_melee, o, [
                    ["Item", lambda x: self.itemname(x)],
                    ["Bleed Rate"],
                    ["Knockout Probability"],
                ])
                o.write("""

# Additional Melee Weapons

""")
                self.match_and_save(DefineItemTypeWeapon_custom, o, [
                    ["Item", lambda x: self.itemname(x)],
                    ["Bleed Rate"],
                    ["Knockout Probability"],
                    ["Attack Type"],
                ])

    def itemname(self, varname):
        return self.items[varname]["name"]

    def match_and_save(self, regex, file, columns, ignore=""):
        headings = [x[0] for x in columns]
        print("| {headers} |".format(headers=" | ".join(headings)), file=file)
        print('|', ' | '.join([
            ''.join(['-' for y in x])
            for x in headings
        ]), '|', file=file)
        for _, match in enumerate(re.finditer(regex, self.content, re.MULTILINE), start=1):
            if match.group(1) == ignore:
                continue
            print('|', ' | '.join([
                y[1](match.group(x + 1)) if len(y) > 1 else match.group(x + 1)
                for x, y in enumerate(columns)
            ]), '|', file=file)


Extractor()

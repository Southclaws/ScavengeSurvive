from os.path import join

from .player_db import get_account

from modio import open


class Player:
    def __init__(self, name, datapath='../scriptfiles/data/player/'):
        self.name = name

        account = get_account(name)

        self.passhash = account.passhash
        self.ipv4 = account.ipv4
        self.alive = account.alive
        self.regdate = account.regdate
        self.lastlog = account.lastlog
        self.spawntime = account.spawntime
        self.spawns = account.spawns
        self.warnings = account.warnings
        self.gpci = account.gpci
        self.active = account.active

        with open(join(datapath, name) + '.dat', 'r') as f:
            self.LANG = f.get("LANG").get_data_format()
            self.INV0 = f.get("INV0").get_data_format()
            self.DRUG = f.get("DRUG").get_data_format()
            self.WNDS = f.get("WNDS").get_data_format()
            self.INFC = f.get("INFC").get_data_format()
            self.HELD = f.get("HELD").get_data_format()
            self.HOLS = f.get("HOLS").get_data_format()
            self.SKIL = f.get("SKIL").get_data_format()
            self.SHOU = f.get("SHOU").get_data_format()
            self.CHAR = f.get("CHAR").get_data_format()
            self.PVEH = f.get("PVEH").get_data_format()
            self.BAG0 = f.get("BAG0").get_data_format()
            self.TRAV = f.get("TRAV").get_data_format()

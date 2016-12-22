from os.path import join
from struct import pack, unpack
from socket import inet_ntoa
from datetime import datetime

from .player_db import get_account
from ..sif.item_sequence import ItemSequence

from modio import open


class Player:
    def __init__(self, name, datapath='../scriptfiles/data/player/'):
        self.name = name

        account = get_account(name)

        self.passhash = account.passhash
        self.ipv4 = inet_ntoa(pack("!I", int(account.ipv4)))
        self.alive = account.alive
        self.regdate = datetime.fromtimestamp(account.regdate)
        self.lastlog = datetime.fromtimestamp(account.lastlog)
        self.spawntime = datetime.fromtimestamp(account.spawntime)
        self.spawns = account.spawns
        self.warnings = account.warnings
        self.gpci = account.gpci
        self.active = account.active

        self.file_version = None
        self.health = None
        self.armour = None
        self.food = None
        self.skin = None
        self.hat = None
        self.holst = None
        self.holstex = None
        self.held = None
        self.heldex = None
        self.stance = None
        self.bleeding = None
        self.cuffed = None
        self.warns = None
        self.freq = None
        self.chatmode = None
        self.unused = None
        self.tooltips = None
        self.spawn_x = None
        self.spawn_y = None
        self.spawn_z = None
        self.spawn_r = None
        self.mask = None
        self.mute_time = None
        self.knockout = None
        self.bagtype = None
        self.world = None
        self.interior = None

        self._character_data = None
        self.items_inv = None
        self.items_bag = None
        self.held_item = None
        self.holstered_item = None

        self.language_id = None
        self.aimshout = None
        self.skills = None
        self.wounds = None
        self.drug_effects = None
        self.infection = None
        self.save_vehicles = None
        self.travel_stats = None

        with open(join(datapath, name) + '.dat', 'r') as f:
            self._character_data = f.get("CHAR").get_data_format()
            self.items_inv = ItemSequence(f.get("INV0").get_data_format())
            self.items_bag = ItemSequence(f.get("BAG0").get_data_format())
            self.held_item = f.get("HELD").get_data_format()
            self.holstered_item = f.get("HOLS").get_data_format()

            self.language_id = f.get("LANG").get_data_format()[0]
            self.aimshout = f.get("SHOU").get_data_format()
            self.skills = f.get("SKIL").get_data_format()
            self.wounds = f.get("WNDS").get_data_format()
            self.drug_effects = f.get("DRUG").get_data_format()
            self.infection = f.get("INFC").get_data_format()
            self.save_vehicles = f.get("PVEH").get_data_format()
            self.travel_stats = f.get("TRAV").get_data_format()

        self._decode_character_data()

    def _decode_character_data(self):
        self.file_version = self._character_data[0]
        self.health = unpack('f', pack('I', self._character_data[1]))[0]
        self.armour = unpack('f', pack('I', self._character_data[2]))[0]
        self.food = unpack('f', pack('I', self._character_data[3]))[0]
        self.skin = self._character_data[4]
        self.hat = self._character_data[5]
        self.holst = self._character_data[6]
        self.holstex = self._character_data[7]
        self.held = self._character_data[8]
        self.heldex = self._character_data[9]
        self.stance = self._character_data[10]
        self.bleeding = unpack('f', pack('I', self._character_data[11]))[0]
        self.cuffed = self._character_data[12]
        self.warns = self._character_data[13]
        self.freq = self._character_data[14]
        self.chatmode = self._character_data[15]
        self.unused = self._character_data[16]
        self.tooltips = self._character_data[17]
        self.spawn_x = unpack('f', pack('I', self._character_data[18]))[0]
        self.spawn_y = unpack('f', pack('I', self._character_data[19]))[0]
        self.spawn_z = unpack('f', pack('I', self._character_data[20]))[0]
        self.spawn_r = unpack('f', pack('I', self._character_data[21]))[0]
        self.mask = self._character_data[22]
        self.mute_time = self._character_data[23]
        self.knockout = self._character_data[24]
        self.bagtype = self._character_data[25]
        self.world = self._character_data[26]
        self.interior = self._character_data[27]

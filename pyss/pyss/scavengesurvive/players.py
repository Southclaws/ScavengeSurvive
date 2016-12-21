from .player import Player
from .player_db import get_all_accounts


class Players:
    def __init__(self, dbpath):
        self.players = []
        self.accounts = get_all_accounts()

        for player in self.accounts:
            self.players.append(Player(player.name))

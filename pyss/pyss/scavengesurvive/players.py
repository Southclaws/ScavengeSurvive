from .player import Player
from .player_db import AccountsConnector


class Players:
    def __init__(self, dbpath):
        self.players = []
        self.accounts = AccountsConnector(dbpath)

        for player in self.accounts:
            self.players.append(Player(
                name=player.name
            ))

from peewee import (SqliteDatabase, Model, CharField, DateField, BooleanField,
                    DecimalField)


db = SqliteDatabase("../scriptfiles/data/accounts.db")


class Player(Model):
    name = CharField(primary_key=True)
    passhash = CharField(db_column='pass')
    ipv4 = DecimalField()
    alive = BooleanField()
    regdate = DateField()
    lastlog = DateField()
    spawntime = DecimalField()
    spawns = DecimalField()
    warnings = DecimalField()
    gpci = CharField()
    active = BooleanField()

    class Meta:
        database = db


def get_account(name):
    return Player.select().where(Player.name == name).get()


def get_all_accounts():
    return Player.select().get()

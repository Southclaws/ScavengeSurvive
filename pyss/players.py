import argparse

from pyss.scavengesurvive.player import Player


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('name', type=str, help='player name to look up')
    args = parser.parse_args()

    p = Player(args.name)

    print("passhash:", p.passhash)
    print("ipv4:", p.ipv4)
    print("alive:", p.alive)
    print("regdate:", p.regdate)
    print("lastlog:", p.lastlog)
    print("spawntime:", p.spawntime)
    print("spawns:", p.spawns)
    print("warnings:", p.warnings)
    print("gpci:", p.gpci)
    print("active:", p.active)

    print("items_inv:", p.items_inv)
    print("items_bag:", p.items_bag)

    print("file_version:", p.file_version)
    print("health:", p.health)
    print("armour:", p.armour)
    print("food:", p.food)
    print("skin:", p.skin)
    print("hat:", p.hat)
    print("holst:", p.holst)
    print("holstex:", p.holstex)
    print("held:", p.held)
    print("heldex:", p.heldex)
    print("stance:", p.stance)
    print("bleeding:", p.bleeding)
    print("cuffed:", p.cuffed)
    print("warns:", p.warns)
    print("freq:", p.freq)
    print("chatmode:", p.chatmode)
    print("unused:", p.unused)
    print("tooltips:", p.tooltips)
    print("spawn_x:", p.spawn_x)
    print("spawn_y:", p.spawn_y)
    print("spawn_z:", p.spawn_z)
    print("spawn_r:", p.spawn_r)
    print("mask:", p.mask)
    print("mute_time:", p.mute_time)
    print("knockout:", p.knockout)
    print("bagtype:", p.bagtype)
    print("world:", p.world)
    print("interior:", p.interior)


if __name__ == '__main__':
    main()

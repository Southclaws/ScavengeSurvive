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
    print("LANG:", p.LANG)
    print("INV0:", p.INV0)
    print("DRUG:", p.DRUG)
    print("WNDS:", p.WNDS)
    print("INFC:", p.INFC)
    print("HELD:", p.HELD)
    print("HOLS:", p.HOLS)
    print("SKIL:", p.SKIL)
    print("SHOU:", p.SHOU)
    print("CHAR:", p.CHAR)
    print("PVEH:", p.PVEH)
    print("BAG0:", p.BAG0)
    print("TRAV:", p.TRAV)


if __name__ == '__main__':
    main()

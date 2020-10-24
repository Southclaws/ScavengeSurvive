---
title: Weapons
---

There are various different types of weapon available to use in the server, more
than the original game. Weapons are split into categories: Melee Weapons and
Firearms.

Weapons can also be classified by their most common spawn areas, simple melee
weapons and firearms can be found in civilian areas, but military grade or rare
and unique weapons are harder to find, usually in hard to reach places such as
military bases or survivor loot piles on rooftops.

This page lists all melee, custom melee and firearms.

## Firearms

Firearms are the most common and reliable method of taking down hostile players
in the wastelands. There is a total of 16 usable firearms in the game at the
moment ranging from close quarters pistols to long range rifles.

Each weapon has a calibre which corresponds to an ammunition type (See below).

Here is a list of all firearms and their respective ammunition types.

| Item           | Ammo Calibre  | Muzzle Velocity | Magazine Size | Maximum Magazines |
| -------------- | ------------- | --------------- | ------------- | ----------------- |
| M9             | calibre_9mm   | 330.0           | 10            | 1                 |
| M9 SD          | calibre_9mm   | 295.0           | 10            | 1                 |
| Desert Eagle   | calibre_357   | 420.0           | 7             | 2                 |
| Shotgun        | calibre_12g   | 475.0           | 6             | 1                 |
| Sawnoff        | calibre_12g   | 265.0           | 2             | 6                 |
| Spas 12        | calibre_12g   | 480.0           | 6             | 1                 |
| Mac 10         | calibre_9mm   | 376.0           | 32            | 1                 |
| MP5            | calibre_9mm   | 400.0           | 30            | 1                 |
| WASR-3         | calibre_556   | 943.0           | 30            | 1                 |
| M16            | calibre_556   | 948.0           | 30            | 1                 |
| Tec 9          | calibre_9mm   | 360.0           | 36            | 1                 |
| Rifle          | calibre_357   | 829.0           | 5             | 1                 |
| Sniper         | calibre_357   | 864.0           | 5             | 1                 |
| RPG            | calibre_rpg   | 0.0             | 1             | 0                 |
| Heatseeker     | calibre_rpg   | 0.0             | 1             | 0                 |
| Flamer         | liquid_Petrol | 0.0             | 100           | 10                |
| Minigun        | calibre_556   | 853.0           | 100           | 1                 |
| Camera         | calibre_film  | 1337.0          | 24            | 4                 |
| VEHICLE_WEAPON | calibre_556   | 750.0           | 0             | 1                 |
| AK-47          | calibre_762   | 715.0           | 30            | 1                 |
| M77-RM         | calibre_357   | 823.0           | 1             | 9                 |
| Dog's Breath   | calibre_50bmg | 888.8           | 1             | 9                 |
| Model 70       | calibre_308   | 860.6           | 1             | 9                 |
| The Len-Knocks | calibre_50bmg | 938.5           | 1             | 4                 |

### How Firearm Damage Works

Before reading this, ensure you have familiarised yourself with how Health works
on Scavenge and Survive.

A weapon has two parts: the gun and the ammunition. Each part has factors that
effect how the weapon will inflict the target.

Ammunition has a base bleed rate which is where the result bleed rate is derived
from. Read more about bleeding on the Health page.

Firearms have a muzzle velocity which determines how quickly the bullet force
drops off over distance.

#### Upon Firing

The bullet that is fired now contains this information: the muzzle velocity
(initial velocity) and the base bleed rate of that calibre. This static
information about the items will be used when the bullet hits in conjunction
with circumstantial data based on the individual event.

#### Upon Impact

_(please note that the game uses hitscan rather than balistics, there is no
actual interval between fire and impact.)_

When the bullet hits the target the distance is recorded which is then used to
calculate the actual bullet velocity at the time of impact. The muzzle velocity
of the weapon determines how much the resulting velocity is affected by the
distance. For example, a bullet fired from a very high muzzle velocity weapon
will likely not lose much of that speed over 100m but a low muzzle velocity
weapon will lose a lot of the velocity (and thus force) over the distance of
100m.

Now that the bullet velocity on impact is calculated, this value is used to
affect the calibre's base bleed rate resulting in a lower bleed rate depending
on the distance to the target.

#### Wounding and Unconsciousness

(you can read more about this on the Health page.)

When a bullet hits a target, a wound will be inflicted and they will start to
bleed. A calculation is then performed to determine whether or not the player
should become unconscious. This is based on how many wounds they had and their
bleed rate prior to the impact. Higher values result in a higher chance to get
knocked out.

#### Conclusion

Firearms will weaken your opponent however currently, a bullet will rarely kill
a player since bullets don't remove huge chunks of blood immediately. There is a
wound limit of 64, when a player reaches that value they will die instantly.

This means that weapons are key in getting your enemy to an unhealthy state from
a safe distance. Once they are weakened you can use melee weapons or get
creative to finish them off.

This major change in combat and health mechanics was made in an update that
aimed to extend combat from one-bullet knockouts and fast kills so combat
scenarios would become more interesting, tactical and tense. Learning how to use
your tools to their full advantage and not waste ammo is key to survival. Every
bullet counts.

### Ammunition

The obvious downside to firearms is ammunition, often seen as more rare than the
guns themselves. Ammunition can be found in the same kinds of places as weapons
in the form of Ammo Tins, lower grade ammunition is found in civilian areas
where the good stuff is only available in military areas and survivor stashes on
rooftops.

Ammunition comes in different types, which correspond to different weapons, some
ammo types work in multiple weapons and can be swapped between them with the
"Transfer Ammo" option in containers.

Most standard firearms fit one magazine in the weapon and one reserve.

| Item           | Ammo Name      | Calibre       | Bleed Rate | K/O Multiplier | Penetration | Size |
| -------------- | -------------- | ------------- | ---------- | -------------- | ----------- | ---- |
| 9mm Rounds     | Hollow Point   | calibre_9mm   | 1.0        | 1.0            | 0.2         | 20   |
| .50 Rounds     | Action Express | calibre_50cae | 1.0        | 1.5            | 0.9         | 28   |
| Shotgun Shells | No. 1          | calibre_12g   | 1.1        | 1.8            | 0.5         | 24   |
| 5.56 Rounds    | FMJ            | calibre_556   | 1.1        | 1.2            | 0.8         | 30   |
| .357 Rounds    | FMJ            | calibre_357   | 1.2        | 1.1            | 0.9         | 10   |
| Rockets        | RPG            | calibre_rpg   | 1.0        | 1.0            | 1.0         | 1    |
| Petrol Can     | Petrol         | calibre_fuel  | 0.0        | 0.0            | 0.0         | 20   |
| 9mm Rounds     | FMJ            | calibre_9mm   | 1.2        | 0.5            | 0.8         | 20   |
| Shotgun Shells | Flechette      | calibre_12g   | 1.6        | 0.6            | 0.2         | 8    |
| Shotgun Shells | Improvised     | calibre_12g   | 1.6        | 0.4            | 0.3         | 14   |
| 5.56 Rounds    | Tracer         | calibre_556   | 0.9        | 1.1            | 0.5         | 30   |
| 5.56 Rounds    | Hollow Point   | calibre_556   | 1.3        | 1.6            | 0.4         | 30   |
| .357 Rounds    | Tracer         | calibre_357   | 1.2        | 1.1            | 0.6         | 10   |
| 7.62 Rounds    | FMJ            | calibre_762   | 1.3        | 1.1            | 0.9         | 30   |
| .50 Rounds     | BMG            | calibre_50bmg | 1.8        | 1.8            | 1.0         | 16   |
| .308 Rounds    | FMJ            | calibre_308   | 1.2        | 1.1            | 0.8         | 10   |

### Effectiveness

Generally, hollow point rounds are better against non-armoured targets and full
metal jacket rounds will penetrate armour. Tracer rounds have no additional
properties other than lighting up their flight path and possibly igniting
explosive materials.

### Ammunition Types

- Hollow Point - more knockout, moderate bleed, less effective against
  vehicles/occupants
- Soft Point - less knockout than above, faster bleed rate, less effective
  against vehicles/occupants
- FMJ - armour piercing, shield piercing, more effective against
  vehicles/occupants
- Tracer - lit bullet, chance to ignite fuel tanks
- Explosive/incendiary - ignites fuel tanks, extra knockout chance and burn
  damage

### Transferring Ammunition

Transferring ammunition between weapons and Ammunition Storage is a vital part
of trading, weapon management and teamwork. You can transfer ammo into any
weapon that fires that ammo type.

To transfer ammo from item 1 to item 2, you must have item 1 in your inventory
or a container of some sort, then hold item 2, open up the item options and
click the "Transfer Ammo" option, a dialog will show where you can type the
amount of ammo to transfer into.

For instance, you have a tin of 5.56 rounds and an AK47 in your hands, put the
tin in your bag, hold the AK47, open up the bag > tin options > "Transfer Ammo
to gun". This also works the other way around, as well as with transferring ammo
from one tin to another, or from one gun to another (the guns don't have to be
the same type of gun, they only need to use the same ammo type)

This feature becomes invaluable when working your way up through better guns,
you may pick up an M9 soon after spawning which uses 9mm rounds. And then, in a
few days you find a Tec9 which also uses 9mm rounds, why waste that precious
ammo just because you upgraded to a better weapon? Transfer it!

## Melee Weapons

Melee weapons are among the simplest in a multitude of ways to slaughter other
players in the crepid wastelands of what was once San Andreas.

Each weapon has an infliction bleed rate and a knock-out chance. Read more about
how health works [here](health).

### Blunt

Most blunt melee weapons like the Baseball Bat or Pool Cue are less effective at
making the victim bleed but have a higher chance to knock them out. These are
the most common to find and are best for getting your enemy down on the ground,
but may not be the best choice if you're looking to get the job done quickly.
Despite this downside, the increased chance to knockout can make it easier to
immobilise enemies.

### Sharp

Sharp melee weapons such as the Knife or Sword have a lower chance to knock-out
but will cause very fast bleeding. Sharp weapons are intended for weakening a
player and inflicting long term damage. Sharp weapons are generally found in
civilian and industrial areas depending on the type.

### Stun Gun

The Stun Gun is a close-range contact electrical stun weapon. It doesn't inflict
wounds on your target but rather a very powerful buzz that will leave them
shocked for a minute.

| Item           | Bleed Rate | Knockout Probability |
| -------------- | ---------- | -------------------- |
| Knuckle Duster | 0.05       | 20                   |
| Golf Club      | 0.07       | 35                   |
| Baton          | 0.03       | 24                   |
| Combat Knife   | 0.35       | 14                   |
| Baseball Bat   | 0.09       | 35                   |
| Spade          | 0.21       | 40                   |
| Pool Cue       | 0.08       | 37                   |
| Sword          | 0.44       | 15                   |
| Chainsaw       | 0.93       | 100                  |
| Dildo          | 0.01       | 0                    |
| Dildo          | 0.01       | 0                    |
| Dildo          | 0.01       | 0                    |
| Dildo          | 0.01       | 0                    |
| Flowers        | 0.01       | 0                    |
| Cane           | 0.06       | 24                   |
| Grenade        | 0.0        | 0                    |
| Teargas        | 0.0        | 0                    |
| Molotov        | 0.0        | 0                    |
| M9             | 330.0      | 10                   |
| M9 SD          | 295.0      | 10                   |
| Desert Eagle   | 420.0      | 7                    |
| Shotgun        | 475.0      | 6                    |
| Sawnoff        | 265.0      | 2                    |
| Spas 12        | 480.0      | 6                    |
| Mac 10         | 376.0      | 32                   |
| MP5            | 400.0      | 30                   |
| WASR-3         | 943.0      | 30                   |
| M16            | 948.0      | 30                   |
| Tec 9          | 360.0      | 36                   |
| Rifle          | 829.0      | 5                    |
| Sniper         | 864.0      | 5                    |
| RPG            | 0.0        | 1                    |
| Heatseeker     | 0.0        | 1                    |
| Flamer         | 0.0        | 100                  |
| Minigun        | 853.0      | 100                  |
| Remote Bomb    | 0.0        | 1                    |
| Detonator      | 0.0        | 1                    |
| Spray Paint    | 0.0        | 100                  |
| Extinguisher   | 0.0        | 100                  |
| Camera         | 1337.0     | 24                   |
| VEHICLE_WEAPON | 750.0      | 0                    |
| AK-47          | 715.0      | 30                   |
| M77-RM         | 823.0      | 1                    |
| Dog's Breath   | 888.8      | 1                    |
| Model 70       | 860.6      | 1                    |
| The Len-Knocks | 938.5      | 1                    |

## Additional Melee Weapons

| Item          | Bleed Rate | Knockout Probability | Attack Type |
| ------------- | ---------- | -------------------- | ----------- |
| Wrench        | 0.01       | 1.20                 | Blunt       |
| Crowbar       | 0.03       | 1.25                 | Blunt       |
| Hammer        | 0.02       | 1.30                 | Blunt       |
| Rake          | 0.18       | 1.30                 | Heavy       |
| Cane          | 0.08       | 1.25                 | Blunt       |
| Stun Gun      | 0.0        | 0                    | Stab        |
| Screwdriver   | 0.24       | 0                    | Stab        |
| Mailbox       | 0.0        | 1.40                 | Heavy       |
| Sledgehammer  | 0.03       | 2.9                  | Heavy       |
| Big Ass Sword | 0.39       | 0.15                 | Heavy       |
| Spatula       | 0.001      | 0                    | Blunt       |
| Pan           | 0.01       | 1.05                 | Blunt       |
| Kitchen Knife | 0.29       | 0                    | Stab        |
| Frying Pan    | 0.01       | 1.06                 | Blunt       |
| Fork          | 0.17       | 0                    | Stab        |
| Broom         | 0.11       | 1.1                  | Heavy       |

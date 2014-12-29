import tkinter
import math
from tkinter import *
from tkinter import ttk


class AppMain(object):

	def __init__(self):

		self.root = tkinter.Tk()
		self.style = ttk.Style()

		# Load the data into lists
		calibres, weapons, ammo = define_data()

		# Serialise the lists
		self.dict_weapons = {str(el):el for el in weapons}
		self.dict_ammo = {str(el):el for el in ammo}


		#
		#	INPUTS FRAME
		#


		frame_inputs = ttk.Frame(self.root, relief=SUNKEN, borderwidth=15)

		# Weapon label
		self.lab_weapon = ttk.Label(frame_inputs, text='Weapon:')

		# Weapon input
		self.menu_weapons = ttk.Combobox(frame_inputs, width=40)
		self.menu_weapons.bind('<<ComboboxSelected>>', self.calculate_callback)
		self.menu_weapons['values'] = tuple(weapons)
		self.menu_weapons.current(0)

		# Ammo type label
		self.lab_ammo = ttk.Label(frame_inputs, text='Ammunition:')

		# Ammo type input
		self.menu_ammo = ttk.Combobox(frame_inputs)
		self.menu_ammo.bind('<<ComboboxSelected>>', self.calculate_callback)
		self.menu_ammo['values'] = tuple(ammo)
		self.menu_ammo.current(0)

		# Distance label
		self.lab_distance = ttk.Label(frame_inputs, text='Distance:')

		# Distance slider
		self.sli_distance = Scale(frame_inputs, from_=0, to=200, orient=HORIZONTAL)
		self.sli_distance.set(30)
		self.sli_distance.bind("<B1-Motion>", self.calculate_callback)

		# Simulate shot button
		self.btn_fireshot = ttk.Button(frame_inputs, text='Fire Shot', width=80)
		self.btn_fireshot.bind('<Button-1>', self.simulate_shot_callback)

		# Grid stuff
		frame_inputs.grid		(column=0, row=0, sticky=(N, S, E, W))
		self.lab_weapon.grid	(column=0, row=0, sticky=(E, W))
		self.menu_weapons.grid	(column=1, row=0, sticky=(E, W))
		self.lab_ammo.grid		(column=0, row=1, sticky=(E, W))
		self.menu_ammo.grid		(column=1, row=1, sticky=(E, W))
		self.lab_distance.grid	(column=0, row=2, sticky=(E, W))
		self.sli_distance.grid	(column=1, row=2, sticky=(E, W))
		self.btn_fireshot.grid	(sticky=(N, S, E, W), columnspan=2)


		#
		#	TARGET ATTRIBUTES FRAME
		#


		frame_target = ttk.Frame(self.root, relief=SUNKEN, borderwidth=15)

		# Target wounds label
		self.lab_wounds = ttk.Label(frame_target, text='Wounds:')

		# Target wounds slider
		self.sli_wounds = Scale(frame_target, from_=0, to=64, orient=HORIZONTAL)
		self.sli_wounds.set(2)
		self.sli_wounds.bind("<B1-Motion>", self.calculate_callback)

		# Target bleed rate label
		self.lab_bleed = ttk.Label(frame_target, text='Bleed rate:')

		# Total bleed rate input
		self.ent_totalbleed_string = StringVar()
		self.ent_totalbleed = Entry(frame_target, textvariable=self.ent_totalbleed_string)
		self.ent_totalbleed_string.set("0.0")
		self.ent_totalbleed.bind("<Key>", self.calculate_callback)

		# Target wounds label
		self.lab_health = ttk.Label(frame_target, text='Health:')

		# Target wounds slider
		self.sli_health = Scale(frame_target, from_=0, to=100, orient=HORIZONTAL, resolution=0.1)
		self.sli_health.set(100.0)
		self.sli_health.bind("<B1-Motion>", self.calculate_callback)



		# Grid stuff
		frame_target.grid		(column=0, row=1, sticky=(N, S, E, W))
		self.lab_wounds.grid	(column=0, row=0, sticky=(E, W))
		self.sli_wounds.grid	(column=1, row=0, sticky=(E, W))
		self.lab_bleed.grid		(column=0, row=1, sticky=(E, W))
		self.ent_totalbleed.grid(column=1, row=1, sticky=(E, W))
		self.lab_health.grid	(column=0, row=2, sticky=(E, W))
		self.sli_health.grid	(column=1, row=2, sticky=(E, W))


		#
		#	OUTPUT FRAME
		#


		frame_outputs = ttk.Frame(self.root, relief=SUNKEN, borderwidth=15)

		self.output_bulletvel = self.create_output(frame_outputs, "Bullet velocity at impact:", 0)
		self.output_veldegrad = self.create_output(frame_outputs, "Velocity degradation rate:", 1)
		self.output_bleedrate = self.create_output(frame_outputs, "Bleed rate:", 2)
		self.output_knockout = self.create_output(frame_outputs, "Knockout multiplier:", 3)
		self.output_bloodloss = self.create_output(frame_outputs, "Instant blood loss:", 4)
		self.output_timetolive = self.create_output(frame_outputs, "Worst case time to live:", 5)
		self.output_finalknock = self.create_output(frame_outputs, "Knockout chance:", 6)
		self.output_knocktime = self.create_output(frame_outputs, "Knockout time:", 7)

		self.btn_calculate = ttk.Button(frame_outputs, text='Calculate', width=80)
		self.btn_calculate.bind('<Button-1>', self.calculate_callback)


		# Grid stuff
		frame_outputs.grid(column=0, row=2, sticky=(N, S, E, W))
		self.btn_calculate.grid(sticky=(N, S, E, W), columnspan=2)

		# Calculate with the default values
		self.calculate()
		self.update_ui()


	def create_output(self, parent, title, row):

		output_title = ttk.Label(parent, text=title)
		output_title.grid(column=0, row=row, sticky=E)

		output_string = StringVar()
		output_label = ttk.Label(parent, textvariable=output_string)
		output_label.grid(column=1, row=row, sticky=W)

		return output_string


	def update_output(self, output, value, suffix=""):

		output.set(str(value) + suffix)


	def update_ui(self):

		bulletvelocity, velocitydegredationrate, bleedrate, knockmult, hploss, timetolive, knockchance, knockouttime = self.calculate()

		self.update_output(self.output_bulletvel, round(bulletvelocity, 8), "m/s")
		self.update_output(self.output_veldegrad, round(velocitydegredationrate, 8))
		self.update_output(self.output_bleedrate, round(bleedrate, 8))
		self.update_output(self.output_knockout, round(knockmult, 8))
		self.update_output(self.output_bloodloss, round(hploss, 8), "hp")
		self.update_output(self.output_timetolive, round(timetolive), "s")
		self.update_output(self.output_finalknock, round(knockchance, 8), "%")
		self.update_output(self.output_knocktime, knockouttime, "ms")


	def calculate_callback(self, event):

		self.calculate()
		self.update_ui()


	def calculate(self):

		weapon_key = self.menu_weapons.get()
		ammo_key = self.menu_ammo.get()

		if weapon_key == "" or ammo_key == "":
			return

		weapon = self.dict_weapons[weapon_key]
		ammotype = self.dict_ammo[ammo_key]

		bleedrate = weapon.calibre.bleedrate;
		knockmult = 1.0
		bulletvelocity = weapon.muzzvel;
		distance = float(self.sli_distance.get())
		totalbleedrate = float(self.ent_totalbleed.get())
		hp = float(self.sli_health.get())


		velocitydegredationrate = 1.0 - (bulletvelocity / 11300);

		bulletvelocity -= math.pow(distance, velocitydegredationrate);

		bleedrate = (bleedrate * (bulletvelocity / 1000.0));

		bleedrate *= ammotype.get_bleed_multiplier()
		knockmult *= ammotype.get_knockout_multiplier()

		hploss = (bleedrate * 800)

		woundcount = self.sli_wounds.get()

		knockchance = knockmult * (woundcount * (totalbleedrate * 30))

		timetolive = 0

		if totalbleedrate > 0.0:
			timetolive = 100 / (totalbleedrate * 10)

		knockouttime = round((woundcount * (totalbleedrate * 10) * (100.0 - hp) + (200 * (100.0 - hp))));

		return bulletvelocity, velocitydegredationrate, bleedrate, knockmult, hploss, timetolive, knockchance, knockouttime


	def simulate_shot_callback(self, event):

		self.simulate_shot()
		self.update_ui()


	def simulate_shot(self):

		bulletvelocity, velocitydegredationrate, bleedrate, knockmult, hploss, timetolive, knockchance, knockouttime = self.calculate()

		health = self.sli_health.get()

		self.sli_health.set(health - hploss)

		self.sli_wounds.set(self.sli_wounds.get() + 1)

		self.ent_totalbleed_string.set(str(round(float(self.ent_totalbleed_string.get()) + bleedrate, 8)))


#
#	Definitions
#


class AmmoCalibre():
	def __init__(self, name, bleedrate):
		self.name = name
		self.bleedrate = bleedrate

	def __repr__(self):
		return self.name

class ItemTypeWeapon():
	def __init__(self, item, weaponid, calibre, muzzvel, magsize, maxmags):
		self.item = item
		self.weaponid = weaponid
		self.calibre = calibre
		self.muzzvel = muzzvel
		self.magsize = magsize
		self.maxmags = maxmags

	def __repr__(self):
		return self.item + " (" + str(self.calibre) + " @ " + str(self.muzzvel) + "m/s" + ")"

class ItemTypeAmmo():
	def __init__(self, item, name, calibre, bleedmult, knockmult, penetration, capacity):
		self.item = item
		self.name = name
		self.calibre = calibre
		self.bleedmult = bleedmult
		self.knockmult = knockmult
		self.penetration = penetration
		self.capacity = capacity

	def __repr__(self):
		return self.name + " (" + str(self.calibre) + ")"

	def get_bleed_multiplier(self):
		return self.bleedmult

	def get_knockout_multiplier(self):
		return self.knockmult



def DefineAmmoCalibre(name, bleedrate):
	return AmmoCalibre(name, bleedrate)

def DefineItemTypeWeapon(item, weaponid, calibre, muzzvel, magsize, maxmags):
	return ItemTypeWeapon(item, weaponid, calibre, muzzvel, magsize, maxmags)

def DefineItemTypeAmmo(item, name, calibre, bleedmult, knockmult, penetration, capacity):
	return ItemTypeAmmo(item, name, calibre, bleedmult, knockmult, penetration, capacity)


def define_data():
	calibre_9mm		= DefineAmmoCalibre("9mm",		0.025)
	calibre_50cae	= DefineAmmoCalibre(".50",		0.073)
	calibre_12g		= DefineAmmoCalibre("12 Gauge",	0.031)
	calibre_556		= DefineAmmoCalibre("5.56mm",	0.019)
	calibre_357		= DefineAmmoCalibre(".357",		0.036)
	calibre_762		= DefineAmmoCalibre("7.62",		0.032)
	calibre_rpg		= DefineAmmoCalibre("RPG",		0.0)
	calibre_fuel	= DefineAmmoCalibre("Fuel",		0.0)
	calibre_film	= DefineAmmoCalibre("Film",		0.0)
	calibre_50bmg	= DefineAmmoCalibre(".50",		0.073)
	calibre_308		= DefineAmmoCalibre(".308",		0.043)

	calibres = [
		calibre_9mm,
		calibre_50cae,
		calibre_12g,
		calibre_556,
		calibre_357,
		calibre_762,
		calibre_rpg,
		calibre_fuel,
		calibre_film,
		calibre_50bmg,
		calibre_308
	]

	weapons = [
		DefineItemTypeWeapon("M9Pistol",   			"WEAPON_COLT45",  				calibre_9mm,	330.0,			10,		1),
		DefineItemTypeWeapon("M9PistolSD",   		"WEAPON_SILENCED",  			calibre_9mm,	295.0,			10,		1),
		DefineItemTypeWeapon("DesertEagle",   		"WEAPON_DEAGLE",  				calibre_357,	420.0,			7,		2),
		DefineItemTypeWeapon("PumpShotgun",   		"WEAPON_SHOTGUN",  				calibre_12g,	475.0,			6,		1),
		DefineItemTypeWeapon("Sawnoff",   			"WEAPON_SAWEDOFF",  			calibre_12g,	265.0,			2,		6),
		DefineItemTypeWeapon("Spas12",   			"WEAPON_SHOTGSPA",  			calibre_12g,	480.0,			6,		1),
		DefineItemTypeWeapon("Mac10",   			"WEAPON_UZI",  					calibre_9mm,	376.0,			32,		1),
		DefineItemTypeWeapon("MP5",   				"WEAPON_MP5",  					calibre_9mm,	400.0,			30,		1),
		DefineItemTypeWeapon("WASR3Rifle",   		"WEAPON_AK47",  				calibre_556,	943.0,			30,		1),
		DefineItemTypeWeapon("M16Rifle",   			"WEAPON_M4",  					calibre_556,	948.0,			30,		1),
		DefineItemTypeWeapon("Tec9",   				"WEAPON_TEC9",  				calibre_9mm,	360.0,			36,		1),
		DefineItemTypeWeapon("SemiAutoRifle",   	"WEAPON_RIFLE",  				calibre_357,	829.0,			5,		1),
		DefineItemTypeWeapon("SniperRifle",   		"WEAPON_SNIPER",  				calibre_357,	864.0,			5,		1),
		DefineItemTypeWeapon("RocketLauncher",   	"WEAPON_ROCKETLAUNCHER",  		calibre_rpg,	0.0,			1,		0),
		DefineItemTypeWeapon("Heatseeker",   		"WEAPON_HEATSEEKER",  			calibre_rpg,	0.0,			1,		0),
		DefineItemTypeWeapon("Flamer",   			"WEAPON_FLAMETHROWER",  		calibre_fuel,	0.0,			100,	1),
		DefineItemTypeWeapon("Minigun",   			"WEAPON_MINIGUN",  				calibre_556,	853.0,			100,	1),
		DefineItemTypeWeapon("RemoteBomb",   		"WEAPON_SATCHEL",  				-1,				0.0,			1,		1),
		DefineItemTypeWeapon("Detonator",   		"WEAPON_BOMB",  				-1,				0.0,			1,		1),
		DefineItemTypeWeapon("SprayPaint",   		"WEAPON_SPRAYCAN",  			-1,				0.0,			100,	0),
		DefineItemTypeWeapon("Extinguisher",   		"WEAPON_FIREEXTINGUISHER",  	-1,				0.0,			100,	0),
		DefineItemTypeWeapon("Camera",   			"WEAPON_CAMERA",  				calibre_film,	1337.0,			24,		4),
		DefineItemTypeWeapon("VehicleWeapon",   	"WEAPON_M4",  					calibre_556,	750.0,			0,		1),
		DefineItemTypeWeapon("AK47Rifle",   		"WEAPON_AK47",  				calibre_762,	715.0,			30,		1),
		DefineItemTypeWeapon("M77RMRifle",   		"WEAPON_RIFLE",  				calibre_357,	823.0,			1,		9),
		DefineItemTypeWeapon("DogsBreath",   		"WEAPON_DEAGLE",  				calibre_50bmg,	1398.6,			1,		9),
		DefineItemTypeWeapon("Model70Rifle",   		"WEAPON_SNIPER",  				calibre_308,	860.6,			1,		9),
		DefineItemTypeWeapon("LenKnocksRifle",   	"WEAPON_SNIPER",  				calibre_50bmg,	938.5,			1,		4)
	]

	ammo = [
		DefineItemTypeAmmo("Ammo9mm",   			"Hollow Point",		calibre_9mm,	1.0,	1.0,	0.2,	20),
		DefineItemTypeAmmo("Ammo50",   				"Action Express",	calibre_50cae,	1.0,	1.5,	0.9,	28),
		DefineItemTypeAmmo("AmmoBuck",   			"No. 1",			calibre_12g,	1.1,	1.8,	0.5,	24),
		DefineItemTypeAmmo("Ammo556",   			"FMJ",				calibre_556,	1.1,	1.2,	0.8,	30),
		DefineItemTypeAmmo("Ammo357",   			"FMJ",				calibre_357,	1.2,	1.1,	0.9,	10),
		DefineItemTypeAmmo("AmmoRocket",   			"RPG",				calibre_rpg,	1.0,	1.0,	2.0,	1),
		DefineItemTypeAmmo("GasCan",   				"Petrol",			calibre_fuel,	0.0,	0.0,	0.0,	20),
		DefineItemTypeAmmo("Ammo9mmFMJ",   			"FMJ",				calibre_9mm,	1.2,	0.5,	0.8,	20),
		DefineItemTypeAmmo("AmmoFlechette",   		"Flechette",		calibre_12g,	1.6,	0.6,	0.2,	8),
		DefineItemTypeAmmo("AmmoHomeBuck",   		"Improvised",		calibre_12g,	1.6,	0.4,	0.3,	14),
		DefineItemTypeAmmo("Ammo556Tracer",   		"Tracer",			calibre_556,	0.9,	1.1,	0.5,	30),
		DefineItemTypeAmmo("Ammo556HP",   			"Hollow Point",		calibre_556,	1.3,	1.6,	0.4,	30),
		DefineItemTypeAmmo("Ammo357Tracer",   		"Tracer",			calibre_357,	0.9,	1.1,	0.6,	10),
		DefineItemTypeAmmo("Ammo762",   			"FMJ",				calibre_762,	1.3,	1.1,	0.9,	30),
		DefineItemTypeAmmo("Ammo50BMG",   			"BMG",				calibre_50bmg,	2.0,	2.0,	1.0,	16),
		DefineItemTypeAmmo("Ammo308",   			"FMJ",				calibre_308,	1.2,	1.1,	0.8,	10)
	]

	return calibres, weapons, ammo



if __name__ == "__main__":
	app = AppMain()
	app.root.title("Scavenge and Survive Weapon Calculator")
	app.root.resizable(width=FALSE, height=FALSE)
	app.root.mainloop()

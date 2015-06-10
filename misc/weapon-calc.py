import tkinter
import math
import random
from tkinter import *
from tkinter import ttk


class AppMain(object):

	def __init__(self):

		self.root = tkinter.Tk()
		self.style = ttk.Style()

		# Load the data into lists
		self.calibres, self.weapons, self.ammo, self.bodyparts = define_data()


		#
		#	INPUTS FRAME
		#


		frame_inputs = ttk.Frame(self.root, relief=SUNKEN, borderwidth=15)

		# Frame title
		self.lab_inputs = ttk.Label(frame_inputs, text='Weapon and shot information:')

		# Weapon label
		self.lab_weapon = ttk.Label(frame_inputs, text='Weapon:')

		# Weapon input
		self.menu_weapons = ttk.Combobox(frame_inputs, width=40)
		self.menu_weapons.bind('<<ComboboxSelected>>', self.calculate_callback)
		self.menu_weapons['values'] = tuple(self.weapons)
		self.menu_weapons.current(0)

		# Ammo type label
		self.lab_ammo = ttk.Label(frame_inputs, text='Ammunition:')

		# Ammo type input
		self.menu_ammo = ttk.Combobox(frame_inputs)
		self.menu_ammo.bind('<<ComboboxSelected>>', self.calculate_callback)
		self.menu_ammo['values'] = tuple(self.ammo)
		self.menu_ammo.current(0)

		# Distance label
		self.lab_distance = ttk.Label(frame_inputs, text='Distance:')

		# Distance slider
		self.sli_distance = Scale(frame_inputs, from_=0, to=200, orient=HORIZONTAL)
		self.sli_distance.set(30)
		self.sli_distance.bind("<B1-Motion>", self.calculate_callback)

		# Body part label
		self.lab_bodypart = ttk.Label(frame_inputs, text='Body part:')

		# Body part menu
		self.menu_bodypart = ttk.Combobox(frame_inputs, width=40)
		self.menu_bodypart.bind('<<ComboboxSelected>>', self.calculate_callback)
		self.menu_bodypart['values'] = tuple(self.bodyparts)
		self.menu_bodypart.current(0)

		# Simulate shot button
		self.btn_fireshot = ttk.Button(frame_inputs, text='Fire Shot', width=80)
		self.btn_fireshot.bind('<Button-1>', self.simulate_shot_callback)

		# Grid stuff
		frame_inputs.grid		(column=0, row=0, sticky=(N, S, E, W))
		self.lab_inputs.grid	(column=0, row=0, sticky=(N, S, E, W), columnspan=2)
		self.lab_weapon.grid	(column=0, row=1, sticky=(E, W))
		self.menu_weapons.grid	(column=1, row=1, sticky=(E, W))
		self.lab_ammo.grid		(column=0, row=2, sticky=(E, W))
		self.menu_ammo.grid		(column=1, row=2, sticky=(E, W))
		self.lab_distance.grid	(column=0, row=3, sticky=(E, W))
		self.sli_distance.grid	(column=1, row=3, sticky=(E, W))
		self.lab_bodypart.grid	(column=0, row=4, sticky=(E, W))
		self.menu_bodypart.grid	(column=1, row=4, sticky=(E, W))
		self.btn_fireshot.grid	(sticky=(N, S, E, W), columnspan=2)


		#
		#	TARGET ATTRIBUTES FRAME
		#


		frame_target = ttk.Frame(self.root, relief=SUNKEN, borderwidth=15)

		# Frame title
		self.lab_target = ttk.Label(frame_target, text='Shot target attributes:')

		# Target wounds label
		self.lab_wounds = ttk.Label(frame_target, text='Wounds:')

		# Target wounds slider
		self.sli_wounds = Scale(frame_target, from_=0, to=64, orient=HORIZONTAL)
		self.sli_wounds.set(0)
		self.sli_wounds.bind("<B1-Motion>", self.calculate_callback)

		# Target bleed rate label
		self.lab_bleed = ttk.Label(frame_target, text='Bleed rate:')

		# Total bleed rate input
		self.ent_totalbleed_string = StringVar()
		self.ent_totalbleed = Spinbox(frame_target, from_=0.0, to=1.0, increment=0.001, textvariable=self.ent_totalbleed_string)
		self.ent_totalbleed_string.set("0.0")
		self.ent_totalbleed.bind("<Key>", self.calculate_callback)
		self.ent_totalbleed.bind("<Button-1>", self.calculate_callback)

		# Reset health button
		self.btn_resetbleed = ttk.Button(frame_target, text='0', width=1)
		self.btn_resetbleed.bind('<Button-1>', self.reset_bleed)

		# Target health label
		self.lab_health = ttk.Label(frame_target, text='Health:')

		# Target health slider
		self.sli_health = Scale(frame_target, from_=0, to=100, orient=HORIZONTAL, resolution=0.1)
		self.sli_health.set(100.0)
		self.sli_health.bind("<B1-Motion>", self.calculate_callback)

		# Target armour label
		self.lab_armour = ttk.Label(frame_target, text='Armour:')

		# Target armour slider
		self.sli_armour = Scale(frame_target, from_=0, to=100, orient=HORIZONTAL, resolution=0.1)
		self.sli_armour.set(0.0)
		self.sli_armour.bind("<B1-Motion>", self.calculate_callback)

		self.chk_knockedout_int = IntVar()
		self.chk_knockedout = Checkbutton(frame_target, text="Knocked out", variable=self.chk_knockedout_int)


		# Grid stuff
		frame_target.grid		(column=0, row=1, sticky=(N, S, E, W))
		self.lab_target.grid	(column=0, row=0, sticky=(N, S, E, W), columnspan=2)
		self.lab_wounds.grid	(column=0, row=1, sticky=(E, W))
		self.sli_wounds.grid	(column=1, row=1, sticky=(E, W))
		self.lab_bleed.grid		(column=0, row=2, sticky=(E, W))
		self.ent_totalbleed.grid(column=1, row=2, sticky=(E, W))
		self.btn_resetbleed.grid(column=2, row=2, sticky=(E, W))
		self.lab_health.grid	(column=0, row=3, sticky=(E, W))
		self.sli_health.grid	(column=1, row=3, sticky=(E, W))
		self.lab_armour.grid	(column=0, row=4, sticky=(E, W))
		self.sli_armour.grid	(column=1, row=4, sticky=(E, W))
		self.chk_knockedout.grid(column=0, row=5, sticky=(E, W))


		#
		#	OUTPUT FRAME
		#


		frame_outputs = ttk.Frame(self.root, relief=SUNKEN, borderwidth=15)

		# Frame title
		self.lab_outputs = ttk.Label(frame_outputs, text='Output results:')

		self.output_bulletvel = self.create_output(frame_outputs, "Bullet velocity at impact:", 1)
		self.output_veldegrad = self.create_output(frame_outputs, "Velocity degradation rate:", 2)
		self.output_bleedrate = self.create_output(frame_outputs, "Bleed rate:", 3)
		self.output_knockout = self.create_output(frame_outputs, "Knockout multiplier:", 4)
		self.output_bloodloss = self.create_output(frame_outputs, "Instant blood loss:", 5)
		self.output_armourloss = self.create_output(frame_outputs, "Armour damage:", 6)
		self.output_timetolive = self.create_output(frame_outputs, "Worst case time to live:", 7)
		self.output_finalknock = self.create_output(frame_outputs, "Knockout chance:", 8)
		self.output_knocktime = self.create_output(frame_outputs, "Knockout time:", 9)
		self.output_shotstokill = self.create_output(frame_outputs, "Shots to kill:", 10)
		self.output_timetokill = self.create_output(frame_outputs, "Instant blood loss TTK:", 11)
		self.output_firerate = self.create_output(frame_outputs, "Rate of fire:", 12)

		self.btn_calculate = ttk.Button(frame_outputs, text='Calculate', width=80)
		self.btn_calculate.bind('<Button-1>', self.calculate_callback)


		# Grid stuff
		frame_outputs.grid		(column=0, row=2, sticky=(N, S, E, W))
		self.lab_outputs.grid	(column=0, row=0, sticky=(N, S, E, W), columnspan=2)
		self.btn_calculate.grid	(sticky=(N, S, E, W), columnspan=2)

		# Calculate with the default values and update the UI
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


	def calculate_callback(self, event):

		self.update_ui()


	def update_ui(self):

		bulletvelocity, velocitydegredationrate, bleedrate, knockmult, hploss, aploss, timetolive, knockchance, knockouttime, shotstokill, timetokill, firerate = self.calculate()

		self.update_output(self.output_bulletvel, round(bulletvelocity, 8), "m/s")
		self.update_output(self.output_veldegrad, round(velocitydegredationrate, 8))
		self.update_output(self.output_bleedrate, round(bleedrate, 8))
		self.update_output(self.output_knockout, round(knockmult, 8))
		self.update_output(self.output_bloodloss, round(hploss, 8), "hp")
		self.update_output(self.output_armourloss, round(aploss, 8), "ap")
		self.update_output(self.output_timetolive, round(timetolive), "s")
		self.update_output(self.output_finalknock, round(knockchance, 8), "%")
		self.update_output(self.output_knocktime, knockouttime, "ms")
		self.update_output(self.output_shotstokill, shotstokill, " shots")
		self.update_output(self.output_timetokill, timetokill, "ms")
		self.update_output(self.output_firerate, firerate, "RPM")


	def calculate(self):

		weapon_key = self.menu_weapons.current()
		ammo_key = self.menu_ammo.current()
		bodypart = self.menu_bodypart.current()

		if weapon_key == -1 or ammo_key == -1 or bodypart == -1:
			return

		weapon = self.weapons[weapon_key]
		ammotype = self.ammo[ammo_key]

		bulletvelocity = 0.0
		velocitydegredationrate = 0.0
		bleedrate = 0.0
		knockmult = 0.0
		hploss = 0.0
		aploss = 0.0
		timetolive = 0
		knockchance = 0.0
		knockouttime = 0
		shotstokill = 0
		timetokill = 0
		firerate = 0.0

		if weapon.calibre != ammotype.calibre:
			for i, a in enumerate(self.ammo):
				if a.calibre == weapon.calibre:
					ammotype = a
					self.menu_ammo.current(i)
					break

			else:
				return bulletvelocity, velocitydegredationrate, bleedrate, knockmult, hploss, aploss, timetolive, knockchance, knockouttime, shotstokill, timetokill, firerate

		bleedrate = weapon.calibre.bleedrate;
		knockmult = 1.0
		bulletvelocity = weapon.muzzvel;
		distance = float(self.sli_distance.get())
		totalbleedrate = float(self.ent_totalbleed.get())
		hp = float(self.sli_health.get())
		ap = float(self.sli_armour.get())


		velocitydegredationrate = 1.0 - (bulletvelocity / 11300)

		bulletvelocity -= math.pow(distance, velocitydegredationrate)

		bleedrate *= bulletvelocity / 1000.0

		knockmult *= bulletvelocity / 50.0

		bleedrate *= ammotype.get_bleed_multiplier()
		knockmult *= ammotype.get_knockout_multiplier()

		if ap > 0.0:
			bleedrate *= ammotype.penetration
			aploss = ((ap + 10) * (bleedrate * 10.0))

		if bodypart == 0: knockmult *= 1.0
		if bodypart == 1: knockmult *= 1.2
		if bodypart == 2: knockmult *= 0.9
		if bodypart == 3: knockmult *= 0.9
		if bodypart == 4: knockmult *= 0.8
		if bodypart == 5: knockmult *= 0.8
		if bodypart == 6: knockmult *= 9.9

		hploss = (bleedrate * 100)

		woundcount = self.sli_wounds.get()

		knockchance = knockmult * (((woundcount + 1) * 0.2) * ((totalbleedrate * 50) + 1))

		timetolive = 0

		if totalbleedrate > 0.0:
			timetolive = hp / (totalbleedrate * 10)

		knockouttime = round((knockmult * 0.2) * ((woundcount + 1) * ((totalbleedrate * 10) + 1) * (110.0 - hp) + (200 * (110.0 - hp))));

		if hploss > 0.0:
			shotstokill = math.ceil(hp / hploss)

		timetokill = shotstokill * weapon.shotinterval

		if weapon.shotinterval > 0:
			firerate = (1000 / weapon.shotinterval) * 60

		return bulletvelocity, velocitydegredationrate, bleedrate, knockmult, hploss, aploss, timetolive, knockchance, knockouttime, shotstokill, timetokill, firerate


	def simulate_shot_callback(self, event):

		self.simulate_shot()
		self.update_ui()


	def simulate_shot(self):

		bulletvelocity, velocitydegredationrate, bleedrate, knockmult, hploss, aploss, timetolive, knockchance, knockouttime, shotstokill, timetokill, firerate = self.calculate()

		health = self.sli_health.get()
		armour = self.sli_armour.get()

		self.sli_health.set(health - hploss)
		self.sli_armour.set(armour - aploss)

		self.sli_wounds.set(self.sli_wounds.get() + 1)

		knockrand = (random.random() * 100.0)

		if knockrand < knockchance:
			self.chk_knockedout_int.set(1)

		self.ent_totalbleed_string.set(str(round(float(self.ent_totalbleed_string.get()) + bleedrate, 8)))


	def reset_bleed(self, event):

		self.ent_totalbleed_string.set(0.0)
		self.update_ui()


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

		if   weaponid == "WEAPON_COLT45":			self.shotinterval = 300
		elif weaponid == "WEAPON_SILENCED":			self.shotinterval = 400
		elif weaponid == "WEAPON_DEAGLE":			self.shotinterval = 800
		elif weaponid == "WEAPON_SHOTGUN":			self.shotinterval = 1060
		elif weaponid == "WEAPON_SAWEDOFF":			self.shotinterval = 300
		elif weaponid == "WEAPON_SHOTGSPA":			self.shotinterval = 320
		elif weaponid == "WEAPON_UZI":				self.shotinterval = 120
		elif weaponid == "WEAPON_MP5":				self.shotinterval = 100
		elif weaponid == "WEAPON_AK47":				self.shotinterval = 120
		elif weaponid == "WEAPON_M4":				self.shotinterval = 120
		elif weaponid == "WEAPON_TEC9":				self.shotinterval = 120
		elif weaponid == "WEAPON_RIFLE":			self.shotinterval = 1060
		elif weaponid == "WEAPON_SNIPER":			self.shotinterval = 1060
		elif weaponid == "WEAPON_ROCKETLAUNCHER":	self.shotinterval = 1000
		elif weaponid == "WEAPON_HEATSEEKER":		self.shotinterval = 1000
		elif weaponid == "WEAPON_FLAMETHROWER":		self.shotinterval = 20
		elif weaponid == "WEAPON_MINIGUN":			self.shotinterval = 20
		else: self.shotinterval = 0

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
	calibre_none	= DefineAmmoCalibre("None",		0.0)
	calibre_9mm		= DefineAmmoCalibre("9mm",		0.25)
	calibre_50cae	= DefineAmmoCalibre(".50",		0.73)
	calibre_12g		= DefineAmmoCalibre("12 Gauge",	0.31)
	calibre_556		= DefineAmmoCalibre("5.56mm",	0.19)
	calibre_357		= DefineAmmoCalibre(".357",		0.36)
	calibre_762		= DefineAmmoCalibre("7.62",		0.32)
	calibre_rpg		= DefineAmmoCalibre("RPG",		0.0)
	calibre_fuel	= DefineAmmoCalibre("Fuel",		0.0)
	calibre_film	= DefineAmmoCalibre("Film",		0.0)
	calibre_50bmg	= DefineAmmoCalibre(".50",		0.63)
	calibre_308		= DefineAmmoCalibre(".308",		0.43)

	calibres = [
		calibre_none,
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
		DefineItemTypeWeapon("RemoteBomb",   		"WEAPON_SATCHEL",  				calibre_none,	0.0,			1,		1),
		DefineItemTypeWeapon("Detonator",   		"WEAPON_BOMB",  				calibre_none,	0.0,			1,		1),
		DefineItemTypeWeapon("SprayPaint",   		"WEAPON_SPRAYCAN",  			calibre_none,	0.0,			100,	0),
		DefineItemTypeWeapon("Extinguisher",   		"WEAPON_FIREEXTINGUISHER",  	calibre_none,	0.0,			100,	0),
		DefineItemTypeWeapon("Camera",   			"WEAPON_CAMERA",  				calibre_film,	1337.0,			24,		4),
		DefineItemTypeWeapon("VehicleWeapon",   	"WEAPON_M4",  					calibre_556,	750.0,			0,		1),
		DefineItemTypeWeapon("AK47Rifle",   		"WEAPON_AK47",  				calibre_762,	715.0,			30,		1),
		DefineItemTypeWeapon("M77RMRifle",   		"WEAPON_RIFLE",  				calibre_357,	823.0,			1,		9),
		DefineItemTypeWeapon("DogsBreath",   		"WEAPON_DEAGLE",  				calibre_50bmg,	888.8,			1,		9),
		DefineItemTypeWeapon("Model70Rifle",   		"WEAPON_SNIPER",  				calibre_308,	860.6,			1,		9),
		DefineItemTypeWeapon("LenKnocksRifle",   	"WEAPON_SNIPER",  				calibre_50bmg,	938.5,			1,		4)
	]

	ammo = [
		DefineItemTypeAmmo("None",   				"",					calibre_none,	0.0,	0.0,	0.0,	0),
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
		DefineItemTypeAmmo("Ammo50BMG",   			"BMG",				calibre_50bmg,	1.8,	1.8,	1.0,	16),
		DefineItemTypeAmmo("Ammo308",   			"FMJ",				calibre_308,	1.2,	1.1,	0.8,	10)
	]

	bodyparts = [
		"Torso",
		"Groin",
		"Left arm",
		"Right arm",
		"Left leg",
		"Right leg",
		"Head"
	]

	return calibres, weapons, ammo, bodyparts



if __name__ == "__main__":
	app = AppMain()
	app.root.title("Scavenge and Survive Weapon Calculator")
	app.root.resizable(width=FALSE, height=FALSE)
	app.root.mainloop()

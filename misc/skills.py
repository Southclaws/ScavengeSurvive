# Skills/experience formula test code


def gain(exp):
	return 0.1 * ((3 * pow(exp, 2) - 2 * pow(exp, 3)))


def exp_to_time_modifier(exp):
	return round(pow(exp * 100, 2))


def main():
	exp = 0.01
	i = 0

	while exp < 1.0:
		gained = gain(exp)
		exp += gained
		print(exp, " + ", gained, "25000 -=", exp_to_time_modifier(exp), " = ", round(25000 - exp_to_time_modifier(exp)))
		i += 1

	print("iterations:", i)


if __name__ == '__main__':
	main()

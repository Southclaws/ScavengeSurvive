# Skills/experience formula test code


def gain(experience_value):
	return 0.001 + 0.001 * (
		(3 * pow(experience_value, 2) -
			2 * pow(experience_value, 3)))


def exp_to_time_modifier(time, exp):
	return round(time - time * (0.5 * exp))


def main():
	exp = 0.0
	i = 0

	while exp < 1.0:
		gained = gain(exp)
		exp = min(1.0, exp + gained)

		modifier05s = exp_to_time_modifier(5000, exp)
		modifier30s = exp_to_time_modifier(30000, exp)
		modifier60s = exp_to_time_modifier(60000, exp)

		print(
			i,
			exp,
			" + ",
			gained,
			modifier05s,
			modifier30s,
			modifier60s)

		i += 1

	print("iterations:", i)


if __name__ == '__main__':
	main()

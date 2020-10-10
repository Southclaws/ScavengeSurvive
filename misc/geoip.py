import maxminddb

def lookup(*args):
	ipstring = args[0]

	result = ""

	try:
		reader = maxminddb.open_database('GeoLite2-Country.mmdb')
		ipdata = reader.get(ipstring)
		reader.close()
		result = ipdata['country']['names']['en']

	except maxminddb.InvalidDatabaseError:
		result = "InvalidDatabaseError"

	except FileNotFoundError:
		result = "FileNotFoundError"

	except ValueError:
		result = "ValueError"

	return result

require 'marky_markov'
require 'json'
require 'twitter'


# read settings
file = File.read('config.json')
data = JSON.parse(file)


CONSUMER_KEY = data["consumer_key"]
CONSUMER_SECRET = data["consumer_secret"]
ACCESS_TOKEN = data["access_token"]
ACCESS_SECRET = data["access_secret"]
LOG_DIRECTORY = data["log_directory"]


# open dict
markov = MarkyMarkov::Dictionary.new('logdict')


if ARGV[0] == "build"
	Dir.foreach(LOG_DIRECTORY) do |item|

		next if item == '.' or item == '..'

		puts "Parsing file " + item + "..."
		#todo extract [chat] only with grep or something
		markov.parse_file LOG_DIRECTORY + item
		puts "Parsing complete!"

	end
	markov.save_dictionary!
end


# post a tweet

client = Twitter::REST::Client.new do |config|
	config.consumer_key        = CONSUMER_KEY
	config.consumer_secret     = CONSUMER_SECRET
	config.access_token        = ACCESS_TOKEN
	config.access_token_secret = ACCESS_SECRET
end

s = markov.generate_1_sentence
puts s

begin
	client.update(s)
rescue => error
	puts error.message
end

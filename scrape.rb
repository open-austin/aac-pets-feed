require 'bundler'
Bundler.require
require 'time'
require 'json'
require_relative 'models/image'
require_relative 'api-config'

pa_client = HTTP.auth(:basic, user: API[:USERNAME], pass: API[:PASSWORD])

client = SODA::Client.new domain: 'data.austintexas.gov'
results = client.get 'hjeh-idye', {'$limit'=>50000}
puts "Retrieved #{results.count} results..."

def result_to_hash(result)
	intake_date = result.intake_date.split('/')
	{
		species: result.animal_type.downcase,
		name: result.name,
		image: Image.from_pet_id(result.animal_id).url,
		pet_id: result.animal_id,
		gender: result.sex_upon_intake.match(/(Fem|fem)ale/) ? 'female' : 'male',
		fixed: !result.sex_upon_intake.match(/(I|i)ntact/),
		breed: result.breed,
		found_on: Time.new("20#{intake_date[2]}", intake_date[0], intake_date[1]).iso8601,
		scraped_at: Time.now.to_s,
		shelter_name: 'Austin Animal Center',
		color: result.color,
		active: true
	}
end

puts 'Getting pet ids from Pet Alerts...'
pets_in_database = JSON.parse pa_client.get("#{API[:BASEURL]}/pets/external-ids").body

puts 'Limiting push set...'
unscraped_results = results.select {|result| !pets_in_database.include? result.animal_id }

puts 'Formatting result data...'
result_hashes = unscraped_results.each_with_index.reduce({}) do |hashes, (result, index)|
	hashes[index.to_s.to_sym] = result_to_hash(result)
	hashes
end

puts "Posting #{result_hashes.count} pets to Pet Alerts..."
res = pa_client.post "#{API[:BASEURL]}/populator/update", json: { pets: result_hashes }

puts res.code != 200 ? res.body : 'Everything looks good...'

# EXAMPLE DATA RETURNED FROM AAC
# [["sex_upon_intake", "Intact Male"],
#  ["breed", "Dachshund/Chihuahua Shorthair"],
#  ["intake_condition", "Normal"],
#  ["color", "Sable/Tan"],
#  ["name", "Louie"],
#  ["age_upon_intake", "4 months"],
#  ["intake_date", "10/01/14"],
#  ["found_location", "3005 S. Lamar in Austin (TX)"],
#  ["animal_type", "Dog"],
#  ["intake_type", "Stray"],
#  ["intake_time", "7:21AM"],
#  ["animal_id", "A689228"]]

require 'bundler'
Bundler.require
require 'optparse'
require_relative 'models/image'
require_relative 'api-config'

http = HTTP.auth(:basic, user: API[:USERNAME], pass: API[:PASSWORD])
res = http.get "#{API[:BASEURL]}/pets/without-images"

pets = JSON.parse res

puts "#{pets.count} results received..."

pets.each do |pet_hash|
	image = Image.from_pet_id pet_hash['remote_id']
	http.post "#{API[:BASEURL]}/pet/#{pet_hash['id']}/reconcile-image", json: { image: image.url }
end

puts "Everything looks good..."

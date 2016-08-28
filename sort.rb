require 'open-uri'
require 'json'

films_file = File.read('films/films.json')

films_abc = JSON[films_file].sort_by { |f| f['name'].downcase }

File.open("films/films_abc.json","w") do |f|
  f.write(JSON.pretty_generate(films_abc))
end

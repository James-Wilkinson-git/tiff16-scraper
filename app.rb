require 'nokogiri'
require 'open-uri'
require 'json'

urls_file = 'urls.json'
urls = Array.new
urlsDOM = Nokogiri::HTML(open('http://tiff.net/?filter=festival'), nil, 'utf-8')
tiff_urls = urlsDOM.css("#calendar .container .row .card.festival .card-title")

tiff_urls.each do |url|
  # don't strip spaces in urls, gsub them with url encoded %20 instead
  href = url['href'].gsub(' ', '%20')
  if href.match(/^films/)
    urls.push("http://tiff.net/#{href}")
  end
end
File.open("urls.json", "w") do |f|
  f.write(JSON.pretty_generate(urls))
end

films = Array.new

for url in urls do
  tiffDOM = Nokogiri::HTML(open(url), nil, 'utf-8')
  film = Hash.new
  film["name"] = tiffDOM.css("body #wrap .container h1").text || "N/A"
  film["program"] = tiffDOM.css("body #wrap > div:nth-child(2) > p.center.type > a").text || "N/A"
  film["director"] = tiffDOM.css("#director .credit-content").text || "N/A"
  film["countries"] = tiffDOM.css("span.quick-info .countries").text || "N/A"
  film["runtime"] = tiffDOM.css("span.quick-info .runtime").text || "N/A"
  film["premiere"] = tiffDOM.css("span.quick-info .premiere").text || "N/A"
  film["year"] = tiffDOM.css("span.quick-info .year").text || "N/A"
  film["language"] = tiffDOM.css("span.quick-info .language").text || "N/A"
  film["pitch"] = tiffDOM.css(".pitch").text || "N/A"
  film["production"] = tiffDOM.css("#productionCompany .credit-content").text || "N/A"
  film["producers"] = tiffDOM.css("#producers .credit-content").text || "N/A"
  film["screenplay"] = tiffDOM.css("#screenplay .credit-content").text || "N/A"
  film["cinematographers"] = tiffDOM.css("#cinematographers .credit-content").text || "N/A"
  film["editors"] = tiffDOM.css("#editors .credit-content").text || "N/A"
  film["score"] = tiffDOM.css("#originalScore .credit-content").text || "N/A"
  film["sound"] = tiffDOM.css("#sound .credit-content").text || "N/A"
  film["cast"] = tiffDOM.css("#cast .credit-content").text || "N/A"
  imageDom = tiffDOM.at_css("#work-images img")
  if !imageDom.nil?
    film["image"] = "https:" + imageDom.attr("src").to_str().split("?")[0] + "?w=300&q=40"
  end
  film["url"] = url
  film["schedule"] = []
  scheduleDom = tiffDOM.css("#schedule-buttons > div")
  for dateDom in scheduleDom
    dateid = dateDom.attr("id")[0...-3].to_i
    date = Time.at(dateid).strftime('%A %B %e')
    hash = {:date => date, :shows => []}
    timeDom = tiffDOM.css("#" + dateDom.attr("id") + " a")
    for time in timeDom
      timeHash = {}
      timeHash[:time] = time.css(".time").text
      timeHash[:location] = time.css(".flags .location").text
      timeHash[:press] = time.at_css("i.press-industry") ? true : false
      timeHash[:premium] = time.at_css(".flag.premium") ? true : false
      hash[:shows].push(timeHash)
    end

    film["schedule"].push(hash)
  end
  films.push(film)
end

File.open("films/films.json","w") do |f|
  f.write(JSON.pretty_generate(films))
end

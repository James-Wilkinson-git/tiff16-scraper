require 'nokogiri'
require 'open-uri'
require 'json'
require 'date'

urls = ["http://www.tiff.net/films/the-man-trap/", "http://www.tiff.net/films/x-quinientos/"]

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
  film["screenplay"] = tiffDOM.css("#screenplay .credit-content").text
  film["cinematographers"] = tiffDOM.css("#cinematographers .credit-content").text
  film["editors"] = tiffDOM.css("#editors .credit-content").text
  film["score"] = tiffDOM.css("#originalScore .credit-content").text
  film["sound"] = tiffDOM.css("#sound .credit-content").text
  film["cast"] = tiffDOM.css("#cast .credit-content").text
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

File.open("films/schedule.json","w") do |f|
  f.write(JSON.pretty_generate(films))
end

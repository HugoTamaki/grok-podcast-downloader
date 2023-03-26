require 'mechanize'
require 'thread/pool'

agent = Mechanize.new
agent.get("https://www.grokpodcast.com.br")

posts = agent.page.search(".serie-posts")

pool = Thread.pool(3)

posts.each do |post|
  pool.process do
    links = post.search("a")
    links.each do |link|
      url = "https://www.grokpodcast.com.br#{link.attributes["href"].value}"
      post_page = agent.get(url)
      download_element = post_page.search(".download-podcast").first
      folder_name = post_page.search("#serie-name").search("a").first.text

      puts "Saving #{download_element["download"]}..."
      agent.get(download_element["href"]).save("grokpodcast/#{folder_name}/#{download_element["download"]}")
    end
  end
end

pool.shutdown
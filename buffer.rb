require 'rubygems'
require 'bundler'

Bundler.require(:default)

require 'buffer'
require 'nokogiri'
require 'excon'

def get_response(url, referer)
  opts = {
    headers: {
      'User-Agent' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
      'Referer' => referer
    },
    omit_default_port: true,
    idempotent: true,
    retry_limit: 6,
    read_timeout: 360,
    connect_timeout: 360
  }
  connection = Excon.new(url, opts)
  response = connection.request(method: :get)

  if response.status == 200
    response.body
  else
    return nil
  end
end


ISSUE_NUMBER = "24"

response = get_response("http://botweekly.com/issues/#{ISSUE_NUMBER}", 'http://botweekly.com')
doc = Nokogiri::HTML.parse(response)
client = Buffer::Client.new(ENV['BUFFER_ACCESS_TOKEN'])

PROFILE_IDS = [
  # Twitter
  '579826d6a97d6abb4821b090',
]

doc.css('div.item--link a > img').each do |image_elem|
  link_id = nil
  title = nil
  image = nil

  title = image_elem.attr('title').to_s.strip
  image = image_elem.attr('src').to_s.strip
  link_href = image_elem.parent.attr('href').to_s.strip

  if (matcher = link_href.match(/http:\/\/cur\.at\/(.*?)[\?$]/im))
    link_id = matcher[1]
  end

  if !link_id.nil? && !title.nil? && !image.nil?
    link = "http://botweekly.com/issues/#{ISSUE_NUMBER}##{link_id}"

    response = client.create_update(
      body: {
        profile_ids: PROFILE_IDS,
        text: "Issue #{ISSUE_NUMBER}: #{title}\n\n#{link}",
        shorten: false,
        media: {
          link: link,
          photo: image
        }
      }
    )

    if response.success
      puts "Submitted #{title} | #{link} | #{image} to Buffer!"
    else
      puts "Error submitting #{title}, response: #{response.inspect}"
    end
  end
end

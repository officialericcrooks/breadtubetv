require 'json'
require 'open-uri'
require 'ostruct'
require 'psych'

results = JSON.parse open("http://localhost:1337/channels").read

class Hash
  def to_ostruct
    JSON.parse to_json, object_class: OpenStruct
  end
end

results.each do |result|
  channel = result.to_ostruct
  channel_path = "channels/#{ channel.slug }"
  channel_folder = "content/#{ channel_path }/"

  `rm -rf #{ channel_folder }`
  `hugo new --kind channel "#{ channel_path }"`

  channel_page = "#{ channel_folder }_index.md"

  File.open(channel_page, 'r+') do |file|
    file.seek(-4, IO::SEEK_END)
    file.puts("title: |\n  #{ channel.name }")
    file.puts("slug: #{ channel.slug }")
    file.puts("url: /#{ channel.slug }/")
    file.puts("date: #{ channel.created_at }")
    file.puts("description: |\n  #{ channel.description }")
    file.puts("image: #{ channel.image.url }")
    file.puts("---")
  end

  channel.contents.each do |content|
    content_slug = content.slug
    content_path = "#{ channel_path }/#{ content_slug }"
    content_folder = "content/#{ content_path }/"

    `hugo new --kind content "#{ content_path }"`

    content_page = "#{ content_folder }_index.md"

    File.open(content_page, 'r+') do |file|
      file.seek(-4, IO::SEEK_END)
      file.puts("title: |\n  #{ content.name }")
      file.puts("slug: #{ content.slug }")
      file.puts("url: /#{ channel.slug }/#{ content.slug }/")
      file.puts("date: #{ channel.created_at }")
      file.puts("description: |\n  #{ content.description }")
      file.puts("image: #{ content.image.url }")
      file.puts("---")
    end
  end
end

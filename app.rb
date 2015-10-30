# require 'sinatra'
require 'vk-ruby'
require 'redis'
require 'telegram/bot'


def get_posts
	app = VK::Application.new(app_id: 1, version: '5.37')
	posts = app.wall.get owner_id: -30666517, count: 20
	posts["items"]
end

def return_largest_photo attr_photos
	photo = attr_photos.keep_if {|x| /photo_\d+/ =~ x}.sort_by{|k, v| k.split(/\D/).join.to_i}
	photo[-1][-1] # returns value of last element in sorted structure
end

host = "pub-redis-13908.us-east-1-4.5.ec2.garantiadata.com"
port = 13908
redis_pass = File.read('redis_pass.dat')
redis = Redis.new(:host => host, :port => port, :password => redis_pass)

token = File.read('token.dat')

posts = get_posts

Telegram::Bot::Client.run(token) do |bot|
	posts.each do |post|
		text = post["text"]

		if post.has_key? 'attachments'
			post["attachments"].each do |attachment|
				if attachment["type"] == "link"
					a = attachment["link"]
					text << "\n" + a["url"]
				elsif attachment["type"] == "photo"
					text << "\n" + return_largest_photo(attachment['photo'])
				elsif attachment["type"] == "video"
					# puts "video"
					# puts attachment
				end
			end
		end

		if text.length >= 16
			bot.api.sendMessage(chat_id: '@VK_tproger', text: text)
		end
	end
end

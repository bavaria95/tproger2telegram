# require 'sinatra'
require 'vk-ruby'
require 'redis'
require 'telegram/bot'

group_id = 30666517

def get_posts group_id
	app = VK::Application.new(app_id: 1, version: '5.37')
	posts = app.wall.get owner_id: -group_id, count: 20
	posts["items"]
end

def return_largest_photo attr_photos
	photo = attr_photos.keep_if {|x| /photo_\d+/ =~ x}.sort_by{|k, v| k.split(/\D/).join.to_i}
	photo[-1][-1] # returns value of last element in sorted structure
end

host = "pub-redis-12892.us-east-1-4.5.ec2.garantiadata.com"
port = 12892
redis_pass = File.read('redis_pass.dat')
redis = Redis.new(:host => host, :port => port, :password => redis_pass)

token = File.read('token.dat')

posts = get_posts group_id

Telegram::Bot::Client.run(token) do |bot|
	posts.each do |post|
		pid = post["id"]
		unless redis.sismember(group_id.to_s, pid)
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

			redis.sadd(group_id.to_s, pid)
		end
	end
end

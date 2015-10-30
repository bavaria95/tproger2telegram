# require 'sinatra'
require 'vk-ruby'
require 'redis'
require 'telegram/bot'


def get_posts
	app = VK::Application.new(app_id: 1, version: '5.37')
	posts = app.wall.get owner_id: -30666517, count: 20
	posts["items"]
end

host = "pub-redis-13908.us-east-1-4.5.ec2.garantiadata.com"
port = 13908
redis_pass = File.read('redis_pass.dat')
redis = Redis.new(:host => host, :port => port, :password => redis_pass)

token = File.read('token.dat')

posts = get_posts
post = posts[3]

Telegram::Bot::Client.run(token) do |bot|
	bot.api.sendMessage(chat_id: '@VK_tproger', text: post["text"])
	post["attachments"].each do |attachment|
		if attachment["type"] == "link"
			bot.api.sendMessage(chat_id: '@VK_tproger', text: attachment["link"]["url"])
		elsif attachment["type"] == "photo"
			bot.api.sendMessage(chat_id: '@VK_tproger', text: "there should be some photo")
		elsif attachment["type"] == "video"
			bot.api.sendMessage(chat_id: '@VK_tproger', text: "there should be some video URL")
		end
	end
end

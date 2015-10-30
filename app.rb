# require 'sinatra'
require 'vk-ruby'
require 'redis'


def get_posts
	app = VK::Application.new(app_id: 1, version: '5.37')
	posts = app.wall.get owner_id: -30666517, count: 20
	posts["items"]
end

host = "pub-redis-13908.us-east-1-4.5.ec2.garantiadata.com"
port = 13908
redis_pass = File.read('redis_pass.dat')

redis = Redis.new(:host => host, :port => port, :password => redis_pass)

posts = get_posts
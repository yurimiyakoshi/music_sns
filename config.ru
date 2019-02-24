require 'bundler'
Bundler.require

require './app'

Dotenv.load

Cloudinary.config do |config|
  config.cloud_name = "dgr8cnpfv"
  config.api_key    = "593827296312283"
  config.api_secret = "FU7qgghDeYZ4jFaXteJR4WBd2tA"
end

run Sinatra::Application

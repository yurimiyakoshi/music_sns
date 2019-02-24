require 'bundler/setup'
Bundler.require

if development?
  ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class Song < ActiveRecord::Base
  belongs_to :user
end

class User < ActiveRecord::Base
  has_many :songs
  has_secure_password
  validates :password,
  length: {in: 5..15}
end
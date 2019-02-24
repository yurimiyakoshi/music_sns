require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require 'sinatra/json'
require './image_uploader.rb'
require './models'
require 'bcrypt'
require 'pry'

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

#新規登録するページだよ
get '/signup' do
  erb :sign_up
end

# 新規登録ボタン押したよ
post '/signup' do
  @user = User.create(
    name: params[:name],
    password: params[:password],
    password_confirmation: params[:password_confirmation],
    user_img: ""
  )
  if @user.persisted?
    session[:user] = @user.id
  end
  if params[:file]
    image_upload(params[:file])
  else
  default_img = User.first.user_img
  @user.update(
    user_img: default_img
  )
  end
  redirect '/search'
end

# ログインページ
# get '/signin' do
#   erb :sign_in
# end

#ログインする
post '/signin' do
  user = User.find_by(
    name: params[:name]
  )
  if user && user.authenticate(params[:password])
    session[:user] = user.id
    redirect '/search'
  else
    redirect '/signin'
  end
end

#ログアウト
get '/signout' do
  session[:user] = nil
  redirect '/'
end

#タイムライン
get '/' do
  @songs = Song.all
  erb :index
end

#自分の投稿だけ表示
get '/home' do
  @user_songs = Song.where(
    user_id: session[:user]
  )
  binding.pry
  @user_name = User.find(session[:user]).name
  erb :home
end

#投稿ボタン押したとき
post '/new' do
  user_name = User.find(current_user.id).name
  Song.create(
        user_id: session[:user],
        user_name: user_name,
        body: params[:body],
        img: params[:img],
        artist: params[:artist],
        sample: params[:sample],
        album: params[:album],
        title: params[:title]
  )
  if params[:file]
      image_upload(params[:file])
  end
  redirect '/home'
end

#削除ボタン押したとき
get '/delete/:id' do
  Song.find(params[:id]).destroy
  redirect '/home'
end

#編集ページ
get '/edit/:id' do
  @song = Song.find(params[:id])
  erb :edit
end

#編集内容更新ボタン押したとき
post '/update/:id' do
  song = Song.find(params[:id])
  song.update({
    body: params[:body]
  })
  redirect '/home'
end

#searchボタン押したとき(検索ページへ)
get '/search' do
  erb :search
end

#検索ボタン押したとき
post "/search" do
  word = params[:word]
  uri = URI("https://itunes.apple.com/search")
  uri.query = URI.encode_www_form({term: word, country: "US", media: "music", limit: 10 })
  res = Net::HTTP.get_response(uri)
  returned_json = JSON.parse(res.body)
  @musics = returned_json["results"]
  #json書かなきゃ
  erb :search
end
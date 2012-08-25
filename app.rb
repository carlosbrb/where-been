require 'sinatra'
require 'sinatra/activerecord'
require 'omniauth'
require 'omniauth-foursquare'
require 'pry'
require 'foursquare2'
require 'sqlite3'
require 'json'

set :database, 'sqlite:///wherebeen.db'

use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :foursquare, "B4ZPCWZTJLFKXPAYKB5D5OCDUZVHYJU0OODHXIFMO23FDAZY", "JJUZKBDNX3IRUWHEXJXX41CMGUPWVGTTHWESL1AU32Y0LLEA"
end

configure do
  enable :sessions
end


get '/' do
  client = Foursquare2::Client.new(:oauth_token => session[:access_token])
  @data = client.user_checkins(limit: 30).items

  haml :index
end

get '/map' do
  client = Foursquare2::Client.new(:oauth_token => session[:access_token])
  @data = client.user_checkins(limit: 30).items

  erb :map
end

get '/auth/foursquare/callback' do
  @auth = request.env['omniauth.auth']
  session[:access_token] = @auth.credentials.token
  session[:login] = @auth[:uid].to_i

  client = Foursquare2::Client.new(:oauth_token => session[:access_token])
  @auth[:user_checkins] = client.user_checkins(limit: 30).items.to_json

  #@user = User.find_or_create_from_hash(@auth)
  #haml :user_info
end

get '/auth/failure' do
  "Oops!"
end

get '/user/:id' do
  #@user = User.find(params[:id])
  #haml :user_info
end

get '/profile' do
  content_type :json
  client = Foursquare2::Client.new(:oauth_token => session[:access_token])
  #binding.pry
  client.user_checkins(limit: 30).items.to_json
end



require 'sinatra'

get '/' do
  erb :index
end

get '/podcast' do
  content_type 'application/rss+xml'
  erb :podcast
end

get '/podcast/index.xml' do
  redirect '/podcast'
end
require "sinatra/base"
require "sinatra/reloader" #if development?
require "open-uri"
require "json"

class Movies < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  before do
    @app_name = "Movie App"
    @page_title = @app_name
  end

  get "/" do
    @page_title += ": Home"
    erb :home
  end

  get "/search" do
    @query = params[:q]
    @button = params[:button]
    file = open("http://www.omdbapi.com/?s=#{URI.escape(@query)}")
    @results = JSON.load(file.read)["Search"]
    erb :results
  end

  get "/movies" do
    @id = params[:id]
    file = open("http://www.omdbapi.com/?i=#{URI.escape(@id)}")
    @result = JSON.load(file.read)
    erb :detail
  end

  run!
end
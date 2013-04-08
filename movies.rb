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
    @page_title += ": Search Results for #{@query}"
    file = open("http://www.omdbapi.com/?s=#{URI.escape(@query)}")
    @results = JSON.load(file.read)["Search"] || []
    if @results.size == 1
      redirect "/movies"
    else
      erb :results
    end
  end

  get "/movies" do
    @id = params[:id]
    file = open("http://www.omdbapi.com/?i=#{URI.escape(@id)}&tomatoes=true")
    @result = JSON.load(file.read)
    set_actors_and_directors(@result)
    erb :detail
  end

  def set_actors_and_directors(result)
    @actors = result["Actors"].split(", ")
    @directors = result["Director"].split(", ")
  end

  run!
end
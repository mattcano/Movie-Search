require "sinatra"
require "sinatra/reloader" #if development?
require "open-uri"
require "json"
require "date"

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


#make search results as its own ERB file so it can be replicated in related results
get "/search" do
  @query = params[:q]
  @button = params[:button]
  if @button == "lucky"
    file = open("http://www.omdbapi.com/?t=#{URI.escape(@query)}&tomatoes=true")
    @result = JSON.load(file.read)  
    @page_title += ": #{@result["Title"]}"
    set_actors_and_directors(@result)
    erb :detail
  else
    @page_title += ": Search Results for #{@query}"
    file = open("http://www.omdbapi.com/?s=#{URI.escape(@query)}")
    @results = JSON.load(file.read)["Search"] || []
    if @results.size == 1
      redirect "/movies"
    else
      erb :results
    end
  end
end

#when doing related results, use the code below to remove current movie from related list
#@results.reject!{|movie| movie["imdbID"] == @result["imdbID"]}
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
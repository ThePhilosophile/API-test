require 'sinatra'
require 'rubygems'
require 'sinatra/json'
require 'bundler'
require 'mongoid'

Bundler.require

#Prevents errors with storing subdocument named "times" as a singular class
ActiveSupport::Inflector.inflections do |inflect|
	inflect.singular("times", "times")
end


#Base Restaurant class document, embeds one store
class Restaurant
	include Mongoid::Document
	
	field :_id
	field :active, type: Boolean
	field :categories, type: Array
	field :cover
	field :created_at
	field :foundation_date
	field :name
	field :slogan
	
	embeds_one :store
	
	field :open, type: Boolean
end

#Store class document, embedded in restaurants, embeds many times
class Store
	include Mongoid::Document
	
	field :_id
	field :as
	field :dt, type: Boolean
	field :fn
	field :fw
	field :hi, type: Boolean
	field :loc, type: Array
	
	embeds_many :times
	embedded_in :restaurant
end

#Time class, embedded in stores
class Times
	include Mongoid::Document
	
	field :hours
	field :open
	field :close
	
	embedded_in :store
end


#Database configuration- default settings
configure do
	Mongoid.load!("./mongoid.yml")
end

#Index page
get '/' do
	"Hello!"
end


#Get list of all restaurant data as JSON Array
get '/restaurants/' do
	content_type :json
	
	restaurants = Restaurant.all
	json restaurants.as_json
end


#Get one restaurant data by id as JSON Array
#Wasn't required, but helpful for testing
get '/restaurants/:id' do
	content_type :json
	
	restaurant = Restaurant.where(_id: params[:id])
	json restaurant.as_json
end

#Update one restaurant by id
#Tested using command curl -X PUT -d "restaurant[parameter]= new_value" http://localhost:4567/restaurants/id-of-restaurant
#e.g. curl -X PUT -d "restaurant[name] = The Counter (Palo Alto)" http://localhost:4567/restaurants/the-counter-palo-alto
put '/restaurants/:id' do
	content_type :json

	restaurant = Restaurant.where(_id: params[:id])
	
	if restaurant.update params[:restaurant]
		status 200
		json "Restaurant data updated."
	else
		status 500
		json restaurant.errors.full_messages
	end
	
end

#Delete one restaurant by id
#Tested using command curl -X DELETE http://localhost:4567/restaurants/id-of-restaurant
#e.g. curl -X DELETE http://localhost:4567/restaurants/the-counter-palo-alto
delete '/restaurants/:id' do
	content_type :json

	restaurant = Restaurant.where(_id: params[:id])
	
	if restaurant.delete
		status 200
		json "Restaurant was deleted."
	else
		status 500
		json "Could not delete restaurant."
	end
	
end
require 'sinatra'
require 'json'
require 'jsonify'

API_VERSION='0.0.1'

#Schema
class Person
  attr_accessor :id, :name
  def initialize(id, name)
    @id = id
    @name = name
  end
end

john = Person.new('1', 'John')
peter = Person.new('2', 'Peter')

user = { '1' => john, '2' => peter}


get '/api/users/' do
  json = Jsonify::Builder.new
  json.status 'ok'
  json.users user.keys

  status 200
  content_type 'application/json'
  body json.compile!
end

get '/api/users/:id' do
  person = user[params[:id]]
  if !person.nil? then
    json = Jsonify::Builder.new
    json.status 'ok'
    json.id person.id
    json.name person.name

    status 200 # OK
    content_type 'application/json'
    body json.compile!

  else
    json = Jsonify::Builder.new
    json.status 'error'
    json.id 'none'
    json.name 'none'

    status 200
    content_type 'application/json'
    body json.compile!
  end
end

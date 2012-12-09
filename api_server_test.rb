require './api_server'
require 'rspec'
require 'rack/test'
require 'rest-client'
require 'json'
require 'jsonify'

set :environment, :test

describe 'The REST API server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  it "returns all user ids" do
    get '/api/users/'
    last_response.should be_ok
    data = JSON.parse(last_response.body)
    data['status'].should == 'ok'
    data['users'][0].should == '1'
    data['users'][1].should == '2'
  end

  it 'returns empty user details if user does not exist' do
    get '/api/users/100'
    last_response.should be_ok
    data = JSON.parse(last_response.body)
    data['status'].should == 'error'
    data['id'].should == 'none'
    data['name'].should == 'none'
  end

  it 'returns correct user details' do
    get '/api/users/1'
    last_response.should be_ok
    data = JSON.parse(last_response.body)
    data['status'].should == 'ok'
    data['id'].should == '1'
    data['name'].should == 'John'
  end

  it 'creates a new user' do
    json = Jsonify::Builder.new
    json.id '3'
    json.name 'Sarah'
    
    post '/api/users/', json.compile!
    last_response.should be_ok
    data = JSON.parse(last_response.body)
    data['status'].should == 'ok'
    data['id'].should == '3'
    data['name'].should == 'Sarah'
  end

  it 'does not create a user that already exists' do
    json = Jsonify::Builder.new
    json.id '3'
    json.name 'Sarah'

    post '/api/users/', json.compile!
    last_response.should be_ok
    data = JSON.parse(last_response.body)
    data['status'].should == 'error'
    data['reason'].should == 'user already exists'
  end

  it 'does not accept bad json when creating user' do
    json = Jsonify::Builder.new
    json.id '4'

    post '/api/users/', json.compile!
    last_response.should be_ok
    data_first = JSON.parse last_response.body
    data_first['status'].should == 'error'
    data_first['reason'].should == 'bad request'

    json = Jsonify::Builder.new
    json.name 'Jane'
    
    post '/api/users/', json.compile!
    last_response.should be_ok
    data_second = JSON.parse last_response.body
    data_first.should == data_second
  end
end

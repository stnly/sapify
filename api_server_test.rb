require './api_server'
require 'rspec'
require 'rack/test'
require 'rest-client'
require 'json'
require 'jsonify'

set :environment, :test

describe 'The REST API endpoint' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  it "returns all user ids" do
    get '/api/users/'
    last_response.should be_ok
    data = JSON.parse last_response.body
    data['status'].should == 'ok'
    data['users'][0].should == '1'
    data['users'][1].should == '2'
  end

  it 'returns empty user details if user does not exist' do
    get '/api/users/100'
    last_response.should be_ok
    data = JSON.parse last_response.body
    data['status'].should == 'error'
    data['id'].should == 'none'
    data['name'].should == 'none'
  end

  it 'returns individual user details' do
    get '/api/users/1'
    last_response.should be_ok
    data = JSON.parse last_response.body
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
    data = JSON.parse last_response.body
    data['status'].should == 'ok'
    data['id'].should == '3'
    data['name'].should == 'Sarah'
  end

  it 'rejects request to create user if user already exist' do
    json = Jsonify::Builder.new
    json.id '3'
    json.name 'Sarah'

    post '/api/users/', json.compile!
    last_response.should be_ok
    data = JSON.parse last_response.body
    data['status'].should == 'error'
    data['reason'].should == 'user already exists'
  end

  it 'rejects request to create user with bad json' do
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

  it 'modifies user details' do
    json = Jsonify::Builder.new
    json.id '1'
    json.name 'Jon'

    put '/api/users/1', json.compile!
    last_response.should be_ok
    data = JSON.parse last_response.body
    data['status'].should == 'ok'
    data['id'].should == '1'
    data['name'].should == 'Jon'
  end

  it 'rejects request to modify user details with bad json' do
    json = Jsonify::Builder.new
    json.id '3'
    
    put '/api/users/3', json.compile!
    last_response.should be_ok
    data_first = JSON.parse last_response.body
    data_first['status'].should == 'error'
    data_first['reason'].should == 'bad request'

    json = Jsonify::Builder.new
    json.name 'Sara'

    put '/api/users/3', json.compile!
    last_response.should be_ok
    data_second = JSON.parse last_response.body
    data_first.should == data_second
  end

  it 'rejects request to modify details if user does not exist' do
    json = Jsonify::Builder.new
    json.id '10'
    json.name 'Tom'

    put '/api/users/10', json.compile!
    last_response.should be_ok
    data = JSON.parse last_response.body
    data['status'].should == 'error'
    data['reason'].should == 'user does not exist'
  end
end

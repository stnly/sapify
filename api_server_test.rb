require './api_server'
require 'rspec'
require 'rack/test'

set :environment, :test

describe 'The REST API server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  it "returns all user ids" do
    get '/api/users/'
    last_response.should be_ok
    last_response.body.should == '{"status":"ok","users":["1","2"]}'
  end

  it 'returns no user details' do
    get '/api/users/100'
    last_response.should be_ok
    last_response.body.should == '{"status":"error","id":"none","name":"none"}'
  end

  it 'returns user details' do
    get '/api/users/1'
    last_response.should be_ok
    last_response.body.should == '{"status":"ok","id":"1","name":"John"}'
  end
end

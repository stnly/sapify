require './api_server'
require 'rspec'
require 'rack/test'

set :environment, :test

describe 'The REST API server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  it "returns all users" do
    get '/api/users/'
    last_response.should be_ok
  end  
end

require 'sinatra/base'
require 'sinatra_more'
require 'haml'

class RoutingDemo < Sinatra::Base
  register Sinatra::RoutingPlugin

  configure do
    set :root, File.dirname(__FILE__)
  end

  map(:admin, :show).to("/admin/:id/show")
  map :admin do |namespace|
    namespace.map(:update).to("/admin/:id/update/:name")
    namespace.map(:destroy).to("/admin/:id/destroy")
  end
  map(:account).to("/the/accounts/:name/path/:id/end")
  map(:accounts).to("/the/accounts/index/?")
  
  namespace :admin do
    get :show do
      "<p>admin show for id #{params[:id]}</p>"
    end
    
    get :update do
      "<p>updated admin with id #{params[:id]} and name #{params[:name]}</p>"
    end
    
    get :destroy do
      "<p>destroy admin with id #{params[:id]}</p>"
    end
  end
  get :account do
    "<h1>the account url for #{params[:name]} and id #{params[:id]}</h1>"
  end
  
  get :accounts do
    "<h1>the accounts index</h1>"
  end
  
  get '/links' do
    haml :index
  end
  
  get '/failed_route' do
    url_for(:some, :not_real, :id => 5)
  end
end
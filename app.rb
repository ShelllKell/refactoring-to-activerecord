require "sinatra"
require "gschool_database_connection"
require "rack-flash"
require "./lib/fish"
require "./lib/users"
require "active_record"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
  end

  get "/" do
    user = current_user

    if current_user
      users = User.where("id != ?", user[:id])
      fish = Fish.where(:user_id => current_user[:id])
      erb :signed_in, locals: {current_user: user, users: users, fish_list: fish}
    else
      erb :signed_out
    end
  end

  get "/register" do
    erb :register, :locals => {:user => nil}
  end

  post "/registrations" do

    user = User.create(:username => params[:username], :password => params[:password])
    if user.errors.messages == {}
      flash[:notice] = "Thanks for registering"
      redirect "/"
    else
      erb :register, :locals => {:user => user}
    end
  end

  post "/sessions" do
    user = User.where(:usernmae => params[:username], :password => params[:password]).take
      if user != nil
        session[:user_id] = user["id"]
      else
        flash[:notice] = "Username/password is invalid"
      end
    end

    redirect "/"
  end

  delete "/sessions" do
    session[:user_id] = nil
    redirect "/"
  end

  delete "/users/:id" do
    User.where(:id => params[:id]).destroy_all
    redirect "/"
  end

  get "/fish/new" do
    erb :"fish/new", :locals => {:fish => nil}
  end

  get "/fish/:id" do
    fish = Fish.where("id = ?", params[:id])
    erb :"fish/show", locals: {fish: fish}
  end

  post "/fish" do
      fish = Fish.create(:name => params[:name], :wikipedia_page => params[:wikipedia_page], :user_id => current_user[:id])
      if fish.errors.messages == {}
      flash[:notice] = "Fish Created"
      redirect "/"
    else
      erb :"fish/new", :locals => {:fish => fish}
    end
  end

  private


  def validate_authentication_params
    if params[:username] != "" && params[:password] != ""
      return true
    end

    error_messages = []

    if params[:username] == ""
      error_messages.push("Username is required")
    end

    if params[:password] == ""
      error_messages.push("Password is required")
    end

    flash[:notice] = error_messages.join(", ")

    false
  end

  def username_available?(username)
    existing_users = User.where("username = ?", username)

    existing_users.length == 0
  end

  def current_user
    if session[:user_id]
      User.find(session[:user_id])
    else
      nil
    end
  end
end

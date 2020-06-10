# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "geocoder"                                                                    #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

supportplaces_table = DB.from(:supportplaces)
pledge_table = DB.from(:pledge)
users_table = DB.from(:users)

before do
    #select place
   @support = supportplaces_table.where(:id =>params["id"]).to_a[0]
   puts @support.inspect
   # SELECT * FROM users WHERE id = session[:user_id]
    @current_user = users_table.where(:id => session[:user_id]).to_a[0]
    puts @current_user.inspect
    @google_api_key = ENV["GOOGLE_API_KEY"]
end

get "/" do 
    @supportplaces = supportplaces_table.all
    view "supportplaces"
end

get "/supportplaces/:id" do 

    #User Info
    @users_table = users_table

    # SELECT * FROM support WHERE id=:id
    @support = supportplaces_table.where(:id =>params["id"]).to_a[0]
    puts @support.inspect

    #Google maps
    results = Geocoder.search(@support[:location])
    @lat_long = results.first.coordinates.join(",")

    #Pledge Donations
    @pledge = pledge_table.where(:support_id =>params["id"]).to_a
    puts @pledge.inspect
    view "support"
end

post "/supportplaces/:id/pledge/new" do
    @support = supportplaces_table.where(:id => params["id"]).to_a[0]
    puts @support.inspect
    view "new_pledge"
end

 # Create Pledge
get "/supportplaces/:id/pledge/create" do
    puts params.inspect
   
    pledge_table.insert(:support_id => params["id"],
                       :name => @current_user[:name],
                       :email => @current_user[:email],
                       :comments => params["comments"])

    #Auto Send Text To My Phone Letting Me Know there was a new "Pledge"
    account_sid = ENV["TWILIO_ACCOUNT_SID"]
    auth_token = ENV["TWILIO_AUTH_TOKEN"]

    # set up a client to talk to the Twilio REST API
    client = Twilio::REST::Client.new(account_sid, auth_token)

    # send the SMS from your trial Twilio number to your verified non-Twilio number, hard coded because trial
    client.messages.create(
     from: "+12018222063", 
     to: "+16304576329",
     body: params["comments"]
    )

    view "create_pledge"
end

# Form to create a new user
get "/users/new" do
    view "new_user"
end

# Receiving end of new user form
post "/users/create" do
    puts params.inspect
    users_table.insert(:name => params["name"],
                       :email => params["email"],
                       :password => BCrypt::Password.create(params["password"]))
    view "create_user"
end

# Form to login
get "/logins/new" do
    view "new_login"
end

# Receiving end of login form
post "/logins/create" do
    puts params
    email_entered = params["email"]
    password_entered = params["password"]
    # SELECT * FROM users WHERE email = email_entered
    user = users_table.where(:email => email_entered).to_a[0]
    if user
        puts user.inspect
        # test the password against the one in the users table
        if BCrypt::Password.new(user[:password]) == password_entered
            session[:user_id] = user[:id]
            view "create_login"
        else
            view "create_login_failed"
        end
    else 
        view "create_login_failed"
    end
end

# Logout
get "/logout" do
    session[:user_id] = nil
    view "logout"
end
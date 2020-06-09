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

before do
   @support = supportplaces_table.where(:id =>params["id"]).to_a[0]
   puts @support.inspect
end

get "/" do 
    @supportplaces = supportplaces_table.all
    view "supportplaces"
end

get "/supportplaces/:id" do 
    # SELECT * FROM support WHERE id=:id
    @support = supportplaces_table.where(:id =>params["id"]).to_a[0]
    puts @support.inspect

    #Google maps
    results = Geocoder.search(@support[:location])
    @lat_long = results.first.coordinates.join(",")
    view "support"


end


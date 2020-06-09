# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :supportplaces do
  primary_key :id
  String :title
  String :description, text: true
  String :cash_link
  String :location
end
DB.create_table! :pledge do
  primary_key :id
  foreign_key :support_id
  String :name
  String :email
  String :comments, text: true
end

DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
supportplaces_table = DB.from(:supportplaces)

supportplaces_table.insert(title: "Central Camera Company", 
                    description: "On the night of May 30th into early morning May 31st, Central Camera Company, Chicago's oldest camera store, was destroyed and burned. We are still surveying the area to see if we can recover any assets, but at this time it looks like 100% destruction.",
                    cash_link: "https://www.gofundme.com/f/central-camera-company-rebuild",
                    location: "230 S Wabash Ave, Chicago, IL 60604")

supportplaces_table.insert(title: "The Elephant Room Gallery", 
                    description: "On Saturday May 30th,  during the city wide protest, the Elephant Room Gallery was vandalized. All art from the current exhibit that had been previously sold, was stolen. For those that personally know Kimberly Atwood- owner of the gallery, know she is extremely passionate and dedicated to support emerging artists in Chicago.",
                    cash_link: "https://www.gofundme.com/f/sd722-help-the-elephant-room-gallery",
                    location: "704 S Wabash Ave, Chicago, IL 60605")

supportplaces_table.insert(title: "Fashion Bar", 
                    description: "I am Tony Long, CEO of FashionBar LLC  located in Chicago's Uptown neighborhood.    FashionBar has been a victim of and felt the repercussions  of the Black Lives Matter a political protest movement which was agitated by looters and rioters! I NEED YOUR HELP!",
                    cash_link: "https://www.gofundme.com/f/small-business-shattered-dreams",
                    location: "4660 N Broadway, Chicago, IL 60640")

supportplaces_table.insert(title: "Greek Town Cigars", 
                    description: "In the early morning of May 31, my brothers store Greek Town Cigars (next door to Artopolisin Chicago), was robbed and vandalized by 5 different groups of looters between 1:30 - 5:30 AM.  He and my father built this store from nothing 6 years ago, and was one of the last things they did together before my dad passed away a few months later. My brother put everything he had into this store working 6 days a week , 12 + hours a day. His customers and community love him.",
                    cash_link: "https://www.gofundme.com/f/support-damages-from-looting-at-greek-town-cigars",
                    location: "304 S Halsted St, Chicago, IL 60661")

supportplaces_table.insert(title: "Luv Handles", 
                    description: "Ms. Holcomb was a new business owner, she took the risk and leap of faith to entrepreneurship.  Then COVID-19 hit and she had to close her doors.  Just as she was preparing to open, her business was destroyed when a fire was set in the building next to hers.  She now has to start fresh...all of her investment...gone!",
                    cash_link: "https://www.gofundme.com/f/reopen-luv-handles",
                    location: "308 E 47th St, Chicago, IL 60653")

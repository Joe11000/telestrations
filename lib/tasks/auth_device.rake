namespace :auth do
  desc "Creates auth key to give to new player"
  task :device => :environment do
    `rake dropbox:authorize APP_KEY=ENV['DROPBOX_APP_KEY'] APP_SECRET=ENV['DROPBOX_APP_SECRET'] ACCESS_TYPE='app_folder'`
  end
end

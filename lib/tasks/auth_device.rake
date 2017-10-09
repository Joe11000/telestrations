namespace :auth do
  desc "Creates auth key to give to new player"
  task :device => :environment do
    # `rake dropbox:authorize APP_KEY='91kwkvfg4ryj80a' APP_SECRET='lt7sn6kzag0edlc' ACCESS_TYPE='app_folder'`
  end
end

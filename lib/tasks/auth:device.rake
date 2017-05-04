namespace :auth do
  desc "Creates auth key to give to new player"
  task :device do
    rake dropbox:authorize ENV['DROPBOX_APP_KEY'] ENV['DROPBOX_APP_SECRET'] 'app_folder'
  end
end

class CreateAnonymousUser < ActiveRecord::Migration
  def change
    unless Rails.env.test?
      User.create(name: "Anonymous", provider: 'Anonymous', uid: 'Anonymous', provider_avatar: ENV['DOMAIN'] + '/images/anonymous.png')
    end
  end
end


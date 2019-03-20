Rails.application.routes.draw do
  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

  root 'sessions#new'

  get '/choose_game_type'           => 'lobbies#choose_game_type_page', as: :choose_game_type_page

  scope 'lobby' do
    post 'join'                     => 'lobbies#join_lobby',            as: :join_lobby
    get  ':game_type'               => 'lobbies#lobby',                 as: :lobby
  end

  resources :games, only: [:new, :show, :update, :index]

  scope 'cards' do
    resources :in_game_card_uploads, only: [:new, :create], as: :in_game_card_uploads

    resources :out_of_game_card_uploads, only: [ :new, :create, :index ], as: :out_of_game_card_uploads
  end

  get  'login'          => 'sessions#new'
  post 'login'          => 'sessions#create'
  get  'logout'         => 'sessions#destroy', as: :logout

  # get 'auth/:provider/callback', to: 'sessions#create'
  # get 'auth/failure', to: redirect('/'), alert: 'Failed Login Attempt'
end

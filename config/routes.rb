Rails.application.routes.draw do
  root 'sessions#new'

  resource :game, only: [:new]

  scope 'game' do
    scope 'rendezvous' do
      get '/'                         => 'rendezvous#choose_game_type_page', as: :rendezvous_choose_game_type_page
      get  ':game_type'               => 'rendezvous#rendezvous_page',       as: :rendezvous_page
      post 'join'                     => 'rendezvous#join_game',             as: :join_game
      get  'get_updates/:join_code'   => 'rendezvous#get_updates',           as: :get_updates_rendezvous
      post 'update/:join_code'        => 'rendezvous#update',                as: :update_rendezvous
      get  'leave_pregame/:join_code' => 'rendezvous#leave_pregame',         as: :leave_pregame
    end

    get  'start'        => 'games#start_page',  as: :start_game_page
    post 'start'        => 'games#start',       as: :start_game

    post 'card_upload'  => 'games#card_upload', as: :card_upload
    get  'post_game'    => 'games#post_game',   as: :post_game
  end

  scope 'cards' do
    get  'bulk_upload'  => 'cards#bulk_upload_page', as: :bulk_upload_cards_page
    post 'bulk_upload'  => 'cards#bulk_upload',      as: :bulk_upload_cards
  end

  get  'login'          => 'sessions#new'
  post 'login'          => 'sessions#create'
  get  'logout'         => 'sessions#destroy', as: :logout

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

  # match "/websocket", :to => ActionCable.server, via: [:get, :post]
end

Rails.application.routes.draw do
  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'

  root 'sessions#new'

  resource :game, only: [:new]

  scope 'game' do
    scope 'rendezvous' do
      get '/'                         => 'rendezvous#choose_game_type_page', as: :rendezvous_choose_game_type_page
      get  'leave_pregame'            => 'rendezvous#leave_pregame',         as: :leave_pregame
      post 'join'                     => 'rendezvous#join_game',             as: :join_game
      get  ':game_type'               => 'rendezvous#rendezvous_page',       as: :rendezvous_page
    end

    get  '/'          => 'games#game_page', as: :game_page
    post '/'          => 'games#game',      as: :game

    # post 'upload_card' => 'games#upload_card',        as: :upload_card_in_game
    get  'postgame'    => 'games#postgame_page',      as: :postgame_page
    get  'postgames'   => 'games#all_postgames_page', as: :all_postgames_page
  end

  scope 'cards' do
    resources :in_game_card_uploads, only: [:new, :create]

    resources :out_of_game_card_uploads, only: [:new, :create]
  end

  get  'login'          => 'sessions#new'
  post 'login'          => 'sessions#create'
  get  'logout'         => 'sessions#destroy', as: :logout

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/'), alert: 'Failed Login Attempt'
end

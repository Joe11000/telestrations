Rails.application.routes.draw do
  root 'sessions#new'

  resource :game, only: [:new]
  get  'game/start/quick_start'          => 'games#quick_start',   as: :quick_start_game
  get  'game/start/:privacy'             => 'games#start',         as: :start_game
  get  'game/leave_pregame'              => 'games#leave_pregame', as: :leave_pregame
  get  'game/post_game'                  => 'games#post_game',     as: :post_game
  post 'game/join'                       => 'games#join',          as: :join_game
  post 'game/prevent_additional_players' => 'games#prevent_additional_players'


  get 'cards/upload'                     => 'cards#upload_page',   as: :cards_upload_page
  post 'cards/upload'                    => 'cards#upload',        as: :cards_upload

  get  'login'             => 'sessions#new'
  post 'login'             => 'sessions#create'
  get  'logout'            =>'sessions#destroy'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end

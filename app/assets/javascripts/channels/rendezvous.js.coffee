App.rendezvous = App.cable.subscriptions.create { channel: "RendezvousChannel", game_id: $('[data-game-id]').attr('data-game-id') },
  connected: ->
    # console.log('connected')
    $('.loading-gif').removeClass('invisible');

  join_game: (users_game_name) ->
    @perform 'join_game', users_game_name: users_game_name

  unjoin_game: ->
    @perform 'unjoin_game'


  disconnected: ->
    # close
    # debugger
    1 + 1
    # Called when the subscription has been terminated by the server

  received: (data) ->
    if data.partial
      $("[data-id=currently-joined]").replaceWith(data.partial);
    else if data.start_game_signal
      document.location = '/game/start'

      # remove join_code
      # switch to mid game status
      # remove user games_users association to people that didn't submit a name
      # broadcast a message to try and go to the game start page. The before action will allow the commited people through to their game and send the uncommited people back to the game choice page.


    # Called when there's incoming data on the websocket for this channel

  # start_game: ->
  #   # @perform 'start_game'


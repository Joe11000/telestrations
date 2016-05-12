App.rendezvous = App.cable.subscriptions.create { channel: "RendezvousChannel", join_code: $('[data-id="randezvous-join-code"]').html() },
  connected: ->
    $('.loading-gif').removeClass('invisible');

  join_game: (users_game_name) ->
    @perform 'join_game', users_game_name: users_game_name

  unjoin_game: ->
    @perform 'unjoin_game'

  start_game: ->
    @perform 'start_game'

  received: (data) ->
    if data.partial != undefined
      $("[data-id=currently-joined]").replaceWith(data.partial);
    else if data.start_game_signal
      window.location = data.start_game_signal

  disconnected: ->
    # close
    # debugger
    1 + 1
    # Called when the subscription has been terminated by the server








# $('[data-game-id]').attr('data-game-id')

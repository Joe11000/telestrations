App.game = App.cable.subscriptions.create { channel: "GameChannel", not_join_code: 7, join_code: $('[data-id=randezvous-join-code]').html() },
# App.game = App.cable.subscriptions.create { channel: "GameChannel", game_join_code: 'AAAA'},
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
    $("[data-id=currently-joined]").replaceWith(data.partial);


    # Called when there's incoming data on the websocket for this channel

  # start_game: ->
  #   # @perform 'start_game'


if document.querySelectorAll("[data-id='lobby-page']").length > 0
  App.lobby = App.cable.subscriptions.create { channel: "LobbyChannel", join_code: $('[data-id="lobby-join-code"]').html() },
    connected: ->
      $('.loading-gif').removeClass('invisible');

    join_game: (users_game_name) ->
      @perform 'join_game', users_game_name: users_game_name

    unjoin_game: ->
      @perform 'unjoin_game'

    start_game: ->
      @perform 'start_game'

    received: (data) ->
      if data.user_leaving != undefined
        if data.user_leaving.user_id == $("[data-id='leave_link']").attr('data-user')
          window.location = data.user_leaving.url

      if data.partial != undefined
        $("[data-id='currently-joined-partial-wrapper']").replaceWith(data.partial);

      if data.start_game_signal != undefined
        window.location = data.start_game_signal

    disconnected: ->
    # Called when the subscription has been terminated by the server

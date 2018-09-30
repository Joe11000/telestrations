if document.querySelectorAll("[data-id='rendezvous-page']").length > 0
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
      if data.user_leaving != undefined
        if data.user_leaving.user_id == $("[data-id='leave_link']").attr('data-user')
          window.location = data.user_leaving.url

      if data.partial != undefined
        $("[data-id='currently-joined-partial-wrapper']").replaceWith(data.partial);

      if data.start_game_signal != undefined
        window.location = data.start_game_signal

    disconnected: ->
    # Called when the subscription has been terminated by the server

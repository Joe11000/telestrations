App.game = App.cable.subscriptions.create { channel: "GameChannel", prev_card: Number.parseInt( $('[data-prev-card-id]').attr('data-prev-card-id') ), game_id: Number.parseInt( $('[data-game-id]').attr('data-game-id') ) },
  connected: ->
    1 + 1
    # Called when the subscription is ready for use on the server

  disconnected: ->
    1 + 1
    # Called when the subscription has been terminated by the server

  # params a XOR b XOR c XOR d
  #   a) broadcast_params: { game_over: true }
  #   b) broadcast_params: { game_over: false, set_complete: true,  attention_users: current_user_id }
  #   c) broadcast_params: { game_over: false, set_complete: false, attention_users: next_user_id, prev_card: {id: card_id, description_text: description_text} } }
  #   d) broadcast_params: { game_over: false, set_complete: false, attention_users: next_user_id, prev_card: {id: card_id, drawing_url: url} } }
  received: (data) ->
    if(data['game_over'] == true)
      window.location = '/postgame'
    else if(data['attention_users'] == Number.parseInt( $('[data-user-id]').attr('data-user-id') )
      if(data['set_complete'] == true)
        # hide drawing and description container and show waiting for users screen
      else if data['prev_card']['description_text'] != undefined
        # hide and clear the describing form
        # set the description_text in the drawing area so the user can draw it
      else if data['prev_card']['drawing_url'] != undefined
        # hide and clear picture drawing area and drawing upload form
        # set the picture so the user can describe it
      else
        console.warning('received ' + data + ' and front end knew the user, but dropped data on the floor')
    else
      console.warning('received ' + data + ', and did not know if it was the intended user and dropped it on the floor')



  upload_card: (card_uri_info) ->
    @perform 'upload_card',  card_uri_info

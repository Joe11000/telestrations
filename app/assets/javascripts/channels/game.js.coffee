App.game = App.cable.subscriptions.create { channel: "GameChannel", prev_card: Number.parseInt( $('[data-prev-card-id]').attr('data-prev-card-id') ) || '', game_id: Number.parseInt( $('[data-game-id]').attr('data-game-id') ) || '' },
  connected: ->
    1 + 1
    # Called when the subscription is ready for use on the server

  disconnected: ->
    1 + 1
    # Called when the subscription has been terminated by the server

  # params a XOR b XOR c XOR d
  #   a) broadcasted_params: { game_over: true }
  #   b) broadcasted_params: { game_over: false, set_complete: true,  attention_users: current_user_id }
  #   c) broadcasted_params: { game_over: false, set_complete: false, attention_users: next_user_id, prev_card: {id: card_id, description_text: description_text} } }
  #   d) broadcasted_params: { game_over: false, set_complete: false, attention_users: next_user_id, prev_card: {id: card_id, drawing_url: url} } }
  received: (data) ->
    console.log(data)

    if(data['game_over'] == true)
      debugger
      window.location = '/postgame'
      2
    else if( data['attention_users'] == Number.parseInt($('[data-user-id]').attr('data-user-id')) )
      debugger
      if(data['set_complete'] == true)
        debugger
        showLoadingContainer('set_complete')
        # hide drawing and description container and show waiting for users screen
        2

      else if( $("[data-id='loading-container']:visible").length == 0 ) # current user is busy and can't take a new card yet.
        debugger
        console.warn('received ' + data + ' and front end knew the user, but he is busy, so he dropped data on the floor')
        2

      # current user is waiting for a card and received a description card
      else if(data['prev_card']['description_text'] != undefined)
        debugger
        window.updatePageForNextDrawingCard(data['prev_card'])
        # hide and clear the describing form
        # set the description_text in the drawing area so the user can draw it
        2

      # current user is waiting for a card and received a drawing card
      else if(data['prev_card']['drawing_url'] != undefined)
        debugger
        window.updatePageForNextDescriptionCard(data['prev_card'])
        # hide and clear picture drawing area and drawing upload form
        # set the picture so the user can describe it
        2
      else
        debugger
        console.warn('received ' + data + ' and current user knew message was for him, did nothing and dropped data on the floor')
        2
    else
      debugger
      console.warn('received ' + data + ', and did not know if it was the intended user and dropped it on the floor')
      2



  upload_card: (card_uri_info) ->
    debugger
    @perform 'upload_card',  card_uri_info

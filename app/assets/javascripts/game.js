(function(){

  // broadcasted_params: { game_over: false, set_complete: false, attention_users: next_user_id, prev_card: {id: card_id, description_text: description_text} } }
  // broadcasted_params: { game_over: false, set_complete: false, attention_users: next_user_id, prev_card: {id: card_id, drawing_url: url} } }
  window.updatePageForNextDescriptionCard = function(broadcasted_params){
    debugger
    // previous card info
    $('[data-prev-card-id]').attr('data-prev-card-id', broadcasted_params['prev_card']['id'])

      $("[data-id='make-description-container']").hide()
      $("[data-id='make-description-form']").clear()
  };

  window.updatePageForNextDrawingCard = function(broadcasted_params){
    debugger

    $('[data-prev-card-id]').attr('data-prev-card-id', broadcasted_params['prev_card']['id'])

    $("[data-id='make-description-container']").show()

  }


  $('#drawing-tab a').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  });


  $("[data-id='make-description-form']").on('submit', function(e){
    e.preventDefault();
    debugger
    App.game.upload_card({description_text: this.val()});
  });

  function replaceContainerWithWaitingGif() {
    $("[data-id='make-drawing-container'] > *:visible").hide()

  }

  // file upload via game socket
  var files = [];
  $("#file_upload input[type=file]").change(function(event) {
    $.each(event.target.files, function(index, file) {
      var reader = new FileReader();
      reader.onload = function(event) {
        object = {};
        object.filename = file.name;
        object.data = event.target.result;
        files.push(object);
      };
      reader.readAsDataURL(file);
    });
  });
  $('#file_upload').submit(function(event) {
    event.preventDefault();
    $.each(files, function(index, file) {
      let image_info = {prev_card: nil, filename: file.filename, data: file.data};
      debugger
      App.game.upload_card(image_info);
    });

    //  reset form and ready for
    replaceContainerWithWaitingGif();
    files = [];
    $("#file_upload input[type=file]").val('')
  });
})();


// App.game.upload_card({  'description_text': "Suicidal Penguin"});
// image_info['prev_card'] = 43

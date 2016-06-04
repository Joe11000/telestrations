(function(){

  function replaceContainerWithWaitingGif() {
    $("[data-id='make-drawing-container'] > *:visible").hide()
  }


  // prev_card_info: { id: card_id, description_text: description_text }
  // prev_card_info: { id: card_id, drawing_url: url }
  $("[data-id='make-description-form']").submit( function(e){
    $(this).find('button').prop('disabled', true); // prevent user from submitting multiple times
    App.game.upload_card({description_text: $(this).find('input').val()});
    return false;
  });

  window.updatePageForNextDrawingCard = function(prev_card_info){
    debugger
    // replace prev card info at the top of the screen
      $('[data-prev-card-id]').attr('data-prev-card-id', prev_card_info['id'])

    // hide the description input container
      $("[data-id='make-description-container']").addClass('hidden')

    // clear description input field
      $("[data-id='make-description-container'] form")[0].reset();

    // show the
      $("[data-id='make-drawing-container']").removeClass('hidden')
  };

  window.updatePageForNextDescriptionCard = function(prev_card_info){
    debugger
    // replace prev card info at the top of the screen
      $('[data-prev-card-id]').attr('data-prev-card-id', prev_card_info['id'])

    // hide the drawing input container
      $("[data-id='make-drawing-container']").addClass('hidden')

    // clear drawing input field
      $("[data-id='make-description-container'] form")[0].reset();

    // enable user to submit description
      $(this).find('button').prop('disabled', false);

    // show the
      $("[data-id='make-description-container']").removeClass('hidden')
  }


  $('#drawing-tab a').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  });


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

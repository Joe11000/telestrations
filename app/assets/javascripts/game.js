(function(){
  if ($("[data-id='game-page']").length > 0){

    $("[data-id='make-description-form']").submit( function(e){

      $(this).find('button').prop('disabled', true); // prevent user from submitting multiple times
      var description_text = $(this).find('input').val();
      hideAndClearCardContainers();
      App.game.upload_card({description_text: description_text});
      return false;
    });

    showLoadingContainer = function(status) {
      if(status === 'set_complete')
      {
        $("[data-id='set_complete']").removeClass('hidden');
        $("[data-id='set_not_complete']").addClass('hidden');
      }

      $("[data-id='loading-container']").removeClass('hidden');
    }

    hideLoadingContainer = function(status) {
      $("[data-id='loading-container']").addClass('hidden');
    }

    hideAndClearCardContainers = function(){
      // hide drawing container if it is visible
        var $element = $("[data-id='make-drawing-container']:visible");


      if ($element.length > 0 )
      {
      // disable the button in the photo upload form
        $('[data-id=submitPhoto]').prop('disabled', false);

        // hide the description input container
          $("[data-id='make-drawing-container']").addClass('hidden');
        // todo : clear the paint portion!!!
      }

      // hide description container if it is visible
      var $element = $("[data-id='make-description-container']:visible")
      if ($element.length > 0 )
      {
        // hide the description input container
          $("[data-id='make-description-container']").addClass('hidden');

        // clear description input field
          $("[data-id='make-description-container'] form")[0].reset();
      }
      showLoadingContainer();
    }

    // prev_card_info: { id: card_id, description_text: description_text }
    window.updatePageForNextDrawingCard = function(prev_card_info) {
      hideLoadingContainer();

      // change description text to draw
        $("[data-id='description-text-to-draw']").html(prev_card_info['description_text']);

      // show the drawing area
        $("[data-id='make-drawing-container']").removeClass('hidden');

      // replace prev card info at the top of the screen
        $('[data-prev-card-id]').attr('data-prev-card-id', prev_card_info['id']);
    };

    // prev_card_info: { id: card_id, drawing_url: url }
    window.updatePageForNextDescriptionCard = function(prev_card_info) {
      hideLoadingContainer();

      // change the url of the image to describe
        $("[data-id='drawing-to-describe']").attr('src', prev_card_info['drawing_url'])

      // enable user to submit description
        $("[data-id='make-description-form'] button").prop('disabled', false);

      // show the description area
        $("[data-id='make-description-container']").removeClass('hidden')

      // replace prev card info at the top of the screen
        $('[data-prev-card-id]').attr('data-prev-card-id', prev_card_info['id'])
    }

    $("#drawing-tab a").click(function (e) {
      e.preventDefault();
      $(this).tab('show');
    });

    // file upload via game socket
    var files = [];
    $("[data-class='file_upload_form'] input[type=file]").change(function(event) {
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

      if (event.target.files.length > 0) {
        $('[data-id=submitPhoto]').prop('disabled', false);
      }
      else {
        $('[data-id=submitPhoto]').prop('disabled', true);
      }
    });

    $("[data-class='file_upload_form']").submit(function(event) {
      event.preventDefault();
      showLoadingContainer();
      hideAndClearCardContainers();

      $.each(files, function(index, file) {
        var image_info = {filename: file.filename, data: file.data};
        App.game.upload_card(image_info);
      });

      //  reset form and ready for next time
      files = [];
      $("[data-class='file_upload_form'] input[type=file]").val('');
    });
  }
})();

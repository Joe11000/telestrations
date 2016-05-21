(function(){

  $('#drawing-tab a').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  });


  $("[data-id='make-description-form']").on('submit', function(e){
    e.preventDefault();
    App.game.upload_card();

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

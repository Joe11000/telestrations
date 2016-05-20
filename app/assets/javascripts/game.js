(function(){

  $('#drawing-tab a').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  });


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

  $('#file_upload').submit(function(form) {
    form.preventDefault();
    $.each(files, function(index, file) {
      $.ajax({url:  $(form.target).attr('action'),
            type: $(form.target).attr('method'),
            data: {filename: file.filename, data: file.data},
            success: function(data, status, xhr) {
              alert('success');
            },
            failure: function(){

            }
      });
    });

    files = [];
  });

})();

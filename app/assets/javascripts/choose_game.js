$(function() {




  // User has to enter a join_code to join a game
  if ($("[data-id='choose-game-type-page']").length > 0) {
    $("[data-id='join-code-form']").on('submit', function(e){
      val = $(this).find("input").val();

      if(typeof val !== "string" || val.length < 1) {
        e.preventDefault();
      }
    });

    $("[data-id='join-code-form'] button").on('click', function(e){
      val = $(this).parents("form").find('input').val();

      if(typeof val !== "string" || val.length < 1) {
        e.preventDefault();
      }
      else
      {
        $(this).parents("form").submit();
      }
    });
  }



  // Handler for .ready() called.
});

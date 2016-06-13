(function(){
  // User has to enter a join_code to join a game
  if ($("[data-id='choose-game-type-page']").length > 0) {
    $("[data-id='join-code-submit-group']").closest('form').submit(function(e){
      val = $(this).find('data-id=join-code-text-field')

      if(typeof val !== "string" || val.length < 1) {
        e.preventDefault();
      }
    });
  }
})();

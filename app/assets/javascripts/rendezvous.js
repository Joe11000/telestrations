// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function(){
  if($("[data-id='lobby-page']").length > 0) {
    $("[data-id='update-lobby-form']").on('submit', function(e){
      e.preventDefault();

      var $form = $(this);

      // display_error_name_submission_error = function(element){
      //   var input_group = $(this).closest('.form-group');
      //   input_group.addClass('has-error');
      //   input_group.find('.help-block:hidden').removeClass('d-none');
      // }

      users_game_name = $form.find('[data-id=users_game_name]').val();
      // user submitted a games_user_name
      if( users_game_name.length > 0)
      {
        $form.find('button').attr('disabled', 'disabled'); //disable go button

        App.lobby.join_game(users_game_name);

        $('[data-id=update-lobby-group-col]').addClass('d-none');
        $('[data-id=lobby-start-game-button-container]').removeClass('d-none');
      }
    });
  }

  $("[data-id='leave_link']").on('click', function(e){
    e.preventDefault();
    App.lobby.unjoin_game();
  });

  $("[data-id='start_game_button']").closest('form').on('submit', function(e){
    e.preventDefault();
    App.lobby.start_game();
  });
});

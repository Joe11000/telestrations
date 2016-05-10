have a single rendezvous channel during the rendezvous stage.

1) New User comes onto page
  Automatically add a new viewer of the rendezvous page to the rendezvous channel

  a) User leaves
    remove user games_users association

  b) New User submits name
    When a user commit to a game


    aa) User leaves
      remove user games_users association

    bb) User clicks start game
      remove join_code
      switch to mid game status
      remove user games_users association to people that didn't submit a name
      broadcast a message to try and go to the game start page. The before action will allow the commited people through to their game and send the uncommited people back to the game choice page.









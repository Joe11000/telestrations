=== Players new to the game should read ==
Play the telestrations game with your friends and the games will be saved for you to see later. Or upload your own pictures from games you have played at home.


Things you will need to play:
1) Paper
2) Pencil
3) Smartphone or computer


During the drawing phase, you should
1) Draw your picture by hand with pencil and paper
2) With your smartphone, take picture with your of the drawing
3) Find the picture using the file selector
4) submit picture on form

.
.
.
.
.
.

have a single lobby channel during the lobby stage.

1) New User comes onto page
  Automatically add a new viewer of the lobby page to the lobby channel

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


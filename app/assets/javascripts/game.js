$(function(){
  if(document.getElementById('start_game') != undefined)
    window.setInterval(function(){
      console.log(Math.random(1))
    }, 500);
});

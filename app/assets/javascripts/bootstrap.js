jQuery(function() {
  $("a[rel~=popover], .has-popover").popover({trigger: 'focus'});
  $("a[rel~=tooltip], .has-tooltip").tooltip();
  return;
});

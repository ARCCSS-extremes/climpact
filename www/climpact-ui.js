disableTab = function(name) {
  var tab = $('.nav li a[data-value=' + name + ']');
  tab.bind('click.tab', function(e) {
    e.preventDefault();
    return false;
  });
  tab.addClass('disabled');
}

Shiny.addCustomMessageHandler('enableTab', function(name) {
    var tab = $('.nav li a[data-value=' + name + ']');
    tab.unbind('click.tab');
    tab.removeClass('disabled');
  }
);
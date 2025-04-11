$(document).ready(function() {
  function isPrintableCharacter (str) {
    return str.length === 1 && str.match(/\S/);
  }


  // Store the last keypress on the element that opens the menu
  $("[data-toggle='dropdown']").on('keydown', function(e) {
    let target = $(e.target);
    target.data('last-press', e.keyCode);
  });

  // When the menu opens grab the stored keypress and give focus to the menu list element
  $("[data-toggle='dropdown']").parent().on('shown.bs.dropdown', function (e) {
    let menu = $(e.relatedTarget).siblings('.dropdown-menu');
    let listItems = menu.find('li:not(.disabled):visible a');
    let firstElem = listItems.first();
    let lastElem = listItems.last();

    switch($(e.relatedTarget).data('last-press')) {
      // case 35: // end
      // case 36: // home

      case 13: // enter
      case 32: // space
      case 40: // keyboard down
        firstElem.focus();
        break;
      case 38: // keyboard up
        lastElem.focus();
        break;
    };
  });

  // Close menu when tab focus leaves menu button or menu items
  $("[data-toggle='dropdown']").parent().on('focusout', function(e) {
    // The menu we're in
    let menu = $(e.target).closest('ul');
    // The target we're tabbing to
    let target = $(e.relatedTarget);
    // The button that opens our menu
    let button = menu.siblings('button,a');
    // If we tabbed out of the menu, toggle the dropdown off on the button
    if (menu.find(target).length <= 0 && menu.length > 0) {
      button.dropdown('toggle');
    }
  });

  $("[data-toggle='dropdown']").siblings('.dropdown-menu').on('keydown', function(e) {
    // The <ul> of menu items
    let menu = $(this);
    // The <button> that opens the menu
    let dropButton = menu.siblings("[data-toggle='dropdown']");
    // The <li> menu items
    let listItems = menu.find('li:not(.disabled):visible a');
    // The first <li>
    let firstElem = listItems.first();
    // The last <li>
    let lastElem = listItems.last();

    switch(e.keyCode) {
      // Jump to the end
      case 35: // end
        e.preventDefault();
        lastElem.focus();
        break;
      // Jump to the beginning
      case 36: // home
        e.preventDefault();
        firstElem.focus();
        break
      // Bootstrap exits the menu for us, we focus the menu button and traverse the link
      case 13: // enter
        let link = menu.find(':focus');
        dropButton.focus();
        location.href = link.attr('href');
        break;
      // Wrap to the top of the list if at the last item
      case 40: // keyboard down
        if (lastElem.is(':focus')) {
          e.preventDefault();
          e.stopPropagation();
          firstElem.focus();
        }
        break;
      // Wrap to the bottom of the list if at the first item
      case 38: // keyboard up
        if (firstElem.is(':focus')) {
          e.preventDefault();
          e.stopPropagation();
          lastElem.focus();
        }
        break;
      // Find the list item that begins with the pressed alphanumeric
      default:
        // Pressed button
        let char = e.key.toLowerCase();
        // Check if it's not a tab, space, enter, or other whitespace
        if (isPrintableCharacter(char)) {
          // Start from the list item after the one we're focused on
          let focused = menu.find(':focus');
          let start = listItems.index(focused) + 1;
          if (start === listItems.length) {
            start = 0;
          }

          // Split the list into elements after the focused and before the focused
          let firstArray = listItems.slice(start);
          let secondArray = listItems.slice(0, start - 1);
          let found = null;

          // Search the list after the focus first
          firstArray.each( function(_index, elem) {
            // Check if the first char matches the pressed char in any case
            if (elem.innerText[0].toLowerCase() === char) {
              elem.focus();
              found = elem;
              return false;
            }
          });

          // Check the list before the focus if we didn't find it previously
          if (found === null) {
            secondArray.each( function(_index, elem) {
              if (elem.innerText[0].toLowerCase() === char) {
                elem.focus();
                return false;
              }
            });
          }
        }
        break;
    };
  });
});
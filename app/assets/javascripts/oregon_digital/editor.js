$(document).ready(function() {
  // Make sure all buttons in the form are type button
  var form = $("form[data-behavior='work-form']");
  form.find('button').attr('type', 'button');
  // The last button to take care of is the delete files button.
  // This is added into the DOM later, so we find
  console.log(form.find('tbody.files'));
  form.find('tbody.files').on('DOMNodeInserted', "tr.template-download", function() {
    $(this).find('button.delete').attr('type', 'button');
  });

  // Get all possible form inputs
  var inputGroup = $('form .form-group');
  inputGroup.each(function (_, elem) {
    elem = $(elem);
    var label = elem.find('label');
    var help = elem.find('p.help-block');
    var input = elem.find('input, textarea, select');
    // Update help text to describe the input
    if (label.length > 0 && help.length > 0) {
      var newID = input.attr('id') + '_help'
      help.attr('id', newID);
      input.attr('aria-describedby', newID);
    }
  });
});
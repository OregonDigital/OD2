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
});
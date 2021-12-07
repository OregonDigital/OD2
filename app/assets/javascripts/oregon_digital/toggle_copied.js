function toggleCopied(element) {
  $(element).attr("title", "Copied!");
  $(element).attr("data-original-title", "Copied");
  setTimeout(stopTimer,10000, element);
}
function stopTimer(element) {
  $(element).attr("data-original-title", "Copy text to clipboard");
  $(element).attr("title", "Copy text to clipboard");
}
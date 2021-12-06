function toggleCopied() {
  $(".share-button-copy").attr("title", "Copied!");
  $(".share-button-copy").attr("data-original-title", "Copied");
  setTimeout(stopTimer,5000);
}
function stopTimer () {
  $(".share-button-copy").attr("data-original-title", "Copy text to clipboard");
  $(".share-button-copy").attr("title", "Copy text to clipboard");
}
function toggleCopied(element) {
  $(element.classList.value).attr("title", "Copied!");
  $(element.classList.value).attr("data-original-title", "Copied");
  setTimeout(stopTimer(element),15000);
}
function stopTimer(element) {
  $(element.classList.value).attr("data-original-title", "Copy text to clipboard");
  $(element.classList.value).attr("title", "Copy text to clipboard");
}
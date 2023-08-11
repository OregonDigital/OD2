// CUSTOM: Add in custom JS file to help with the characters limit
$(document).ready(function() {
  // Options for the observer (which mutations to observe)
  const config = { childList: true, subtree: true };

  // Callback function to execute when mutations are observed
  const callback = (mutationList, observer) => {
    for (const mutation of mutationList) {
      if (mutation.type === "childList" && mutation.addedNodes.length > 0) {
        if (mutation.target.className == 'thumbsView') {
          let labelChildren = mutation.addedNodes[0].querySelectorAll('.label');
          labelChildren.forEach( (child, index) => {
            if (child.innerHTML.length > 50) {
              child.innerHTML = child.innerHTML.slice(0, 50) + '...';
            }
          });
        }
      }
    }
  };

  // Create an observer instance linked to the callback function
  const observer = new MutationObserver(callback);

  // Start observing the target node for configured mutations
  observer.observe(document.querySelector('#uv'), config);
});
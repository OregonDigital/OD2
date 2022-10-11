$(document).ready(function () {
  window.cookieconsent.initialise({
    "palette": {
      "popup": {
        "background": "#073C5C",
        "text": "#FFFFFF"
      },
      "button": {
        "background": "#E88F2A",
        "text": "#073C5C"
      }
    },
    "content": {
      "message": "This website uses cookies to ensure you get the best experience from Oregon Digital.",
      "dismiss": "Got it!",
      "link": "Learn more about our privacy policy",
      "href": "/privacy"
    }
  })
});
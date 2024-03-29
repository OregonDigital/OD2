export class FieldManager {
  constructor(element, options) {
      this.element = $(element);

      this.options = options;

      this.options.label = this.getFieldLabel(this.element, options)

      this.addSelector = '.add'
      this.removeSelector = '.remove'

      this.adder    = this.createAddHtml(this.options)
      this.remover  = this.createRemoveHtml(this.options)

      this.controls = $(options.controlsHtml);

      this.inputTypeClass = options.inputTypeClass;
      this.fieldWrapperClass = options.fieldWrapperClass;
      this.warningClass = options.warningClass;
      this.listClass = options.listClass;

      this.init();
  }

  init() {
      this._addInitialClasses();
      this._addInitialID();
      this._appendControls();
      this._appendWarning();
      this._attachEvents();
      this._addCallbacks();
  }

  _addInitialClasses() {
      this.element.addClass("managed");
      $(this.fieldWrapperClass, this.element).addClass("input-group input-append");
  }

  _addInitialID() {
      let id = this.element.find('input').attr('id') + '_';
      this.element.find('label').attr('id', id + 'label');
      this.element.find('p.help-block').attr('id', id + 'help');
      this.element.find('input').attr('aria-describedby', id + 'help')
  }

  // Add the "Add another" and "Remove" controls to the DOM
  _appendControls() {
      // We want to make these DOM additions idempotently, so exit if it's
      // already set up.
      if (!this._hasRemoveControl()) {
        this._createRemoveWrapper()
        this._createRemoveControl()
      }

      if (!this._hasAddControl()) {
        this._createAddControl()
      }
  }

  // OVERRIDE to add an invisible warning box to be filled later
  _appendWarning() {
    let $listing = $(this.listClass);
    // Create
    var $warningMessage  = $("<div class=\'message has-warning\' aria-live='assertive' style='height:0;padding:0;border:0;'></div>");
    $listing.nextAll(this.warningClass).remove();
    $listing.after($warningMessage);
  }
  // END OVERRIDE

  _createRemoveWrapper() {
    $(this.fieldWrapperClass, this.element).append(this.controls);
  }

  _createRemoveControl() {
    $(this.fieldWrapperClass + ' .field-controls', this.element).append(this.remover)
  }

  _createAddControl() {
    this.element.find(this.listClass).after(this.adder)
  }

  _hasRemoveControl() {
    return this.element.find(this.removeSelector).length > 0
  }

  _hasAddControl() {
    return this.element.find(this.addSelector).length > 0
  }

  _attachEvents() {
      this.element.on('click', this.removeSelector, (e) => this.removeFromList(e))
      this.element.on('click', this.addSelector, (e) => this.addToList(e))
  }

  _addCallbacks() {
      this.element.bind('managed_field:add', this.options.add);
      this.element.bind('managed_field:remove', this.options.remove);
  }

  _manageFocus() {
      $(this.element).find(this.listClass).children('li').last().find('.form-control').focus();
  }

  addToList( event ) {
      event.preventDefault();
      let $listing = $(event.target).closest(this.inputTypeClass).find(this.listClass)
      let $activeField = $listing.children('li').last()
      // ID from first input + how many other inputs
      let labelID = $listing.children('li').first().find('input').attr('id') + '_';

      if (this.inputIsEmpty($activeField)) {
          this.displayEmptyWarning();
      } else {
          this.clearEmptyWarning();
          // Create new field
          let $new = this._newField($activeField);
          // Make new field labelled by field label
          $new.find('input').attr('aria-labelledby', labelID + 'label')
                            .attr('aria-describedby', labelID + 'help')
                            .attr('id', labelID + $listing.children('li').length);
          $listing.append($new);
      }

      this._manageFocus()
  }

  inputIsEmpty($activeField) {
      return $activeField.children('input.multi-text-field').val() === '';
  }

  _newField ($activeField) {
      var $newField = this.createNewField($activeField);
      return $newField;
  }

  createNewField($activeField) {
      let $newField = $activeField.clone();
      let $newChildren = this.createNewChildren($newField);
      this.element.trigger("managed_field:add", $newChildren);
      return $newField;
  }

  clearEmptyWarning() {
      // OVERRIDE to clear text instead of delete element
      let $listing = $(this.listClass, this.element)
      var $warningElem = $listing.nextAll(this.warningClass);
      $warningElem.css({"height":"0", "border":"0", "padding":"0"});
      $warningElem.empty();
      // END OVERRIDE
  }

  displayEmptyWarning() {
      let $listing = $(this.listClass, this.element)
      // OVERRIDE to push <div> out of <ul> and add aria-live for SR announcement
      // Add text into an existing warning div and remove style that's removing div from visibility
      var $warningMessage  = "Cannot add another with empty field";
      var $warningElem = $listing.nextAll(this.warningClass);
      $warningElem.text($warningMessage);
      $warningElem.removeAttr('style');
      // END OVERRIDE
  }

  removeFromList( event ) {
      event.preventDefault();
      var $field = $(event.target).parents(this.fieldWrapperClass).remove();
      this.element.trigger("managed_field:remove", $field);

      this._manageFocus();
  }

  destroy() {
      $(this.fieldWrapperClass, this.element).removeClass("input-append");
      this.element.removeClass("managed");
  }

  getFieldLabel($element, options) {
      var label = '';
      var $label = $element.find("label").first();

      if ($label.size && options.labelControls) {
        var label = $label.data('label') || $.trim($label.contents().filter(function() { return this.nodeType === 3; }).text());
        label = ' ' + label;
      }

      return label;
  }

  createAddHtml(options) {
      var $addHtml  = $(options.addHtml);
      $addHtml.attr('aria-label', options.addText + options.label);
      $addHtml.find('.controls-add-text').html(options.addText + options.label);
      return $addHtml;
  }

  createRemoveHtml(options) {
      var $removeHtml = $(options.removeHtml);
      $removeHtml.find('.controls-remove-text').html(options.removeText);
      $removeHtml.find('.controls-field-name-text').html(options.label);
      return $removeHtml;
  }

  createNewChildren(clone) {
      let $newChildren = $(clone).children(this.inputTypeClass);
      $newChildren.val('').removeProp('required');
      $newChildren.first().focus();
      return $newChildren.first();
  }
}

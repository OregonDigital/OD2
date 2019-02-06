import Default from './autocomplete/default'
import Resource from './autocomplete/resource'
import LinkedData from './autocomplete/linked_data'

export default class Autocomplete {
  /**
   * Setup for the autocomplete field.
   * @param {jQuery} element - The input field to add autocompete to
   * @param {string} fieldName - The name of the field (e.g. 'based_near')
   * @param {string} url - The url for the autocompete search endpoint
   */
  setup (element, fieldName, url, fieldType=null) {
    // OVERRIDE FROM HYRAX
    // Add linked data support for arbitrary autocomplete fields by accepting
    //  fieldType param on the initial field or fieldType override from controlled_vocabulary fieldmanager
    var switchVal = element.data('fieldType') || fieldType || fieldName
    switch (switchVal) {
      case 'work':
        new Resource(
          element,
          url,
          { excluding: element.data('exclude-work') }
        )
        break
      case 'collection':
        new Resource(
          element,
          url)
        break
      case 'linked_data':
      case 'based_near':
        new LinkedData(element, url)
      default:
        new Default(element, url)
        break
    // END OVERRIDE
    }
  }
}
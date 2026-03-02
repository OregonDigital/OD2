export class UploadedFiles {
  // Monitors the form and runs the callback when files are added
  constructor(form, callback) {
    this.form = form
    this.element = $('#fileupload')
    this.element.bind('fileuploadcompleted', callback)
    this.element.bind('fileuploaddestroyed', callback)
    $('#oembed_urls').bind('blur', callback)
  }

  get hasFileRequirement() {
    let fileRequirement = this.form.find('li#required-files')
    return fileRequirement.length > 0
  }

  get inProgress() {
    // OVERRIDE FROM HYRAX: increase allowed number of active file uploads to 1 because the fileuploadcompleted event fires before... file is completed uploading
    return this.element.fileupload('active') > 1
  }

  get hasFiles() {
    let fileField = this.form.find('input[name="uploaded_files[]"]')
    let oembedField = this.form.find('input[name="oembed_urls[]"]:valid')
    return (fileField.length > 0 && !oembedField.val()) || (oembedField.val() && fileField.length < 1)
  }

  get hasNewFiles() {
    // In a future release hasFiles will include files already on the work plus new files,
    // but hasNewFiles() will include only the files added in this browser window.
    return this.hasFiles
  }
}

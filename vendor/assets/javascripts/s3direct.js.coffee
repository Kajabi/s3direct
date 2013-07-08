#= require jquery-fileupload/basic
#= require s3direct_default_template
#= require_self

class window.S3DirectUploadView
  template: JST['s3_direct_default_template']

  $: (selector) ->
    @$el.find(selector)

  uploader: ->
    @$('.uploader')

  fileInput: ->
    @$('input[type=file]')

  progressMeter: ->
    @$('.progress .meter')

  progressBar: ->
    @$('.progress')

  uploadInfo: ->
    @$('.upload-info')

  alertBox: ->
    @$('.alert-box')

  fileInfo: ->
    @$('.file-info')

  constructor: (options = {}) ->
    @model = options.model
    @fileAttribute = options.fileAttribute
    @requestUrl = options.requestUrl
    @$el = if options.el then $(options.el) else $('<div>')
    @el = @$el[0]

  render: ->
    @$el.html @template(this)
    @setupFileInput()
    @setFileInfo @fileName()

  fileName: ->
    @model.get(@fileAttribute)

  setupFileInput: ->
    filename = null

    @fileInput()
      .fileupload
        paramName  : 'file'
        autoUpload : true
        dropZone   : @$el
        # When a file is added, make an "upload request" to our server to get the S3 bucket URL,
        # policy document, signature, etc.
        add: (e, data) =>
          $.ajax
            url: @requestUrl
            data: {filename: data.files[0].name}
            success: (uploadRequestObj) =>
              # The sanitized version of the filename
              filename = uploadRequestObj.filename
              @fileInput().fileupload 'option', 'url', uploadRequestObj.url
              @fileInput().fileupload 'option', 'formData', _.omit(uploadRequestObj, 'url', 'filename')
              data.submit()
        # Once the upload to S3 is under way, fade in the progress bar and disable the button.
        send: =>
          @uploader().hide()
          @alertBox().remove()
          @progressBar().fadeIn()
          # Show an indeterminate progress bar if browser doesn't support progress (I *think* this is the right attribute to check)
          @progressMeter().css(width: '100%') unless $.support.xhrFileUpload
        # Update the progress bar.
        progress: (e) =>
          percent = Math.round(e.loaded / e.total * 100)
          @progressMeter().css(width: percent + '%')
        # S3 upload was successful; save the LessonMedia object on the server.
        done: (e, response) =>
          msg = "<b>Upload succeeded.</b>"
          @showUploadMessage(msg, true)
          @model.set @fileAttribute, filename
          @model.save()
        # S3 upload failed.
        error: =>
          msg = "<b>Something went wrong!</b> Your upload did not complete. Please try again."
          @showUploadMessage(msg, false)
          @uploader().show()

  # Displays a message about the success or failure of the upload.
  showUploadMessage: (msg, wasSuccess) ->
    @progressBar().fadeOut 300, =>
      @progressMeter().css(width: 0)
      @alertBox().remove()
      alertClass = if wasSuccess then 'success' else 'alert'
      @uploadInfo().append("<div class='alert-box #{alertClass}'>#{msg}</div>")

  setFileInfo: (name) ->
    @fileInfo().text name if name

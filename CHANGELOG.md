### 0.4.0

* enhancements
  * Previously the Content-Type was not set on s3, it was defaulting to 'binary/octet-stream'.
    The mime-types gem now provides content type detection based of the filename and, for maximum
    accuracy, an optional `filetype` param from the browser file object.

class FileAttachment {
  final String url;
  final String? fileName;
  final String? fileSize;
  final String? fileType;
  
  const FileAttachment({
    required this.url,
    this.fileName,
    this.fileSize,
    this.fileType,
  });
  
  factory FileAttachment.fromUrl(String url) {
    // Extract file name from URL
    final fileName = url.split('/').last;
    
    // Create a dummy file size
    final fileSize = '2.3 MB';
    
    // Determine file type from extension
    final extension = fileName.split('.').last.toLowerCase();
    String fileType;
    
    switch (extension) {
      case 'pdf':
        fileType = 'PDF Document';
        break;
      case 'doc':
      case 'docx':
        fileType = 'Word Document';
        break;
      case 'xls':
      case 'xlsx':
        fileType = 'Excel Spreadsheet';
        break;
      case 'ppt':
      case 'pptx':
        fileType = 'PowerPoint Presentation';
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        fileType = 'Image';
        break;
      default:
        fileType = 'Document';
    }
    
    return FileAttachment(
      url: url,
      fileName: fileName,
      fileSize: fileSize,
      fileType: fileType,
    );
  }
  
  @override
  String toString() {
    return 'FileAttachment(url: $url, fileName: $fileName, fileSize: $fileSize, fileType: $fileType)';
  }
}

// Extension method on String to convert to FileAttachment
extension StringToFileAttachment on String {
  FileAttachment toFileAttachment() {
    return FileAttachment.fromUrl(this);
  }
}

// Extension method on List<String> to convert to List<FileAttachment>
extension StringListToFileAttachmentList on List<String>? {
  List<FileAttachment> toFileAttachments() {
    if (this == null) return [];
    return this!.map((url) => FileAttachment.fromUrl(url)).toList();
  }
}
class Document {
  final String id;
  final String userId;
  final String fileName;
  final String url;

  Document({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.url,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      userId: json['userId'],
      fileName: json['fileName'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fileName': fileName,
      'url': url,
    };
  }
}

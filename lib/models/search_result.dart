class SearchResult {
  final String title;
  final String content;
  final String url;
  final DateTime? publishedDate;

  SearchResult({
    required this.title,
    required this.content,
    required this.url,
    this.publishedDate,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      url: json['url'] ?? '',
      publishedDate: json['publishedDate'] != null 
          ? DateTime.tryParse(json['publishedDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'url': url,
      'publishedDate': publishedDate?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SearchResult(title: $title, content: $content, url: $url)';
  }
} 
class Media {
  const Media({
    this.id,
    required this.url,
    this.position = 0,
    this.width = 1080,
    this.height = 1350,
  });

  final String? id;
  final String url;
  final int position;
  final int width;
  final int height;

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id']?.toString(),
      url: (json['url'] ?? '') as String,
      position: (json['position'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toInt() ?? 1080,
      height: (json['height'] as num?)?.toInt() ?? 1350,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'url': url,
    'position': position,
    'width': width,
    'height': height,
  };
}

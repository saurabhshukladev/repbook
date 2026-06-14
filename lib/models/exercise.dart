class Exercise {
  final String name;
  final String gifUrl;

  const Exercise({
    required this.name,
    required this.gifUrl,
  });

  /// Factory constructor for deserialization from JSON.
  factory Exercise.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    final gifUrl = (json['gif-url'] ?? json['gifUrl']) as String?;

    if (name == null || gifUrl == null) {
      throw const FormatException('Failed to load Exercise: missing name or gif-url.');
    }

    return Exercise(
      name: name,
      gifUrl: gifUrl,
    );
  }

  /// Method for serialization to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gif-url': gifUrl,
    };
  }
}

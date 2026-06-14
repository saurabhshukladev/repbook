class Exercise {
  final String name;
  final String gifUrl;
  final String? localFilePath;

  const Exercise({
    required this.name,
    required this.gifUrl,
    this.localFilePath,
  });

  bool get isLocallyCached => localFilePath != null;

  /// Factory constructor for deserialization from JSON.
  factory Exercise.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    final gifUrl = (json['gif-url'] ?? json['gifUrl']) as String?;
    final localFilePath = json['localFilePath'] as String?;

    if (name == null || gifUrl == null) {
      throw const FormatException('Failed to load Exercise: missing name or gif-url.');
    }

    return Exercise(
      name: name,
      gifUrl: gifUrl,
      localFilePath: localFilePath,
    );
  }

  /// Method for serialization to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gif-url': gifUrl,
      if (localFilePath != null) 'localFilePath': localFilePath,
    };
  }

  /// Returns a new instance with copied fields.
  Exercise copyWith({
    String? name,
    String? gifUrl,
    String? localFilePath,
  }) {
    return Exercise(
      name: name ?? this.name,
      gifUrl: gifUrl ?? this.gifUrl,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }
}

import 'package:http/http.dart' as http;

/// Handles network communication with GitHub APIs and downloading asset binaries.
class GitHubService {
  final http.Client _client;

  GitHubService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the raw text content of a file from a private/public GitHub repository.
  Future<String> fetchRawSchedule({
    required String token,
    required String owner,
    required String repo,
    required String path,
  }) async {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$cleanPath');

    final response = await _client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3.raw',
        'User-Agent': 'RepBook-App',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
        'GitHub API request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  /// Downloads file bytes from any URL (used to fetch the exercise GIFs).
  Future<List<int>> downloadBytes(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
        'Failed to download asset from URL (status ${response.statusCode}): $url',
      );
    }
  }
}

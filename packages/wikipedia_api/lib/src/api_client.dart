import 'dart:convert';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

import 'models/models.dart';

/// Thrown if an exception occurs while making an `http` request.
class HttpException implements Exception {}

/// {@template http_request_failure}
/// Thrown if an `http` request returns a non-200 status code.
/// {@endtemplate}
class HttpRequestFailure implements Exception {
  /// {@macro http_request_failure}
  const HttpRequestFailure(this.statusCode);

  /// The status code of the response.
  final int statusCode;
}

/// Thrown if an excepton occurs while decoding the response body.
class JsonDecodeException implements Exception {}

/// Thrown is an error occurs while deserializing the response body.
class JsonDeserializationException implements Exception {}

class WikipediaApi {
  WikipediaApi({http.Client httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _authority = 'en.wikipedia.org';

  final http.Client _httpClient;

  /// Returns a list of wiki pages from a given query.
  Future<List<WikiPage>> searchPages(
    String query, {
    int max,
  }) async {
    final queryParams = <String, String>{
      'action': 'opensearch',
      'format': 'json'
    };
    if (query != null) {
      queryParams.addAll({'search': query});
    }
    if (max != null) {
      queryParams.addAll({'limit': '$max'});
    }

    http.Response response;

    try {
      response = await _wikiRequest(queryParams);
    } on Exception {
      rethrow;
    }

    List body;

    try {
      body = json.decode(response.body) as List;
    } on Exception {
      throw JsonDecodeException();
    }

    try {
      // get length of search results
      final titlesLength = (body[1] as List).length;

      final result = <WikiPage>[];

      // deserialize
      for (var i = 0; i < titlesLength; i++) {
        final title = body[1][i].toString();
        final url = body[3][i].toString();
        List<String> images;

        try {
          images = await getImageUrls(title);
        } on Exception {
          // error occured during title's images parsing
          images = null;
        }

        result.add(WikiPage(
          title: title,
          url: url,
          images: images,
        ));
      }

      return result;
    } on Exception {
      throw JsonDeserializationException();
    }
  }

  /// returns List of image urls for wiki page with provided title
  /// gets raw html of the article and parses it for images
  Future<List<String>> getImageUrls(String title) async {
    final queryParams = <String, String>{
      'action': 'parse',
      'prop': 'text',
      'format': 'json',
      'formatversion': '2'
    };

    if (title != null) {
      queryParams.addAll({'page': title});
    }

    http.Response response;

    try {
      response = await _wikiRequest(queryParams);
    } on Exception {
      rethrow;
    }

    Map<String, dynamic> body;

    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } on Exception {
      throw JsonDecodeException();
    }

    String html;

    try {
      html = body['parse']['text'].toString();

      // if no images object found
      if (html == null) return null;
      if (html.isEmpty) return null;
    } on Exception {
      throw JsonDeserializationException();
    }

    final document = parse(html);

    final images = document.getElementsByClassName('image');
    final imageSources = images
        .map<String>((e) => 'https:${e.firstChild.attributes['src']}')
        .toList();

    return imageSources;
  }

  /// returns main image of Wiki article with providede title
  Future<String> _getMainImage(String title) async {
    final queryParams = <String, String>{
      'action': 'query',
      'format': 'json',
      'prop': 'pageimages',
    };

    if (title != null) {
      queryParams.addAll({'titles': title});
    }

    http.Response response;

    try {
      response = await _wikiRequest(queryParams);
    } on Exception {
      rethrow;
    }

    Map<String, dynamic> body;

    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } on Exception {
      throw JsonDecodeException();
    }

    try {
      final url = (body['query']['pages'] as Map)
          .values
          .toList()
          .first['thumbnail']['source']
          .toString();

      // if no images object found
      if (url == null) return null;
      if (url.isEmpty) return null;

      return url;
    } on Exception {
      throw JsonDeserializationException();
    }
  }

  /// returns image url for image name provided
  Future<String> _getImageUrl(String imageName) async {
    final queryParams = <String, String>{
      'action': 'query',
      'format': 'json',
      'prop': 'imageinfo',
      'iiprop': 'url'
    };

    if (imageName != null) {
      queryParams.addAll({'titles': imageName});
    }

    http.Response response;

    try {
      response = await _wikiRequest(queryParams);
    } on Exception {
      rethrow;
    }

    Map<String, dynamic> body;

    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } on Exception {
      throw JsonDecodeException();
    }

    try {
      final url = (body['query']['pages'] as Map)
          .values
          .toList()
          .first['imageinfo']
          .first['url']
          .toString();

      // if no images object found
      if (url == null) return null;
      if (url.isEmpty) return null;

      return url;
    } on Exception {
      throw JsonDeserializationException();
    }
  }

  /// returns List<String> names of images of the wiki artivle with title
  Future<List<String>> _getImageNames(String title) async {
    final queryParams = <String, String>{
      'action': 'query',
      'format': 'json',
      'prop': 'images',
    };

    if (title != null) {
      queryParams.addAll({'titles': title});
    }

    http.Response response;

    try {
      response = await _wikiRequest(queryParams);
    } on Exception {
      rethrow;
    }

    Map<String, dynamic> body;

    try {
      body = json.decode(response.body) as Map<String, dynamic>;
    } on Exception {
      throw JsonDecodeException();
    }

    try {
      final images = (body['query']['pages'] as Map)
          .values
          .toList()
          .first['images'] as List<dynamic>;

      // if no images object found
      if (images == null) return null;
      if (images.isEmpty) return null;

      final imageNames = images
          .map<String>((dynamic image) => image['title'].toString())
          .toList();

      return imageNames;
    } on Exception {
      throw JsonDeserializationException();
    }
  }

  /// makes request to Wikipedia API with provided query params and returns [http.Response]
  Future<http.Response> _wikiRequest(Map<String, String> queryParams) async {
    final uri = Uri.https(_authority, '/w/api.php', queryParams);

    try {
      final response = await _httpClient.get(
        uri,
        headers: <String, String>{
          'Origin': 'https://www.google.com',
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

      if (response.statusCode != 200) {
        throw HttpRequestFailure(response.statusCode);
      }

      return response;
    } on Exception {
      throw HttpException();
    }
  }
}

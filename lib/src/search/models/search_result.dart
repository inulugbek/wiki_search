import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  const SearchResult({
    this.title,
    this.url,
    this.images,
  });

  final String title;
  final String url;
  final List<String> images;

  @override
  List<Object> get props => [title, url, images];
}

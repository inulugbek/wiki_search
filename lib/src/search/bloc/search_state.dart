part of 'search_bloc.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  const SearchState._({
    this.status = SearchStatus.initial,
    this.searchResults = const <SearchResult>[],
  });

  const SearchState.initial() : this._();

  const SearchState.loading() : this._(status: SearchStatus.loading);

  const SearchState.success(List<SearchResult> searchResults)
      : this._(status: SearchStatus.success, searchResults: searchResults);

  const SearchState.failure() : this._(status: SearchStatus.failure);

  final SearchStatus status;
  final List<SearchResult> searchResults;

  @override
  List<Object> get props => [status, searchResults];
}

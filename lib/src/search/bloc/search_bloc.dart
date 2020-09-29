import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:search_repository/search_repository.dart';

import '../models/search_result.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._searchRepository)
      : assert(_searchRepository != null),
        super(const SearchState.initial());

  final SearchRepository _searchRepository;

  @override
  Stream<Transition<SearchEvent, SearchState>> transformEvents(
    Stream<SearchEvent> events,
    TransitionFunction<SearchEvent, SearchState> transitionFn,
  ) =>
      events
          .debounceTime(const Duration(milliseconds: 350))
          .switchMap(transitionFn);

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is SearchQueryChanged) {
      yield* _mapSearchQueryChangedToState(event, state);
    }
  }

  Stream<SearchState> _mapSearchQueryChangedToState(
    SearchQueryChanged event,
    SearchState state,
  ) async* {
    // no query from user
    if (event.query.isEmpty) {
      yield const SearchState.initial();
      return;
    }

    yield const SearchState.loading();

    try {
      final results = await _searchRepository.search(query: event.query);

      final searchResults = results
          .map<SearchResult>((result) => SearchResult(
                title: result.title,
                url: result.url,
                images: result.images,
              ))
          .toList();

      yield SearchState.success(searchResults);
    } on Exception {
      yield const SearchState.failure();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localisation_provider/localisation_provider.dart';
import 'package:platform_actions/platform_actions.dart';

import '../bloc/search_bloc.dart';
import '../models/models.dart';
import 'search_bar.dart';
import 'search_results.dart';

class SearchForm extends StatelessWidget {
  const SearchForm({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchBar(
            onChanged: (query) {
              context.bloc<SearchBloc>().add(SearchQueryChanged(query));
            },
          ),
          const _SearchContent(),
        ],
      );
}

class _SearchContent extends StatelessWidget {
  const _SearchContent({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Flexible(
        child: BlocConsumer<SearchBloc, SearchState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == SearchStatus.failure) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                      content: Text(
                    context.localisedString('error'),
                  )),
                );
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case SearchStatus.loading:
                return const _SearchLoading();
              case SearchStatus.success:
                if (state.searchResults.isEmpty) {
                  return const _NoSearchResults();
                }
                return _SearchSuccess(searchResults: state.searchResults);
              case SearchStatus.failure:
                return const _SearchError();
              default:
                return const _SearchInitial();
            }
          },
        ),
      );
}

class _SearchLoading extends StatelessWidget {
  const _SearchLoading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      );
}

class _SearchSuccess extends StatelessWidget {
  const _SearchSuccess({
    @required this.searchResults,
    Key key,
  }) : super(key: key);

  final List<SearchResult> searchResults;

  @override
  Widget build(BuildContext context) => SearchResults(
        searchResults: searchResults,
        onTap: (searchResult) => PlatformActions.launchURL(searchResult.url),
      );
}

class _SearchError extends StatelessWidget {
  const _SearchError({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      _InfoMessage(context.localisedString('error'));
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      _InfoMessage(context.localisedString('no_results'));
}

class _SearchInitial extends StatelessWidget {
  const _SearchInitial({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      _InfoMessage(context.localisedString('welcome'));
}

class _InfoMessage extends StatelessWidget {
  final String message;

  const _InfoMessage(
    this.message, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
      );
}

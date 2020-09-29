import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localisation_provider/localisation_provider.dart';

import '../models/models.dart';
import 'app_image.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({
    Key key,
    this.onTap,
    this.searchResults = const <SearchResult>[],
  }) : super(key: key);

  final ValueSetter<SearchResult> onTap;
  final List<SearchResult> searchResults;

  @override
  Widget build(BuildContext context) => ListView.builder(
        shrinkWrap: true,
        itemCount: searchResults.length,
        itemBuilder: (context, index) => _SearchResult(
          result: searchResults[index],
          onTap: () => onTap(searchResults[index]),
        ),
      );
}

class _SearchResult extends StatelessWidget {
  const _SearchResult({
    Key key,
    this.result,
    this.onTap,
  }) : super(key: key);

  final SearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${result.title} (${result.images.length} ${context.localisedString('pictures')})',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),

              // link
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(result.url),
              ),
              const SizedBox(height: 10),

              // images
              if (result.images != null)
                if (result.images.isNotEmpty)
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: result.images.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) => Row(
                        children: [
                          if (index == 0) const SizedBox(width: 10),
                          AppImage(
                            result.images[index],
                            size: 140,
                          ),
                          if (index == result.images.length - 1)
                            const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  thickness: 2,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ],
          ),
        ),
      );
}

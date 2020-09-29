import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localisation_provider/localisation_provider.dart';
import 'package:search_repository/search_repository.dart';
import 'package:network_info/network_info.dart';

import 'bloc/search_bloc.dart';
import 'widgets/search_form.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) => NetworkInfoStatus(
        noNetworkMessage: context.localisedString('no_network'),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('${context.localisedString('search')} Wikipedia'),
            actions: [
              AppLocalizationButton(
                title: context.localisedString('language'),
              ),
            ],
          ),
          body: BlocProvider(
            create: (context) => SearchBloc(
              SearchRepository(),
            ),
            child: const SearchForm(),
          ),
        ),
      );
}

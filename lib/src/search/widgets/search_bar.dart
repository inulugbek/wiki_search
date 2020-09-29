import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final ValueSetter<String> onChanged;

  const SearchBar({
    Key key,
    this.onChanged,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController controller;
  Widget trailing;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController()
      ..addListener(() {
        // show clear button if there is some query inputted

        if (controller.text.isEmpty) {
          setState(() => trailing = null);
        } else {
          if (trailing == null) {
            setState(() {
              trailing = IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  widget.onChanged('');
                  controller.clear();
                },
                icon: Icon(
                  Icons.cancel,
                  color: Theme.of(context).accentColor,
                ),
              );
            });
          }
        }
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).accentColor,
        alignment: Alignment.center,
        child: Container(
          height: 55,
          constraints: const BoxConstraints(
            maxWidth: 555,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).accentColor,
              ),
              suffixIcon: trailing,
            ),
            onChanged: widget.onChanged,
          ),
        ),
      );
}

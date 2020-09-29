import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

///Wrapper widget for displaying images
///supports loading images from internet
///local assets with `png` , `svg` formats
class AppImage extends StatefulWidget {
  final String path;
  final Color color;
  final double size;
  final BoxFit fit;

  const AppImage(
    this.path, {
    Key key,
    this.color,
    this.fit = BoxFit.contain,
    this.size,
  }) : super(key: key);

  @override
  _AppImageState createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  @override
  void dispose() {
    imageCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.path != null) {
      if (widget.path.contains('http')) {
        if (widget.path.endsWith('svg')) {
          return SvgPicture.network(
            widget.path,
            color: widget.color,
            height: widget.size,
            width: widget.size,
            fit: widget.fit,
            placeholderBuilder: (context) => const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return Image.network(
          widget.path,
          color: widget.color,
          height: widget.size,
          width: widget.size,
          fit: widget.fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => const SizedBox(
            height: 30,
            width: 30,
            child: Icon(Icons.error_outline),
          ),
        );
      } else if (widget.path.endsWith('png')) {
        return Image.asset(
          widget.path,
          color: widget.color,
          width: widget.size,
          height: widget.size,
          fit: widget.fit,
        );
      } else if (widget.path.endsWith('svg')) {
        return SvgPicture.asset(
          widget.path,
          color: widget.color,
          width: widget.size,
          height: widget.size,
          fit: widget.fit,
        );
      }
    }
    return const SizedBox.shrink();
  }
}

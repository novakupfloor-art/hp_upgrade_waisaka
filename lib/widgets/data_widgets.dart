import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers_property.dart';
import '../providers/providers_article.dart';

// Custom widget untuk Property data
class DataIklanProperty extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    PropertyProvider provider,
    Widget? child,
  )
  builder;
  final Widget? child;

  const DataIklanProperty({super.key, required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(builder: builder, child: child);
  }
}

// Custom widget untuk Article data
class DataArticle extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    ArticleProvider provider,
    Widget? child,
  )
  builder;
  final Widget? child;

  const DataArticle({super.key, required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleProvider>(builder: builder, child: child);
  }
}

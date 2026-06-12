import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
  final String slug;
  const NewsDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nyhet')),
      body: Center(child: Text('Artikel: $slug')),
    );
  }
}

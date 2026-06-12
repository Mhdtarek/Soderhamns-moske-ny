import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/routes.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mer')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Donera'),
            onTap: () => context.push(Routes.donate),
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Kontakt'),
            onTap: () => context.push(Routes.contact),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Inställningar'),
            onTap: () => context.push(Routes.settings),
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Qibla'),
            onTap: () => context.push(Routes.qibla),
          ),
        ],
      ),
    );
  }
}

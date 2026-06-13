import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();

  return Stream<bool>.multi((controller) async {
    final initial = await connectivity.checkConnectivity();
    controller.add(initial.any((r) => r != ConnectivityResult.none));

    final sub = connectivity.onConnectivityChanged.listen((results) {
      controller.add(results.any((r) => r != ConnectivityResult.none));
    });

    ref.onDispose(sub.cancel);
  });
});

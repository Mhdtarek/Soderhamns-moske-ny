import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soderhamns_moske_app/data/datasources/local/ayah_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/ayah_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/ayah.dart';
import 'package:soderhamns_moske_app/data/repositories/ayah_repository.dart';

final ayahLocalDsProvider = Provider<AyahLocalDs>((ref) {
  return AyahLocalDs();
});

final ayahRemoteDsProvider = Provider<AyahRemoteDs>((ref) {
  return AyahRemoteDs();
});

final ayahRepositoryProvider = Provider<AyahRepository>((ref) {
  return AyahRepository(
    local: ref.watch(ayahLocalDsProvider),
    remote: ref.watch(ayahRemoteDsProvider),
  );
});

final dailyAyahProvider = FutureProvider<Ayah>((ref) async {
  final repo = ref.watch(ayahRepositoryProvider);
  try {
    return await repo.syncIfNeeded();
  } catch (_) {
    final cached = repo.getDailyAyah();
    if (cached != null) return cached;
    rethrow;
  }
});

import 'package:soderhamns_moske_app/data/datasources/local/ayah_local_ds.dart';
import 'package:soderhamns_moske_app/data/datasources/remote/ayah_remote_ds.dart';
import 'package:soderhamns_moske_app/data/models/ayah.dart';

class AyahRepository {
  final AyahLocalDs local;
  final AyahRemoteDs remote;

  AyahRepository({required this.local, required this.remote});

  Ayah? getDailyAyah() {
    return local.getCachedAyah();
  }

  Future<Ayah> syncIfNeeded() async {
    final today = AyahRemoteDs.todayKey();
    final cachedDate = local.getCachedDate();

    if (cachedDate == today) {
      final cached = local.getCachedAyah();
      if (cached != null) return cached;
    }

    try {
      final number = AyahRemoteDs.dailyAyahNumber();
      final ayah = await remote.getAyah(number);
      await local.cacheAyah(ayah);
      return ayah;
    } catch (_) {
      final cached = local.getCachedAyah();
      if (cached != null) return cached;
      rethrow;
    }
  }
}

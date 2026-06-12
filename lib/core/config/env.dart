class Env {
  static const prayerApiBase = String.fromEnvironment(
    'PRAYER_API_BASE',
    defaultValue: 'https://soderhamns-moske.netlify.app',
  );
  static const alquranApiBase = String.fromEnvironment(
    'ALQURAN_API_BASE',
    defaultValue: 'https://api.alquran.cloud/v1',
  );
}

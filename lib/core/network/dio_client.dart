import 'package:dio/dio.dart';
import '../../core/config/env.dart';

final dioClient = Dio(BaseOptions(
  baseUrl: Env.prayerApiBase,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
));

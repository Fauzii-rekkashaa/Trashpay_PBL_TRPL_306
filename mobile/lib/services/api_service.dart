import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Ganti sesuai device testing kamu:
  // - Android Emulator  -> http://10.0.2.2:8000/api
  // - HP fisik (1 WiFi)  -> http://IP_LAPTOP_KAMU:8000/api (misal http://192.168.1.5:8000/api)
  // - Chrome/Web         -> http://localhost:8000/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
    },
  ));

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    // Interceptor: otomatis nempelin token Sanctum di setiap request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Kalau token expired/invalid, bisa ditambah logic redirect ke login di sini nanti
          return handler.next(e);
        },
      ),
    );
  }

  // ===== AUTH =====

  /// [identitas] = email ATAU nomor HP (login_screen sudah menormalkannya).
  /// Dikirim sebagai kunci "identitas" -> backend LoginController membaca kunci ini.
  Future<Response> login(String identitas, String password) async {
    return await _dio.post('/login', data: {
      'identitas': identitas,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post('/register', data: data);
  }

  /// Minta tautan reset kata sandi. Backend selalu membalas generik (200)
  /// berisi { message, cooldown_seconds }.
  Future<Response> forgotPassword(String identitas) async {
    return await _dio.post('/forgot-password', data: {
      'identitas': identitas,
    });
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> logout() async {
    await _dio.post('/logout');
    await _storage.delete(key: 'auth_token');
  }

  // ===== CONTOH ENDPOINT LAIN (tambah sesuai kebutuhan) =====
  Future<Response> getJenisSampah() async {
    return await _dio.get('/jenis-sampah');
  }

  Future<Response> ajukanSetoran(FormData data) async {
    return await _dio.post('/setoran', data: data);
  }

  Future<Response> getRiwayatSetoran() async {
    return await _dio.get('/riwayat-setoran');
  }
}
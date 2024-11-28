import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpService {
  final Dio _dio = Dio();

  HttpService() {
    _dio.options.baseUrl = dotenv.env['BASE_URL'] ?? '';
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${dotenv.env['AUTH_TOKEN']}',
    };
  }

  Future<List<Map<String, dynamic>>> fetchParcelasAVencer() async {
    try {
      final response = await _dio.get('/carteira');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['tbParcelasAVencer']);
      } else {
        throw Exception('Erro ao buscar dados: ${response.statusMessage}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

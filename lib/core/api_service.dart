import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String get baseUrl => AppConstants.baseUrl;

  // ============================================================
  // Autenticação
  // ============================================================
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/trpc/auth.login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Salvar token/session
        await _storage.write(key: 'session', value: response.body);
        return data;
      } else {
        throw Exception('Falha no login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<void> logout() async {
    await _client.post(
      Uri.parse('$baseUrl/api/trpc/auth.logout'),
      headers: _authHeaders,
    );
    await _storage.deleteAll();
  }

  Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/trpc/auth.me'),
        headers: _authHeaders,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // Veículos
  // ============================================================
  Future<List<Map<String, dynamic>>> getVehiclesPatio() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/vehicles.patio'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  Future<Map<String, dynamic>> createVehicle(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/vehicles.create'),
      headers: {'Content-Type': 'application/json', ..._authHeaders},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erro ao criar veículo');
  }

  Future<Map<String, dynamic>> updateVehicle(int id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/trpc/vehicles.update/$id'),
      headers: {'Content-Type': 'application/json', ..._authHeaders},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erro ao atualizar veículo');
  }

  // ============================================================
  // Clientes
  // ============================================================
  Future<List<Map<String, dynamic>>> getClients() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/clients.list'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  Future<Map<String, dynamic>> createClient(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/clients.create'),
      headers: {'Content-Type': 'application/json', ..._authHeaders},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erro ao criar cliente');
  }

  // ============================================================
  // Funcionários
  // ============================================================
  Future<List<Map<String, dynamic>>> getEmployees() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/employees.list'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/employees.create'),
      headers: {'Content-Type': 'application/json', ..._authHeaders},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erro ao criar funcionário');
  }

  // ============================================================
  // Serviços
  // ============================================================
  Future<Map<String, dynamic>> createService(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/services.create'),
      headers: {'Content-Type': 'application/json', ..._authHeaders},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erro ao criar serviço');
  }

  // ============================================================
  // Transações
  // ============================================================
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/transactions.list'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/transactions.create'),
      headers: {'Content-Type': 'application/json', ..._authHeaders},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erro ao criar transação');
  }

  // ============================================================
  // Comissões
  // ============================================================
  Future<List<Map<String, dynamic>>> getCommissions() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/commissions.list'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  // ============================================================
  // Dashboard
  // ============================================================
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/dashboard.stats'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  }

  // ============================================================
  // Inventário
  // ============================================================
  Future<List<Map<String, dynamic>>> getInventory() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/inventory.list'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  // ============================================================
  // Agendamentos
  // ============================================================
  Future<List<Map<String, dynamic>>> getAppointments() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/appointments.list'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    return [];
  }

  // ============================================================
  // Clima
  // ============================================================
  Future<Map<String, dynamic>> getWeather() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/weather.latest'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  }

  // ============================================================
  // Helpers
  // ============================================================
  Map<String, String> get _authHeaders {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  void dispose() {
    _client.close();
  }
}

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
  String? _sessionToken;

  String get baseUrl => AppConstants.baseUrl;

  // ============================================================
  // Autenticação
  // ============================================================
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // tRPC v11 format: body must be {"json": {...}}
      final response = await _client.post(
        Uri.parse('$baseUrl/api/trpc/auth.login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'json': {'username': username, 'password': password}}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract result from tRPC response format: {"result":{"data":{"json":...}}}
        final result = data['result']?['data']?['json'] ?? data['result']?['data'] ?? data;
        // Save session token
        await _storage.write(key: 'session', value: jsonEncode(result));
        _sessionToken = jsonEncode(result);
        return result as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        final body = jsonDecode(response.body);
        final msg = body['error']?['json']?['message'] ?? 'Usuário ou senha inválidos';
        throw Exception(msg);
      } else {
        throw Exception('Falha no login: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<void> logout() async {
    await _client.post(
      Uri.parse('$baseUrl/api/trpc/auth.logout'),
      headers: _authHeaders,
    );
    _sessionToken = null;
    await _storage.deleteAll();
  }

  Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/trpc/auth.me'),
        headers: _authHeaders,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result']?['data']?['json'] ?? data['result']?['data'] ?? data;
        if (result != null) {
          return result as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // Helpers para extrair dados do formato tRPC
  // ============================================================
  Map<String, dynamic>? _extractResult(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response['result']?['data']?['json'] ?? 
             response['result']?['data'] ?? response;
    }
    return null;
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    if (response is Map<String, dynamic>) {
      final result = response['result']?['data']?['json'];
      if (result is List) {
        return List<Map<String, dynamic>>.from(result);
      }
    }
    return [];
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
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> createVehicle(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/vehicles.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao criar veículo');
  }

  Future<Map<String, dynamic>> updateVehicle(int id, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/vehicles.update'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id, ...data}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao atualizar veículo');
  }

  Future<void> releaseVehicle(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/vehicles.release'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id}}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao liberar veículo');
    }
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
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> createClient(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/clients.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
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
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/employees.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao criar funcionário');
  }

  // ============================================================
  // Serviços
  // ============================================================
  Future<Map<String, dynamic>> createService(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/services.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao criar serviço');
  }

  Future<List<Map<String, dynamic>>> getServices() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/services.list'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
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
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/transactions.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
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
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> createCommission(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/commissions.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao criar comissão');
  }

  Future<Map<String, dynamic>> updateCommission(int id, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/commissions.update'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id, ...data}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao atualizar comissão');
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
      final data = jsonDecode(response.body);
      return _extractResult(data) ?? {};
    }
    return {};
  }

  Future<Map<String, dynamic>> getEmployeeDashboard() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/dashboard.employeeStats'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractResult(data) ?? {};
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
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> createInventoryItem(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/inventory.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao criar item de inventário');
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
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/appointments.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao criar agendamento');
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
      final data = jsonDecode(response.body);
      return _extractResult(data) ?? {};
    }
    return {};
  }

  // ============================================================
  // Helpers
  // ============================================================
  Map<String, String> get _authHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_sessionToken != null) {
      headers['Authorization'] = 'Bearer $_sessionToken';
    }
    return headers;
  }

  Map<String, String> get _trpcHeaders {
    return _authHeaders;
  }

  void dispose() {
    _client.close();
  }
}

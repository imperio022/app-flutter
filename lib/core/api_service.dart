import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

/// Serviço principal de API do Império 022.
/// Gerencia comunicação com o backend tRPC v11.
/// Autenticação: JWT via Bearer token (extraído do Set-Cookie do login).
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _sessionToken; // JWT string (não JSON)

  String get baseUrl => AppConstants.baseUrl;

  // ============================================================
  // Inicialização - carrega token salvo
  // ============================================================
  Future<void> init() async {
    _sessionToken = await _storage.read(key: 'jwt_token');
  }

  // ============================================================
  // Autenticação
  // ============================================================

  /// Faz login e extrai o JWT do header Set-Cookie.
  /// Salva o token no secure storage para uso futuro.
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/trpc/auth.login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'json': {'username': username, 'password': password}}),
      );

      if (response.statusCode == 200) {
        // Extrair token do Set-Cookie header
        final setCookieHeader = response.headers['set-cookie'] ?? '';
        String? token;
        if (setCookieHeader.isNotEmpty) {
          // Set-Cookie: app_session_id=JWT_TOKEN; Max-Age=...
          final match = RegExp(r'app_session_id=([^;]+)').firstMatch(setCookieHeader);
          token = match?.group(1);
        }

        // Decodificar resposta tRPC
        final data = jsonDecode(response.body);
        final result = data['result']?['data']?['json'] ?? data['result']?['data'] ?? data;

        if (token != null) {
          _sessionToken = token;
          await _storage.write(key: 'jwt_token', value: token);
          // Salvar user info também
          await _storage.write(key: 'user', value: jsonEncode(result));
        }

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
    try {
      await _client.post(
        Uri.parse('$baseUrl/api/trpc/auth.logout'),
        headers: _authHeaders,
      );
    } catch (_) {}
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
        final result = data['result']?['data']?['json'] ?? data['result']?['data'];
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

  Future<List<Map<String, dynamic>>> getVehicles(String? status) async {
    final uri = status != null
        ? Uri.parse('$baseUrl/api/trpc/vehicles.list?input=${jsonEncode(jsonEncode({"status": status}))}')
        : Uri.parse('$baseUrl/api/trpc/vehicles.list');
    final response = await _client.get(uri, headers: _authHeaders);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> getVehicleById(int id) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/vehicles.getById?input=${jsonEncode(jsonEncode({"id": id}))}'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    return {};
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
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['json']?['message'] ?? 'Erro ao criar veículo');
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
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['json']?['message'] ?? 'Erro ao atualizar veículo');
  }

  Future<void> deleteVehicle(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/vehicles.delete'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id}}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar veículo');
    }
  }

  Future<List<Map<String, dynamic>>> getVehicleHistory(String plate) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/vehicles.getByPlate?input=${jsonEncode(jsonEncode({"plate": plate}))}'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
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

  Future<Map<String, dynamic>> getClientById(int id) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/clients.getById?input=${jsonEncode(jsonEncode({"id": id}))}'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    return {};
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
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['json']?['message'] ?? 'Erro ao criar cliente');
  }

  Future<Map<String, dynamic>> updateClient(int id, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/clients.update'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id, ...data}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['json']?['message'] ?? 'Erro ao atualizar cliente');
  }

  Future<void> deleteClient(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/clients.delete'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id}}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar cliente');
    }
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
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['json']?['message'] ?? 'Erro ao criar funcionário');
  }

  Future<Map<String, dynamic>> updateEmployee(int id, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/employees.update'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id, ...data}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['json']?['message'] ?? 'Erro ao atualizar funcionário');
  }

  Future<void> deleteEmployee(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/employees.delete'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id}}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar funcionário');
    }
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
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['json']?['message'] ?? 'Erro ao criar serviço');
  }

  Future<List<Map<String, dynamic>>> getServices(int? vehicleId) async {
    final uri = vehicleId != null
        ? Uri.parse('$baseUrl/api/trpc/services.list?input=${jsonEncode(jsonEncode({"vehicleId": vehicleId}))}')
        : Uri.parse('$baseUrl/api/trpc/services.list');
    final response = await _client.get(uri, headers: _authHeaders);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> updateService(int id, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/services.update'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id, ...data}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao atualizar serviço');
  }

  Future<void> deleteService(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/services.delete'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id}}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar serviço');
    }
  }

  // ============================================================
  // Transações
  // ============================================================
  Future<List<Map<String, dynamic>>> getTransactions(String? type) async {
    final uri = type != null
        ? Uri.parse('$baseUrl/api/trpc/transactions.list?input=${jsonEncode(jsonEncode({"type": type}))}')
        : Uri.parse('$baseUrl/api/trpc/transactions.list');
    final response = await _client.get(uri, headers: _authHeaders);
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
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['json']?['message'] ?? 'Erro ao criar transação');
  }

  Future<Map<String, dynamic>> updateTransaction(int id, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/transactions.update'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id, ...data}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao atualizar transação');
  }

  Future<void> deleteTransaction(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/transactions.delete'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id}}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar transação');
    }
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
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['json']?['message'] ?? 'Erro ao criar comissão');
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

  Future<Map<String, dynamic>> payCommission(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/commissions.pay'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['json']?['message'] ?? 'Erro ao pagar comissão');
  }

  Future<void> deleteCommission(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/commissions.delete'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id}}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar comissão');
    }
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
  // Relatórios
  // ============================================================
  Future<Map<String, dynamic>> getWeeklyRevenue() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/reports.weeklyRevenue'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractResult(data) ?? {};
    }
    return {};
  }

  Future<Map<String, dynamic>> getMonthlyRevenue() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/reports.monthlyRevenue'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractResult(data) ?? {};
    }
    return {};
  }

  Future<Map<String, dynamic>> getRevenueByMethod() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/reports.revenueByMethod'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractResult(data) ?? {};
    }
    return {};
  }

  Future<Map<String, dynamic>> getDailyTotals(String period) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/reports.dailyTotals?input=${jsonEncode(jsonEncode({"period": period}))}'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractResult(data) ?? {};
    }
    return {};
  }

  // ============================================================
  // Analytics / Inteligência
  // ============================================================
  Future<Map<String, dynamic>> getAnalyticsByHour(String period) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/analytics.byHour?input=${jsonEncode(jsonEncode({"period": period}))}'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractResult(data) ?? {};
    }
    return {};
  }

  Future<Map<String, dynamic>> getAnalyticsByDay() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/analytics.byDay'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractResult(data) ?? {};
    }
    return {};
  }

  Future<Map<String, dynamic>> getTopServices() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/analytics.topServices'),
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

  Future<List<Map<String, dynamic>>> getLowStockItems() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/inventory.lowStock'),
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
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['json']?['message'] ?? 'Erro ao criar item');
  }

  Future<Map<String, dynamic>> updateInventory(int id, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/inventory.update'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id, ...data}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao atualizar item');
  }

  Future<void> deleteInventory(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/inventory.delete'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id}}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar item');
    }
  }

  // ============================================================
  // Agendamentos
  // ============================================================
  Future<List<Map<String, dynamic>>> getAppointments(String? status) async {
    final uri = status != null
        ? Uri.parse('$baseUrl/api/trpc/appointments.list?input=${jsonEncode(jsonEncode({"status": status}))}')
        : Uri.parse('$baseUrl/api/trpc/appointments.list');
    final response = await _client.get(uri, headers: _authHeaders);
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
    final body = jsonDecode(response.body);
    throw Exception(body['error']?['json']?['message'] ?? 'Erro ao criar agendamento');
  }

  Future<Map<String, dynamic>> updateAppointment(int id, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/appointments.update'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id, ...data}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao atualizar agendamento');
  }

  Future<void> deleteAppointment(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/appointments.delete'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id}}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar agendamento');
    }
  }

  // ============================================================
  // Fotos de Danos
  // ============================================================
  Future<List<Map<String, dynamic>>> getDamagePhotos(int vehicleId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/damages.get?input=${jsonEncode(jsonEncode({"vehicleId": vehicleId}))}'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> createDamagePhoto(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/damages.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao criar foto de dano');
  }

  Future<Map<String, dynamic>> uploadDamagePhoto(String fileData, String fileName) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/damages.upload'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'fileData': fileData, 'fileName': fileName}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao upload foto');
  }

  Future<void> deleteDamagePhoto(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/damages.delete'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id}}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar foto');
    }
  }

  // ============================================================
  // Checklist de Qualidade
  // ============================================================
  Future<Map<String, dynamic>> getQualityChecklist(int vehicleId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/quality.get?input=${jsonEncode(jsonEncode({"vehicleId": vehicleId}))}'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    return {};
  }

  Future<Map<String, dynamic>> createQualityChecklist(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/quality.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao criar checklist');
  }

  Future<Map<String, dynamic>> updateQualityChecklist(int id, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/quality.update'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id, ...data}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao atualizar checklist');
  }

  // ============================================================
  // Assinaturas
  // ============================================================
  Future<List<Map<String, dynamic>>> getSubscriptions() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/subscriptions.list'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> createSubscription(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/subscriptions.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao criar assinatura');
  }

  Future<Map<String, dynamic>> updateSubscription(int id, Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/subscriptions.update'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'id': id, ...data}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao atualizar assinatura');
  }

  // ============================================================
  // Escala de Equipe
  // ============================================================
  Future<List<Map<String, dynamic>>> getEmployeeSchedule(String weekStart) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/schedule.list?input=${jsonEncode(jsonEncode({"weekStart": weekStart}))}'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> saveEmployeeSchedule(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/schedule.save'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao salvar escala');
  }

  // ============================================================
  // Clima
  // ============================================================
  Future<Map<String, dynamic>> getWeather() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/weather.saquarema'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractResult(data) ?? {};
    }
    return {};
  }

  // ============================================================
  // Fidelidade
  // ============================================================
  Future<Map<String, dynamic>> getLoyaltyCard(int clientId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/loyalty.get?input=${jsonEncode(jsonEncode({"clientId": clientId}))}'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    return {};
  }

  Future<Map<String, dynamic>> addLoyaltyWash(int clientId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/loyalty.addWash'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'clientId': clientId}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao adicionar lavagem fidelidade');
  }

  Future<Map<String, dynamic>> useFreeWash(int clientId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/loyalty.useFree'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': {'clientId': clientId}}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao usar lavagem grátis');
  }

  // ============================================================
  // Avaliações
  // ============================================================
  Future<Map<String, dynamic>> createEvaluation(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/evaluations.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao criar avaliação');
  }

  Future<List<Map<String, dynamic>>> getEvaluations() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/evaluations.list'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _extractList(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> getAverageRating() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/trpc/evaluations.average'),
      headers: _authHeaders,
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    return {};
  }

  // ============================================================
  // Notifications
  // ============================================================
  Future<Map<String, dynamic>> createNotification(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/trpc/notifications.create'),
      headers: _trpcHeaders,
      body: jsonEncode({'json': data}),
    );
    if (response.statusCode == 200) {
      return _extractResult(jsonDecode(response.body)) ?? {};
    }
    throw Exception('Erro ao criar notificação');
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

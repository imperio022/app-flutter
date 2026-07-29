import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../core/models.dart';

/// Provider global de dados do Império 022.
/// Gerencia cache de veículos, clientes, funcionários, transações, etc.
/// NOTA: O backend tRPC retorna apenas { id } nos endpoints create,
/// então os métodos createXxx retornam o id e a tela deve recarregar.
class DataNotifier extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ============================================================
  // Veículos no pátio
  // ============================================================
  List<Vehicle> _vehiclesPatio = [];
  List<Vehicle> get vehiclesPatio => _vehiclesPatio;

  Future<void> loadVehiclesPatio() async {
    try {
      final data = await _api.getVehiclesPatio();
      _vehiclesPatio = data.map((e) => Vehicle.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silencioso para offline
    }
  }

  /// Cria veículo. Retorna o id. Recarrega pátio após sucesso.
  Future<int> createVehicle(Map<String, dynamic> data) async {
    final result = await _api.createVehicle(data);
    final id = result['id'] ?? 0;
    await loadVehiclesPatio(); // Recarrega pátio com o novo veículo
    return id as int;
  }

  Future<void> updateVehicle(int id, Map<String, dynamic> data) async {
    await _api.updateVehicle(id, data);
    await loadVehiclesPatio();
  }

  Future<void> deleteVehicle(int id) async {
    await _api.deleteVehicle(id);
    await loadVehiclesPatio();
  }

  // ============================================================
  // Clientes
  // ============================================================
  List<Client> _clients = [];
  List<Client> get clients => _clients;

  Future<void> loadClients() async {
    try {
      final data = await _api.getClients();
      _clients = data.map((e) => Client.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silencioso
    }
  }

  /// Cria cliente. Retorna o id.
  Future<int> createClient(Map<String, dynamic> data) async {
    final result = await _api.createClient(data);
    await loadClients(); // Recarrega lista
    return result['id'] ?? 0;
  }

  Future<void> updateClient(int id, Map<String, dynamic> data) async {
    await _api.updateClient(id, data);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    await _api.deleteClient(id);
    await loadClients();
  }

  // ============================================================
  // Funcionários
  // ============================================================
  List<Employee> _employees = [];
  List<Employee> get employees => _employees;

  Future<void> loadEmployees() async {
    try {
      final data = await _api.getEmployees();
      _employees = data.map((e) => Employee.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silencioso
    }
  }

  Future<void> createEmployee(Map<String, dynamic> data) async {
    await _api.createEmployee(data);
    await loadEmployees();
  }

  Future<void> updateEmployee(int id, Map<String, dynamic> data) async {
    await _api.updateEmployee(id, data);
    await loadEmployees();
  }

  Future<void> deleteEmployee(int id) async {
    await _api.deleteEmployee(id);
    await loadEmployees();
  }

  // ============================================================
  // Transações
  // ============================================================
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    try {
      final data = await _api.getTransactions(null);
      _transactions = data.map((e) => Transaction.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silencioso
    }
  }

  /// Cria serviço (sem recarregar cache - usado internamente pelo entry_screen)
  Future<int> createService(Map<String, dynamic> data) async {
    final result = await _api.createService(data);
    return result['id'] ?? 0;
  }

  Future<void> createTransaction(Map<String, dynamic> data) async {
    await _api.createTransaction(data);
    await loadTransactions();
  }

  // ============================================================
  // Comissões
  // ============================================================
  List<Commission> _commissions = [];
  List<Commission> get commissions => _commissions;

  Future<void> loadCommissions() async {
    try {
      final data = await _api.getCommissions();
      _commissions = data.map((e) => Commission.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silencioso
    }
  }

  Future<void> createCommission(Map<String, dynamic> data) async {
    await _api.createCommission(data);
    await loadCommissions();
  }

  Future<void> payCommission(int id) async {
    await _api.payCommission(id);
    await loadCommissions();
  }

  // ============================================================
  // Dashboard
  // ============================================================
  DashboardStats? _dashboardStats;
  DashboardStats? get dashboardStats => _dashboardStats;

  Future<void> loadDashboardStats() async {
    try {
      final data = await _api.getDashboardStats();
      _dashboardStats = DashboardStats.fromJson(data);
      notifyListeners();
    } catch (e) {
      // Silencioso
    }
  }

  // ============================================================
  // Inventário
  // ============================================================
  List<InventoryItem> _inventory = [];
  List<InventoryItem> get inventory => _inventory;

  Future<void> loadInventory() async {
    try {
      final data = await _api.getInventory();
      _inventory = data.map((e) => InventoryItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silencioso
    }
  }

  Future<void> createInventoryItem(Map<String, dynamic> data) async {
    await _api.createInventoryItem(data);
    await loadInventory();
  }

  Future<void> updateInventory(int id, Map<String, dynamic> data) async {
    await _api.updateInventory(id, data);
    await loadInventory();
  }

  Future<void> deleteInventory(int id) async {
    await _api.deleteInventory(id);
    await loadInventory();
  }

  // ============================================================
  // Agendamentos
  // ============================================================
  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  Future<void> loadAppointments() async {
    try {
      final data = await _api.getAppointments(null);
      _appointments = data.map((e) => Appointment.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silencioso
    }
  }

  Future<void> createAppointment(Map<String, dynamic> data) async {
    await _api.createAppointment(data);
    await loadAppointments();
  }

  Future<void> updateAppointment(int id, Map<String, dynamic> data) async {
    await _api.updateAppointment(id, data);
    await loadAppointments();
  }

  Future<void> deleteAppointment(int id) async {
    await _api.deleteAppointment(id);
    await loadAppointments();
  }

  // ============================================================
  // Relatórios
  // ============================================================
  Future<Map<String, dynamic>> getWeeklyRevenue() async {
    return await _api.getWeeklyRevenue();
  }

  Future<Map<String, dynamic>> getMonthlyRevenue() async {
    return await _api.getMonthlyRevenue();
  }

  Future<Map<String, dynamic>> getRevenueByMethod() async {
    return await _api.getRevenueByMethod();
  }

  // ============================================================
  // Analytics
  // ============================================================
  Future<Map<String, dynamic>> getAnalyticsByHour(String period) async {
    return await _api.getAnalyticsByHour(period);
  }

  Future<Map<String, dynamic>> getAnalyticsByDay() async {
    return await _api.getAnalyticsByDay();
  }

  Future<Map<String, dynamic>> getTopServices() async {
    return await _api.getTopServices();
  }

  // ============================================================
  // Clima
  // ============================================================
  Future<Map<String, dynamic>> getWeather() async {
    return await _api.getWeather();
  }

  // ============================================================
  // Escala
  // ============================================================
  Future<List<Map<String, dynamic>>> getEmployeeSchedule(String weekStart) async {
    return await _api.getEmployeeSchedule(weekStart);
  }

  Future<Map<String, dynamic>> saveEmployeeSchedule(Map<String, dynamic> data) async {
    return await _api.saveEmployeeSchedule(data);
  }
}

final dataProvider = ChangeNotifierProvider((ref) => DataNotifier());

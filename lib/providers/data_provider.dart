import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_service.dart';
import '../core/models.dart';

class DataNotifier extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Vehicles
  List<Vehicle> _vehiclesPatio = [];
  List<Vehicle> get vehiclesPatio => _vehiclesPatio;

  Future<void> loadVehiclesPatio() async {
    try {
      final data = await _api.getVehiclesPatio();
      _vehiclesPatio = data.map((e) => Vehicle.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silent fail - offline mode
    }
  }

  Future<Vehicle> createVehicle(Map<String, dynamic> data) async {
    final result = await _api.createVehicle(data);
    final vehicle = Vehicle.fromJson(result['data'] ?? result);
    _vehiclesPatio.add(vehicle);
    notifyListeners();
    return vehicle;
  }

  // Clients
  List<Client> _clients = [];
  List<Client> get clients => _clients;

  Future<void> loadClients() async {
    try {
      final data = await _api.getClients();
      _clients = data.map((e) => Client.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }

  // Employees
  List<Employee> _employees = [];
  List<Employee> get employees => _employees;

  Future<void> loadEmployees() async {
    try {
      final data = await _api.getEmployees();
      _employees = data.map((e) => Employee.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }

  // Transactions
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    try {
      final data = await _api.getTransactions();
      _transactions = data.map((e) => Transaction.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }

  // Commissions
  List<Commission> _commissions = [];
  List<Commission> get commissions => _commissions;

  Future<void> loadCommissions() async {
    try {
      final data = await _api.getCommissions();
      _commissions = data.map((e) => Commission.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }

  // Dashboard
  DashboardStats? _dashboardStats;
  DashboardStats? get dashboardStats => _dashboardStats;

  Future<void> loadDashboardStats() async {
    try {
      final data = await _api.getDashboardStats();
      _dashboardStats = DashboardStats.fromJson(data['data'] ?? data);
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }

  // Inventory
  List<InventoryItem> _inventory = [];
  List<InventoryItem> get inventory => _inventory;

  Future<void> loadInventory() async {
    try {
      final data = await _api.getInventory();
      _inventory = data.map((e) => InventoryItem.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }

  // Appointments
  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  Future<void> loadAppointments() async {
    try {
      final data = await _api.getAppointments();
      _appointments = data.map((e) => Appointment.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }
}

final dataProvider = ChangeNotifierProvider((ref) => DataNotifier());

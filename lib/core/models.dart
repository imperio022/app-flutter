/// Modelos de dados do Império 022

// ============================================================
// Autenticação
// ============================================================
class AuthUser {
  final int id;
  final String username;
  final String name;
  final String role; // 'admin' ou 'employee'
  final String? createdAt;

  AuthUser({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'employee',
      createdAt: json['createdAt'],
    );
  }

  bool get isAdmin => role == 'admin';
}

// ============================================================
// Funcionários
// ============================================================
class Employee {
  final int id;
  final String name;
  final String? phone;
  final int commissionRate;
  final String isActive; // 'active' ou 'inactive'

  Employee({
    required this.id,
    required this.name,
    this.phone,
    required this.commissionRate,
    required this.isActive,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
      commissionRate: json['commissionRate'] ?? 0,
      isActive: json['isActive'] ?? 'active',
    );
  }
}

// ============================================================
// Clientes
// ============================================================
class Client {
  final int id;
  final String name;
  final String? phone;
  final String? cpf;
  final String? email;
  final String? notes;
  final int loyaltyWashes;

  Client({
    required this.id,
    required this.name,
    this.phone,
    this.cpf,
    this.email,
    this.notes,
    this.loyaltyWashes = 0,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'],
      cpf: json['cpf'],
      email: json['email'],
      notes: json['notes'],
      loyaltyWashes: json['loyaltyWashes'] ?? 0,
    );
  }
}

// ============================================================
// Veículos
// ============================================================
class Vehicle {
  final int id;
  final int? clientId;
  final int? employeeId;
  final String plate;
  final String type; // 'moto', 'hatch', 'sedan', 'suv', 'truck', 'other'
  final String? model;
  final String? color;
  final String status; // 'patio', 'completed', 'left'
  final String entryDate;
  final String? exitDate;
  final String? notes;
  final String? clientName;

  Vehicle({
    required this.id,
    this.clientId,
    this.employeeId,
    required this.plate,
    required this.type,
    this.model,
    this.color,
    required this.status,
    required this.entryDate,
    this.exitDate,
    this.notes,
    this.clientName,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? 0,
      clientId: json['clientId'],
      employeeId: json['employeeId'],
      plate: json['plate'] ?? '',
      type: json['type'] ?? 'other',
      model: json['model'],
      color: json['color'],
      status: json['status'] ?? 'patio',
      entryDate: json['entryDate'] ?? '',
      exitDate: json['exitDate'],
      notes: json['notes'],
      clientName: json['clientName'],
    );
  }
}

// ============================================================
// Serviços
// ============================================================
class Service {
  final int id;
  final int vehicleId;
  final String description;
  final double value;
  final int? employeeId;
  final String status; // 'pending', 'paid'

  Service({
    required this.id,
    required this.vehicleId,
    required this.description,
    required this.value,
    this.employeeId,
    required this.status,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      vehicleId: json['vehicleId'] ?? 0,
      description: json['description'] ?? '',
      value: double.tryParse(json['value']?.toString() ?? '0') ?? 0,
      employeeId: json['employeeId'],
      status: json['status'] ?? 'pending',
    );
  }
}

// ============================================================
// Transações
// ============================================================
class Transaction {
  final int id;
  final String type; // 'income', 'expense'
  final String method; // 'cash', 'pix'
  final String description;
  final double amount;
  final int? vehicleId;
  final int? commissionId;

  Transaction({
    required this.id,
    required this.type,
    required this.method,
    required this.description,
    required this.amount,
    this.vehicleId,
    this.commissionId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'income',
      method: json['method'] ?? 'cash',
      description: json['description'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      vehicleId: json['vehicleId'],
      commissionId: json['commissionId'],
    );
  }
}

// ============================================================
// Comissões
// ============================================================
class Commission {
  final int id;
  final int employeeId;
  final int? vehicleId;
  final double amount;
  final String? serviceDescription;
  final String isPaid; // 'yes', 'no'
  final String? paidAt;

  Commission({
    required this.id,
    required this.employeeId,
    this.vehicleId,
    required this.amount,
    this.serviceDescription,
    required this.isPaid,
    this.paidAt,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      id: json['id'] ?? 0,
      employeeId: json['employeeId'] ?? 0,
      vehicleId: json['vehicleId'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      serviceDescription: json['serviceDescription'],
      isPaid: json['isPaid'] ?? 'no',
      paidAt: json['paidAt'],
    );
  }
}

// ============================================================
// Inventário
// ============================================================
class InventoryItem {
  final int id;
  final String name;
  final String category;
  final int quantity;
  final int minStock;
  final double unitPrice;
  final String? unit;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minStock,
    required this.unitPrice,
    this.unit,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: json['quantity'] ?? 0,
      minStock: json['minStock'] ?? 0,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0,
      unit: json['unit'],
    );
  }

  bool get isLowStock => quantity <= minStock;
}

// ============================================================
// Agendamentos
// ============================================================
class Appointment {
  final int id;
  final int? clientId;
  final String clientName;
  final String clientPhone;
  final String? vehiclePlate;
  final String? vehicleType;
  final String serviceType;
  final String appointmentDate; // datetime completo
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? notes;
  final int? createdBy;

  Appointment({
    required this.id,
    this.clientId,
    required this.clientName,
    required this.clientPhone,
    this.vehiclePlate,
    this.vehicleType,
    required this.serviceType,
    required this.appointmentDate,
    required this.status,
    this.notes,
    this.createdBy,
  });

  /// Retorna a data formatada (ex: "30/07/2026")
  String get dateFormatted {
    try {
      final dt = DateTime.parse(appointmentDate);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return appointmentDate;
    }
  }

  /// Retorna a hora formatada (ex: "10:00")
  String get timeFormatted {
    try {
      final dt = DateTime.parse(appointmentDate);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      clientId: json['clientId'],
      clientName: json['clientName'] ?? '',
      clientPhone: json['clientPhone'] ?? '',
      vehiclePlate: json['vehiclePlate'],
      vehicleType: json['vehicleType'],
      serviceType: json['serviceType'] ?? '',
      appointmentDate: json['appointmentDate'] ?? '',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdBy: json['createdBy'],
    );
  }
}

// ============================================================
// Fotos de Danos
// ============================================================
class DamagePhoto {
  final int id;
  final int vehicleId;
  final String type; // 'before', 'after'
  final String imageUrl;
  final String? notes;

  DamagePhoto({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.imageUrl,
    this.notes,
  });

  factory DamagePhoto.fromJson(Map<String, dynamic> json) {
    return DamagePhoto(
      id: json['id'] ?? 0,
      vehicleId: json['vehicleId'] ?? 0,
      type: json['type'] ?? 'before',
      imageUrl: json['imageUrl'] ?? '',
      notes: json['notes'],
    );
  }
}

// ============================================================
// Checklist de Qualidade
// ============================================================
class QualityChecklist {
  final int id;
  final int vehicleId;
  final int employeeId;
  final String exterior;
  final String interior;
  final String wheels;
  final String engine;
  final String leather;
  final String polish;
  final String fragrance;
  final String? notes;

  QualityChecklist({
    required this.id,
    required this.vehicleId,
    required this.employeeId,
    required this.exterior,
    required this.interior,
    required this.wheels,
    required this.engine,
    required this.leather,
    required this.polish,
    required this.fragrance,
    this.notes,
  });

  factory QualityChecklist.fromJson(Map<String, dynamic> json) {
    return QualityChecklist(
      id: json['id'] ?? 0,
      vehicleId: json['vehicleId'] ?? 0,
      employeeId: json['employeeId'] ?? 0,
      exterior: json['exterior'] ?? 'pending',
      interior: json['interior'] ?? 'pending',
      wheels: json['wheels'] ?? 'pending',
      engine: json['engine'] ?? 'skip',
      leather: json['leather'] ?? 'skip',
      polish: json['polish'] ?? 'skip',
      fragrance: json['fragrance'] ?? 'pending',
      notes: json['notes'],
    );
  }
}

// ============================================================
// Assinaturas
// ============================================================
class Subscription {
  final int id;
  final int clientId;
  final String planName;
  final int washesPerMonth;
  final double price;
  final int washesUsed;
  final String isActive;
  final String startDate;
  final String? endDate;

  Subscription({
    required this.id,
    required this.clientId,
    required this.planName,
    required this.washesPerMonth,
    required this.price,
    required this.washesUsed,
    required this.isActive,
    required this.startDate,
    this.endDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? 0,
      clientId: json['clientId'] ?? 0,
      planName: json['planName'] ?? '',
      washesPerMonth: json['washesPerMonth'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      washesUsed: json['washesUsed'] ?? 0,
      isActive: json['isActive'] ?? 'active',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'],
    );
  }
}

// ============================================================
// Escala de Equipe
// ============================================================
class EmployeeSchedule {
  final int id;
  final int employeeId;
  final String weekStart;
  final String monday;
  final String tuesday;
  final String wednesday;
  final String thursday;
  final String friday;
  final String saturday;
  final String sunday;

  EmployeeSchedule({
    required this.id,
    required this.employeeId,
    required this.weekStart,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  factory EmployeeSchedule.fromJson(Map<String, dynamic> json) {
    return EmployeeSchedule(
      id: json['id'] ?? 0,
      employeeId: json['employeeId'] ?? 0,
      weekStart: json['weekStart'] ?? '',
      monday: json['monday'] ?? 'off',
      tuesday: json['tuesday'] ?? 'off',
      wednesday: json['wednesday'] ?? 'off',
      thursday: json['thursday'] ?? 'off',
      friday: json['friday'] ?? 'off',
      saturday: json['saturday'] ?? 'off',
      sunday: json['sunday'] ?? 'off',
    );
  }
}

// ============================================================
// Clima
// ============================================================
class WeatherData {
  final String city;
  final double temperature;
  final String description;
  final String? icon;
  final double rainChance;
  final double humidity;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.description,
    this.icon,
    required this.rainChance,
    required this.humidity,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['city'] ?? 'Saquarema',
      temperature: double.tryParse(json['temperature']?.toString() ?? '0') ?? 0,
      description: json['description'] ?? '',
      icon: json['icon'],
      rainChance: double.tryParse(json['rainChance']?.toString() ?? '0') ?? 0,
      humidity: double.tryParse(json['humidity']?.toString() ?? '0') ?? 0,
    );
  }
}

// ============================================================
// Dashboard Stats
// ============================================================
class DashboardStats {
  final int totalVehiclesPatio;
  final double totalRevenueToday;
  final int servicesCompleted;
  final double monthlyRevenue;
  final int clientsCount;
  final int employeesCount;

  DashboardStats({
    required this.totalVehiclesPatio,
    required this.totalRevenueToday,
    required this.servicesCompleted,
    required this.monthlyRevenue,
    required this.clientsCount,
    required this.employeesCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    // Mapeamento dos campos do backend tRPC para o modelo do app
    // Backend retorna: {patioCount, completedCount, vehicleCounts, cash, pix, toReceive, expenses, pendingCommissions}
    final cash = double.tryParse(json['cash']?.toString() ?? '0') ?? 0;
    final pix = double.tryParse(json['pix']?.toString() ?? '0') ?? 0;
    final revenueToday = cash + pix;

    return DashboardStats(
      totalVehiclesPatio: json['patioCount'] ?? 0,
      totalRevenueToday: revenueToday,
      servicesCompleted: json['completedCount'] ?? 0,
      monthlyRevenue: revenueToday, // Usar receita do dia como proxy mensal (backend atual não separa)
      clientsCount: json['clientsCount'] ?? 0,
      employeesCount: json['employeesCount'] ?? 0,
    );
  }
}

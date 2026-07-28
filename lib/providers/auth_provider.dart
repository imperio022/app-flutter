import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models.dart';
import '../core/api_service.dart';

class AuthNotifier extends ChangeNotifier {
  AuthUser? _user;
  bool _isLoading = false;
  String? _error;

  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  final ApiService _api = ApiService();

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.login(username, password);
      // tRPC returns data directly in the result field
      _user = AuthUser.fromJson(data);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.getMe();
      if (data != null) {
        _user = AuthUser.fromJson(data);
      } else {
        _user = null;
      }
    } catch (e) {
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}

final authProvider = ChangeNotifierProvider((ref) {
  final auth = AuthNotifier();
  auth.checkAuth();
  return auth;
});

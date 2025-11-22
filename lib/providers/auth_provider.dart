import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api;
  bool _loading = false;
  String? _token;
  String? _error;

  static const _kTokenKey = 'auth_token';

  AuthProvider(this.api) {
    _loadToken();
  }

  bool get loading => _loading;
  String? get token => _token;
  String? get error => _error;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_kTokenKey);
    if (t != null && t.isNotEmpty) {
      _token = t;
      api.setToken(_token);
      notifyListeners();
    }
  }

  Future<bool> login({required String username, required String password, int comId = 1}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await api.login(username: username, password: password, comId: comId);
      if (res.containsKey('error') && res['error'] == true) {
        _error = (res['message'] ?? 'Login failed').toString();
        return false;
      }
      String? t;
      if (res['Token'] != null) t = res['Token'].toString();
      if (t == null && res['token'] != null) t = res['token'].toString();
      if (t == null && res['data'] != null && res['data']['Token'] != null) t = res['data']['Token'].toString();
      _token = t;
      api.setToken(_token);
      // persist token if present
      if (_token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kTokenKey, _token!);
      }
      return _token != null;
    } catch (e) {
      _error = 'Login error: ${e.toString()}';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    notifyListeners();
  }
}

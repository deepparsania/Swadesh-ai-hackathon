import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final MockApiService _apiService;
  User? _currentUser;
  List<User> _users = [];
  bool _isLoading = false;

  UserProvider(this._apiService);

  User? get currentUser => _currentUser;
  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await _apiService.getUsers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void login(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

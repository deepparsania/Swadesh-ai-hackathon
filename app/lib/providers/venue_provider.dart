import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../services/api_service.dart';

class VenueProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Venue> _venues = [];
  bool _isLoading = false;

  VenueProvider(this._apiService);

  List<Venue> get venues => _venues;
  bool get isLoading => _isLoading;

  Future<void> fetchVenues() async {
    _isLoading = true;
    notifyListeners();
    try {
      _venues = await _apiService.getVenues();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

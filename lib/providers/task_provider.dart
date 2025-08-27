import 'package:flutter/material.dart';
import 'package:taskmanage_frontend/models/task.dart';
import 'package:taskmanage_frontend/services/api_service.dart';

class TaskProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  String? _statusFilter;
  String? _priorityFilter;
  String _sortBy = 'title';
  String _sortOrder = 'asc';
  String? _searchTerm;
  int _currentPage = 1;
  bool _hasMorePages = true;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get statusFilter => _statusFilter;
  String? get priorityFilter => _priorityFilter;
  String get sortField => _sortBy;
  String get sortOrder => _sortOrder;
  String? get searchTerm => _searchTerm;
  int get currentPage => _currentPage;
  bool get hasMorePages => _hasMorePages;

  Future<void> fetchTasks({bool reload = false}) async {
    if (reload) {
      _tasks = [];
      _currentPage = 1;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedTasks = await _apiService.fetchTasks(
        page: _currentPage,
        status: _statusFilter,
        priority: _priorityFilter,
        search: _searchTerm,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
      if (fetchedTasks.length < 10) {
        _hasMorePages = false;
      } else {
        _hasMorePages = true;
      }
      _tasks = fetchedTasks;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(Task task) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _apiService.createTask(task);
      await fetchTasks(reload: true);
    } catch (e) {
      _error = 'Failed to create task: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _apiService.updateTask(task);
      await fetchTasks(reload: true);
    } catch (e) {
      _error = 'Failed to update task: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _apiService.deleteTask(id);
      await fetchTasks(reload: true);
    } catch (e) {
      _error = 'Failed to delete task: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    fetchTasks(reload: true);
  }

  void setPriorityFilter(String? priority) {
    _priorityFilter = priority;
    fetchTasks(reload: true);
  }

  void setSort(String sortBy, [String? sortOrder]) {
    _sortBy = sortBy;
    if (sortOrder != null) {
      _sortOrder = sortOrder;
    } else {
      _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
    }
    fetchTasks(reload: true);
  }

  void setSearchTerm(String? term) {
    _searchTerm = term;
    fetchTasks(reload: true);
  }

  void setPage(int page) {
    _currentPage = page;
    fetchTasks();
  }
}

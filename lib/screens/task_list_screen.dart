import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmanage_frontend/providers/task_provider.dart';
import 'package:taskmanage_frontend/screens/task_form_screen.dart';
import 'package:taskmanage_frontend/models/task.dart';
import 'dart:async';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks(reload: true);
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final provider = Provider.of<TaskProvider>(context, listen: false);
      if (provider.searchTerm != _searchController.text) {
        provider.setSearchTerm(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TaskFormScreen(),
                ),
              ).then((_) {
                taskProvider.fetchTasks(reload: true);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterAndSortControls(taskProvider),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.tasks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(
                    child: Text('Error: ${provider.error}'),
                  );
                }
                if (provider.tasks.isEmpty) {
                  return const Center(child: Text('No tasks found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: provider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = provider.tasks[index];
                    return TaskCard(task: task, onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TaskFormScreen(task: task),
                        ),
                      ).then((_) {
                        provider.fetchTasks(reload: true);
                      });
                    });
                  },
                );
              },
            ),
          ),
          _buildPaginationControls(taskProvider),
        ],
      ),
    );
  }

  Widget _buildFilterAndSortControls(TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  value: provider.statusFilter,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Status')),
                    DropdownMenuItem(value: 'todo', child: Text('To Do')),
                    DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'done', child: Text('Completed')),
                  ],
                  onChanged: (value) => provider.setStatusFilter(value),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  value: provider.priorityFilter,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Priority')),
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (value) => provider.setPriorityFilter(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Sort By',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  value: provider.sortField,
                  items: const [
                    DropdownMenuItem(value: 'title', child: Text('Title')),
                    DropdownMenuItem(value: 'dueDate', child: Text('Due Date')),
                    DropdownMenuItem(value: 'priority', child: Text('Priority')),
                  ],
                  onChanged: (value) => provider.setSort(value ?? 'title', provider.sortOrder),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                child: IconButton(
                  icon: Icon(provider.sortOrder == 'asc' ? Icons.arrow_downward : Icons.arrow_upward),
                  onPressed: () {
                   final currentSortOrder = provider.sortOrder == 'asc' ? 'desc' : 'asc';
                    provider.setSort(provider.sortField, currentSortOrder);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: provider.currentPage > 1 && !provider.isLoading
                ? () => provider.setPage(provider.currentPage - 1)
                : null,
            child: const Text('Previous'),
          ),
          const SizedBox(width: 16),
          Text('${provider.currentPage}'),
          const SizedBox(width: 16),
          TextButton(
            onPressed: provider.hasMorePages && !provider.isLoading
                ? () => provider.setPage(provider.currentPage + 1)
                : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({Key? key, required this.task, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (task.status) {
      case 'todo':
        statusColor = Colors.grey;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        break;
      case 'done':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    String statusText;
    switch (task.status) {
      case 'todo':
        statusText = 'To Do';
        break;
      case 'in_progress':
        statusText = 'In Progress';
        break;
      case 'done':
        statusText = 'Completed';
        break;
      default:
        statusText = 'Unknown';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (task.dueDate != null)
                      Text(
                        'Due: ${task.dueDate!.month}/${task.dueDate!.day}/${task.dueDate!.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.redAccent,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

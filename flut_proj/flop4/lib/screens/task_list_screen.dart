import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/dialogs.dart';
import 'dart:convert'; 
import 'package:shared_preferences/shared_preferences.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Task> _tasks = [];
  @override
  void initState() {
    super.initState();
    _loadTasks();
    _tasks = [
      Task(
        id: '1', 
        title: 'test1', 
        description: 'desc1', 
        category: 'Personal', 
        date: DateTime.now(),
        priority: 'High',
      ),
      Task(
        id: '2', 
        title: 'test2', 
        description: 'desc2', 
        category: 'Work', 
        date: DateTime.now(),
        priority: 'Medium'
      ),
    ];
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _tasks.map((task) => task.toJson()).toList(),
    );
    await prefs.setString('user_tasks', encodedData);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('user_tasks');

    if (savedData != null) {
      final List<dynamic> decodedData = jsonDecode(savedData);
      setState(() {
        _tasks = decodedData.map((item) => Task.fromJson(item)).toList();
      });
    }
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
    _saveTasks();
  }

  void _toggleTaskStatus(String id) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index].isCompleted = !_tasks[index].isCompleted;
      }
    });
    _saveTasks();
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
    _saveTasks();
  }
  void _updateTask(Task updatedTask) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    });
    _saveTasks();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
            },
          ),
        ],
      ),
      body: _tasks.isEmpty 
      ? const Center(child: Text("There's nothing to do"))
      : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            color: Theme.of(context).colorScheme.surface.withAlpha(50),
            child: ListTile(
              onTap: () async {
                final result = await Navigator.pushNamed(context, '/details', arguments: task);
                if (result == "delete") {
                  _deleteTask(task.id);
                } else if (result != null && result is Task) {
                  _updateTask(result);
                }
              },
              leading: Checkbox(value: task.isCompleted, onChanged: (value) {_toggleTaskStatus(task.id);}),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
              subtitle: Text(task.category),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final bool ? confirmed = await showDeleteConfirmationDialog(context, task.title);
                  if (confirmed == true) {
                    _deleteTask(task.id);
                  }
                }
              ),
            )
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) async {
          if (index == 1) {
            final dynamic result = await Navigator.pushNamed(context, '/add');
            if (result != null && result is Task) {
              _addTask(result);
            }
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/dialogs.dart';
import 'dart:convert'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import '../services/weather_service.dart';  
import '../services/calendar_service.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
final WeatherService _weatherService = WeatherService();
final GoogleCalendarService _calendarService = GoogleCalendarService();
late Future<Map<String, dynamic>> _weatherFuture;
  List<Task> _tasks = [];
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  String? _userImageUrl;
  @override
  void initState() {
    super.initState();
    _loadTasks();
    _weatherFuture = _weatherService.getCurrentWeather(50.45, 30.52);
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

  void _addTask(Task task) async {
    setState(() {
      _tasks.add(task);
    });
    _saveTasks();
  

    if (_isLoggedIn) {
      final token = await _calendarService.getExistingToken();
      if (token != null) {
        final googleId = await _calendarService.insertEvent(task, token);
        if (googleId != null) {
          setState(() {
            task.googleEventId = googleId;
          });
          _saveTasks(); 
        }
      }
    }
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

  void _deleteTask(String id) async{
    final taskToDelete = _tasks.firstWhere((t) => t.id == id);
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
    _saveTasks();

    if (_isLoggedIn && taskToDelete.googleEventId != null) {
      final token = await _calendarService.getExistingToken();
      if (token != null) {
        await _calendarService.deleteEvent(taskToDelete.googleEventId!, token);
      }
    }
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
      body: Column(children: [
        FutureBuilder<Map<String, dynamic>>(
          future: _weatherFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            } else if (snapshot.hasError) {
              return const SizedBox.shrink();
            }

            final temp = snapshot.data!['temp'];
            final icon = _weatherService.getWeatherIcon(snapshot.data!['code']);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withAlpha(100),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Kyiv, Ukraine", style: TextStyle(fontWeight: FontWeight.w500)),
                  Text("$icon $temp°C", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        ),
          Expanded(
            child: _tasks.isEmpty 
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
                )
            ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) async {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            final dynamic result = await Navigator.pushNamed(context, '/add');
            if (result != null && result is Task) {
              _addTask(result);
            }
          } 
          else if (index == 2) {
            final token = await _calendarService.getAccessToken();
            if (token != null) {
              setState(() {
                _isLoggedIn = true;
                _userImageUrl = _calendarService.getCurrentUserPhoto();
              });
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
            icon: _userImageUrl != null 
                ? CircleAvatar(
                    radius: 12, 
                    backgroundColor: Colors.transparent,
                
                    child: ClipOval(
                      child: Image.network(
                        _userImageUrl!,
                        fit: BoxFit.cover,
                        width: 24,
                        height: 24,
                    
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(_isLoggedIn ? Icons.person : Icons.person_outline);
                        },
                      ),
                    ),
                  )
                : Icon(_isLoggedIn ? Icons.person : Icons.person_outline),
              label: 'Profile',
            ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

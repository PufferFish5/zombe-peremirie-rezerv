import 'package:flop3/screens/add_task_screen.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/dialogs.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  Widget build(BuildContext context) {
    final task = ModalRoute.of(context)!.settings.arguments as Task;

    Map<String, dynamic> _getCategoryStyle(String category) {
      switch (category) {
        case 'Work':
          return {'icon': Icons.work, 'color':  Color(0xFFF3701E)};
        case 'Personal':
          return {'icon': Icons.person, 'color':  Color(0xFFF3701E)};
        case 'Study':
          return {'icon': Icons.school, 'color':  Color(0xFFF3701E)};
        default:
          return {'icon': Icons.more_horiz, 'color':  Color(0xFFF3701E)};
      }
    }

    Color _getPriorityColor(String priority) {
      switch (priority) {
        case 'High':
          return Colors.red;
        case 'Medium':
          return Colors.yellow;
        case 'Low':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }
    final categoryStyle = _getCategoryStyle(task.category);
    final priorityColor = _getPriorityColor(task.priority);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, task),
        ),
        title: const Text('Task Details'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            //ikonka
            CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFFFFF1E6),
              child: Icon(categoryStyle['icon'], size: 60, color: categoryStyle['color']),
            ),
            const SizedBox(height: 20),

            //Task name
            Text(
              task.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Tags
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTag(categoryStyle['icon'], task.category, categoryStyle['color']),
                const SizedBox(width: 10),
                _buildTag(Icons.priority_high, task.priority, priorityColor),
              ],
            ),
            const SizedBox(height: 30),

            // Details
            _buildInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 10),
                      const Text('Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    task.description.isNotEmpty ? task.description : 'No description provided.',
                    style: TextStyle(color: Colors.white, height: 1.5),
                  ),
                ],
              ),
            ),

            // Dates
            _buildInfoCard(
              child: Column(
                children: [
                  _buildDateItem(Icons.edit_note, 'Created', '10.03.2026  14:30', Colors.green),
                  const Divider(height: 30),
                  _buildDateItem(Icons.calendar_today, 'Deadline', '${task.date.day}.${task.date.month}.${task.date.year} ${task.date.hour}:${task.date.minute}', Colors.red),
                ],
              ),
            ),

            //Switch 
            _buildInfoCard(
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Status', style: TextStyle(fontSize: 16))),
                  Switch(value: task.isCompleted, onChanged: (value) {
                    setState(() {
                      task.isCompleted = value;
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      //Actions
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final updatedTask = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddScreen(taskToEdit: task)));
                  if (updatedTask != null && updatedTask is Task) {
                    Navigator.pop(context, updatedTask);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface.withValues(red: 200, blue:200, green:200),
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  minimumSize: const Size(0, 50),
                  //side: const BorderSide(color: Color(0xFFF3701E)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final bool? confirmed = await showDeleteConfirmationDialog(context, task.title);
                  if (confirmed == true) {
                    Navigator.pop(context, "delete");
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface.withValues(red: 200, blue:200, green:200),
                  foregroundColor: Colors.red,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        //color: Color(0xFFF6DA9D),
        color: Color(0xFF1E1F1E),
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(color: Color(0xFFF3701E)),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(color: Colors.orange.withAlpha(15), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDateItem(IconData icon, String title, String date, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}
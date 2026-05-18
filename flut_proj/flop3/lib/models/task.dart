class Task {
  final String id;
  final String title;
  final String description;
  bool isCompleted;
  final String category;
  final DateTime date;
  final String priority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.category,
    required this.date,
    required this.priority
  });
}
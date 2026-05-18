class Task {
  final String id;
  final String title;
  final String description;
  bool isCompleted;
  final String category;
  final DateTime date;
  final String priority;
  String? googleEventId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.category,
    required this.date,
    required this.priority,
    this.googleEventId,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'category': category,
    'date': date.toIso8601String(),
    'priority': priority,
    'googleEventId': googleEventId,

  };
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    isCompleted: json['isCompleted'],
    category: json['category'],
    date: DateTime.parse(json['date']),
    priority: json['priority'],
    googleEventId: json['googleEventId'],
  );
}
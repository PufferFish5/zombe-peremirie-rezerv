class Post {
  final int id;
  final String title;
  final String body;
  final String type;
  final String imageUrl;
  final DateTime? eventDate;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.imageUrl,
    this.eventDate,
    required this.createdAt,
  });

  bool get isEvent => type == 'event';

  factory Post.fromMap(Map<String, dynamic> map) => Post(
    id:        map['id']    as int,
    title:     map['title'] as String,
    body:      map['body']  as String,
    type:      map['type']  as String,
    imageUrl:  map['image_url'] as String? ?? '',
    eventDate: map['event_date'] != null
        ? DateTime.tryParse(map['event_date'] as String)
        : null,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
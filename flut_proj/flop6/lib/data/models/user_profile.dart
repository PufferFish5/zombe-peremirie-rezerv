class UserProfile {
  final int? id;
  final String name;
  final String email;
  final int phone;
  final String googleId;
  final bool isGoogleConnected;

  const UserProfile({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.googleId,
    required this.isGoogleConnected,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    id:                map['id']                  as int?,
    name:              map['name']                as String,
    email:             map['email']               as String? ?? '',
    phone:             map['phone']               as int? ?? 0,
    googleId:          map['google_id']           as String? ?? '',
    isGoogleConnected: (map['is_google_connected'] as int? ?? 0) == 1,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name':                name,
    'email':               email,
    'phone':               phone,
    'google_id':           googleId,
    'is_google_connected': isGoogleConnected ? 1 : 0,
  };

  UserProfile copyWith({
    String? name,
    String? email,
    int? phone,
    String? googleId,
    bool? isGoogleConnected,
  }) => UserProfile(
    id:                id,
    name:              name ?? this.name,
    email:             email ?? this.email,
    phone:             phone ?? this.phone,
    googleId:          googleId ?? this.googleId,
    isGoogleConnected: isGoogleConnected ?? this.isGoogleConnected,
  );
}
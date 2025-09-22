class AppUser {
  final String id;
  final String name;
  final String status;

  AppUser({required this.id, required this.name, required this.status});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'status': status};
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      status: map['status'] ?? '',
    );
  }
}

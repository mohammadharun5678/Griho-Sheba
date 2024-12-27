class Worker {
  final String name;
  final String phone;
  final String picture;

  Worker({required this.name, required this.phone, required this.picture});

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      name: json['name'] as String,
      phone: json['phone'] as String,
      picture: json['picture'] as String,
    );
  }
}

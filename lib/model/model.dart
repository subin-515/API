class curd {
  final String id; // Add this field for unique identification
  final String name;
  final String address;
  final String email;

  curd({required this.id, required this.name, required this.address, required this.email});

  // Factory method to create a curd instance from JSON
  factory curd.fromJson(Map<String, dynamic> json) {
    return curd(
      id: json['_id'], // Ensure this matches the backend field for ID
      name: json['name'],
      address: json['address'],
      email: json['email'],
    );
  }

  // Convert curd instance to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'email': email,
    };
  }
}

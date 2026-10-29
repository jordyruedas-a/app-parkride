class UserProfile {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? company;
  final String? department;
  final String? employeeNumber;
  final String? phone;
  final String? shift;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.company,
    this.department,
    this.employeeNumber,
    this.phone,
    this.shift,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'passenger',
      company: json['company']?.toString(),
      department: json['department']?.toString(),
      employeeNumber: json['employee_number']?.toString(),
      phone: json['phone']?.toString(),
      shift: json['shift']?.toString(),
    );
  }
}

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? company;
  final String? department;
  final String? employeeNumber;
  final String? phone;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.company,
    this.department,
    this.employeeNumber,
    this.phone,
  });

  factory UserProfile.fromJson(Map<String, dynamic> data) => UserProfile(
        id: data['id']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        role: data['role']?.toString() ?? 'passenger',
        company: data['company']?.toString(),
        department: data['department']?.toString(),
        employeeNumber: data['employee_number']?.toString(),
        phone: data['phone']?.toString(),
      );
}

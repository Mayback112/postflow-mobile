class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Workspace',
      ownerId: json['ownerId'] as String?,
      createdAt: _dateTimeFromJson(json['createdAt']),
      updatedAt: _dateTimeFromJson(json['updatedAt']),
    );
  }

  static DateTime? _dateTimeFromJson(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

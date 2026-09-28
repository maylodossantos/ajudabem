class NeedTag {
  const NeedTag({required this.id, required this.name});

  factory NeedTag.fromJson(Map<String, dynamic> json) => NeedTag(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
  );

  final int id;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is NeedTag && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

class TrainingModel {
  final int id;
  final String title;
  final String? description;
  final int? participantCount;
  final String? standard;
  final String? duration;
  final String? createdAt;
  final String? updatedAt;

  TrainingModel({
    required this.id,
    required this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      participantCount: json['participant_count'] != null
          ? int.tryParse(json['participant_count'].toString())
          : null,
      standard: json['standard'],
      duration: json['duration'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'participant_count': participantCount,
      'standard': standard,
      'duration': duration,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

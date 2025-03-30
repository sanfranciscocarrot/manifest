import 'package:cloud_firestore/cloud_firestore.dart';

class MeditationUserData {
  final String name;
  final String age;
  final String gender;
  final String purpose;
  final Map<String, dynamic> deviceInfo;
  final DateTime? createdAt;
  final String? id;

  MeditationUserData({
    required this.name,
    required this.age,
    required this.gender,
    required this.purpose,
    required this.deviceInfo,
    this.createdAt,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'purpose': purpose,
      'deviceInfo': deviceInfo,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory MeditationUserData.fromMap(Map<String, dynamic> map, String docId) {
    return MeditationUserData(
      name: map['name'] ?? 'Anonymous',
      age: map['age'] ?? 'Not specified',
      gender: map['gender'] ?? 'Not specified',
      purpose: map['purpose'] ?? 'Not specified',
      deviceInfo: map['deviceInfo'] ?? {},
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      id: docId,
    );
  }

  MeditationUserData copyWith({
    String? name,
    String? age,
    String? gender,
    String? purpose,
    Map<String, dynamic>? deviceInfo,
    DateTime? createdAt,
    String? id,
  }) {
    return MeditationUserData(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      purpose: purpose ?? this.purpose,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
    );
  }
} 
import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String userId;
  final String serviceId;
  final DateTime date;
  final String timeSlot;
  final String status;
  final String? notes;
  final DateTime createdAt;

  String? userName;
  String? serviceName;
  double? servicePrice;
  int? serviceDuration;

  Appointment({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.notes,
    required this.createdAt,
    this.userName,
    this.serviceName,
    this.servicePrice,
    this.serviceDuration,
  });

  factory Appointment.fromMap(String id, Map<String, dynamic> data) {
    return Appointment(
      id: id,
      userId: data['userId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      status: data['status'] ?? 'pending',
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'serviceId': serviceId,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

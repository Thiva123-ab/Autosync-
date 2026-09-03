class JobModel {
  final String id;
  final String vehicleInfo;
  final String title;
  final String? description;
  final List<String> inspectionPhotos;
  final String status;
  final DateTime scheduledTime;
  final String? assignedMechanicId;
  final String? customerId;
  final double? quoteAmount;
  final bool customerApproved;
  final String? mechanicNotes;
  final List<String> requestedParts;

  JobModel({
    required this.id,
    required this.vehicleInfo,
    required this.title,
    this.description,
    this.inspectionPhotos = const [],
    required this.status,
    required this.scheduledTime,
    this.assignedMechanicId,
    this.customerId,
    this.quoteAmount,
    this.customerApproved = false,
    this.mechanicNotes,
    this.requestedParts = const [],
  });

  factory JobModel.fromMap(String id, Map<String, dynamic> data) {
    return JobModel(
      id: id,
      vehicleInfo: data['vehicleInfo'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      inspectionPhotos: List<String>.from(data['inspectionPhotos'] ?? []),
      status: data['status'] ?? 'pending',
      scheduledTime: data['scheduledTime'] != null
          ? (data['scheduledTime'] as dynamic).toDate()
          : DateTime.now(),
      assignedMechanicId: data['assignedMechanicId'],
      customerId: data['customerId'],
      quoteAmount: data['quoteAmount'] != null ? (data['quoteAmount'] as num).toDouble() : null,
      customerApproved: data['customerApproved'] ?? false,
      mechanicNotes: data['mechanicNotes'],
      requestedParts: List<String>.from(data['requestedParts'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleInfo': vehicleInfo,
      'title': title,
      'description': description,
      'inspectionPhotos': inspectionPhotos,
      'status': status,
      'scheduledTime': scheduledTime,
      'assignedMechanicId': assignedMechanicId,
      'customerId': customerId,
      'quoteAmount': quoteAmount,
      'customerApproved': customerApproved,
      'mechanicNotes': mechanicNotes,
      'requestedParts': requestedParts,
    };
  }
}

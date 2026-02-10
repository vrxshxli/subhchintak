class QRModel {
  final String id;
  final String ownerId;
  final String purpose;
  final String template;
  final String qrDataUrl;
  final String orderType; // 'pdf' or 'sticker'
  final bool isActive;
  final String? customPurpose;
  final String qrColor;
  final String bgColor;
  final DateTime createdAt;

  QRModel({
    required this.id,
    required this.ownerId,
    required this.purpose,
    required this.template,
    required this.qrDataUrl,
    required this.orderType,
    this.isActive = false,
    this.customPurpose,
    this.qrColor = '#000000',
    this.bgColor = '#FFFFFF',
    required this.createdAt,
  });

  factory QRModel.fromJson(Map<String, dynamic> json) {
    return QRModel(
      id: json['_id'] ?? json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      purpose: json['purpose'] ?? '',
      template: json['template'] ?? '',
      qrDataUrl: json['qrDataUrl'] ?? '',
      orderType: json['orderType'] ?? 'pdf',
      isActive: json['isActive'] ?? false,
      customPurpose: json['customPurpose'],
      qrColor: json['qrColor'] ?? '#000000',
      bgColor: json['bgColor'] ?? '#FFFFFF',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  QRModel copyWith({bool? isActive}) {
    return QRModel(
      id: id,
      ownerId: ownerId,
      purpose: purpose,
      template: template,
      qrDataUrl: qrDataUrl,
      orderType: orderType,
      isActive: isActive ?? this.isActive,
      customPurpose: customPurpose,
      qrColor: qrColor,
      bgColor: bgColor,
      createdAt: createdAt,
    );
  }
}
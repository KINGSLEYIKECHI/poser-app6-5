class SubscriptionReportModel {
  final int? id;
  final String? name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? paymentBy;
  final bool isPaid;

  SubscriptionReportModel({
    this.id,
    this.name,
    this.startDate,
    this.endDate,
    this.paymentBy,
    this.isPaid = false,
  });

  factory SubscriptionReportModel.fromJson(Map<String, dynamic> json) {
    final _startDate = json["created_at"] == null ? null : DateTime.parse(json['created_at']);
    final int _duration = json['duration'] ?? 0;

    return SubscriptionReportModel(
      id: json['id'],
      name: json['plan']?['subscriptionName'],
      startDate: _startDate,
      endDate: _startDate?.add(Duration(days: _duration)),
      paymentBy: json['gateway']?['name'],
      isPaid: json['payment_status'] == "paid",
    );
  }
}

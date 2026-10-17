class ScheduleEntry {
  final String id;
  final String date;
  final double amount;

  ScheduleEntry({
    required this.id,
    required this.date,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'amount': amount,
  };

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) => ScheduleEntry(
    id: json['id'],
    date: json['date'],
    amount: (json['amount'] as num).toDouble(),
  );
}
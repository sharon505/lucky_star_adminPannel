import 'dart:convert';

class AgentReceivablesResponse {
  final List<AgentReceivableItem> result;

  const AgentReceivablesResponse({required this.result});

  factory AgentReceivablesResponse.fromMap(Map<String, dynamic> map) {
    final list = (map['Result'] as List<dynamic>? ?? const [])
        .map((e) => AgentReceivableItem.fromMap(e as Map<String, dynamic>))
        .toList();
    return AgentReceivablesResponse(result: list);
  }

  Map<String, dynamic> toMap() => {
    'Result': result.map((e) => e.toMap()).toList(),
  };

  factory AgentReceivablesResponse.fromJson(String source) =>
      AgentReceivablesResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  AgentReceivablesResponse copyWith({
    List<AgentReceivableItem>? result,
  }) {
    return AgentReceivablesResponse(
      result: result ?? this.result,
    );
  }
}

class AgentReceivableItem {
  final double amount;

  const AgentReceivableItem({required this.amount});

  factory AgentReceivableItem.fromMap(Map<String, dynamic> map) {
    final raw = map['AMOUNT'];
    double amt;
    if (raw is int) {
      amt = raw.toDouble();
    } else if (raw is double) {
      amt = raw;
    } else if (raw is String) {
      amt = double.tryParse(raw) ?? 0.0;
    } else {
      amt = 0.0;
    }
    return AgentReceivableItem(amount: amt);
  }

  Map<String, dynamic> toMap() => {
    'AMOUNT': amount,
  };

  factory AgentReceivableItem.fromJson(String source) =>
      AgentReceivableItem.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  AgentReceivableItem copyWith({
    double? amount,
  }) {
    return AgentReceivableItem(
      amount: amount ?? this.amount,
    );
  }
}

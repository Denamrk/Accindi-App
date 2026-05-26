import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import 'bix_api.dart';
import 'session.dart';

/// Holds the user's wallet balance and transaction list.
///
/// Call [fetch] after login to load data from the BIX API.
/// Screens listen via [addListener] / [ChangeNotifier].
class WalletState extends ChangeNotifier {
  static final WalletState _instance = WalletState._();
  factory WalletState() => _instance;
  WalletState._();

  double _balance = 0;
  List<Transaction> _transactions = [];
  bool _loading = false;
  String? _error;

  double get balance => _balance;
  List<Transaction> get transactions => _transactions;
  bool get loading => _loading;
  String? get error => _error;

  /// Format balance for display (e.g. "4,998").
  String get balanceDisplay {
    final whole = _balance.truncate();
    final str = whole.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  /// Fetch balance and transactions from the BIX API.
  ///
  /// API response format:
  ///   data[0] = balance (e.g. "4998.00")
  ///   data[1] = summary rows separated by ";"
  ///             each row: "date,txType,amount,runningBalance"
  ///   data[2] = (unused)
  ///   data[3] = detailed JSON objects separated by ";"
  ///             each: {seqNo, dateTime, senderEmail, receiverEmail, payload}
  ///             payload (JSON string): {txType, txID, sendAmount, txCost,
  ///                                     recAmount, bixCoinsTokensBalance, ...}
  Future<void> fetch() async {
    final session = Session();
    if (!session.isLoggedIn) return;

    _loading = true;
    _error = null;
    notifyListeners();

    final response = await BixApi.listTransactions(
      authorizationKey: session.authorizationKey!,
      email: session.email ?? '',
    );

    if (response.isSuccess) {
      // data[0] = balance
      if (response.data.isNotEmpty) {
        _balance = double.tryParse(response.data[0]) ?? 0;
      }

      // Parse transactions from data[3] (detailed JSON entries)
      _transactions = [];
      if (response.data.length > 3 && response.data[3].isNotEmpty) {
        _parseDetailedTransactions(response.data[3]);
      } else if (response.data.length > 1 && response.data[1].isNotEmpty) {
        // Fallback: parse from data[1] summary rows
        _parseSummaryTransactions(response.data[1]);
      }

      _error = null;
    } else {
      _error = response.displayMessage.isNotEmpty
          ? response.displayMessage
          : 'Failed to load transactions';
    }

    _loading = false;
    notifyListeners();
  }

  /// Parse detailed transaction entries from data[3].
  ///
  /// Format: JSON objects separated by ";"
  /// Each: {"seqNo":146,"dateTime":"2026-03-17-13:30:17",
  ///         "senderEmail":"...","receiverEmail":"...",
  ///         "payload":"{\"txType\":\"buyUsingBankCard\",...}"}
  void _parseDetailedTransactions(String raw) {
    final entries = raw.split('};');
    for (int i = 0; i < entries.length; i++) {
      var entry = entries[i].trim();
      if (entry.isEmpty) continue;
      // Re-add closing brace if it was split off (except for last entry)
      if (!entry.endsWith('}')) entry += '}';

      try {
        final json = jsonDecode(entry) as Map<String, dynamic>;
        final dateTime = json['dateTime']?.toString() ?? '';
        final senderEmail = json['senderEmail']?.toString() ?? '';
        final receiverEmail = json['receiverEmail']?.toString() ?? '';
        final seqNo = json['seqNo']?.toString() ?? '';

        // Parse nested payload JSON
        final payloadStr = json['payload']?.toString() ?? '{}';
        final payload = jsonDecode(payloadStr) as Map<String, dynamic>;

        final txType = payload['txType']?.toString() ?? '';
        final txId = payload['txID']?.toString() ?? '';
        final sendAmount = double.tryParse(payload['sendAmount']?.toString() ?? '') ?? 0;
        final txCost = double.tryParse(payload['txCost']?.toString() ?? '') ?? 0;
        final recAmount = double.tryParse(payload['recAmount']?.toString() ?? '') ?? 0;
        final balanceAfter = payload['bixCoinsTokensBalance']?.toString() ?? '';

        // Determine if incoming (received) or outgoing (sent)
        final isIncoming = recAmount > 0;
        final displayAmount = isIncoming ? recAmount : sendAmount;
        final amountWhole = displayAmount.truncate();

        // Format date for display: "2026-03-17-13:30:17" → "17 Mar 2026"
        final dateShort = _formatDateShort(dateTime);
        final dateLong = _formatDateLong(dateTime);

        // Human-readable description from txType
        final desc = _txTypeLabel(txType);

        _transactions.add(Transaction(
          id: 'tx-$seqNo',
          desc: desc,
          date: dateShort,
          dateLong: dateLong,
          amount: isIncoming ? '+$amountWhole pts' : '−$amountWhole pts',
          incoming: isIncoming,
          type: _txTypeCategory(txType),
          study: '—',
          from: isIncoming ? senderEmail : receiverEmail,
          txid: txId,
          status: 'Completed',
        ));
      } catch (_) {
        // Skip malformed entries
      }
    }
  }

  /// Fallback: parse summary rows from data[1].
  ///
  /// Format: rows separated by ";",
  ///   each: "date,txType,amount,runningBalance"
  void _parseSummaryTransactions(String raw) {
    final rows = raw.split(';');
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i].trim();
      if (row.isEmpty) continue;

      final parts = row.split(',');
      if (parts.length < 3) continue;

      final dateTime = parts[0].trim();
      final txType = parts[1].trim();
      final amount = double.tryParse(parts[2].trim()) ?? 0;
      final amountWhole = amount.truncate();
      final isIncoming = amount > 0;

      final dateShort = _formatDateShort(dateTime);
      final dateLong = _formatDateLong(dateTime);

      _transactions.add(Transaction(
        id: 'tx-$i',
        desc: _txTypeLabel(txType),
        date: dateShort,
        dateLong: dateLong,
        amount: isIncoming ? '+$amountWhole pts' : '−$amountWhole pts',
        incoming: isIncoming,
        type: _txTypeCategory(txType),
        study: '—',
        from: '—',
        txid: '—',
        status: 'Completed',
      ));
    }
  }

  /// "2026-03-17-13:30:17" → "17 Mar 2026"
  String _formatDateShort(String dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    try {
      final datePart = dt.split('-');
      if (datePart.length < 3) return dt;
      final year = datePart[0];
      final month = int.tryParse(datePart[1]) ?? 1;
      final day = int.tryParse(datePart[2]) ?? 1;
      return '$day ${months[month]} $year';
    } catch (_) {
      return dt;
    }
  }

  /// "2026-03-17-13:30:17" → "17 Mar 2026, 13:30"
  String _formatDateLong(String dt) {
    final short = _formatDateShort(dt);
    try {
      final parts = dt.split('-');
      if (parts.length >= 4) {
        final timePart = parts[3];
        final hhmm = timePart.length >= 5 ? timePart.substring(0, 5) : timePart;
        return '$short, $hhmm';
      }
    } catch (_) {}
    return short;
  }

  /// Map API txType to a human-readable label.
  String _txTypeLabel(String txType) {
    switch (txType) {
      case 'buyUsingBankCard':
        return 'Purchased with Bank Card';
      case 'sendToUser':
        return 'Sent to User';
      case 'receiveFromUser':
        return 'Received from User';
      case 'redeem':
        return 'Redeemed';
      case 'reward':
        return 'Reward';
      default:
        // CamelCase → spaced: "buyUsingBankCard" → "Buy Using Bank Card"
        return txType
            .replaceAllMapped(
              RegExp(r'([a-z])([A-Z])'),
              (m) => '${m[1]} ${m[2]}',
            )
            .replaceRange(0, 1, txType[0].toUpperCase());
    }
  }

  /// Map API txType to a display category.
  String _txTypeCategory(String txType) {
    switch (txType) {
      case 'buyUsingBankCard':
        return 'Purchase';
      case 'sendToUser':
        return 'Sent';
      case 'receiveFromUser':
        return 'Received';
      case 'redeem':
        return 'Redemption';
      case 'reward':
        return 'Reward';
      default:
        return txType;
    }
  }

  /// Reset state on logout.
  void clear() {
    _balance = 0;
    _transactions = [];
    _loading = false;
    _error = null;
    notifyListeners();
  }
}

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
    // Add thousand separators
    final str = whole.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  /// Fetch balance and transactions from the BIX API.
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
      // data[0] = balance string (e.g. "4998.00")
      if (response.data.isNotEmpty) {
        _balance = double.tryParse(response.data[0]) ?? 0;
      }

      // Parse transactions from data array.
      // Each transaction is a comma-separated string in data[4+].
      // Format: "date,description,amount,type,txId,from,study,status"
      _transactions = [];
      for (int i = 4; i < response.data.length; i++) {
        final raw = response.data[i];
        if (raw.isEmpty || raw == '-') continue;

        final tx = _parseTransaction(raw, i);
        if (tx != null) _transactions.add(tx);
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

  /// Parse a single transaction entry from the API data.
  Transaction? _parseTransaction(String raw, int index) {
    // Try comma-separated format
    final parts = raw.split(',');
    if (parts.length < 3) return null;

    final amountVal = double.tryParse(parts[2].trim()) ?? 0;
    final incoming = amountVal >= 0;
    final absAmount = amountVal.abs().truncate();

    return Transaction(
      id: 'tx-$index',
      desc: parts[1].trim(),
      date: parts[0].trim(),
      dateLong: parts[0].trim(),
      amount: incoming ? '+$absAmount pts' : '−$absAmount pts',
      incoming: incoming,
      type: incoming ? 'Received' : 'Sent',
      study: parts.length > 6 ? parts[6].trim() : '—',
      from: parts.length > 5 ? parts[5].trim() : '—',
      txid: parts.length > 4 ? parts[4].trim() : '—',
      status: parts.length > 7 ? parts[7].trim() : 'Completed',
    );
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

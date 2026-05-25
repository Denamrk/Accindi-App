import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/session.dart';
import '../services/wallet_state.dart';
import '../widgets/app_tab_bar.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'send_points_screen.dart';
import 'request_points_screen.dart';
import 'transaction_detail_screen.dart';

/// Shell that owns the bottom tab bar and switches between core app screens.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  String _activeTab = 'home';
  final _wallet = WalletState();

  @override
  void initState() {
    super.initState();
    _wallet.addListener(_onWalletChanged);
  }

  @override
  void dispose() {
    _wallet.removeListener(_onWalletChanged);
    super.dispose();
  }

  void _onWalletChanged() {
    if (mounted) setState(() {});
  }

  void _onTabChanged(String tab) {
    setState(() => _activeTab = tab);
  }

  void _pushScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _openTxDetail(Transaction tx) {
    _pushScreen(TransactionDetailScreen(
      tx: tx,
      onBack: () => Navigator.of(context).pop(),
    ));
  }

  void _openSend() {
    _pushScreen(SendPointsScreen(
      onBack: () => Navigator.of(context).pop(),
    ));
  }

  void _openRequest() {
    _pushScreen(RequestPointsScreen(
      onBack: () => Navigator.of(context).pop(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          AppTabBar(
            active: _activeTab,
            onChanged: _onTabChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_activeTab) {
      case 'home':
        // Extract first name from session for greeting
        final userName = Session().email?.split('@').first ?? 'there';
        return DashboardScreen(
          userName: userName,
          balance: _wallet.balanceDisplay,
          transactions: _wallet.transactions,
          onWallet: () => _onTabChanged('wallet'),
          onViewAll: () => _onTabChanged('wallet'),
          onTxClick: _openTxDetail,
          onScan: () {
            // TODO: QR scanner
          },
          onNotifications: () {
            // TODO: notifications screen
          },
        );
      case 'wallet':
        return WalletScreen(
          balance: _wallet.balanceDisplay,
          transactions: _wallet.transactions,
          onSend: _openSend,
          onRequest: _openRequest,
          onTxClick: _openTxDetail,
        );
      case 'ids':
        return _PlaceholderTab(label: 'IDs');
      case 'settings':
        return _PlaceholderTab(label: 'Settings');
      default:
        return DashboardScreen();
    }
  }
}

/// Placeholder for tabs not yet implemented
class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label\n(Coming soon)',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF6B7A90),
        ),
      ),
    );
  }
}

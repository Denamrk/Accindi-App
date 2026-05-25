import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/transaction.dart';
import '../widgets/tx_row.dart';
import '../widgets/top_bar.dart';

enum SortMode { newest, oldest, high, low }

class WalletScreen extends StatefulWidget {
  final String balance;
  final List<Transaction> transactions;
  final VoidCallback? onSend;
  final VoidCallback? onRequest;
  final ValueChanged<Transaction>? onTxClick;

  const WalletScreen({
    super.key,
    this.balance = '0',
    this.transactions = const [],
    this.onSend,
    this.onRequest,
    this.onTxClick,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _query = '';
  String _filter = 'all'; // all | received | sent
  SortMode _sort = SortMode.newest;

  final _sortLabels = {
    SortMode.newest: 'Newest',
    SortMode.oldest: 'Oldest',
    SortMode.high: 'Highest',
    SortMode.low: 'Lowest',
  };

  List<Transaction> get _filteredList {
    var list = widget.transactions.where((t) {
      if (_query.isNotEmpty &&
          !t.desc.toLowerCase().contains(_query.toLowerCase())) {
        return false;
      }
      if (_filter == 'received' && !t.incoming) return false;
      if (_filter == 'sent' && t.incoming) return false;
      return true;
    }).toList();

    list.sort((a, b) {
      switch (_sort) {
        case SortMode.newest:
          return _parseDate(b.date).compareTo(_parseDate(a.date));
        case SortMode.oldest:
          return _parseDate(a.date).compareTo(_parseDate(b.date));
        case SortMode.high:
          return _parseAmount(b.amount).abs().compareTo(_parseAmount(a.amount).abs());
        case SortMode.low:
          return _parseAmount(a.amount).abs().compareTo(_parseAmount(b.amount).abs());
      }
    });

    return list;
  }

  int _parseAmount(String s) {
    final digits = s.replaceAll(RegExp(r'[^\d]'), '');
    final value = int.tryParse(digits) ?? 0;
    return (s.startsWith('−') || s.startsWith('-')) ? -value : value;
  }

  DateTime _parseDate(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      // Parse "3 May 2026" format
      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };
      final parts = s.split(' ');
      if (parts.length >= 3) {
        final day = int.tryParse(parts[0]) ?? 1;
        final month = months[parts[1]] ?? 1;
        final year = int.tryParse(parts[2]) ?? 2026;
        return DateTime(year, month, day);
      }
      return DateTime(2026);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredList;

    return Column(
      children: [
        const TopBar(title: 'Wallet'),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              _buildBalanceCard(),
              const SizedBox(height: 16),
              _buildActionPills(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildSectionHeader(),
              const SizedBox(height: 10),
              _buildFilterChips(),
              const SizedBox(height: 4),
              _buildTransactionList(list),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -0.8),
          end: Alignment(0.8, 0.8),
          colors: [Color(0xFF1A365D), Color(0xFF0E2244)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E1A365D),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gold accent top line
          Positioned(
            top: -22,
            left: -22,
            right: -22,
            child: Container(height: 4, color: AppColors.gold),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR BALANCE',
                style: AppTypography.xsBold.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 1.92,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.balance,
                    style: AppTypography.h2.copyWith(
                      fontSize: 44,
                      color: Colors.white,
                      letterSpacing: -1.2,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'pts',
                    style: AppTypography.lBold.copyWith(
                      fontSize: 22,
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '≈ ${widget.balance} SEK',
                style: AppTypography.sReg.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 18),
                color: Colors.white.withValues(alpha: 0.14),
              ),
              // Available + Pending
              Row(
                children: [
                  _balanceSplit('Available', '${widget.balance} pts', Colors.white),
                  const SizedBox(width: 24),
                  _balanceSplit('Pending', '0 pts', AppColors.gold),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceSplit(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.xsReg.copyWith(
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.mBold.copyWith(color: valueColor),
        ),
      ],
    );
  }

  Widget _buildActionPills() {
    return Row(
      children: [
        Expanded(
          child: _ActionPill(
            icon: Icons.send,
            label: 'Send',
            onTap: widget.onSend,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionPill(
            icon: Icons.call_received,
            label: 'Request',
            onTap: widget.onRequest,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.ink3, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: AppTypography.mReg.copyWith(color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Search transactions',
                hintStyle: AppTypography.mReg.copyWith(color: AppColors.ink3),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transaction History',
          style: AppTypography.mBold.copyWith(color: AppColors.ink),
        ),
        // Sort button
        GestureDetector(
          onTap: () => _showSortMenu(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.hair),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort, color: AppColors.navy, size: 14),
                const SizedBox(width: 6),
                Text(
                  _sortLabels[_sort]!,
                  style: AppTypography.sBold.copyWith(color: AppColors.navy),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.hair,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ...SortMode.values.map((mode) => ListTile(
                  title: Text(
                    _sortLabels[mode]!,
                    style: AppTypography.sReg.copyWith(color: AppColors.ink),
                  ),
                  trailing: _sort == mode
                      ? const Icon(Icons.check, color: AppColors.navy, size: 16)
                      : null,
                  tileColor: _sort == mode ? AppColors.navySoft : null,
                  onTap: () {
                    setState(() => _sort = mode);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('all', 'All', widget.transactions.length),
      ('received', 'Received', widget.transactions.where((t) => t.incoming).length),
      ('sent', 'Sent', widget.transactions.where((t) => !t.incoming).length),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isActive = _filter == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.navy : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isActive ? AppColors.navy : AppColors.hair,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      f.$2,
                      style: AppTypography.sBold.copyWith(
                        color: isActive ? Colors.white : AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${f.$3}',
                      style: AppTypography.sReg.copyWith(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.65)
                            : AppColors.ink3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> list) {
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No transactions match your filters',
            style: AppTypography.sReg.copyWith(color: AppColors.ink3),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(list.length, (i) {
        final tx = list[i];
        return TxRow(
          desc: tx.desc,
          date: tx.date,
          amount: tx.amount,
          incoming: tx.incoming,
          onTap: () => widget.onTxClick?.call(tx),
          last: i == list.length - 1,
        );
      }),
    );
  }
}

class _ActionPill extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) {
        setState(() => _hovered = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 52,
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.navy.withValues(alpha: 0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.navy, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: AppColors.navy, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: AppTypography.mBold.copyWith(color: AppColors.navy),
            ),
          ],
        ),
      ),
    );
  }
}

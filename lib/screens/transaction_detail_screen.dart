import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/transaction.dart';
import '../widgets/top_bar.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction tx;
  final VoidCallback? onBack;

  const TransactionDetailScreen({
    super.key,
    required this.tx,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TopBar(title: 'Transaction', onBack: onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _buildAmountHero(),
                const SizedBox(height: 24),
                _buildDetailCard(),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Report an issue',
                      style: AppTypography.sBold.copyWith(
                        color: AppColors.navy,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountHero() {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 22),
      child: Column(
        children: [
          // Icon circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: tx.incoming
                  ? const Color(0xFFE6F4F3)
                  : const Color(0xFFF5EEE0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tx.incoming
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: tx.incoming ? AppColors.teal : const Color(0xFFA36F00),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),

          // Amount
          Text(
            tx.amount,
            style: AppTypography.h2.copyWith(
              fontSize: 44,
              color: tx.incoming ? AppColors.teal : AppColors.ink,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4F3),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  tx.status,
                  style: AppTypography.sBold.copyWith(color: AppColors.teal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border.all(color: AppColors.hair),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Column(
        children: [
          _DetailRow(label: 'Type', value: tx.type),
          _DetailRow(label: 'Study', value: tx.study),
          _DetailRow(label: 'From', value: tx.from),
          _DetailRow(label: 'Date', value: tx.dateLong),
          _DetailRow(
            label: 'Transaction ID',
            value: tx.txid,
            mono: true,
            last: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  final bool last;

  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.hair, width: 1),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.sReg.copyWith(color: AppColors.ink3),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: AppTypography.sBold.copyWith(
                color: AppColors.ink,
                fontFamily: mono ? 'monospace' : null,
                letterSpacing: mono ? 0 : -0.2,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/transaction.dart';
import '../widgets/tx_row.dart';

class DashboardScreen extends StatelessWidget {
  final String userName;
  final VoidCallback? onNotifications;
  final VoidCallback? onWallet;
  final VoidCallback? onScan;
  final VoidCallback? onViewAll;
  final ValueChanged<Transaction>? onTxClick;

  const DashboardScreen({
    super.key,
    this.userName = 'Erik',
    this.onNotifications,
    this.onWallet,
    this.onScan,
    this.onViewAll,
    this.onTxClick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Greeting header
        _buildGreeting(context),

        // Scrollable body
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            children: [
              _buildWalletCard(),
              const SizedBox(height: 14),
              _buildRecentActivity(),
              const SizedBox(height: 14),
              _buildScanBlock(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        6,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: AppTypography.xsReg.copyWith(color: AppColors.ink3),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hi, $userName',
                  style: AppTypography.h4.copyWith(color: AppColors.navy),
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: onNotifications,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.navy,
                    size: 22,
                  ),
                  // Gold notification dot
                  Positioned(
                    top: 10,
                    right: 11,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.bg,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return GestureDetector(
      onTap: onWallet,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-0.8, -0.8),
            end: Alignment(0.8, 0.8),
            colors: [Color(0xFF00847C), Color(0xFF006963)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3800847C),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BALANCE',
                    style: AppTypography.xsBold.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 1.92, // 0.16em at 12px
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1,430 pts',
                    style: AppTypography.h3.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '≈ 1,430 SEK',
                    style: AppTypography.sReg.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View wallet',
                  style: AppTypography.sBold.copyWith(color: Colors.white),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recent = demoTransactions.take(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTypography.mBold.copyWith(color: AppColors.ink),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View all',
                style: AppTypography.sBold.copyWith(color: AppColors.navy),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...List.generate(recent.length, (i) {
          final tx = recent[i];
          return TxRow(
            desc: tx.desc,
            date: tx.date,
            amount: tx.amount,
            incoming: tx.incoming,
            onTap: () => onTxClick?.call(tx),
            last: i == recent.length - 1,
          );
        }),
      ],
    );
  }

  Widget _buildScanBlock() {
    return GestureDetector(
      onTap: onScan,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x381A365D),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // QR icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan to Verify',
                    style: AppTypography.lBold.copyWith(
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Authenticate or share your ID',
                    style: AppTypography.sReg.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.6),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

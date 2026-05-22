import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TxRow extends StatelessWidget {
  final String desc;
  final String date;
  final String amount;
  final bool incoming;
  final VoidCallback? onTap;
  final bool last;

  const TxRow({
    super.key,
    required this.desc,
    required this.date,
    required this.amount,
    this.incoming = true,
    this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipBg = incoming
        ? const Color(0xFFE6F4F3)
        : const Color(0xFFF5EEE0);
    final chipFg = incoming
        ? AppColors.teal
        : const Color(0xFFA36F00);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.hair, width: 1),
                ),
        ),
        child: Row(
          children: [
            // Icon chip
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: chipBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                incoming
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: chipFg,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),

            // Description + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    desc,
                    style: AppTypography.mBold.copyWith(color: AppColors.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: AppTypography.sReg.copyWith(color: AppColors.ink3),
                  ),
                ],
              ),
            ),

            // Amount
            const SizedBox(width: 12),
            Text(
              amount,
              style: AppTypography.mBold.copyWith(
                color: incoming ? AppColors.teal : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? right;

  const TopBar({
    super.key,
    required this.title,
    this.onBack,
    this.right,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.hair, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.chevron_left,
                    color: AppColors.navy,
                    size: 28,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 52),

          // Title
          Expanded(
            child: Text(
              title,
              style: AppTypography.mBold.copyWith(color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
          ),

          // Right action
          if (right != null)
            right!
          else
            const SizedBox(width: 52),
        ],
      ),
    );
  }
}

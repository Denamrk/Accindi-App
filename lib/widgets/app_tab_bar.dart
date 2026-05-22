import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppTabBar extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChanged;

  const AppTabBar({
    super.key,
    required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.hair, width: 1)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 4,
      ),
      child: Row(
        children: [
          _TabItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            id: 'home',
            isActive: active == 'home',
            onTap: () => onChanged('home'),
          ),
          _TabItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet,
            label: 'Wallet',
            id: 'wallet',
            isActive: active == 'wallet',
            onTap: () => onChanged('wallet'),
          ),
          _TabItem(
            icon: Icons.badge_outlined,
            activeIcon: Icons.badge,
            label: 'IDs',
            id: 'ids',
            isActive: active == 'ids',
            onTap: () => onChanged('ids'),
          ),
          _TabItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
            id: 'settings',
            isActive: active == 'settings',
            onTap: () => onChanged('settings'),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String id;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.id,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.navy : AppColors.ink3;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 6),
                  Icon(
                    isActive ? activeIcon : icon,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppTypography.xsBold.copyWith(
                      color: color,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: -0.05,
                    ),
                  ),
                ],
              ),
              // Gold active indicator pill
              if (isActive)
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

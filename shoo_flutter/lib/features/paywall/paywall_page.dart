import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/purchase/purchase_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.upgradeToPro),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // 皇冠图标
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange.withValues(alpha: 0.2), Colors.red.withValues(alpha: 0.1)],
                  ),
                ),
                child: const Icon(Icons.workspace_premium, size: 40, color: Colors.orange),
              ),
              const SizedBox(height: 16),
              // 标题
              Text(
                s.shooPro,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                s.unlockAllAnimals,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColorsDark.textSecondary : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // 功能列表
              _buildFeatureItem(context, Icons.pets, s.freeAnimals, s.freeAnimalsDesc),
              _buildFeatureItem(context, Icons.lock_open, s.proAnimals, s.proAnimalsDesc),
              _buildFeatureItem(context, Icons.all_inclusive, s.allFeatures, s.allFeaturesDesc),
              _buildFeatureItem(context, Icons.update, s.futureUpdates, s.futureUpdatesDesc),
              const SizedBox(height: 32),
              // 价格
              Text(
                PurchaseManager.instance.proPrice.isEmpty
                    ? s.defaultPrice
                    : PurchaseManager.instance.proPrice,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                s.oneTimePurchase,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              // 购买按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isPurchasing ? null : _purchase,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isPurchasing
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(s.unlockPro, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              // 恢复购买
              TextButton(
                onPressed: _restore,
                child: Text(s.restorePurchases, style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 16),
              // 安全提示
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    s.purchaseSecureNote,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String desc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColorsDark.textSecondary : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, size: 20, color: Colors.green[400]),
        ],
      ),
    );
  }

  Future<void> _purchase() async {
    setState(() => _isPurchasing = true);
    final success = await PurchaseManager.instance.purchasePro();
    if (mounted) {
      setState(() => _isPurchasing = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).purchaseSuccess)),
        );
        context.pop();
      } else if (PurchaseManager.instance.lastError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(PurchaseManager.instance.lastError!)),
        );
      }
    }
  }

  Future<void> _restore() async {
    final success = await PurchaseManager.instance.restorePurchases();
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).restoreSuccess)),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).restoreFailed)),
        );
      }
    }
  }
}

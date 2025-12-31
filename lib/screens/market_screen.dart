import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/localizations.dart';
import '../models/shop_item.dart';

/// Market screen for purchasing themes and items
class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final localizations = AppLocalizations(settings.language);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store, color: AppTheme.primaryPurple),
                const SizedBox(width: 8),
                Text(localizations.isTurkish ? 'Market' : 'Market'),
              ],
            );
          },
        ),
      ),
      body: Consumer2<ShopProvider, AppStateProvider>(
        builder: (context, shop, appState, child) {
          final settings = Provider.of<SettingsProvider>(
            context,
            listen: false,
          );
          final localizations = AppLocalizations(settings.language);
          final coins = appState.userProgress.coins;

          return Column(
            children: [
              // Coins display
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                decoration: BoxDecoration(
                  gradient: AppTheme.xpGradient,
                  boxShadow: AppTheme.softGlow,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          localizations.isTurkish ? 'Puanların' : 'Your Coins',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(inherit: false, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$coins',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            inherit: false,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            textBaseline: TextBaseline.alphabetic,
                          ),
                    ),
                  ],
                ),
              ),
              // Shop items list
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 800 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette,
                              color: AppTheme.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              localizations.isTurkish ? 'Temalar' : 'Themes',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ...shop.shopItems
                            .where((item) => item.type == ShopItemType.theme)
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _ModernShopItemCard(item: item),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Modern shop item card widget
class _ModernShopItemCard extends StatelessWidget {
  final ShopItem item;

  const _ModernShopItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final shop = Provider.of<ShopProvider>(context, listen: false);
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final localizations = AppLocalizations(settings.language);

    final canAfford = appState.userProgress.coins >= item.price;
    final isPurchased = item.isPurchased;
    final isEquipped = item.isEquipped;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: isEquipped
              ? AppTheme.xpGreen
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: isEquipped ? 2 : 1,
        ),
        boxShadow: isEquipped ? AppTheme.softGlow : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryPurple.withValues(alpha: 0.15),
                    AppTheme.secondaryBlue.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.palette,
                size: 40,
                color: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(width: 20),
            // Item info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      if (isEquipped)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.xpGradient,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSM,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                localizations.isTurkish ? 'Aktif' : 'Active',
                                style: const TextStyle(
                                  inherit: false,
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  textBaseline: TextBaseline.alphabetic,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Price/Action button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isPurchased)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.xpGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMD,
                          ),
                          border: Border.all(
                            color: AppTheme.xpGreen.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              size: 18,
                              color: AppTheme.xpGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.price}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    inherit: false,
                                    color: AppTheme.xpGreen,
                                    fontWeight: FontWeight.bold,
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: canAfford
                            ? () async {
                                final success = await shop.purchaseItem(item);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            localizations.isTurkish
                                                ? 'Satın alındı!'
                                                : 'Purchased!',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            localizations.isTurkish
                                                ? 'Yetersiz puan!'
                                                : 'Not enough coins!',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.xpGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.shopping_cart),
                        label: Text(
                          localizations.isTurkish ? 'Satın Al' : 'Buy',
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: isEquipped
                        ? null
                        : () async {
                            await shop.equipItem(item);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.palette,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        localizations.isTurkish
                                            ? 'Tema aktif edildi!'
                                            : 'Theme activated!',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEquipped
                          ? AppTheme.textTertiary
                          : AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    icon: Icon(isEquipped ? Icons.check_circle : Icons.palette),
                    label: Text(
                      isEquipped
                          ? (localizations.isTurkish ? 'Aktif' : 'Active')
                          : (localizations.isTurkish ? 'Kullan' : 'Use'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

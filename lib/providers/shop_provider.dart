import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/shop_item.dart';
import '../models/user_progress.dart';
import '../services/storage_service.dart';

/// Shop provider for managing shop items and purchases
class ShopProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<ShopItem> _shopItems = [];
  UserProgress? _userProgress;

  List<ShopItem> get shopItems => _shopItems;
  UserProgress? get userProgress => _userProgress;

  /// Initialize shop with default items
  Future<void> initialize(UserProgress userProgress) async {
    _userProgress = userProgress;
    await _loadShopItems();
    await _loadPurchasedItems();
    notifyListeners();
  }

  /// Update user progress
  void updateUserProgress(UserProgress progress) {
    _userProgress = progress;
    notifyListeners();
  }

  /// Load shop items (default themes)
  Future<void> _loadShopItems() async {
    if (_shopItems.isNotEmpty) return;

    _shopItems = [
      // Default theme (free)
      ShopItem(
        id: 'theme_default',
        name: 'Default Theme',
        description: 'The classic StudyQuest theme',
        price: 0,
        type: ShopItemType.theme,
        themeId: 'default',
        icon: '🎨',
        isPurchased: true,
        isEquipped: true,
      ),
      // Premium themes
      ShopItem(
        id: 'theme_ocean',
        name: 'Ocean Theme',
        description: 'Calm blue ocean vibes',
        price: 500,
        type: ShopItemType.theme,
        themeId: 'ocean',
        icon: '🌊',
      ),
      ShopItem(
        id: 'theme_forest',
        name: 'Forest Theme',
        description: 'Green nature theme',
        price: 500,
        type: ShopItemType.theme,
        themeId: 'forest',
        icon: '🌲',
      ),
      ShopItem(
        id: 'theme_sunset',
        name: 'Sunset Theme',
        description: 'Warm orange and pink',
        price: 750,
        type: ShopItemType.theme,
        themeId: 'sunset',
        icon: '🌅',
      ),
      ShopItem(
        id: 'theme_neon',
        name: 'Neon Theme',
        description: 'Vibrant neon colors',
        price: 1000,
        type: ShopItemType.theme,
        themeId: 'neon',
        icon: '💡',
      ),
    ];
  }

  /// Load purchased items from storage
  Future<void> _loadPurchasedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final purchasedJson = prefs.getString('purchased_items');
    if (purchasedJson == null) return;

    try {
      final List<dynamic> purchased = jsonDecode(purchasedJson);
      for (var itemId in purchased) {
        final index = _shopItems.indexWhere((item) => item.id == itemId);
        if (index != -1) {
          _shopItems[index] = _shopItems[index].copyWith(isPurchased: true);
        }
      }
    } catch (e) {
      debugPrint('Error loading purchased items: $e');
    }

    // Load equipped item
    final equippedId = prefs.getString('equipped_item');
    if (equippedId != null) {
      for (var i = 0; i < _shopItems.length; i++) {
        _shopItems[i] = _shopItems[i].copyWith(
          isEquipped: _shopItems[i].id == equippedId,
        );
      }
    }
  }

  /// Save purchased items to storage
  Future<void> _savePurchasedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final purchased = _shopItems
        .where((item) => item.isPurchased)
        .map((item) => item.id)
        .toList();
    await prefs.setString('purchased_items', jsonEncode(purchased));
  }

  /// Purchase an item
  Future<bool> purchaseItem(ShopItem item) async {
    final userProgress = _userProgress;
    if (userProgress == null) return false;
    if (item.isPurchased) return false;
    if (userProgress.coins < item.price) return false;

    // Deduct coins
    final newCoins = userProgress.coins - item.price;
    _userProgress = userProgress.copyWith(coins: newCoins);

    // Mark as purchased
    final index = _shopItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _shopItems[index] = _shopItems[index].copyWith(isPurchased: true);
    }

    // Save to storage
    await _savePurchasedItems();
    final updatedProgress = _userProgress;
    if (updatedProgress != null) {
      await _storageService.saveUserProgress(updatedProgress);
    }

    notifyListeners();
    return true;
  }

  /// Equip an item
  Future<void> equipItem(ShopItem item) async {
    if (!item.isPurchased) return;

    // Unequip all items
    for (var i = 0; i < _shopItems.length; i++) {
      _shopItems[i] = _shopItems[i].copyWith(isEquipped: false);
    }

    // Equip selected item
    final index = _shopItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _shopItems[index] = _shopItems[index].copyWith(isEquipped: true);
    }

    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equipped_item', item.id);

    notifyListeners();
  }

  /// Get equipped theme ID
  String? get equippedThemeId {
    if (_shopItems.isEmpty) return null;
    try {
      final equipped = _shopItems.firstWhere(
        (item) => item.isEquipped && item.type == ShopItemType.theme,
        orElse: () {
          // Safe fallback: return first item if list is not empty
          // This should never be called if _shopItems is empty due to check above
          if (_shopItems.isEmpty) {
            throw StateError('No shop items available');
          }
          return _shopItems.first;
        },
      );
      return equipped.themeId;
    } catch (e) {
      return null;
    }
  }
}

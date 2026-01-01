import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/localizations.dart';

/// Leaderboard screen showing top users ranked by XP
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _topUsers = [];
  Map<String, dynamic>? _currentUserData;
  int _userRank = -1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Loading leaderboard...');
      final topUsers = await _firestoreService.getTopUsers(limit: 100);
      debugPrint('Top users count: ${topUsers.length}');

      final currentUserData = await _firestoreService.getCurrentUserLeaderboardData();
      debugPrint('Current user data: $currentUserData');

      final userRank = await _firestoreService.getUserRank();
      debugPrint('User rank: $userRank');

      if (mounted) {
        setState(() {
          _topUsers = topUsers;
          _currentUserData = currentUserData;
          _userRank = userRank;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading leaderboard: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading leaderboard: $e')),
        );
      }
    }
  }

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
                Icon(Icons.emoji_events, color: AppTheme.primaryPurple),
                const SizedBox(width: 8),
                Text(localizations.leaderboard),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settings, auth, child) {
          final localizations = AppLocalizations(settings.language);

          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show login message only if not authenticated
          if (!auth.isAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.leaderboard_outlined,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.topPlayers,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          inherit: false,
                          color: AppTheme.textSecondary,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.loginToSeeRank,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          inherit: false,
                          color: AppTheme.textSecondary,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                  ),
                ],
              ),
            );
          }

          // If authenticated but no users in leaderboard
          if (_topUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.leaderboard_outlined,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.topPlayers,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          inherit: false,
                          color: AppTheme.textSecondary,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.isTurkish
                        ? 'Henüz sıralamada kimse yok. İlk sen ol!'
                        : 'No one in the leaderboard yet. Be the first!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          inherit: false,
                          color: AppTheme.textSecondary,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadLeaderboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current user rank card
                  if (_currentUserData != null && _userRank > 0) ...[
                    _buildCurrentUserCard(
                      context,
                      localizations,
                      _currentUserData!,
                      _userRank,
                      isTablet,
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Top 3 podium
                  if (_topUsers.length >= 3) ...[
                    _buildTopThreePodium(context, localizations, isTablet),
                    const SizedBox(height: 24),
                  ],
                  // Leaderboard title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      localizations.topPlayers,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            inherit: false,
                            textBaseline: TextBaseline.alphabetic,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rest of the leaderboard
                  ..._topUsers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final user = entry.value;
                    final rank = index + 1;

                    // Skip top 3 if they exist (already shown in podium)
                    if (rank <= 3 && _topUsers.length >= 3) {
                      return const SizedBox.shrink();
                    }

                    return _buildLeaderboardItem(
                      context,
                      localizations,
                      user,
                      rank,
                      isTablet,
                      isCurrentUser: _currentUserData != null &&
                          user['userId'] == _currentUserData!['userId'],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentUserCard(
    BuildContext context,
    AppLocalizations localizations,
    Map<String, dynamic> userData,
    int rank,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.15),
            AppTheme.xpCyan.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: isTablet ? 56 : 48,
            height: isTablet ? 56 : 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      inherit: false,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      textBaseline: TextBaseline.alphabetic,
                    ),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['name'] as String? ?? localizations.anonymous,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        inherit: false,
                        fontWeight: FontWeight.bold,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                ),
                if (userData['username'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@${userData['username']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          inherit: false,
                          color: AppTheme.textSecondary,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                  ),
                ],
              ],
            ),
          ),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: AppTheme.xpGreen),
                  const SizedBox(width: 4),
                  Text(
                    '${userData['totalXP']}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          inherit: false,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.xpGreen,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${localizations.level} ${userData['level']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          inherit: false,
                          color: AppTheme.textSecondary,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopThreePodium(
    BuildContext context,
    AppLocalizations localizations,
    bool isTablet,
  ) {
    final first = _topUsers[0];
    final second = _topUsers[1];
    final third = _topUsers[2];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        Expanded(
          child: _buildPodiumItem(
            context,
            localizations,
            second,
            2,
            Colors.grey.shade400,
            isTablet,
            height: 120,
          ),
        ),
        const SizedBox(width: 8),
        // 1st place
        Expanded(
          child: _buildPodiumItem(
            context,
            localizations,
            first,
            1,
            Colors.amber,
            isTablet,
            height: 160,
          ),
        ),
        const SizedBox(width: 8),
        // 3rd place
        Expanded(
          child: _buildPodiumItem(
            context,
            localizations,
            third,
            3,
            Colors.brown.shade400,
            isTablet,
            height: 100,
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    AppLocalizations localizations,
    Map<String, dynamic> user,
    int rank,
    Color medalColor,
    bool isTablet,
    {required double height}
  ) {
    return Column(
      children: [
        // Medal icon
        Container(
          width: isTablet ? 64 : 56,
          height: isTablet ? 64 : 56,
          decoration: BoxDecoration(
            color: medalColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: medalColor.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: isTablet ? 32 : 28,
          ),
        ),
        const SizedBox(height: 8),
        // User name
        Text(
          user['name'] as String? ?? localizations.anonymous,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                inherit: false,
                fontWeight: FontWeight.bold,
                textBaseline: TextBaseline.alphabetic,
              ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (user['username'] != null) ...[
          const SizedBox(height: 4),
          Text(
            '@${user['username']}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  inherit: false,
                  color: AppTheme.textSecondary,
                  textBaseline: TextBaseline.alphabetic,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        // XP
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 16, color: AppTheme.xpGreen),
            const SizedBox(width: 4),
            Text(
              '${user['totalXP']}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    inherit: false,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.xpGreen,
                    textBaseline: TextBaseline.alphabetic,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Podium base
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                medalColor.withValues(alpha: 0.3),
                medalColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: medalColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    inherit: false,
                    color: medalColor,
                    fontWeight: FontWeight.bold,
                    textBaseline: TextBaseline.alphabetic,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    AppLocalizations localizations,
    Map<String, dynamic> user,
    int rank,
    bool isTablet, {
    required bool isCurrentUser,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.primaryPurple.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surface,
        gradient: isCurrentUser
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryPurple.withValues(alpha: 0.15),
                  AppTheme.xpCyan.withValues(alpha: 0.1),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: isCurrentUser
              ? AppTheme.primaryPurple.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: isTablet ? 48 : 40,
            child: Text(
              '#$rank',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    inherit: false,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    textBaseline: TextBaseline.alphabetic,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['name'] as String? ?? localizations.anonymous,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              inherit: false,
                              fontWeight: FontWeight.bold,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          localizations.you,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                inherit: false,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                textBaseline: TextBaseline.alphabetic,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (user['username'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@${user['username']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          inherit: false,
                          color: AppTheme.textSecondary,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: AppTheme.xpGreen),
                  const SizedBox(width: 4),
                  Text(
                    '${user['totalXP']}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          inherit: false,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.xpGreen,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${localizations.level} ${user['level']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          inherit: false,
                          color: AppTheme.textSecondary,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


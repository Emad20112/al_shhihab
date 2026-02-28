import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// LOCATION PROVIDER - Region Selection & Persistence
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Manages user's selected region (Northern vs Southern cities).
/// Persists choice via SharedPreferences so the onboarding screen
/// is only shown on the very first app launch.
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// SHARED PREFERENCES KEY
// ═══════════════════════════════════════════════════════════════════════════

const String _regionPreferenceKey = 'app_user_region';

// ═══════════════════════════════════════════════════════════════════════════
// LOCATION REGION ENUM
// ═══════════════════════════════════════════════════════════════════════════

/// The two geographical zones the user can pick from
enum LocationRegion {
  north('north'),
  south('south');

  final String value;
  const LocationRegion(this.value);

  static LocationRegion? fromString(String? value) {
    if (value == null) return null;
    return LocationRegion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LocationRegion.north,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LOCATION STATE
// ═══════════════════════════════════════════════════════════════════════════

class LocationState {
  final bool isFirstLaunch;
  final LocationRegion? selectedRegion;

  const LocationState({required this.isFirstLaunch, this.selectedRegion});

  /// Default – assume first launch until prefs are read
  factory LocationState.initial() {
    return const LocationState(isFirstLaunch: true, selectedRegion: null);
  }

  LocationState copyWith({
    bool? isFirstLaunch,
    LocationRegion? selectedRegion,
  }) {
    return LocationState(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      selectedRegion: selectedRegion ?? this.selectedRegion,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LOCATION NOTIFIER (RIVERPOD v3 API)
// ═══════════════════════════════════════════════════════════════════════════

class LocationNotifier extends Notifier<LocationState> {
  @override
  LocationState build() {
    _loadRegionPreference();
    return LocationState.initial();
  }

  /// Load saved region preference from SharedPreferences
  Future<void> _loadRegionPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final regionValue = prefs.getString(_regionPreferenceKey);

      if (regionValue != null) {
        // User has selected a region before
        state = LocationState(
          isFirstLaunch: false,
          selectedRegion: LocationRegion.fromString(regionValue),
        );
      } else {
        // No region saved → first launch
        state = const LocationState(isFirstLaunch: true, selectedRegion: null);
      }
    } catch (e) {
      // On error keep first-launch state
    }
  }

  /// Select a region, persist it, and dismiss onboarding
  Future<void> selectRegion(LocationRegion region) async {
    state = LocationState(isFirstLaunch: false, selectedRegion: region);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_regionPreferenceKey, region.value);
    } catch (e) {
      // Silently handle save errors
    }
  }

  /// Get the currently selected region
  LocationRegion? get currentRegion => state.selectedRegion;

  /// Check if this is the first launch
  bool get isFirstLaunch => state.isFirstLaunch;
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Provider for location state
final locationProvider = NotifierProvider<LocationNotifier, LocationState>(() {
  return LocationNotifier();
});

/// Convenience provider for first-launch check
final isFirstLaunchProvider = Provider<bool>((ref) {
  return ref.watch(locationProvider).isFirstLaunch;
});

/// Convenience provider for selected region
final selectedRegionProvider = Provider<LocationRegion?>((ref) {
  return ref.watch(locationProvider).selectedRegion;
});

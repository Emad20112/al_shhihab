import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CITY PROVIDER - Yemeni City Selection & Persistence
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Manages the user's selected city. Persists via SharedPreferences.
/// Default city: صنعاء (Sana'a)
/// ═══════════════════════════════════════════════════════════════════════════

const String _cityPreferenceKey = 'app_selected_city';

// ═══════════════════════════════════════════════════════════════════════════
// YEMENI CITY MODEL
// ═══════════════════════════════════════════════════════════════════════════

class YemeniCity {
  final String id;
  final String nameEn;
  final String nameAr;

  const YemeniCity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });
}

/// All available Yemeni cities
const List<YemeniCity> yemeniCities = [
  YemeniCity(id: 'sanaa', nameEn: "Sana'a", nameAr: 'صنعاء'),
  YemeniCity(id: 'aden', nameEn: 'Aden', nameAr: 'عدن'),
  YemeniCity(id: 'taiz', nameEn: 'Taiz', nameAr: 'تعز'),
  YemeniCity(id: 'ibb', nameEn: 'Ibb', nameAr: 'إب'),
  YemeniCity(id: 'dhamar', nameEn: 'Dhamar', nameAr: 'ذمار'),
  YemeniCity(id: 'amran', nameEn: 'Amran', nameAr: 'عمران'),
  YemeniCity(id: 'hajjah', nameEn: 'Hajjah', nameAr: 'حجة'),
  YemeniCity(id: 'hudaydah', nameEn: 'Al Hudaydah', nameAr: 'الحديدة'),
  YemeniCity(id: 'mukalla', nameEn: 'Al Mukalla', nameAr: 'المكلا'),
  YemeniCity(id: 'sayoun', nameEn: 'Sayoun', nameAr: 'سيئون'),
  YemeniCity(id: 'marib', nameEn: 'Marib', nameAr: 'مأرب'),
  YemeniCity(id: 'abyan', nameEn: 'Abyan', nameAr: 'أبين'),
  YemeniCity(id: 'lahij', nameEn: 'Lahij', nameAr: 'لحج'),
  YemeniCity(id: 'dhale', nameEn: "Al-Dhale'e", nameAr: 'الضالع'),
  YemeniCity(id: 'sadah', nameEn: "Sa'dah", nameAr: 'صعدة'),
  YemeniCity(id: 'bayda', nameEn: 'Al Bayda', nameAr: 'البيضاء'),
];

// ═══════════════════════════════════════════════════════════════════════════
// CITY STATE
// ═══════════════════════════════════════════════════════════════════════════

class CityState {
  final YemeniCity selectedCity;

  const CityState({required this.selectedCity});

  /// Default: Sana'a
  factory CityState.initial() {
    return CityState(selectedCity: yemeniCities.first);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CITY NOTIFIER
// ═══════════════════════════════════════════════════════════════════════════

class CityNotifier extends Notifier<CityState> {
  @override
  CityState build() {
    _loadCityPreference();
    return CityState.initial();
  }

  Future<void> _loadCityPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cityId = prefs.getString(_cityPreferenceKey);

      if (cityId != null) {
        final city = yemeniCities.firstWhere(
          (c) => c.id == cityId,
          orElse: () => yemeniCities.first,
        );
        state = CityState(selectedCity: city);
      }
    } catch (_) {
      // Keep default (Sana'a)
    }
  }

  Future<void> selectCity(YemeniCity city) async {
    state = CityState(selectedCity: city);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cityPreferenceKey, city.id);
    } catch (_) {
      // Silently handle save errors
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

final cityProvider = NotifierProvider<CityNotifier, CityState>(() {
  return CityNotifier();
});

final selectedCityProvider = Provider<YemeniCity>((ref) {
  return ref.watch(cityProvider).selectedCity;
});

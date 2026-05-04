import '../../../data/dummy_data.dart';
import '../../../core/network/api_client.dart';

class AdvertisingRepository {
  const AdvertisingRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<AdvertisementModel>> fetchHomeAdvertisements() async {
    final response = await _apiClient.get<List<AdvertisementModel>>(
      '/advert/madverts',
      authenticated: false,
      fromData: (value) {
        if (value is! List) return const <AdvertisementModel>[];

        return value
            .whereType<Map>()
            .map((item) => _advertFromJson(Map<String, dynamic>.from(item)))
            .where((ad) => ad.isActive)
            .toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));
      },
    );

    return response.data ?? const <AdvertisementModel>[];
  }

  AdvertisementModel _advertFromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id']?.toString() ?? json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleAr: json['title_ar']?.toString() ?? json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      subtitleAr:
          json['subtitle_ar']?.toString() ?? json['subtitle']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      ctaLabel: json['cta_label']?.toString() ?? 'Shop Now',
      ctaLabelAr: json['cta_label_ar']?.toString() ?? 'تسوق الآن',
      placement: _placementFromJson(json['placement']?.toString()),
      campaignType: json['campaign_type']?.toString() ?? 'campaign',
      discountPercent: _intFromJson(json['discount_percent']),
      productId: json['product_id']?.toString(),
      categoryId: json['category_id']?.toString(),
      priority: _intFromJson(json['priority']) ?? 100,
      startsAt: _dateFromJson(json['starts_at']) ?? DateTime(2026),
      endsAt: _dateFromJson(json['ends_at']) ?? DateTime(2027),
    );
  }

  AdPlacement _placementFromJson(String? value) {
    switch (value) {
      case 'home_hero':
        return AdPlacement.homeHero;
      case 'category':
        return AdPlacement.category;
      case 'home_strip':
      default:
        return AdPlacement.homeStrip;
    }
  }

  int? _intFromJson(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  DateTime? _dateFromJson(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

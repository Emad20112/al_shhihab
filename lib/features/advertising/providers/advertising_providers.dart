import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/dummy_data.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/advertising_repository.dart';

final advertisingRepositoryProvider = Provider<AdvertisingRepository>((ref) {
  return AdvertisingRepository(apiClient: ref.watch(apiClientProvider));
});

final homeAdvertisementsProvider = FutureProvider<List<AdvertisementModel>>((
  ref,
) async {
  return ref.watch(advertisingRepositoryProvider).fetchHomeAdvertisements();
});

import 'package:bogoballers/core/models/league_model.dart';
import 'package:bogoballers/core/services/league_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final leagueCarouselProvider = FutureProvider.autoDispose<List<LeagueModel>?>((ref) async {
  ref.keepAlive();
  return await LeagueServices().fetchLeaguesForCarousel();
});

// 🟢 Wrapper class for data, loading, error, refetch
class LeagueCarouselState {
  final List<LeagueModel>? leagues;
  final bool isLoading;
  final bool isError;
  final void Function() refetch;

  LeagueCarouselState({
    required this.leagues,
    required this.isLoading,
    required this.isError,
    required this.refetch,
  });
}

// 🟢 Getter function for use inside widgets
LeagueCarouselState watchLeagueCarousel(WidgetRef ref) {
  final asyncData = ref.watch(leagueCarouselProvider);

  return LeagueCarouselState(
    leagues: asyncData.value,
    isLoading: asyncData.isLoading,
    isError: asyncData.hasError,
    refetch: () => ref.refresh(leagueCarouselProvider),
  );
}

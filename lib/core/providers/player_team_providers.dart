import 'package:bogoballers/core/models/player_model_beta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bogoballers/core/services/team_creator_services.dart';

class PlayerTeamFetchState {
  final List<PlayerTeamWrapper>? players;
  final bool isLoading;
  final bool isError;
  final void Function() refetch;

  PlayerTeamFetchState({
    required this.players,
    required this.isLoading,
    required this.isError,
    required this.refetch,
  });
}

final playerTeamProvider = FutureProvider.family
    .autoDispose<List<PlayerTeamWrapper>?, String>((ref, teamId) async {
  ref.keepAlive();
  return await TeamCreatorServices().fetchPlayers(teamId,status: 'Accepted');
});

PlayerTeamFetchState watchTeamPlayers(WidgetRef ref, String teamId) {
  final asyncData = ref.watch(playerTeamProvider(teamId));

  return PlayerTeamFetchState(
    players: asyncData.value,
    isLoading: asyncData.isLoading,
    isError: asyncData.hasError,
    refetch: () => ref.refresh(playerTeamProvider(teamId)),
  );
}

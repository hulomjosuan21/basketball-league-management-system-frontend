import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/services/team_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final teamsByUserIdProvider = FutureProvider.family
    .autoDispose<List<TeamModel>?, String>((ref, userId) async {
      ref.keepAlive();
      return await TeamService().fetchTeamsByUserID(userId);
    });

class TeamsByUserIdState {
  final List<TeamModel>? teams;
  final bool isLoading;
  final bool isError;
  final void Function() refetch;

  TeamsByUserIdState({
    required this.teams,
    required this.isLoading,
    required this.isError,
    required this.refetch,
  });
}

TeamsByUserIdState watchTeamsByUserId(WidgetRef ref, String userId) {
  final asyncData = ref.watch(teamsByUserIdProvider(userId));

  return TeamsByUserIdState(
    teams: asyncData.value,
    isLoading: asyncData.isLoading,
    isError: asyncData.hasError,
    refetch: () => ref.refresh(teamsByUserIdProvider(userId)),
  );
}

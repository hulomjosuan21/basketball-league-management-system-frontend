import 'package:bogoballers/client/screens/team_creator_team_screen.dart';
import 'package:bogoballers/core/constants/image_strings.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/extensions/extensions.dart';
import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/providers/team_providers.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/service_locator.dart';
import 'package:bogoballers/core/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamCreatorTeamListScreen extends ConsumerStatefulWidget {
  const TeamCreatorTeamListScreen({
    super.key,
    this.selectable = false,
    this.onDoubleTapSelectedTeam,
  });

  final bool selectable;
  final void Function(TeamModel)? onDoubleTapSelectedTeam;

  @override
  ConsumerState<TeamCreatorTeamListScreen> createState() =>
      _TeamCreatorTeamListScreenState();
}

class _TeamCreatorTeamListScreenState
    extends ConsumerState<TeamCreatorTeamListScreen> {
  TeamModel? _selectedTeam;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final user = getIt<EntityState<UserModel>>().entity;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAppSnackbar(
          context,
          message: "Unauthorized access",
          title: "Error",
          variant: SnackbarVariant.error,
        );
        Navigator.pushReplacementNamed(context, '/client/login/screen');
      });
      return const SizedBox.shrink();
    }

    late final TeamsByUserIdState state;
    try {
      state = watchTeamsByUserId(ref, user.user_id);
    } catch (e) {
      return _errorWidget(onRetry: () {
        ref.invalidate(teamsByUserIdProvider(user.user_id));
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.selectable ? "Select team" : "Team",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: Sizes.fontSizeMd,
            color: appColors.gray1100,
          ),
        ),
        iconTheme: IconThemeData(color: appColors.gray1100),
        backgroundColor: appColors.gray200,
      ),
      body: RefreshIndicator(
        color: appColors.accent900,
        onRefresh: () async => state.refetch(),
        child: state.isLoading
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: appColors.accent900),
                ),
              )
            : state.isError
                ? _errorWidget(onRetry: state.refetch)
                : (state.teams?.isEmpty ?? true)
                    ? _emptyWidget()
                    : ListView.builder(
                        itemCount: state.teams!.length,
                        itemBuilder: (context, index) {
                          final team = state.teams![index];
                          final isSelected =
                              team.team_id == _selectedTeam?.team_id;
                          return _teamListItemCard(team, isSelected);
                        },
                      ),
      ),
    );
  }

  Widget _teamListItemCard(TeamModel team, bool isSelected) {
    final appColors = context.appColors;

    return GestureDetector(
      onTap: () {
        if (widget.selectable) {
          setState(() => _selectedTeam = team);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamCreatorTeamScreen(team: team),
            ),
          );
        }
      },
      onDoubleTap: () {
        if (widget.selectable && _selectedTeam?.team_id == team.team_id) {
          widget.onDoubleTapSelectedTeam?.call(team);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        clipBehavior: Clip.hardEdge,
        height: 120,
        padding: EdgeInsets.all(Sizes.spaceXs),
        margin: EdgeInsets.only(
          left: Sizes.spaceMd,
          right: Sizes.spaceMd,
          bottom: Sizes.spaceMd,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            width: isSelected ? 2.5 : Sizes.borderWidthSm,
            color: isSelected ? appColors.accent900 : appColors.gray600,
          ),
          borderRadius: BorderRadius.circular(Sizes.radiusMd),
          color: isSelected
              ? appColors.accent100.withAlpha(20)
              : appColors.gray100,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: appColors.accent100.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                FlexibleNetworkImage(
                  imageUrl: team.team_logo_url,
                  fallbackAsset: ImageStrings.exampleTeamLogo,
                  isCircular: false,
                  size: 100,
                  radius: Sizes.radiusMd,
                ),
                const SizedBox(width: Sizes.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        team.team_name.orNoData(),
                        style: TextStyle(
                          color: appColors.gray1100,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.emoji_events,
                              color: Colors.green, size: 18),
                          const SizedBox(width: 4),
                          Text('Wins: ${team.total_wins}',
                              style: TextStyle(
                                  color: appColors.gray900, fontSize: 14)),
                          const SizedBox(width: 12),
                          Icon(Icons.close, color: Colors.red, size: 18),
                          const SizedBox(width: 4),
                          Text('Losses: ${team.total_losses}',
                              style: TextStyle(
                                  color: appColors.gray900, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.selectable && isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle,
                    color: appColors.accent900, size: 24),
              ),
            if (widget.selectable && isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(30),
                    borderRadius: BorderRadius.circular(Sizes.radiusMd),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Double tap to join league',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black45,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget({required VoidCallback onRetry}) {
    final appColors = context.appColors;
    return ListView(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load teams. Please try again.',
                  style: TextStyle(color: appColors.gray800),
                ),
                const SizedBox(height: 16),
                AppButton(
                  size: ButtonSize.sm,
                  label: 'Retry',
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyWidget() {
    final appColors = context.appColors;
    return ListView(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              "No teams found",
              style: TextStyle(color: appColors.gray800),
            ),
          ),
        ),
      ],
    );
  }
}

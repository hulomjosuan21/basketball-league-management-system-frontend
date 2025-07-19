import 'dart:async';
import 'package:bogoballers/core/providers/player_team_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/extensions/extensions.dart';
import 'package:bogoballers/core/helpers/helpers.dart';
import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/services/team_service.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/widgets/index.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/widgets/snackbars.dart';
import 'package:bogoballers/core/models/player_model_beta.dart';
import 'package:bogoballers/core/services/team_creator_services.dart';

class TeamCreatorTeamPlayerScreen extends ConsumerStatefulWidget {
  const TeamCreatorTeamPlayerScreen({required this.team, super.key});

  final TeamModel team;

  @override
  ConsumerState<TeamCreatorTeamPlayerScreen> createState() =>
      _TeamCreatorTeamPlayerScreenState();
}

class _TeamCreatorTeamPlayerScreenState
    extends ConsumerState<TeamCreatorTeamPlayerScreen> {
  bool isInviting = false;
  final nameOrEmailController = TextEditingController();

  Future<void> _handleInvitePlayer() async {
    setState(() => isInviting = true);
    try {
      if (nameOrEmailController.text.isEmpty) {
        throw Exception("Please enter a name or email to invite.");
      }

      final service = TeamService();
      final response = await service.invitePlayer(
        team_id: widget.team.team_id,
        name_or_email: nameOrEmailController.text,
      );

      if (response.status) {
        if (context.mounted) {
          showAppSnackbar(
            context,
            message: "Player invited successfully.",
            title: "Success",
            variant: SnackbarVariant.success,
          );
          nameOrEmailController.clear();
          ref.invalidate(
            playerTeamProvider(widget.team.team_id),
          ); // Refresh players
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (context.mounted) {
        handleErrorCallBack(e, (message) {
          showAppSnackbar(
            context,
            message: message,
            title: "Error",
            variant: SnackbarVariant.error,
          );
        });
      }
    } finally {
      if (context.mounted) {
        scheduleMicrotask(() => setState(() => isInviting = false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final asyncPlayers = ref.watch(playerTeamProvider(widget.team.team_id));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColors.gray200,
        iconTheme: IconThemeData(color: appColors.gray1100),
        centerTitle: true,
        title: Text(
          "Players",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: Sizes.fontSizeMd,
            color: appColors.gray1100,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildInvitePlayerInput(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(playerTeamProvider(widget.team.team_id));
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: asyncPlayers.when(
                data: (players) {
                  if (players == null || players.isEmpty) {
                    return ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 100),
                        Center(child: Text("No players yet.")),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index].player;
                      return TeamPlayerCard(player: player);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 100),
                    Center(
                      child: Column(
                        children: [
                          Text("Failed to load players"),
                          SizedBox(height: Sizes.spaceSm),
                          AppButton(
                            label: "Retry",
                            onPressed: () => ref.invalidate(
                              playerTeamProvider(widget.team.team_id),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildInvitePlayerInput() {
    return Padding(
      padding: const EdgeInsets.all(Sizes.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: nameOrEmailController,
              decoration: const InputDecoration(
                labelText: "Invite Player",
                helperText: "Player email or name",
              ),
            ),
          ),
          const SizedBox(width: Sizes.spaceSm),
          AppButton(
            label: 'Invite',
            onPressed: _handleInvitePlayer,
            isDisabled: isInviting,
          ),
        ],
      ),
    );
  }
}

class TeamPlayerCard extends StatelessWidget {
  const TeamPlayerCard({super.key, required this.player});

  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPlayerBottomSheet(context),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Sizes.spaceMd,
          vertical: Sizes.spaceSm,
        ),
        decoration: BoxDecoration(
          color: context.appColors.gray100,
          borderRadius: BorderRadius.circular(Sizes.radiusMd),
          border: Border.all(
            width: Sizes.borderWidthSm,
            color: context.appColors.gray600,
          ),
        ),
        padding: const EdgeInsets.all(Sizes.spaceSm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlexibleNetworkImage(
              imageUrl: player.profile_image_url,
              size: 40,
              isCircular: true,
            ),
            const SizedBox(width: Sizes.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.full_name.orNoData(),
                    style: const TextStyle(
                      fontSize: Sizes.fontSizeMd,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    player.position.replaceAll(', ', ' or ').orNoData(),
                    style: const TextStyle(fontSize: Sizes.fontSizeSm),
                  ),
                  Text(
                    "Gender: ${player.gender.orNoData()}",
                    style: const TextStyle(fontSize: Sizes.fontSizeSm),
                  ),
                  Text(
                    "Jersey: ${player.jersey_name.orNoData()} • #${formatJerseyNumber(player.jersey_number)}",
                    style: const TextStyle(fontSize: Sizes.fontSizeSm),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayerBottomSheet(BuildContext context) {
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Sizes.radiusSm),
        ),
      ),
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: Sizes.spaceMd,
            right: Sizes.spaceMd,
            bottom: MediaQuery.of(context).viewInsets.bottom + Sizes.spaceMd,
            top: Sizes.spaceMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                player.full_name.orNoData(),
                style: const TextStyle(
                  fontSize: Sizes.fontSizeMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Sizes.spaceSm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        labelText: "Send Message/feedback",
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      Navigator.pop(context);
                      showAppSnackbar(
                        context,
                        title: "Message Sent",
                        message:
                            "Your message has been sent to ${player.full_name}.",
                        variant: SnackbarVariant.success,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: Sizes.spaceMd),
              AppButton(
                label: "Make Team Captain",
                size: ButtonSize.sm,
                onPressed: () {
                  Navigator.pop(context);
                  showAppSnackbar(
                    context,
                    title: "Updated",
                    message: "${player.full_name} is now the team captain.",
                    variant: SnackbarVariant.success,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

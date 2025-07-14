import 'package:bogoballers/client/screens/team_creator_list_team_screen.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/extensions/extensions.dart';
import 'package:bogoballers/core/models/league_model.dart';
import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/services/league_services.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class JoinLeagueMetaScreen extends StatefulWidget {
  const JoinLeagueMetaScreen({required this.league, super.key});
  final LeagueModel league;

  @override
  State<JoinLeagueMetaScreen> createState() => _JoinLeagueMetaScreenState();
}

class _JoinLeagueMetaScreenState extends State<JoinLeagueMetaScreen> {
  late LeagueModel league;
  bool isJoining = false;

  @override
  void initState() {
    super.initState();
    league = widget.league;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColors.gray200,
        iconTheme: IconThemeData(color: appColors.gray1100),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Sizes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.radiusMd),
                child: ViewOnlyNetworkImage(
                  imageUrl: league.banner_url,
                  fit: BoxFit.cover,
                  enableViewImageFull: true,
                ),
              ),
            ),
            const SizedBox(height: Sizes.spaceMd),
            Text(
              league.league_title,
              style: const TextStyle(
                fontSize: Sizes.fontSizeLg,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 5,
              overflow: TextOverflow.fade,
            ),
            const SizedBox(height: Sizes.spaceSm),
            Divider(thickness: 0.5, color: appColors.gray600),
            const Text(
              "Description",
              style: TextStyle(
                fontSize: Sizes.fontSizeMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            MarkdownBody(
              data: league.league_description.orNoData(),
              styleSheet: _markdownStyleSheet(context),
            ),
            const SizedBox(height: Sizes.spaceSm),
            const Text(
              "Rules",
              style: TextStyle(
                fontSize: Sizes.fontSizeMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            MarkdownBody(
              data: league.league_rules.orNoData(),
              styleSheet: _markdownStyleSheet(context),
            ),
            const SizedBox(height: Sizes.spaceLg),
            const Text(
              "Categories",
              style: TextStyle(
                fontSize: Sizes.fontSizeMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            ...league.categories.map((category) {
              return _buildCategoriesCard(category);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Container _buildCategoriesCard(LeagueCategoryModel category) {
    final appColors = context.appColors;
    final fee = category.entrance_fee_amount;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Sizes.spaceSm),
      decoration: BoxDecoration(
        color: appColors.gray100,
        borderRadius: BorderRadius.circular(Sizes.radiusMd),
        border: BoxBorder.all(
          width: Sizes.borderWidthSm,
          color: appColors.gray600,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.category_name,
              style: const TextStyle(
                fontSize: Sizes.fontSizeLg,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 20,
              overflow: TextOverflow.fade,
            ),
            Divider(thickness: 0.5, color: appColors.gray600),

            // Markdown display for Format
            const Text(
              "Format:",
              style: TextStyle(
                fontSize: Sizes.fontSizeSm,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            MarkdownBody(
              data: category.category_format.orNoData(),
              styleSheet: _markdownStyleSheet(context),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                if (fee == 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "FREE",
                      style: TextStyle(
                        color: appColors.gray100,
                        fontWeight: FontWeight.bold,
                        fontSize: Sizes.fontSizeSm,
                      ),
                    ),
                  )
                else
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "Entrance Fee: ",
                          style: TextStyle(
                            fontSize: Sizes.fontSizeSm,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "₱${fee.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: Sizes.fontSizeSm,
                            fontWeight: FontWeight.w500,
                            color: appColors.accent900,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                AppButton(
                  onPressed: () => _handleGotoTeams(category),
                  label: isJoining ? "Joining...": "Join",
                  size: ButtonSize.sm,
                  isDisabled: isJoining,
                ),
              ],
            ),
            const SizedBox(height: Sizes.spaceXs),
            Text(
              "Make sure your team is eligible and matches this category's requirements.",
              style: TextStyle(
                fontSize: Sizes.fontSizeXs,
                color: appColors.gray900,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _markdownStyleSheet(BuildContext context) {
    final appColors = context.appColors;

    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: TextStyle(
        fontSize: Sizes.fontSizeSm,
        fontWeight: FontWeight.w500,
        color: appColors.gray900,
      ),
      blockSpacing: 4,
    );
  }

  void _handleGotoTeams(LeagueCategoryModel c) {
    setState(() => isJoining = true);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamCreatorTeamListScreen(
          selectable: true,
          onDoubleTapSelectedTeam: (t) => _onDoubleTapSelectedTeam(t, c),
        ),
      ),
    );
  }

  Future<void> _onDoubleTapSelectedTeam(
    TeamModel t,
    LeagueCategoryModel c,
  ) async {
      Navigator.pop(context, t);
    try {
      final response = await LeagueServices.joinTeam(
        league_id: league.league_id,
        team_id: t.team_id,
        category_id: c.category_id,
      );
      if (mounted) {
        showAppSnackbar(
          context,
          message: response.message,
          title: "Success",
          variant: SnackbarVariant.success,
        );
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
      setState(() => isJoining = false);
    }
  }
}

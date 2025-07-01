import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/extensions/extensions.dart';
import 'package:bogoballers/core/models/league_model.dart';
import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/service_locator.dart';
import 'package:bogoballers/core/services/team_service.dart';
import 'package:bogoballers/core/state/app_state.dart';
import 'package:bogoballers/core/state/team_provider.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/widgets/snackbars.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

enum Loading { joinTeam, isFetchingTeams, none }

class JoinLeagueScreen extends StatefulWidget {
  const JoinLeagueScreen({required this.league, super.key});
  final LeagueModel league;

  @override
  State<JoinLeagueScreen> createState() => _JoinLeagueScreenState();
}

class _JoinLeagueScreenState extends State<JoinLeagueScreen> {
  late LeagueModel league;
  final List<Map<String, dynamic>> teams = [];

  Loading loading = Loading.none;

  @override
  void initState() {
    super.initState();
    league = widget.league;
    getTeams();
  }

  Future<void> getTeams() async {
    try {
      final user_id = getIt<AppState>().user_id;
      if (user_id == null) throw EntityNotFound(AccountTypeEnum.SYSTEM);

      final fetchedTeams = await TeamService.fetchTeamForLeagueToJoin(
        league_id: league.league_id,
        user_id: user_id,
      );

      if (mounted) {
        setState(() {
          teams
            ..clear()
            ..addAll(fetchedTeams);
        });
      }
    } on EntityNotFound catch (e) {
      if (context.mounted) {
        showAppSnackbar(
          context,
          message: e.toString(),
          title: "Error",
          variant: SnackbarVariant.error,
        );

        Navigator.pushReplacementNamed(context, '/client/login/sreen');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColors.gray200,
        flexibleSpace: Container(color: appColors.gray200),
        iconTheme: IconThemeData(color: appColors.gray1100),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 0,
          right: Sizes.spaceMd,
          left: Sizes.spaceMd,
          bottom: Sizes.spaceMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: ViewOnlyNetworkImage(
                        imageUrl:
                            league.league_administrator.organization_logo_url,
                        fit: BoxFit.cover,
                        enableViewImageFull: true,
                      ),
                    ),
                  ),
                  SizedBox(width: Sizes.spaceSm),
                  Text(
                    league.league_administrator.organization_name,
                    style: TextStyle(
                      fontSize: Sizes.fontSizeSm,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
            ),
            Divider(thickness: 0.5, color: appColors.gray600),
            const SizedBox(height: Sizes.spaceMd),
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
            Text(
              league.league_description.orNoData(),
              style: const TextStyle(fontSize: Sizes.fontSizeSm),
              maxLines: 10,
              textAlign: TextAlign.justify,
              overflow: TextOverflow.fade,
            ),
            const SizedBox(height: Sizes.spaceSm),
            const Text(
              "Rules",
              style: TextStyle(
                fontSize: Sizes.fontSizeMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              league.league_rules.orNoData(),
              style: const TextStyle(fontSize: Sizes.fontSizeSm),
              maxLines: 10,
              textAlign: TextAlign.justify,
              overflow: TextOverflow.fade,
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
            const SizedBox(height: Sizes.spaceSm),
            const Text(
              "Championship Trophies",
              style: TextStyle(
                fontSize: Sizes.fontSizeMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Sizes.spaceSm),
            _buildTropyCarouselSlider(),
            const SizedBox(height: Sizes.spaceSm),
            const Text(
              "Sponsors",
              style: TextStyle(
                fontSize: Sizes.fontSizeMd,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              league.sponsors.orNoData(),
              style: const TextStyle(fontSize: Sizes.fontSizeSm),
              maxLines: 10,
              overflow: TextOverflow.fade,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTropyCarouselSlider() {
    final appColors = context.appColors;
    return Container(
      padding: EdgeInsets.symmetric(vertical: Sizes.spaceMd),
      decoration: BoxDecoration(
        color: appColors.gray100,
        borderRadius: BorderRadius.circular(Sizes.radiusMd),
        border: BoxBorder.all(
          width: Sizes.borderWidthSm,
          color: appColors.gray600,
        ),
      ),
      child: CarouselSlider.builder(
        itemCount: league.championship_trophies.length,
        options: CarouselOptions(
          height: 150,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.5,
          padEnds: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
        ),
        itemBuilder: (context, index, realIndex) {
          final trophy = league.championship_trophies[index];
          return AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.radiusMd),
              child: ViewOnlyNetworkImage(
                imageUrl: trophy.image_url,
                fit: BoxFit.cover,
                enableViewImageFull: true,
              ),
            ),
          );
        },
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

            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "Format: ",
                    style: TextStyle(
                      fontSize: Sizes.fontSizeSm,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: category.category_format,
                    style: TextStyle(
                      fontSize: Sizes.fontSizeSm,
                      fontWeight: FontWeight.w500,
                      color: appColors.gray900,
                    ),
                  ),
                ],
              ),
              maxLines: 50,
              overflow: TextOverflow.fade,
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
                            color: Colors.black, // base color
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
                    maxLines: 5,
                    overflow: TextOverflow.fade,
                  ),

                const Spacer(),

                AppButton(
                  onPressed: () => _handleShowBottomSheets(
                    category_id: category.category_id,
                  ),
                  label: "Join",
                  size: ButtonSize.sm,
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

  Future<void> _handleShowBottomSheets({required String category_id}) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Sizes.radiusLg),
        ),
      ),
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        return SizedBox(
          height: screenHeight * 0.6,
          child: DraggableScrollableSheet(
            expand: true,
            initialChildSize: 1.0,
            minChildSize: 1.0,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Select Team',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      ...((teams.isEmpty)
                          ? List.generate(
                              teams.length,
                              (_) => buildTeamShimmer(),
                            )
                          : teams.map((t) {
                              return _buildToJoinTeamCard(
                                team: t,
                                category_id: category_id,
                              );
                            }).toList()),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildTeamShimmer() {
    final appColors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: appColors.gray300,
        highlightColor: appColors.gray100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: appColors.gray100,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: Sizes.spaceSm),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: appColors.gray100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: appColors.gray100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToJoinTeamCard({
    required String category_id,
    required Map<String, dynamic> team,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              width: 50,
              height: 50,
              child: ViewOnlyNetworkImage(
                imageUrl: team['team_logo_url'] ?? null,
              ),
            ),
          ),
          SizedBox(width: Sizes.spaceSm),
          Expanded(
            child: Text(
              team['team_name'].toString().orNoData(),
              style: TextStyle(
                fontSize: Sizes.fontSizeSm,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.fade,
            ),
          ),
          AppButton(
            label: team['team_name'] == true ? 'Already in' : 'Select',
            onPressed: () => _handleJoinLeagueByCategory(
              category_id: category_id,
              team_id: team['team_id'],
            ),
            size: ButtonSize.xs,
            isDisabled: team['team_name'] == true,
          ),
        ],
      ),
    );
  }

  Future<void> _handleJoinLeagueByCategory({
    required String team_id,
    required String category_id,
  }) async {
    try {
      await Future.delayed(Duration(seconds: 5));
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
      if (context.mounted) {}
    }
  }
}

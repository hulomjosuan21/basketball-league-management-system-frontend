import 'package:bogoballers/client/screens/client_join_league_screen.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/extensions/extensions.dart';
import 'package:bogoballers/core/models/league_model.dart';
import 'package:bogoballers/core/providers/league_providers.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class LeagueCarousel extends ConsumerWidget {
  const LeagueCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLeagues = ref.watch(leagueCarouselProvider);

    return asyncLeagues.when(
      loading: () => _buildLeagueCarouselSkeleton(context),
      error: (e, _) => _buildLeagueError(context, "Failed to load leagues."),
      data: (leagues) {
        if (leagues == null || leagues.isEmpty) {
          return _buildLeagueError(context, "No leagues found.");
        }
        return _buildLeagueCarousel(context, leagues);
      },
    );
  }

  Widget _buildLeagueCarousel(
    BuildContext context,
    List<LeagueModel> leagues,
  ) {
    final appColors = context.appColors;

    return CarouselSlider.builder(
      itemCount: leagues.length,
      itemBuilder: (context, index, realIdx) {
        final league = leagues[index];
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JoinLeagueMetaScreen(league: league),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.radiusMd),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ViewOnlyNetworkImage(
                      imageUrl: league.banner_url,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(color: Colors.black.withAlpha(30)),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            league.league_title.orNoData(),
                            style: TextStyle(
                              color: appColors.gray100,
                              fontSize: Sizes.fontSizeSm,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppButton(
                          label: 'Join now',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  JoinLeagueMetaScreen(league: league),
                            ),
                          ),
                          size: ButtonSize.xs,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 200,
        viewportFraction: 0.85,
        enableInfiniteScroll: false,
        enlargeCenterPage: true,
        scrollPhysics: const BouncingScrollPhysics(),
      ),
    );
  }

  Widget _buildLeagueCarouselSkeleton(BuildContext context) {
    final appColors = context.appColors;

    return CarouselSlider.builder(
      itemCount: 3,
      itemBuilder: (_, __, ___) => AspectRatio(
        aspectRatio: 16 / 9,
        child: Shimmer.fromColors(
          baseColor: appColors.gray300,
          highlightColor: appColors.gray100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Sizes.radiusMd),
            child: Container(color: Colors.grey.shade300),
          ),
        ),
      ),
      options: CarouselOptions(
        height: 200,
        viewportFraction: 0.85,
        enlargeCenterPage: true,
        scrollPhysics: const NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget _buildLeagueError(BuildContext context, String message) {
    final appColors = context.appColors;

    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: appColors.gray500, size: 28),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: appColors.gray700,
                fontSize: Sizes.fontSizeSm,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

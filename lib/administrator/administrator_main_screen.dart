import 'package:bogoballers/administrator/screen/administrator_analytics_screen.dart';
import 'package:bogoballers/administrator/screen/administrator_player_screen.dart';
import 'package:bogoballers/administrator/screen/administrator_team_screen.dart';
import 'package:bogoballers/administrator/screen/administrator_trophies_screen.dart';
import 'package:bogoballers/administrator/screen/bracket_structure_content.dart';
import 'package:bogoballers/administrator/screen/dashboard.dart';
import 'package:bogoballers/administrator/screen/league_content/league_content.dart';
import 'package:bogoballers/administrator/widgets/header.dart';
import 'package:bogoballers/administrator/widgets/sidebar.dart';
import 'package:bogoballers/core/constants/custom_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdministratorScreenNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final contents = [
    const AdministratorDashboard(),
    const AdministratorAnalytics(),
    AdministratorTrophiesScreen(),
    AdministratorTeamScreen(),
    AdministratorPlayerScreen(),
    LeagueContent(),
    const Center(child: Text('Account Page')),
  ];
}

class LeagueAdministratorMainScreen extends StatelessWidget {
  const LeagueAdministratorMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.put(AdministratorScreenNavigationController());
    final RxBool isCollapsed = false.obs;

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final screenWidth = MediaQuery.of(context).size.width;
          final bool smallScreen = screenWidth < 600;
          isCollapsed.value = smallScreen ? true : isCollapsed.value;

          final sidebarItems = [
            SidebarItem(
              label: 'Dashboard',
              icon: Icons.dashboard,
              selected: navController.selectedIndex.value == 0,
              onTap: () => navController.selectedIndex.value = 0,
            ),
            SidebarItem(
              label: 'Analytics',
              icon: Icons.analytics,
              selected: navController.selectedIndex.value == 1,
              onTap: () => navController.selectedIndex.value = 1,
            ),
            SidebarItem(
              label: 'Trophies',
              icon: Icons.emoji_events,
              selected: navController.selectedIndex.value == 2,
              onTap: () => navController.selectedIndex.value = 2,
            ),
            SidebarItem(
              label: 'Teams',
              icon: CustomIcon.basketballTeam,
              selected: navController.selectedIndex.value == 3,
              onTap: () => navController.selectedIndex.value = 3,
            ),
            SidebarItem(
              label: 'Players',
              icon: Icons.person,
              selected: navController.selectedIndex.value == 4,
              onTap: () => navController.selectedIndex.value = 4,
            ),
            SidebarItem(
              label: 'League',
              icon: CustomIcon.leauge,
              selected: navController.selectedIndex.value == 5,
              onTap: () => navController.selectedIndex.value = 5,
              subMenu: [
                SubMenuItem(
                  label: 'Bracket Structure',
                  selected: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BracketStructureContent(),
                    ),
                  ),
                ),
                SubMenuItem(
                  label: 'More',
                  selected: false,
                  onTap: () => navController.selectedIndex.value = 0,
                ),
              ],
            ),
          ];

          return Row(
            children: [
              AppSidebar(
                sidebarItems: sidebarItems,
                sidebarFooterItems: [],
                isCollapsed: isCollapsed.value,
              ),
              Expanded(
                child: Column(
                  children: [
                    AppHeader(
                      isCollapsed: isCollapsed.value,
                      onToggleSidebar: () =>
                          isCollapsed.value = !isCollapsed.value,
                    ),
                    Expanded(
                      child: Obx(
                        () => navController
                            .contents[navController.selectedIndex.value],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

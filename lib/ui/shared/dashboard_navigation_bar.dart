import 'package:chronolapse/ui/pages/dashboard_page/dashboard_page.dart';
import 'package:chronolapse/ui/pages/settings_page.dart';
import 'package:chronolapse/ui/shared/instant_page_route.dart';
import 'package:chronolapse/util/shared_keys.dart';
import 'package:flutter/material.dart';

import '../pages/dashboard_page/dashboard_icons.dart';

/// Navigation bar for the dashboard
class DashboardNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const DashboardNavigationBar(this.selectedIndex, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40)),
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(35),
        //   topRight: Radius.circular(35)
        // ),
        // boxShadow: [BoxShadow(color: Colors.grey.shade600, blurRadius: 1)]
      ),
      child: NavigationBar(
          shadowColor: Theme.of(context).colorScheme.onInverseSurface,
          height: 60,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          selectedIndex: selectedIndex,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => const DashboardPage()));
                break;

              case 1:
                Navigator.of(context).pushReplacement(InstantPageRoute(
                    builder: (context) => const SettingsPage(null)));
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                DashboardPageIcons.projects,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              label: "Projects",
            ),
            NavigationDestination(
              icon: Icon(
                DashboardPageIcons.settings,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
              label: "Settings",
              key: dashboardNavigationSettingsKey,
            )
          ]),
    );
  }
}

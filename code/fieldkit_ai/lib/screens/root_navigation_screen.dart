import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'reports_list_screen.dart';
import 'data_collection_screen.dart';
import 'live_support_screen.dart';

class RootNavigationScreen extends StatefulWidget {
  const RootNavigationScreen({super.key});

  @override
  State<RootNavigationScreen> createState() => _RootNavigationScreenState();
}

class _RootNavigationScreenState extends State<RootNavigationScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: context.read<AppProvider>().currentTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    bool isDesktop = MediaQuery.of(context).size.width >= 800;

    if (_pageController.hasClients && _pageController.page?.round() != provider.currentTabIndex) {
      _pageController.jumpToPage(provider.currentTabIndex);
    }

    final pages = const [DataCollectionScreen(), ReportsListScreen(), LiveSupportScreen()];

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            NavigationRail(
              backgroundColor: AppTheme.sidebarBg,
              indicatorColor: AppTheme.primary,
              selectedIndex: provider.currentTabIndex,
              onDestinationSelected: (index) => context.read<AppProvider>().setTab(index),
              unselectedIconTheme: const IconThemeData(color: Colors.white54, opacity: 1),
              selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
              selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              extended: true,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('lib/assets/icons/logo.png', width: 36, height: 36, errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, color: AppTheme.primary, size: 32)),
                    const SizedBox(width: 12),
                    Text('FieldKit AI', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 22)),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.camera_alt_outlined), selectedIcon: Icon(Icons.camera_alt), label: Text('Ispezione')),
                NavigationRailDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder_shared), label: Text('Archivio')),
                NavigationRailDestination(icon: Icon(Icons.headset_mic_outlined), selectedIcon: Icon(Icons.headset_mic), label: Text('Live')),
              ],
            ),
          
          Expanded(
            child: PageView(
              controller: _pageController, 
              physics: const NeverScrollableScrollPhysics(), 
              children: pages
            )
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : BottomNavigationBar(
        currentIndex: provider.currentTabIndex,
        onTap: (index) => context.read<AppProvider>().setTab(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Ispezione'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_shared), label: 'Archivio'),
          BottomNavigationBarItem(icon: Icon(Icons.headset_mic), label: 'Live'),
        ],
      ),
    );
  }
}
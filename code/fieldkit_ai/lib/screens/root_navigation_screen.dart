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
            // SIDEBAR NATIVA - Zero padding fissi strani, tutto calcolato sulla stessa griglia
            Container(
              width: 250,
              color: AppTheme.sidebarBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  
                  // HEADER (Stessa esatta struttura dei menu item)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Image.asset(
                          'lib/assets/icons/logo.png', 
                          width: 26, 
                          height: 26, 
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, color: AppTheme.primary, size: 26)
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'FieldKit AI', 
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 18)
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // VOCI DI MENU
                  _buildMenuItem(context, provider, Icons.camera_alt, 'Ispezione', 0),
                  _buildMenuItem(context, provider, Icons.folder_shared, 'Archivio', 1),
                  _buildMenuItem(context, provider, Icons.headset_mic, 'Live', 2),
                ],
              ),
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
        selectedItemColor: AppTheme.primary,
        selectedLabelStyle: TextStyle(fontSize: AppTheme.bodySize(context)),
        unselectedLabelStyle: TextStyle(fontSize: AppTheme.bodySize(context)),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Ispezione'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_shared), label: 'Archivio'),
          BottomNavigationBarItem(icon: Icon(Icons.headset_mic), label: 'Live'),
        ],
      ),
    );
  }

  // Costruttore delle singole voci di menu. Identico al blocco dell'header!
  Widget _buildMenuItem(BuildContext context, AppProvider provider, IconData icon, String label, int index) {
    bool isSelected = provider.currentTabIndex == index;
    
    return Padding(
      // 12px fuori + 12px dentro = 24px di distanza dal bordo sinistro, esattamente come l'header in alto!
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Material(
        color: isSelected ? AppTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => provider.setTab(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 26), // 26px come il logo
                const SizedBox(width: 16), // 16px come lo spazio dell'header
                Text(
                  label, 
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
                    fontSize: AppTheme.bodySize(context)
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
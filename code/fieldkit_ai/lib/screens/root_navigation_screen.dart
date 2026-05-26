import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
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
    int initialPage = context.read<AppProvider>().currentTabIndex;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (_pageController.hasClients && _pageController.page?.round() != provider.currentTabIndex) {
      _pageController.animateToPage(
        provider.currentTabIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => context.read<AppProvider>().setTab(index),
        children: const [
          DataCollectionScreen(), // Tab 0
          ReportsListScreen(),   // Tab 1 
          LiveSupportScreen(),   // Tab 2
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: provider.currentTabIndex,
        onTap: (index) => context.read<AppProvider>().setTab(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Ispeziona'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_shared), label: 'Archivio'),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Live'),
        ],
      ),
    );
  }
}
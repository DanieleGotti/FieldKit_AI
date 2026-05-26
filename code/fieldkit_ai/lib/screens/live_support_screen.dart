import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LiveSupportScreen extends StatelessWidget {
  const LiveSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cameraBackground,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.document_scanner, color: AppTheme.textWhite.withOpacity(0.5), size: 100),
                const SizedBox(height: 16),
                const Text('', style: TextStyle(color: AppTheme.textWhite)),
              ],
            ),
          ),
          Positioned(
            top: 60, right: 20,
            child: Container(
              width: 100, height: 150,
              decoration: BoxDecoration(
                color: AppTheme.textDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.textWhite, width: 2),
              ),
              child: const Center(child: Icon(Icons.person, color: AppTheme.textWhite, size: 50)),
            ),
          ),
          Positioned(
            top: 60, left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.error, borderRadius: BorderRadius.circular(20)),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: AppTheme.textWhite, size: 12),
                  SizedBox(width: 8),
                  Text('LIVE 02:45', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _callBtn(Icons.mic, AppTheme.textDark),
                _callBtn(Icons.call_end, AppTheme.error, size: 64),
                _callBtn(Icons.flip_camera_ios, AppTheme.textDark),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _callBtn(IconData icon, Color color, {double size = 48}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: AppTheme.textWhite, size: size * 0.5),
    );
  }
}
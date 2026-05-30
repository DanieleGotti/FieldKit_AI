import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LiveSupportScreen extends StatelessWidget {
  const LiveSupportScreen({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funzionalità in fase di sviluppo. Disponibile a breve!'),
        backgroundColor: AppTheme.textDark,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(title: const Text('Live', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000), 
          padding: const EdgeInsets.all(24.0),
          child: GestureDetector(
            onTap: () => _showComingSoon(context),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Supporto tecnico remoto', style: TextStyle(fontWeight: FontWeight.w800, fontSize: isDesktop ? 20 : 16, color: AppTheme.textDark)),
                    const SizedBox(height: 8),
                    Text('Inquadra l\'impianto. Un tecnico ti guiderà in tempo reale.', style: TextStyle(color: AppTheme.textLight, fontSize: isDesktop ? 16 : 14, height: 1.5)),
                    const SizedBox(height: 32),
                    
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration( 
                          color: AppTheme.cameraBackground,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.videocam_off, color: Colors.white.withOpacity(0.3), size: 80),
                                  const SizedBox(height: 16),
                                  Text('Telecamera in avvio...', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 24, right: 24,
                              child: Container(
                                width: 120, height: 160,
                                decoration: BoxDecoration(
                                  color: AppTheme.sidebarBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                                ),
                                child: const Center(child: Icon(Icons.person, color: Colors.white, size: 60)),
                              ),
                            ),
                            Positioned(
                              top: 24, left: 24,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(color: AppTheme.error, borderRadius: BorderRadius.circular(30)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle, color: Colors.white, size: 10),
                                    SizedBox(width: 8),
                                    Text('LIVE 02:45', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 32, left: 0, right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildControlBtn(Icons.mic_off, Colors.white.withOpacity(0.2), Colors.white),
                                      const SizedBox(width: 24),
                                      _buildControlBtn(Icons.call_end, AppTheme.error, Colors.white, size: 64),
                                      const SizedBox(width: 24),
                                      _buildControlBtn(Icons.flip_camera_ios, Colors.white.withOpacity(0.2), Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn(IconData icon, Color bgColor, Color iconColor, {double size = 50}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: size * 0.5),
    );
  }
}
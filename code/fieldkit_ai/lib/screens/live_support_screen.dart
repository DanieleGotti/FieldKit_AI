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
    // CALCOLO DINAMICO ASSOLUTO PER EVITARE SOVRAPPOSIZIONI
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    bool isMobile = screenWidth < 600 || screenHeight < 600;

    // Dimensioni calcolate
    double expertBoxWidth = isMobile ? 70 : 120;
    double expertBoxHeight = isMobile ? 90 : 160;
    double iconCenterSize = isMobile ? 40 : 80;
    double callButtonSize = isMobile ? 45 : 64;
    double sideButtonSize = isMobile ? 35 : 50;

    return Scaffold(
      appBar: AppBar(title: Text('Live', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppTheme.titleSize(context)))),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000), 
          padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
          child: GestureDetector(
            onTap: () => _showComingSoon(context),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Supporto tecnico remoto', style: TextStyle(fontWeight: FontWeight.w800, fontSize: AppTheme.titleSize(context), color: AppTheme.textDark)),
                    const SizedBox(height: 4),
                    Text('Inquadra l\'impianto. Un tecnico ti guiderà in tempo reale.', style: TextStyle(color: AppTheme.textLight, fontSize: AppTheme.bodySize(context), height: 1.5)),
                    SizedBox(height: isMobile ? 12 : 32),
                    
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration( 
                          color: AppTheme.cameraBackground,
                          borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                        ),
                        child: Stack(
                          children: [
                            // CENTRO DELLA FOTOCAMERA
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.videocam_off, color: Colors.white.withOpacity(0.3), size: iconCenterSize),
                                  const SizedBox(height: 12),
                                  Text('Telecamera in avvio...', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: AppTheme.bodySize(context))),
                                ],
                              ),
                            ),
                            // RIQUADRO ESPERTO (Piccolissimo su mobile)
                            Positioned(
                              top: 16, right: 16,
                              child: Container(
                                width: expertBoxWidth, 
                                height: expertBoxHeight,
                                decoration: BoxDecoration(
                                  color: AppTheme.sidebarBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                                ),
                                child: Center(child: Icon(Icons.person, color: Colors.white, size: expertBoxWidth * 0.4)),
                              ),
                            ),
                            // BADGE LIVE
                            Positioned(
                              top: 16, left: 16,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 6 : 8),
                                decoration: BoxDecoration(color: AppTheme.error, borderRadius: BorderRadius.circular(30)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle, color: Colors.white, size: isMobile ? 8 : 10),
                                    const SizedBox(width: 8),
                                    Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: AppTheme.smallSize(context))),
                                  ],
                                ),
                              ),
                            ),
                            // BOTTONI CHIAMATA IN BASSO
                            Positioned(
                              bottom: 16, left: 0, right: 0,
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 8 : 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildControlBtn(Icons.mic_off, Colors.white.withOpacity(0.2), Colors.white, size: sideButtonSize),
                                      SizedBox(width: isMobile ? 16 : 24),
                                      _buildControlBtn(Icons.call_end, AppTheme.error, Colors.white, size: callButtonSize),
                                      SizedBox(width: isMobile ? 16 : 24),
                                      _buildControlBtn(Icons.flip_camera_ios, Colors.white.withOpacity(0.2), Colors.white, size: sideButtonSize),
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
      child: Icon(icon, color: iconColor, size: size * 0.45),
    );
  }
}
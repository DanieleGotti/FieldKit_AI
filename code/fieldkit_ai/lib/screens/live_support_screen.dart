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
    // Rileva se stiamo usando il cellulare in orizzontale o se c'è poca altezza
    bool isShortScreen = MediaQuery.of(context).size.height < 600; 

    return Scaffold(
      appBar: AppBar(title: Text('Live', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppTheme.titleSize(context)))),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000), 
          // Riduciamo il padding generale su cellulare
          padding: EdgeInsets.all(isShortScreen ? 12.0 : 24.0),
          child: GestureDetector(
            onTap: () => _showComingSoon(context),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Supporto tecnico remoto', style: TextStyle(fontWeight: FontWeight.w800, fontSize: AppTheme.titleSize(context), color: AppTheme.textDark)),
                    const SizedBox(height: 4),
                    Text('Inquadra l\'impianto. Un tecnico ti guiderà in tempo reale.', style: TextStyle(color: AppTheme.textLight, fontSize: AppTheme.bodySize(context), height: 1.5)),
                    SizedBox(height: isShortScreen ? 12 : 32), // Meno spazio se lo schermo è basso
                    
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration( 
                          color: AppTheme.cameraBackground,
                          borderRadius: BorderRadius.circular(isShortScreen ? 16 : 24),
                        ),
                        child: Stack(
                          children: [
                            // Testo centrale rimpicciolito
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.videocam_off, color: Colors.white.withOpacity(0.3), size: isDesktop ? 80 : 45),
                                  const SizedBox(height: 12),
                                  Text('Telecamera in avvio...', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: AppTheme.bodySize(context))),
                                ],
                              ),
                            ),
                            // Riquadro del tecnico (più piccolo su mobile e in orizzontale)
                            Positioned(
                              top: isShortScreen ? 12 : 24, right: isShortScreen ? 12 : 24,
                              child: Container(
                                width: isDesktop ? 120 : (isShortScreen ? 70 : 90), 
                                height: isDesktop ? 160 : (isShortScreen ? 90 : 120),
                                decoration: BoxDecoration(
                                  color: AppTheme.sidebarBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                                ),
                                child: Center(child: Icon(Icons.person, color: Colors.white, size: isDesktop ? 60 : 35)),
                              ),
                            ),
                            // Badge LIVE in alto a sinistra (ridimensionato)
                            Positioned(
                              top: isShortScreen ? 12 : 24, left: isShortScreen ? 12 : 24,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 12, vertical: isDesktop ? 8 : 6),
                                decoration: BoxDecoration(color: AppTheme.error, borderRadius: BorderRadius.circular(30)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle, color: Colors.white, size: isDesktop ? 10 : 8),
                                    const SizedBox(width: 8),
                                    Text('LIVE 02:45', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: AppTheme.smallSize(context))),
                                  ],
                                ),
                              ),
                            ),
                            // Pulsanti della chiamata in basso (rimpiccioliti e ravvicinati)
                            Positioned(
                              bottom: isShortScreen ? 12 : 32, left: 0, right: 0,
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: isDesktop ? 12 : 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildControlBtn(Icons.mic_off, Colors.white.withOpacity(0.2), Colors.white, size: isDesktop ? 50 : 40),
                                      SizedBox(width: isDesktop ? 24 : 16),
                                      _buildControlBtn(Icons.call_end, AppTheme.error, Colors.white, size: isDesktop ? 64 : 50),
                                      SizedBox(width: isDesktop ? 24 : 16),
                                      _buildControlBtn(Icons.flip_camera_ios, Colors.white.withOpacity(0.2), Colors.white, size: isDesktop ? 50 : 40),
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

  // Funzione d'appoggio aggiornata per accettare una dimensione variabile (size)
  Widget _buildControlBtn(IconData icon, Color bgColor, Color iconColor, {double size = 50}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: size * 0.5),
    );
  }
}
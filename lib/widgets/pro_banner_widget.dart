import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

class ProBannerWidget extends StatelessWidget {
  const ProBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchProApp,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.vaultRed.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppConstants.vaultRed.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.vaultRed.withOpacity(0.1),
                    AppConstants.vaultRedLight.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/images/logoPremium.png',
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Aivellum',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: AppConstants.vaultRedGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [AppConstants.premiumShadow],
                        ),
                        child: Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Unlock all prompts, ad-free forever',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppConstants.vaultRed,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchProApp() async {
    final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.khanbasharat.aivellumpro');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

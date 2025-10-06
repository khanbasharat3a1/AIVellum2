import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';

class SubscriptionStatusWidget extends StatelessWidget {
  const SubscriptionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (!provider.isUserSubscribed) return const SizedBox.shrink();

        return FutureBuilder<DateTime?>(
          future: DatabaseService.getSubscriptionEndDate(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const SizedBox.shrink();
            }

            final endDate = snapshot.data!;
            final daysLeft = endDate.difference(DateTime.now()).inDays;

            if (provider.hasLifetimeAccess) {
              return Container(
                margin: const EdgeInsets.all(AppConstants.paddingM),
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade700, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Colors.white),
                    const SizedBox(width: AppConstants.paddingS),
                    Expanded(
                      child: Text(
                        'Lifetime Access Active',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.all(AppConstants.paddingM),
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: daysLeft <= 3 ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: daysLeft <= 3 ? Colors.orange : Colors.green,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    daysLeft <= 3 ? Icons.warning_amber : Icons.check_circle,
                    color: daysLeft <= 3 ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: AppConstants.paddingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subscription Active',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          daysLeft <= 0
                              ? 'Expires today'
                              : daysLeft == 1
                                  ? 'Expires tomorrow'
                                  : 'Expires in $daysLeft days',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

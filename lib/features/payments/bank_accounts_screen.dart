import 'package:flutter/material.dart';
import '../../core/payments/bank_account_service.dart';
import '../../design_system/strot_tokens.dart';

class BankAccountsScreen extends StatelessWidget {
  const BankAccountsScreen({super.key, required this.service});
  final BankAccountService service;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<BankAccountRecord>>(
    future: service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'MANUAL PAYMENT CONTROLS',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Bank accounts',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const Text('Approved collection destinations for offline transfers.'),
          const SizedBox(height: StrotSpacing.xl),
          ...snapshot.data!.map(
            (account) => Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${account.currency} · ${account.label}',
                      style: const TextStyle(
                        color: StrotColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      account.bank,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('${account.name} · ${account.number}'),
                    const Divider(),
                    Text(account.instructions),
                    Text(
                      account.active
                          ? (account.isDefault
                                ? 'Default active account'
                                : 'Active account')
                          : 'Archived',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(StrotSpacing.lg),
              child: Text(
                'Account changes require the web control plane and recent two-factor confirmation.',
              ),
            ),
          ),
        ],
      );
    },
  );
}

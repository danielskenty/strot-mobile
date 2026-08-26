import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../design_system/strot_tokens.dart';

class LegalDocumentDefinition {
  const LegalDocumentDefinition({required this.title, required this.asset});
  final String title;
  final String asset;
}

const strotLegalDocuments = [
  LegalDocumentDefinition(
    title: 'Privacy Policy',
    asset: 'assets/legal/privacy-policy.txt',
  ),
  LegalDocumentDefinition(
    title: 'Terms of Use',
    asset: 'assets/legal/terms-of-use.txt',
  ),
  LegalDocumentDefinition(
    title: 'Data rights, account deletion and retention',
    asset: 'assets/legal/data-rights-account-deletion-retention.txt',
  ),
];

class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Legal & privacy')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          'Your rights and responsibilities',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: StrotSpacing.sm),
        const Text(
          'Approved Strot Limited policies, effective 26 August 2026.',
          style: TextStyle(color: StrotColors.charcoalMuted),
        ),
        const SizedBox(height: StrotSpacing.lg),
        ...strotLegalDocuments.map(
          (document) => Card(
            child: ListTile(
              title: Text(document.title),
              subtitle: const Text('Read the complete approved document'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LegalDocumentScreen(document: document),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: StrotSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account deletion request',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: StrotSpacing.sm),
                const Text(
                  'Contact the Privacy Team from your registered email. Never include your password or a one-time code.',
                ),
                const SizedBox(height: StrotSpacing.md),
                FilledButton(
                  onPressed: () => launchUrl(
                    Uri.parse(
                      'mailto:hello@getstrot.com?subject=Privacy%20Request%20%E2%80%94%20Account%20Deletion',
                    ),
                  ),
                  child: const Text('Email the Privacy Team'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.document});
  final LegalDocumentDefinition document;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(document.title)),
    body: FutureBuilder<String>(
      future: DefaultAssetBundle.of(context).loadString(document.asset),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(StrotSpacing.lg),
              child: Text('The approved document could not be loaded.'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          child: SelectionArea(
            child: Text(
              snapshot.data!.replaceAll('\f', '\n'),
              style: const TextStyle(
                color: StrotColors.charcoal,
                height: 1.65,
              ),
            ),
          ),
        );
      },
    ),
  );
}

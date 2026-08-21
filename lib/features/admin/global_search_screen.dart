import 'package:flutter/material.dart';
import '../../core/admin/admin_service.dart';
import '../../design_system/strot_tokens.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key, required this.service});
  final AdminService service;
  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final query = TextEditingController();
  Future<List<GlobalSearchItem>>? results;
  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Global search')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        const Text(
          'RECORD DISCOVERY',
          style: TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: StrotSpacing.md),
        Text(
          'Find the exact record',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: StrotSpacing.lg),
        TextField(
          controller: query,
          decoration: const InputDecoration(
            labelText: 'Name, reference or title',
          ),
        ),
        const SizedBox(height: StrotSpacing.md),
        FilledButton(
          onPressed: () {
            final value = query.text.trim();
            if (value.length >= 2) {
              setState(() => results = widget.service.search(value));
            }
          },
          child: const Text('Search records'),
        ),
        if (results != null)
          FutureBuilder<List<GlobalSearchItem>>(
            future: results,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(StrotSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                children: snapshot.data!
                    .map(
                      (item) => Card(
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text(
                            '${item.type} · ${item.context}\n${item.status}',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => showModalBottomSheet<void>(
                            context: context,
                            builder: (_) => Padding(
                              padding: const EdgeInsets.all(StrotSpacing.lg),
                              child: Text(
                                'Exact destination: ${item.deepLink}',
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
      ],
    ),
  );
}

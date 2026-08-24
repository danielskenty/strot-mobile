import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/consultations/consultation_models.dart';
import '../../core/consultations/consultation_service.dart';
import '../../design_system/strot_tokens.dart';

class ConsultationsScreen extends StatelessWidget {
  const ConsultationsScreen({super.key, required this.service, this.initialId});
  final ConsultationService service;
  final int? initialId;

  @override
  Widget build(BuildContext context) {
    if (initialId != null) {
      return ConsultationDetailScreen(id: initialId!, service: service);
    }
    return FutureBuilder<List<ClientConsultation>>(
      future: service.list(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('◇ ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'ADVISORY & PROJECT DISCOVERY',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Consultations',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const Text(
              'Review confirmed times, preparation details and requests awaiting STROT’s response.',
            ),
            const SizedBox(height: StrotSpacing.xl),
            if (snapshot.data!.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(StrotSpacing.lg),
                  child: Text(
                    'No consultation records are linked to this account.',
                  ),
                ),
              )
            else
              ...snapshot.data!.map(
                (item) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(StrotSpacing.md),
                    title: Text(item.service.replaceAll('_', ' ')),
                    subtitle: Text(
                      '${item.reference} · ${item.location}\n${_schedule(item)}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ConsultationDetailScreen(
                          id: item.id,
                          service: service,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static String _schedule(ClientConsultation item) => item.scheduledAt == null
      ? 'Scheduling in progress'
      : '${item.scheduledAt!.day}/${item.scheduledAt!.month}/${item.scheduledAt!.year} · ${item.scheduledAt!.hour.toString().padLeft(2, '0')}:${item.scheduledAt!.minute.toString().padLeft(2, '0')}';
}

class ConsultationDetailScreen extends StatefulWidget {
  const ConsultationDetailScreen({
    super.key,
    required this.id,
    required this.service,
  });
  final int id;
  final ConsultationService service;
  @override
  State<ConsultationDetailScreen> createState() =>
      _ConsultationDetailScreenState();
}

class _ConsultationDetailScreenState extends State<ConsultationDetailScreen> {
  late Future<ClientConsultation> future;
  @override
  void initState() {
    super.initState();
    future = widget.service.get(widget.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Consultation detail')),
    body: FutureBuilder<ClientConsultation>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('◇ ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final item = snapshot.data!;
        final actionable = [
          'requested',
          'confirmed',
          'rescheduled',
        ].contains(item.status);
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              item.reference,
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              item.service.replaceAll('_', ' '),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text('${item.propertyType} · ${item.location}'),
            const SizedBox(height: StrotSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointment',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: StrotSpacing.md),
                    Text(ConsultationsScreen._schedule(item)),
                    Text('Advisor: ${item.advisorName ?? 'To be assigned'}'),
                    Text('Status: ${item.status.replaceAll('_', ' ')}'),
                    if (item.meetingUrl != null &&
                        ['confirmed', 'rescheduled'].contains(item.status)) ...[
                      const SizedBox(height: StrotSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          key: const Key('join-consultation'),
                          onPressed: () => launchUrl(
                            Uri.parse(item.meetingUrl!),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.video_call_outlined),
                          label: const Text('Join consultation'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Text(item.brief),
              ),
            ),
            if (item.clientActionNote != null) ...[
              const SizedBox(height: StrotSpacing.md),
              Container(
                padding: const EdgeInsets.all(StrotSpacing.md),
                color: StrotColors.goldMuted,
                child: Text('Latest request: ${item.clientActionNote}'),
              ),
            ],
            if (actionable) ...[
              const SizedBox(height: StrotSpacing.lg),
              OutlinedButton(
                onPressed: () => _change(item),
                child: const Text('Change appointment'),
              ),
            ],
          ],
        );
      },
    ),
  );

  Future<void> _change(ClientConsultation item) async {
    final change = await showDialog<_ConsultationChange>(
      context: context,
      builder: (_) => const _ConsultationChangeDialog(),
    );
    if (change == null) return;
    await widget.service.act(
      id: item.id,
      action: change.action,
      note: change.note,
      preferredDate: change.preferredDate,
    );
    if (mounted) {
      setState(() {
        future = widget.service.get(widget.id);
      });
    }
  }
}

class _ConsultationChange {
  const _ConsultationChange(this.action, this.note, this.preferredDate);
  final String action, note;
  final String? preferredDate;
}

class _ConsultationChangeDialog extends StatefulWidget {
  const _ConsultationChangeDialog();
  @override
  State<_ConsultationChangeDialog> createState() =>
      _ConsultationChangeDialogState();
}

class _ConsultationChangeDialogState extends State<_ConsultationChangeDialog> {
  String action = 'request_reschedule';
  final date = TextEditingController();
  final note = TextEditingController();
  String? error;

  @override
  void dispose() {
    date.dispose();
    note.dispose();
    super.dispose();
  }

  void submit() {
    if (note.text.trim().length < 5 ||
        (action == 'request_reschedule' && date.text.trim().isEmpty)) {
      setState(() => error = 'Add the required date and a short note.');
      return;
    }
    Navigator.pop(
      context,
      _ConsultationChange(
        action,
        note.text.trim(),
        action == 'request_reschedule' ? date.text.trim() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Change appointment'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: action,
            decoration: const InputDecoration(labelText: 'Action'),
            items: const [
              DropdownMenuItem(
                value: 'request_reschedule',
                child: Text('Request reschedule'),
              ),
              DropdownMenuItem(
                value: 'cancel',
                child: Text('Cancel consultation'),
              ),
            ],
            onChanged: (value) => setState(() {
              action = value!;
              error = null;
            }),
          ),
          const SizedBox(height: StrotSpacing.md),
          if (action == 'request_reschedule')
            TextField(
              key: const Key('consultation-date'),
              controller: date,
              decoration: const InputDecoration(
                labelText: 'Preferred date',
                hintText: 'YYYY-MM-DD',
              ),
            ),
          const SizedBox(height: StrotSpacing.md),
          TextField(
            key: const Key('consultation-note'),
            controller: note,
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Note', errorText: error),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: submit, child: const Text('Send request')),
    ],
  );
}

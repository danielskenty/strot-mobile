import 'package:flutter/material.dart';
import '../../core/messages/message_models.dart';
import '../../core/messages/message_service.dart';
import '../../design_system/strot_tokens.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.service,
    required this.canManage,
  });
  final MessageService service;
  final bool canManage;
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Future<List<Conversation>> future;
  @override
  void initState() {
    super.initState();
    future = widget.service.list();
  }

  void refresh() {
    setState(() => future = widget.service.list());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _openSupport,
      icon: const Icon(Icons.add_comment_outlined),
      label: const Text('Support case'),
    ),
    body: FutureBuilder(
      future: future,
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
            Text(
              'Messages & support',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: StrotSpacing.sm),
            const Text(
              'Secure project conversations and accountable support history.',
              style: TextStyle(color: StrotColors.charcoalMuted),
            ),
            const SizedBox(height: StrotSpacing.lg),
            ...snapshot.data!.map(
              (item) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(StrotSpacing.md),
                  title: Text(item.subject),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: StrotSpacing.sm),
                    child: Text(
                      '${item.type} · ${item.status.replaceAll('_', ' ')} · ${item.createdBy.name}',
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ConversationScreen(
                          id: item.id,
                          service: widget.service,
                          canManage: widget.canManage,
                        ),
                      ),
                    );
                    refresh();
                  },
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
  Future<void> _openSupport() async {
    final subject = TextEditingController(), body = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open support case'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subject,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              const SizedBox(height: StrotSpacing.md),
              TextField(
                controller: body,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'How can STROT help?',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open case'),
          ),
        ],
      ),
    );
    if (ok == true &&
        subject.text.trim().isNotEmpty &&
        body.text.trim().isNotEmpty) {
      await widget.service.openSupport(
        subject: subject.text,
        category: 'general',
        priority: 'informational',
        body: body.text,
      );
      refresh();
    }
  }
}

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.id,
    required this.service,
    required this.canManage,
  });
  final int id;
  final MessageService service;
  final bool canManage;
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late Future<Conversation> future;
  final reply = TextEditingController();
  @override
  void initState() {
    super.initState();
    future = widget.service.get(widget.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Conversation')),
    body: FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('◇ ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final item = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              item.type.toUpperCase(),
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              item.subject,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: StrotSpacing.lg),
            ...item.messages.map(
              (message) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(StrotSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.sender.name,
                        style: const TextStyle(
                          color: StrotColors.forest,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: StrotSpacing.sm),
                      Text(message.body),
                    ],
                  ),
                ),
              ),
            ),
            if (item.status != 'closed')
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(StrotSpacing.lg),
                  child: Column(
                    children: [
                      TextField(
                        controller: reply,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Reply'),
                      ),
                      const SizedBox(height: StrotSpacing.md),
                      FilledButton(
                        onPressed: () async {
                          if (reply.text.trim().isEmpty) return;
                          await widget.service.reply(item.id, reply.text);
                          reply.clear();
                          setState(() => future = widget.service.get(item.id));
                        },
                        child: const Text('Send reply'),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.canManage && item.type == 'support')
              Padding(
                padding: const EdgeInsets.only(top: StrotSpacing.md),
                child: OutlinedButton(
                  onPressed: () async {
                    await widget.service.updateStatus(item.id, 'resolved');
                    setState(() => future = widget.service.get(item.id));
                  },
                  child: const Text('Mark resolved'),
                ),
              ),
          ],
        );
      },
    ),
  );
}

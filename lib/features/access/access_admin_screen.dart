import 'package:flutter/material.dart';
import '../../core/access/access_models.dart';
import '../../core/access/access_service.dart';
import '../../design_system/strot_tokens.dart';

class AccessAdminScreen extends StatefulWidget {
  const AccessAdminScreen({super.key, required this.service});
  final AccessService service;
  @override
  State<AccessAdminScreen> createState() => _AccessAdminScreenState();
}

class _AccessAdminScreenState extends State<AccessAdminScreen> {
  late Future<AccessCentre> future = widget.service.load();
  void reload() => setState(() => future = widget.service.load());
  @override
  Widget build(BuildContext context) => FutureBuilder<AccessCentre>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(
          child: Text(
            'Access records could not be loaded.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }
      final data = snapshot.requireData;
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          Text(
            'IDENTITY GOVERNANCE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: StrotColors.gold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.sm),
          Text('Team access', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: StrotSpacing.sm),
          Text(
            'Monitor secure invitations and active organization memberships. New invitations are issued from the web control plane.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: StrotSpacing.xl),
          _Heading(
            title: 'Pending invitations',
            count: data.invitations
                .where((item) => item.status == 'pending')
                .length,
          ),
          ...data.invitations.map(
            (item) => _InvitationCard(
              item: item,
              onRevoke: () async {
                await widget.service.revokeInvitation(item.id);
                reload();
              },
            ),
          ),
          const SizedBox(height: StrotSpacing.xl),
          _Heading(title: 'Active memberships', count: data.memberships.length),
          ...data.memberships.map(
            (item) => _MembershipCard(
              item: item,
              onRevoke: () async {
                await widget.service.revokeMembership(item);
                reload();
              },
            ),
          ),
        ],
      );
    },
  );
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, required this.count});
  final String title;
  final int count;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: StrotSpacing.md),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: StrotColors.goldMuted),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: StrotSpacing.sm,
            vertical: StrotSpacing.xs,
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: StrotColors.forest,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.item, required this.onRevoke});
  final AccessInvitation item;
  final VoidCallback onRevoke;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: StrotSpacing.sm),
    padding: const EdgeInsets.all(StrotSpacing.md),
    decoration: BoxDecoration(
      border: Border.all(color: StrotColors.forestMuted),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.email,
                style: const TextStyle(
                  color: StrotColors.forest,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: StrotSpacing.xs),
              Text(
                '${item.organization} · ${item.role}\nExpires ${item.expiresAt.day}/${item.expiresAt.month}/${item.expiresAt.year}',
              ),
            ],
          ),
        ),
        TextButton(onPressed: onRevoke, child: const Text('Revoke')),
      ],
    ),
  );
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.item, required this.onRevoke});
  final AccessMembership item;
  final VoidCallback onRevoke;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: StrotSpacing.sm),
    padding: const EdgeInsets.all(StrotSpacing.md),
    decoration: BoxDecoration(
      border: Border.all(color: StrotColors.forestMuted),
    ),
    child: Row(
      children: [
        const Icon(Icons.person_outline, color: StrotColors.gold),
        const SizedBox(width: StrotSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  color: StrotColors.forest,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(item.email),
              Text(
                '${item.organization} · ${item.role}',
                style: const TextStyle(color: StrotColors.gold),
              ),
            ],
          ),
        ),
        TextButton(onPressed: onRevoke, child: const Text('Remove')),
      ],
    ),
  );
}

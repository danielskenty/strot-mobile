import 'package:flutter/material.dart';
import '../../core/property_care/property_care_service.dart';
import '../../core/property_assets/property_asset_service.dart';
import '../../core/care_plans/care_plan_service.dart';
import '../../core/properties/property_service.dart';
import '../../design_system/strot_tokens.dart';
import '../property_assets/property_assets_screen.dart';
import '../care_plans/care_plans_screen.dart';
import '../properties/properties_screen.dart';

class PropertyCareScreen extends StatelessWidget {
  const PropertyCareScreen({
    super.key,
    required this.service,
    required this.canRequest,
    required this.assetService,
    required this.planService,
    required this.propertyService,
    this.canWork = false,
  });
  final PropertyCareService service;
  final PropertyAssetService assetService;
  final CarePlanService planService;
  final PropertyService propertyService;
  final bool canRequest;
  final bool canWork;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<CareProperty>>(
    future: service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'PROPERTY CONTINUITY',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Property care',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const Text('Planned servicing and accountable maintenance.'),
          const SizedBox(height: StrotSpacing.xl),
          FilledButton.icon(
            icon: const Icon(Icons.apartment_outlined),
            label: const Text('Open property portfolio'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PropertiesScreen(service: propertyService),
              ),
            ),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Open asset register'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PropertyAssetsScreen(service: assetService),
              ),
            ),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('View care plans'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => CarePlansScreen(service: planService),
              ),
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          ...snapshot.data!.map(
            (property) => Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(property.location),
                    const Divider(),
                    ...property.requests.map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.reference} · ${item.priority}\n${item.description}',
                        ),
                        isThreeLine: true,
                        trailing: Text(item.status.replaceAll('_', ' ')),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => CareRequestScreen(
                              item: item,
                              service: service,
                              canWork: canWork,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (canRequest)
            const Padding(
              padding: EdgeInsets.only(top: StrotSpacing.md),
              child: Text(
                'New maintenance requests can be submitted from the STROT web portal.',
              ),
            ),
        ],
      );
    },
  );
}

class CareRequestScreen extends StatefulWidget {
  const CareRequestScreen({
    super.key,
    required this.item,
    required this.service,
    required this.canWork,
  });
  final CareRequest item;
  final PropertyCareService service;
  final bool canWork;
  @override
  State<CareRequestScreen> createState() => _CareRequestScreenState();
}

class _CareRequestScreenState extends State<CareRequestScreen> {
  late final List<bool> checks = widget.item.visits.isEmpty
      ? []
      : widget.item.visits.first.checklist
            .map((item) => item.complete)
            .toList();
  bool saving = false;

  Future<void> _update(String action) async {
    setState(() => saving = true);
    try {
      final visit = widget.item.visits.first;
      await widget.service.updateVisit(
        visitId: visit.id,
        action: action,
        checklist: action == 'complete'
            ? [
                for (var index = 0; index < visit.checklist.length; index++)
                  CareChecklistItem(
                    label: visit.checklist[index].label,
                    complete: checks[index],
                  ),
              ]
            : null,
        resolutionNote: action == 'complete'
            ? 'Technician checklist completed; submitted for STROT review.'
            : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'start'
                  ? 'Visit started.'
                  : 'Visit submitted for review.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Maintenance record')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          widget.item.reference,
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          widget.item.title,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: StrotSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Text(widget.item.description),
          ),
        ),
        if (widget.item.scheduledAt != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Scheduled visit'),
              subtitle: Text(widget.item.scheduledAt!.toLocal().toString()),
            ),
          ),
        if (widget.canWork && widget.item.visits.isNotEmpty) ...[
          const SizedBox(height: StrotSpacing.lg),
          Text(
            'Technician checklist',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          for (
            var index = 0;
            index < widget.item.visits.first.checklist.length;
            index++
          )
            CheckboxListTile(
              value: checks[index],
              title: Text(widget.item.visits.first.checklist[index].label),
              onChanged: saving
                  ? null
                  : (value) => setState(() => checks[index] = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          const SizedBox(height: StrotSpacing.md),
          if (widget.item.visits.first.status == 'scheduled')
            FilledButton(
              onPressed: saving ? null : () => _update('start'),
              child: const Text('Start visit'),
            ),
          if (widget.item.visits.first.status != 'completed')
            OutlinedButton(
              onPressed: saving || checks.any((item) => !item)
                  ? null
                  : () => _update('complete'),
              child: const Text('Submit for review'),
            ),
          const SizedBox(height: StrotSpacing.sm),
          const Text(
            'Photos and supporting evidence are stored privately in STROT media and linked to this maintenance record.',
          ),
        ],
      ],
    ),
  );
}

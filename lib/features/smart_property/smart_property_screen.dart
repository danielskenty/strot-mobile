import 'package:flutter/material.dart';
import '../../core/smart_property/smart_property_models.dart';
import '../../core/smart_property/smart_property_service.dart';
import '../../design_system/strot_tokens.dart';

class SmartPropertiesScreen extends StatelessWidget {
  const SmartPropertiesScreen({super.key, required this.service});
  final SmartPropertyService service;
  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<List<SmartPropertySummary>>(
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
            'CONNECTED PROPERTY INTELLIGENCE',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Smart living dashboard',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const Text(
            'Monitor room systems, connected devices and property-health signals.',
          ),
          const SizedBox(height: StrotSpacing.xl),
          if (snapshot.data!.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(StrotSpacing.xl),
                child: Text(
                  'No connected property yet. Supported systems will appear after commissioning.',
                ),
              ),
            )
          else
            ...snapshot.data!.map(
              (property) => Card(
                child: InkWell(
                  key: Key('smart-property-${property.id}'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SmartPropertyDetailScreen(
                        service: service,
                        id: property.id,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(StrotSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.reference,
                          style: const TextStyle(
                            color: StrotColors.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: StrotSpacing.sm),
                        Text(
                          property.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(property.location),
                        const Divider(height: StrotSpacing.xl),
                        Wrap(
                          spacing: StrotSpacing.lg,
                          runSpacing: StrotSpacing.sm,
                          children: [
                            Text('${property.roomsCount} rooms'),
                            Text('${property.devicesCount} devices'),
                            Text('${property.onlineDevicesCount} online'),
                            Text(
                              '${property.attentionDevicesCount} attention',
                              style: const TextStyle(
                                color: StrotColors.gold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: StrotSpacing.md),
                        const Text(
                          'Open rooms & devices →',
                          style: TextStyle(
                            color: StrotColors.forest,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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

class SmartPropertyDetailScreen extends StatelessWidget {
  const SmartPropertyDetailScreen({
    super.key,
    required this.service,
    required this.id,
  });
  final SmartPropertyService service;
  final int id;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Smart property')),
    body: FutureBuilder<SmartProperty>(
      future: service.get(id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('◇ ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final property = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              property.reference,
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              property.name,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text(property.location),
            const SizedBox(height: StrotSpacing.xl),
            Wrap(
              spacing: StrotSpacing.md,
              runSpacing: StrotSpacing.md,
              children: [
                _Metric('Rooms', property.roomsCount),
                _Metric('Devices', property.devicesCount),
                _Metric('Online', property.onlineCount),
                _Metric('Attention', property.attentionCount),
              ],
            ),
            const SizedBox(height: StrotSpacing.xl),
            ...property.rooms.map((room) => _RoomSection(room: room)),
            if (property.unassignedDevices.isNotEmpty) ...[
              Text(
                'Property-wide systems',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: StrotSpacing.md),
              ...property.unassignedDevices.map(
                (device) => _DeviceCard(device: device),
              ),
            ],
          ],
        );
      },
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Container(
    width: 140,
    padding: const EdgeInsets.all(StrotSpacing.md),
    decoration: BoxDecoration(
      border: Border.all(color: StrotColors.forestMuted),
      borderRadius: BorderRadius.circular(StrotRadius.md),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Text('$value', style: Theme.of(context).textTheme.headlineMedium),
      ],
    ),
  );
}

class _RoomSection extends StatelessWidget {
  const _RoomSection({required this.room});
  final SmartRoom room;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: StrotSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          room.floor ?? 'Property zone',
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(room.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: StrotSpacing.md),
        if (room.devices.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(StrotSpacing.md),
              child: Text('No connected devices are assigned to this room.'),
            ),
          )
        else
          ...room.devices.map((device) => _DeviceCard(device: device)),
      ],
    ),
  );
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device});
  final SmartDevice device;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            device.category.toUpperCase(),
            style: const TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: StrotSpacing.xs),
          Text(device.name, style: Theme.of(context).textTheme.titleLarge),
          Text(device.provider ?? 'Connected building system'),
          const Divider(height: StrotSpacing.xl),
          Text('Connection: ${device.connectivityStatus}'),
          Text(
            'Health: ${device.healthStatus}',
            key: Key('device-health-${device.id}'),
          ),
          Text(
            'Battery: ${device.batteryPercent == null ? 'Mains powered' : '${device.batteryPercent}%'}',
          ),
          if (device.telemetry.isNotEmpty) ...[
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Current readings',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Wrap(
              spacing: StrotSpacing.sm,
              children: device.telemetry.entries
                  .map(
                    (entry) => Chip(
                      label: Text(
                        '${entry.key.replaceAll('_', ' ')}: ${entry.value}',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          ...device.healthEvents.map(
            (event) => Container(
              margin: const EdgeInsets.only(top: StrotSpacing.md),
              padding: const EdgeInsets.all(StrotSpacing.md),
              decoration: const BoxDecoration(
                color: StrotColors.goldMuted,
                border: Border(
                  left: BorderSide(color: StrotColors.gold, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.severity.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      color: StrotColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (event.detail != null) Text(event.detail!),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

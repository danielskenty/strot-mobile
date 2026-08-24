import 'package:flutter/material.dart';
import '../../core/profile/profile_service.dart';
import '../../design_system/strot_tokens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.service});
  final ProfileService service;
  @override
  State<ProfileScreen> createState() => _State();
}

class _State extends State<ProfileScreen> {
  late Future<ProfileRecord> record = widget.service.load();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: FutureBuilder<ProfileRecord>(
      future: record,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = snapshot.requireData,
            name = TextEditingController(text: p.name),
            email = TextEditingController(text: p.preferredEmail),
            phone = TextEditingController(text: p.preferredPhone);
        var contact = p.preferredContact;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'ACCOUNT IDENTITY',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Profile and contact details',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: StrotSpacing.xl),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: StrotSpacing.md),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: p.loginEmail),
              decoration: const InputDecoration(labelText: 'Login email'),
            ),
            const SizedBox(height: StrotSpacing.md),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Preferred contact email',
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Preferred phone'),
            ),
            const SizedBox(height: StrotSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: contact,
              decoration: const InputDecoration(
                labelText: 'Preferred contact method',
              ),
              items: const [
                DropdownMenuItem(value: 'email', child: Text('Email')),
                DropdownMenuItem(value: 'phone', child: Text('Phone')),
                DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
              ],
              onChanged: (value) => contact = value!,
            ),
            const SizedBox(height: StrotSpacing.lg),
            ElevatedButton(
              onPressed: () async {
                await widget.service.update(
                  ProfileRecord(
                    name: name.text.trim(),
                    loginEmail: p.loginEmail,
                    preferredEmail: email.text.trim().isEmpty
                        ? null
                        : email.text.trim(),
                    preferredPhone: phone.text.trim().isEmpty
                        ? null
                        : phone.text.trim(),
                    preferredContact: contact,
                    timezone: p.timezone,
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save profile'),
            ),
          ],
        );
      },
    ),
  );
}

import 'package:flutter/material.dart';

class NotificationsPrefsScreen extends StatefulWidget {
  const NotificationsPrefsScreen({super.key});

  @override
  State<NotificationsPrefsScreen> createState() => _NotificationsPrefsScreenState();
}

class _NotificationsPrefsScreenState extends State<NotificationsPrefsScreen> {
  bool _confirmations = true;
  bool _promos = true;
  bool _rappels = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Confirmations de réservation'),
            value: _confirmations,
            onChanged: (v) => setState(() => _confirmations = v),
          ),
          SwitchListTile(
            title: const Text('Promotions'),
            value: _promos,
            onChanged: (v) => setState(() => _promos = v),
          ),
          SwitchListTile(
            title: const Text('Rappels de départ'),
            value: _rappels,
            onChanged: (v) => setState(() => _rappels = v),
          ),
        ],
      ),
    );
  }
}
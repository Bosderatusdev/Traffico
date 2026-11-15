import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _service = NotificationService();
  bool _isLoading = true;
  String? _erreur;
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _isLoading = true;
      _erreur = null;
    });
    try {
      final notifications = await _service.fetchAll();
      // je veux garder dans messages les confirmations , les détails et les notifs générales aux users

      final filtrees = notifications.where((n) {
        final titre = n.titre.toLowerCase();
        return !titre.contains('billet') && !titre.contains('qr code');
      }).toList();

      filtrees.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted) return;
      setState(() => _notifications = filtrees);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ouvrir(NotificationItem notif) async {
    if (!notif.lu) {
      try {
        await _service.marqueLue(notif.id);
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notif.id);
          if (index != -1) {
            _notifications[index] = NotificationItem(
              id: notif.id,
              titre: notif.titre,
              message: notif.message,
              lu: true,
              createdAt: notif.createdAt,
            );
          }
        });
      } on ApiException {
        // il ne fait rieen.
      }
    }

    if (!mounted) return;

    

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notif.titre, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd/MM/yyyy à HH:mm').format(notif.createdAt),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(notif.message, style: theme.textTheme.bodyLarge),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: RefreshIndicator(
        onRefresh: _charger,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _erreur != null
            ? _EtatVide(
                icon: Icons.error_outline_rounded,
                title: 'Impossible de charger',
                subtitle: _erreur!,
                color: theme.colorScheme.error,
              )
            : _notifications.isEmpty
            ? _EtatVide(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Pas encore de notification',
                subtitle: 'Confirmations et alertes apparaîtront ici',
                color: semantic.textSecondary,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  return _NotificationTile(
                    notif: notif,
                    onTap: () => _ouvrir(notif),
                  );
                },
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notif;
  final VoidCallback onTap;
  const _NotificationTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    theme.extension<AppSemanticColors>()!;

    return Card(
      color: notif.lu ? null : colors.primary.withOpacity(0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: notif.lu ? Colors.transparent : colors.primary,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.titre,
                      style: notif.lu
                          ? theme.textTheme.titleMedium
                          : theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('dd/MM · HH:mm').format(notif.createdAt),
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EtatVide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _EtatVide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 64, color: color),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
